
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../crypto/encryption_service.dart';
import 'package:cryptography/cryptography.dart';

/// Voice call states
enum VoiceCallState {
  idle,
  calling,
  ringing,
  connected,
  ended,
  failed,
}

/// Manages secure voice calls with end-to-end encryption
class VoiceCallService {
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream;
  RTCDataChannel? _controlChannel;
  
  final EncryptionService _encryptionService;
  SecretKey? _callEncryptionKey;
  
  // Call state
  VoiceCallState _state = VoiceCallState.idle;
  bool _isMuted = false;
  bool _isSpeakerOn = false;
  
  // Callbacks
  Function(VoiceCallState state)? onStateChanged;
  Function(MediaStream stream)? onRemoteStream;
  Function(RTCIceCandidate candidate)? onIceCandidate;
  Function(String error)? onError;
  
  // Statistics
  int _callStartTime = 0;
  int _bytesReceived = 0;
  int _bytesSent = 0;
  
  VoiceCallService(this._encryptionService);
  
  VoiceCallState get state => _state;
  bool get isMuted => _isMuted;
  bool get isSpeakerOn => _isSpeakerOn;
  int get callDuration => _callStartTime > 0 
      ? DateTime.now().millisecondsSinceEpoch - _callStartTime 
      : 0;
  
  /// Initialize WebRTC peer connection with STUN/TURN servers
  Future<void> initialize() async {
    try {
      print('🔧 Initializing voice call service...');
      
      // Configure ICE servers with public STUN/TURN
      final Map<String, dynamic> configuration = {
        'iceServers': [
          // Google STUN servers
          {'urls': 'stun:stun.l.google.com:19302'},
          {'urls': 'stun:stun1.l.google.com:19302'},
          {'urls': 'stun:stun2.l.google.com:19302'},
          {'urls': 'stun:stun3.l.google.com:19302'},
          {'urls': 'stun:stun4.l.google.com:19302'},
          
          // Public TURN servers (Metered - free tier)
          {
            'urls': 'turn:openrelay.metered.ca:80',
            'username': 'openrelayproject',
            'credential': 'openrelayproject',
          },
          {
            'urls': 'turn:openrelay.metered.ca:443',
            'username': 'openrelayproject',
            'credential': 'openrelayproject',
          },
          {
            'urls': 'turn:openrelay.metered.ca:443?transport=tcp',
            'username': 'openrelayproject',
            'credential': 'openrelayproject',
          },
        ],
        'sdpSemantics': 'unified-plan',
        'iceCandidatePoolSize': 10,
      };
      
      // Create peer connection
      _peerConnection = await createPeerConnection(configuration);
      
      // Generate encryption key for this call
      _callEncryptionKey = await _encryptionService.generateSymmetricKey();
      
      // Set up event listeners
      _setupEventListeners();
      
      print('✅ Voice call service initialized');
    } catch (e) {
      print('❌ Failed to initialize voice call: $e');
      _updateState(VoiceCallState.failed);
      onError?.call('Failed to initialize: $e');
      rethrow;
    }
  }
  
  /// Set up WebRTC event listeners
  void _setupEventListeners() {
    _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
      print('🧊 ICE candidate generated');
      onIceCandidate?.call(candidate);
    };
    
    _peerConnection!.onConnectionState = (RTCPeerConnectionState state) {
      print('🔗 Connection state: $state');
      
      switch (state) {
        case RTCPeerConnectionState.RTCPeerConnectionStateConnected:
          _updateState(VoiceCallState.connected);
          _callStartTime = DateTime.now().millisecondsSinceEpoch;
          break;
        case RTCPeerConnectionState.RTCPeerConnectionStateDisconnected:
        case RTCPeerConnectionState.RTCPeerConnectionStateFailed:
          _updateState(VoiceCallState.failed);
          break;
        case RTCPeerConnectionState.RTCPeerConnectionStateClosed:
          _updateState(VoiceCallState.ended);
          break;
        default:
          break;
      }
    };
    
    _peerConnection!.onIceConnectionState = (RTCIceConnectionState state) {
      print('🧊 ICE connection state: $state');
    };
    
    _peerConnection!.onTrack = (RTCTrackEvent event) {
      print('🎵 Remote track received');
      
      if (event.streams.isNotEmpty) {
        _remoteStream = event.streams[0];
        onRemoteStream?.call(_remoteStream!);
      }
    };
    
    _peerConnection!.onDataChannel = (RTCDataChannel channel) {
      print('📡 Received control channel');
      _controlChannel = channel;
      _setupControlChannelListeners();
    };
  }
  
  /// Set up control channel for call commands (mute, etc.)
  void _setupControlChannelListeners() {
    _controlChannel!.onMessage = (RTCDataChannelMessage message) {
      try {
        final data = jsonDecode(message.text);
        _handleControlMessage(data);
      } catch (e) {
        print('❌ Failed to handle control message: $e');
      }
    };
  }
  
  /// Handle control messages
  void _handleControlMessage(Map<String, dynamic> data) {
    final command = data['command'];
    
    switch (command) {
      case 'mute':
        print('🔇 Remote peer muted');
        break;
      case 'unmute':
        print('🔊 Remote peer unmuted');
        break;
      case 'end':
        print('📵 Remote peer ended call');
        endCall();
        break;
    }
  }
  
  /// Start a voice call (caller side)
  Future<RTCSessionDescription> startCall() async {
    try {
      print('📞 Starting call...');
      _updateState(VoiceCallState.calling);
      
      // Get user media (audio only)
      _localStream = await navigator.mediaDevices.getUserMedia({
        'audio': {
          'echoCancellation': true,
          'noiseSuppression': true,
          'autoGainControl': true,
        },
        'video': false,
      });
      
      // Add tracks to peer connection
      _localStream!.getTracks().forEach((track) {
        _peerConnection!.addTrack(track, _localStream!);
      });
      
      // Create control channel
      await _createControlChannel();
      
      // Create offer
      RTCSessionDescription offer = await _peerConnection!.createOffer({
        'offerToReceiveAudio': true,
        'offerToReceiveVideo': false,
      });
      
      await _peerConnection!.setLocalDescription(offer);
      
      print('✅ Call offer created');
      return offer;
    } catch (e) {
      print('❌ Failed to start call: $e');
      _updateState(VoiceCallState.failed);
      onError?.call('Failed to start call: $e');
      rethrow;
    }
  }
  
  /// Answer an incoming call (receiver side)
  Future<RTCSessionDescription> answerCall(RTCSessionDescription offer) async {
    try {
      print('📞 Answering call...');
      _updateState(VoiceCallState.ringing);
      
      // Get user media (audio only)
      _localStream = await navigator.mediaDevices.getUserMedia({
        'audio': {
          'echoCancellation': true,
          'noiseSuppression': true,
          'autoGainControl': true,
        },
        'video': false,
      });
      
      // Add tracks to peer connection
      _localStream!.getTracks().forEach((track) {
        _peerConnection!.addTrack(track, _localStream!);
      });
      
      // Set remote description
      await _peerConnection!.setRemoteDescription(offer);
      
      // Create answer
      RTCSessionDescription answer = await _peerConnection!.createAnswer({
        'offerToReceiveAudio': true,
        'offerToReceiveVideo': false,
      });
      
      await _peerConnection!.setLocalDescription(answer);
      
      print('✅ Call answer created');
      return answer;
    } catch (e) {
      print('❌ Failed to answer call: $e');
      _updateState(VoiceCallState.failed);
      onError?.call('Failed to answer call: $e');
      rethrow;
    }
  }
  
  /// Create control channel
  Future<void> _createControlChannel() async {
    try {
      RTCDataChannelInit config = RTCDataChannelInit();
      config.ordered = true;
      
      _controlChannel = await _peerConnection!.createDataChannel(
        'voice_control',
        config,
      );
      
      _setupControlChannelListeners();
      
      print('📡 Control channel created');
    } catch (e) {
      print('⚠️ Failed to create control channel: $e');
    }
  }
  
  /// Set remote session description
  Future<void> setRemoteDescription(RTCSessionDescription description) async {
    try {
      await _peerConnection!.setRemoteDescription(description);
      print('✅ Remote description set');
    } catch (e) {
      print('❌ Failed to set remote description: $e');
      onError?.call('Failed to set remote description: $e');
      rethrow;
    }
  }
  
  /// Add ICE candidate
  Future<void> addIceCandidate(RTCIceCandidate candidate) async {
    try {
      await _peerConnection!.addCandidate(candidate);
      print('✅ ICE candidate added');
    } catch (e) {
      print('❌ Failed to add ICE candidate: $e');
    }
  }
  
  /// Toggle mute
  Future<void> toggleMute() async {
    if (_localStream == null) return;
    
    _isMuted = !_isMuted;
    
    _localStream!.getAudioTracks().forEach((track) {
      track.enabled = !_isMuted;
    });
    
    // Send control message to peer
    _sendControlMessage({'command': _isMuted ? 'mute' : 'unmute'});
    
    print(_isMuted ? '🔇 Muted' : '🔊 Unmuted');
  }
  
  /// Toggle speaker
  Future<void> toggleSpeaker() async {
    _isSpeakerOn = !_isSpeakerOn;
    
    // This is platform-specific (not available on web)
    if (!kIsWeb) {
      try {
        await Helper.setSpeakerphoneOn(_isSpeakerOn);
        print(_isSpeakerOn ? '🔊 Speaker ON' : '🔇 Speaker OFF');
      } catch (e) {
        print('⚠️ Failed to toggle speaker: $e');
      }
    } else {
      // On web, speaker toggle is handled by browser
      print(_isSpeakerOn ? '🔊 Speaker mode (web)' : '🔇 Earpiece mode (web)');
    }
  }
  
  /// Send control message via data channel
  void _sendControlMessage(Map<String, dynamic> message) {
    try {
      if (_controlChannel != null &&
          _controlChannel!.state == RTCDataChannelState.RTCDataChannelOpen) {
        final jsonData = jsonEncode(message);
        _controlChannel!.send(RTCDataChannelMessage(jsonData));
      }
    } catch (e) {
      print('⚠️ Failed to send control message: $e');
    }
  }
  
  /// End the call
  Future<void> endCall() async {
    try {
      print('📵 Ending call...');
      
      // Send end message to peer
      _sendControlMessage({'command': 'end'});
      
      // Stop local tracks
      _localStream?.getTracks().forEach((track) {
        track.stop();
      });
      
      // Close channels and connection
      await _controlChannel?.close();
      await _peerConnection?.close();
      
      // Clean up
      _localStream = null;
      _remoteStream = null;
      _controlChannel = null;
      _peerConnection = null;
      _callEncryptionKey = null;
      _callStartTime = 0;
      
      _updateState(VoiceCallState.ended);
      
      print('✅ Call ended');
    } catch (e) {
      print('⚠️ Error ending call: $e');
    }
  }
  
  /// Update call state
  void _updateState(VoiceCallState newState) {
    _state = newState;
    onStateChanged?.call(newState);
  }
  
  /// Get call statistics
  Future<Map<String, dynamic>> getCallStatistics() async {
    try {
      if (_peerConnection == null) return {};
      
      final stats = await _peerConnection!.getStats();
      
      // Parse statistics
      return {
        'duration': callDuration,
        'state': _state.toString(),
        'bytesReceived': _bytesReceived,
        'bytesSent': _bytesSent,
      };
    } catch (e) {
      print('⚠️ Failed to get statistics: $e');
      return {};
    }
  }
  
  /// Dispose and cleanup
  Future<void> dispose() async {
    await endCall();
  }
}

