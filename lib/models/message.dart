
enum MessageType {
  text,
  image,
  video,
  audio,
  file,
  location,
}

enum MessageStatus {
  sending,
  sent,
  delivered,
  read,
  failed,
}

class Message {
  final String id;
  final String conversationId;
  final String senderId;
  final String receiverId;
  final String content;
  final String encryptedContent;
  final MessageType messageType;
  final MessageStatus status;
  final int timestamp;
  final int? expiresAt;
  final bool isRead;
  final bool isDeleted;
  final String? replyToId;
  
  Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.encryptedContent,
    this.messageType = MessageType.text,
    this.status = MessageStatus.sending,
    required this.timestamp,
    this.expiresAt,
    this.isRead = false,
    this.isDeleted = false,
    this.replyToId,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'content': content,
      'encrypted_content': encryptedContent,
      'message_type': messageType.toString().split('.').last,
      'status': status.toString().split('.').last,
      'timestamp': timestamp,
      'expires_at': expiresAt,
      'is_read': isRead ? 1 : 0,
      'is_deleted': isDeleted ? 1 : 0,
      'reply_to_id': replyToId,
    };
  }
  
  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'],
      conversationId: map['conversation_id'],
      senderId: map['sender_id'],
      receiverId: map['receiver_id'],
      content: map['content'],
      encryptedContent: map['encrypted_content'],
      messageType: MessageType.values.firstWhere(
        (e) => e.toString().split('.').last == map['message_type'],
        orElse: () => MessageType.text,
      ),
      status: MessageStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
        orElse: () => MessageStatus.sent,
      ),
      timestamp: map['timestamp'],
      expiresAt: map['expires_at'],
      isRead: map['is_read'] == 1,
      isDeleted: map['is_deleted'] == 1,
      replyToId: map['reply_to_id'],
    );
  }
  
  Message copyWith({
    MessageStatus? status,
    bool? isRead,
    bool? isDeleted,
    int? expiresAt,
  }) {
    return Message(
      id: id,
      conversationId: conversationId,
      senderId: senderId,
      receiverId: receiverId,
      content: content,
      encryptedContent: encryptedContent,
      messageType: messageType,
      status: status ?? this.status,
      timestamp: timestamp,
      expiresAt: expiresAt ?? this.expiresAt,
      isRead: isRead ?? this.isRead,
      isDeleted: isDeleted ?? this.isDeleted,
      replyToId: replyToId,
    );
  }
  
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().millisecondsSinceEpoch > expiresAt!;
  }
}
