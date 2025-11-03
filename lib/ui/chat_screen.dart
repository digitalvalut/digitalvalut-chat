
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../database/database_service.dart';
import '../models/message.dart';
import '../services/voice_call_service.dart';
import '../crypto/encryption_service.dart';
import 'voice_call_screen.dart';

/// Chat screen with ephemeral message support
class ChatScreen extends StatefulWidget {
  final String conversationId;
  final String contactId;
  final String contactName;
  
  const ChatScreen({
    super.key,
    required this.conversationId,
    required this.contactId,
    required this.contactName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final _uuid = const Uuid();
  
  List<Message> _messages = [];
  bool _isLoading = true;
  Timer? _messageCleanupTimer;
  int _ephemeralTimer = 0; // seconds, 0 = disabled

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _startMessageCleanupTimer();
  }

  Future<void> _loadMessages() async {
    setState(() => _isLoading = true);
    
    try {
      final dbService = Provider.of<DatabaseService>(context, listen: false);
      
      // Load conversation to get ephemeral timer
      final conversation = await dbService.getConversation(widget.conversationId);
      if (conversation != null) {
        _ephemeralTimer = conversation.ephemeralTimer;
      }
      
      // Load messages
      final messages = await dbService.getMessagesForConversation(widget.conversationId);
      
      setState(() {
        _messages = messages.where((m) => !m.isExpired).toList();
        _isLoading = false;
      });
      
      // Mark messages as read
      await dbService.markMessagesAsRead(widget.conversationId);
      
      _scrollToBottom();
    } catch (e) {
      print('Error loading messages: $e');
      setState(() => _isLoading = false);
    }
  }

  void _startMessageCleanupTimer() {
    _messageCleanupTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _cleanupExpiredMessages(),
    );
  }

  Future<void> _cleanupExpiredMessages() async {
    final now = DateTime.now().millisecondsSinceEpoch;
    
    setState(() {
      _messages.removeWhere((msg) => msg.isExpired);
    });
    
    // Delete from database
    final dbService = Provider.of<DatabaseService>(context, listen: false);
    await dbService.deleteExpiredMessages();
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    
    if (text.isEmpty) return;
    
    try {
      final dbService = Provider.of<DatabaseService>(context, listen: false);
      
      // Create message
      final now = DateTime.now().millisecondsSinceEpoch;
      int? expiresAt;
      
      if (_ephemeralTimer > 0) {
        expiresAt = now + (_ephemeralTimer * 1000);
      }
      
      final message = Message(
        id: _uuid.v4(),
        conversationId: widget.conversationId,
        senderId: 'me', // TODO: Get from user service
        receiverId: widget.contactId,
        content: text,
        encryptedContent: text, // TODO: Encrypt with encryption service
        messageType: MessageType.text,
        status: MessageStatus.sent,
        timestamp: now,
        expiresAt: expiresAt,
      );
      
      // Save to database
      await dbService.insertMessage(message);
      
      // Update conversation
      final conversation = await dbService.getConversation(widget.conversationId);
      if (conversation != null) {
        await dbService.updateConversation(
          conversation.copyWith(
            lastMessage: text,
            lastMessageTime: now,
          ),
        );
      }
      
      // Clear input
      _messageController.clear();
      
      // Reload messages
      await _loadMessages();
      
      // TODO: Send via P2P
      
    } catch (e) {
      _showErrorSnackbar('Failed to send message: $e');
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _initiateVoiceCall() async {
    try {
      // Create voice call service
      final encryptionService = EncryptionService();
      final callService = VoiceCallService(encryptionService);
      
      // Initialize the call service
      await callService.initialize();
      
      // Navigate to voice call screen
      if (!mounted) return;
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VoiceCallScreen(
            callService: callService,
            contactName: widget.contactName,
          ),
        ),
      );
      
      // Start the call
      await callService.startCall();
      
    } catch (e) {
      print('❌ Failed to initiate call: $e');
      _showErrorSnackbar('Failed to start call: $e');
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _messageCleanupTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.contactName),
            Row(
              children: [
                const Icon(Icons.lock, size: 12),
                const SizedBox(width: 4),
                const Text(
                  'End-to-end encrypted',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.normal),
                ),
                if (_ephemeralTimer > 0) ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.timer, size: 12),
                  const SizedBox(width: 4),
                  Text(
                    '${_ephemeralTimer}s',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.normal),
                  ),
                ],
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.call),
            tooltip: 'Voice Call',
            onPressed: _initiateVoiceCall,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'ephemeral') {
                _showEphemeralTimerDialog();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'ephemeral',
                child: Text('⏱️ Ephemeral Messages'),
              ),
              const PopupMenuItem(
                value: 'media',
                child: Text('Media & Files'),
              ),
            ],
          ),
        ],
      ),
      
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message = _messages[index];
                          return _buildMessageBubble(message);
                        },
                      ),
          ),
          
          // Message input
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No messages yet',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          if (_ephemeralTimer > 0)
            Text(
              '⏱️ Messages will disappear after $_ephemeralTimer seconds',
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Message message) {
    final isMe = message.senderId == 'me';
    
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        decoration: BoxDecoration(
          color: isMe
              ? Theme.of(context).primaryColor
              : Colors.grey[300],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.content,
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatMessageTime(message.timestamp),
                  style: TextStyle(
                    fontSize: 10,
                    color: isMe ? Colors.white70 : Colors.black54,
                  ),
                ),
                if (message.expiresAt != null) ...[
                  const SizedBox(width: 4),
                  Icon(
                    Icons.timer,
                    size: 10,
                    color: isMe ? Colors.white70 : Colors.black54,
                  ),
                ],
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    _getStatusIcon(message.status),
                    size: 12,
                    color: Colors.white70,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.attach_file),
            onPressed: () {
              // TODO: Implement file attachment
            },
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }

  void _showEphemeralTimerDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⏱️ Ephemeral Messages'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Set message expiration time:'),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Off'),
              leading: Radio<int>(
                value: 0,
                groupValue: _ephemeralTimer,
                onChanged: (value) {
                  setState(() => _ephemeralTimer = value!);
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              title: const Text('10 seconds'),
              leading: Radio<int>(
                value: 10,
                groupValue: _ephemeralTimer,
                onChanged: (value) {
                  setState(() => _ephemeralTimer = value!);
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              title: const Text('1 minute'),
              leading: Radio<int>(
                value: 60,
                groupValue: _ephemeralTimer,
                onChanged: (value) {
                  setState(() => _ephemeralTimer = value!);
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              title: const Text('1 hour'),
              leading: Radio<int>(
                value: 3600,
                groupValue: _ephemeralTimer,
                onChanged: (value) {
                  setState(() => _ephemeralTimer = value!);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatMessageTime(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  IconData _getStatusIcon(MessageStatus status) {
    switch (status) {
      case MessageStatus.sending:
        return Icons.access_time;
      case MessageStatus.sent:
        return Icons.done;
      case MessageStatus.delivered:
        return Icons.done_all;
      case MessageStatus.read:
        return Icons.done_all;
      case MessageStatus.failed:
        return Icons.error;
    }
  }
}
