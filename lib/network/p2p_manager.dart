
import 'dart:convert';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../crypto/encryption_service.dart';

/// Manages WebRTC peer-to-peer connections
class P2PManager {
  RTCPeerConnection? _peerConnection;
  RTCDataChannel? _dataChannel;
  final EncryptionService _encryptionService;
  
  // Callbacks
  Function(String message)? onMessageReceived;
  Function(RTCIceCandidate candidate)? onIceCandidate;
  Function(RTCPeerConnectionState state)? onConnectionStateChanged;
  
  P2PManager(this._encryptionService);
  
  /// Initialize WebRTC peer connection
  Future<void> initialize() async {
    try {
      // ICE servers configuration (STUN for NAT traversal)
      final Map<String, dynamic> configuration = {
        'iceServers': [
          {'urls': 'stun:stun.l.google.com:19302'},
          {'urls': 'stun:stun1.l.google.com:19302'},
          {'urls': 'stun:stun2.l.google.com:19302'},
        ],
        'sdpSemantics': 'unified-plan',
      };
      
      // Create peer connection
      _peerConnection = await createPeerConnection(configuration);
      
      // Set up event listeners
      _setupEventListeners();
      
      print('✅ WebRTC peer connection initialized');
    } catch (e) {
      throw Exception('Failed to initialize P2P connection: $e');
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
      onConnectionStateChanged?.call(state);
    };
    
    _peerConnection!.onDataChannel = (RTCDataChannel channel) {
      print('📡 Received data channel');
      _dataChannel = channel;
      _setupDataChannelListeners();
    };
  }
  
  /// Create data channel for messaging
  Future<void> createDataChannel() async {
    try {
      RTCDataChannelInit config = RTCDataChannelInit();
      config.ordered = true;
      config.maxRetransmits = 30;
      
      _dataChannel = await _peerConnection!.createDataChannel(
        'digitalvalut_messages',
        config,
      );
      
      _setupDataChannelListeners();
      
      print('📡 Data channel created');
    } catch (e) {
      throw Exception('Failed to create data channel: $e');
    }
  }
  
  /// Set up data channel event listeners
  void _setupDataChannelListeners() {
    _dataChannel!.onDataChannelState = (RTCDataChannelState state) {
      print('📊 Data channel state: $state');
    };
    
    _dataChannel!.onMessage = (RTCDataChannelMessage message) {
      print('📩 Received encrypted message');
      _handleIncomingMessage(message);
    };
  }
  
  /// Handle incoming encrypted message
  void _handleIncomingMessage(RTCDataChannelMessage message) async {
    try {
      final Map<String, dynamic> data = jsonDecode(message.text);
      onMessageReceived?.call(data['content']);
    } catch (e) {
      print('❌ Failed to handle incoming message: $e');
    }
  }
  
  /// Send message via data channel
  Future<void> sendMessage(String plaintext) async {
    try {
      if (_dataChannel == null ||
          _dataChannel!.state != RTCDataChannelState.RTCDataChannelOpen) {
        throw Exception('Data channel not ready');
      }
      
      final jsonData = jsonEncode({'content': plaintext});
      _dataChannel!.send(RTCDataChannelMessage(jsonData));
      
      print('✅ Message sent');
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }
  
  /// Create SDP offer
  Future<RTCSessionDescription> createOffer() async {
    try {
      RTCSessionDescription offer = await _peerConnection!.createOffer();
      await _peerConnection!.setLocalDescription(offer);
      return offer;
    } catch (e) {
      throw Exception('Failed to create offer: $e');
    }
  }
  
  /// Create SDP answer
  Future<RTCSessionDescription> createAnswer() async {
    try {
      RTCSessionDescription answer = await _peerConnection!.createAnswer();
      await _peerConnection!.setLocalDescription(answer);
      return answer;
    } catch (e) {
      throw Exception('Failed to create answer: $e');
    }
  }
  
  /// Set remote SDP description
  Future<void> setRemoteDescription(RTCSessionDescription description) async {
    try {
      await _peerConnection!.setRemoteDescription(description);
      print('✅ Remote description set');
    } catch (e) {
      throw Exception('Failed to set remote description: $e');
    }
  }
  
  /// Add ICE candidate
  Future<void> addIceCandidate(RTCIceCandidate candidate) async {
    try {
      await _peerConnection!.addCandidate(candidate);
      print('✅ ICE candidate added');
    } catch (e) {
      throw Exception('Failed to add ICE candidate: $e');
    }
  }
  
  /// Close connection and cleanup
  Future<void> close() async {
    try {
      await _dataChannel?.close();
      await _peerConnection?.close();
      _dataChannel = null;
      _peerConnection = null;
      print('✅ P2P connection closed');
    } catch (e) {
      print('⚠️ Error closing connection: $e');
    }
  }
}
