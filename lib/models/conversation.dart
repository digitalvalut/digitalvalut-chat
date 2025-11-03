
class Conversation {
  final String id;
  final String contactId;
  final String? lastMessage;
  final int? lastMessageTime;
  final int unreadCount;
  final bool isArchived;
  final bool isMuted;
  final int ephemeralTimer; // in seconds, 0 means disabled
  final int createdAt;
  
  Conversation({
    required this.id,
    required this.contactId,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount = 0,
    this.isArchived = false,
    this.isMuted = false,
    this.ephemeralTimer = 0,
    required this.createdAt,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'contact_id': contactId,
      'last_message': lastMessage,
      'last_message_time': lastMessageTime,
      'unread_count': unreadCount,
      'is_archived': isArchived ? 1 : 0,
      'is_muted': isMuted ? 1 : 0,
      'ephemeral_timer': ephemeralTimer,
      'created_at': createdAt,
    };
  }
  
  factory Conversation.fromMap(Map<String, dynamic> map) {
    return Conversation(
      id: map['id'],
      contactId: map['contact_id'],
      lastMessage: map['last_message'],
      lastMessageTime: map['last_message_time'],
      unreadCount: map['unread_count'] ?? 0,
      isArchived: map['is_archived'] == 1,
      isMuted: map['is_muted'] == 1,
      ephemeralTimer: map['ephemeral_timer'] ?? 0,
      createdAt: map['created_at'],
    );
  }
  
  Conversation copyWith({
    String? lastMessage,
    int? lastMessageTime,
    int? unreadCount,
    bool? isArchived,
    bool? isMuted,
    int? ephemeralTimer,
  }) {
    return Conversation(
      id: id,
      contactId: contactId,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
      isArchived: isArchived ?? this.isArchived,
      isMuted: isMuted ?? this.isMuted,
      ephemeralTimer: ephemeralTimer ?? this.ephemeralTimer,
      createdAt: createdAt,
    );
  }
}
