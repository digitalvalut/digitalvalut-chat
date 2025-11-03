
import 'dart:async';
import 'package:flutter/material.dart';
import '../services/voice_call_service.dart';

/// Voice call screen with controls
class VoiceCallScreen extends StatefulWidget {
  final VoiceCallService callService;
  final String contactName;
  final bool isIncoming;
  
  const VoiceCallScreen({
    super.key,
    required this.callService,
    required this.contactName,
    this.isIncoming = false,
  });

  @override
  State<VoiceCallScreen> createState() => _VoiceCallScreenState();
}

class _VoiceCallScreenState extends State<VoiceCallScreen>
    with TickerProviderStateMixin {
  VoiceCallState _callState = VoiceCallState.idle;
  bool _isMuted = false;
  bool _isSpeakerOn = false;
  int _callDuration = 0;
  Timer? _durationTimer;
  
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    // Set up animations
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    // Listen to call state changes
    widget.callService.onStateChanged = (state) {
      setState(() {
        _callState = state;
      });
      
      if (state == VoiceCallState.connected) {
        _startDurationTimer();
      } else if (state == VoiceCallState.ended || state == VoiceCallState.failed) {
        _stopDurationTimer();
        _navigateBack();
      }
    };
    
    // Set initial state
    _callState = widget.callService.state;
  }

  void _startDurationTimer() {
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _callDuration = widget.callService.callDuration ~/ 1000;
      });
    });
  }

  void _stopDurationTimer() {
    _durationTimer?.cancel();
    _durationTimer = null;
  }

  void _navigateBack() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  Future<void> _toggleMute() async {
    await widget.callService.toggleMute();
    setState(() {
      _isMuted = widget.callService.isMuted;
    });
  }

  Future<void> _toggleSpeaker() async {
    await widget.callService.toggleSpeaker();
    setState(() {
      _isSpeakerOn = widget.callService.isSpeakerOn;
    });
  }

  Future<void> _endCall() async {
    await widget.callService.endCall();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _stopDurationTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.lock, size: 16, color: Colors.white70),
                      const SizedBox(width: 4),
                      const Text(
                        'Encrypted',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Main content
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Avatar with pulse animation
                  if (_callState == VoiceCallState.calling || 
                      _callState == VoiceCallState.ringing)
                    ScaleTransition(
                      scale: _pulseAnimation,
                      child: _buildAvatar(),
                    )
                  else
                    _buildAvatar(),
                  
                  const SizedBox(height: 24),
                  
                  // Contact name
                  Text(
                    widget.contactName,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Call status
                  Text(
                    _getStatusText(),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  
                  if (_callState == VoiceCallState.connected) ...[
                    const SizedBox(height: 8),
                    Text(
                      _formatDuration(_callDuration),
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            // Controls
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: _buildControls(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.2),
        border: Border.all(
          color: Colors.white,
          width: 3,
        ),
      ),
      child: Center(
        child: Text(
          widget.contactName[0].toUpperCase(),
          style: const TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildControls() {
    if (_callState == VoiceCallState.calling || 
        _callState == VoiceCallState.ringing) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildEndCallButton(),
        ],
      );
    }
    
    if (_callState == VoiceCallState.connected) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildControlButton(
            icon: _isMuted ? Icons.mic_off : Icons.mic,
            label: _isMuted ? 'Unmute' : 'Mute',
            onPressed: _toggleMute,
            backgroundColor: _isMuted ? Colors.red : Colors.white.withOpacity(0.2),
          ),
          _buildEndCallButton(),
          _buildControlButton(
            icon: _isSpeakerOn ? Icons.volume_up : Icons.volume_down,
            label: 'Speaker',
            onPressed: _toggleSpeaker,
            backgroundColor: _isSpeakerOn 
                ? Colors.blue 
                : Colors.white.withOpacity(0.2),
          ),
        ],
      );
    }
    
    return const SizedBox.shrink();
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    Color? backgroundColor,
  }) {
    return Column(
      children: [
        Material(
          color: backgroundColor ?? Colors.white.withOpacity(0.2),
          shape: const CircleBorder(),
          child: InkWell(
            onTap: onPressed,
            customBorder: const CircleBorder(),
            child: Container(
              width: 60,
              height: 60,
              alignment: Alignment.center,
              child: Icon(
                icon,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildEndCallButton() {
    return Column(
      children: [
        Material(
          color: Colors.red,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: _endCall,
            customBorder: const CircleBorder(),
            child: Container(
              width: 70,
              height: 70,
              alignment: Alignment.center,
              child: const Icon(
                Icons.call_end,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'End',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  String _getStatusText() {
    switch (_callState) {
      case VoiceCallState.calling:
        return 'Calling...';
      case VoiceCallState.ringing:
        return widget.isIncoming ? 'Incoming call...' : 'Ringing...';
      case VoiceCallState.connected:
        return 'Connected';
      case VoiceCallState.ended:
        return 'Call ended';
      case VoiceCallState.failed:
        return 'Call failed';
      default:
        return '';
    }
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}

