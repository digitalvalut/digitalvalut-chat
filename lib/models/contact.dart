
class Contact {
  final String id;
  final String name;
  final String publicKey;
  final String? avatarUrl;
  final String? status;
  final int? lastSeen;
  final int createdAt;
  final bool isBlocked;
  
  Contact({
    required this.id,
    required this.name,
    required this.publicKey,
    this.avatarUrl,
    this.status,
    this.lastSeen,
    required this.createdAt,
    this.isBlocked = false,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'public_key': publicKey,
      'avatar_url': avatarUrl,
      'status': status,
      'last_seen': lastSeen,
      'created_at': createdAt,
      'is_blocked': isBlocked ? 1 : 0,
    };
  }
  
  factory Contact.fromMap(Map<String, dynamic> map) {
    return Contact(
      id: map['id'],
      name: map['name'],
      publicKey: map['public_key'],
      avatarUrl: map['avatar_url'],
      status: map['status'],
      lastSeen: map['last_seen'],
      createdAt: map['created_at'],
      isBlocked: map['is_blocked'] == 1,
    );
  }
  
  Contact copyWith({
    String? name,
    String? avatarUrl,
    String? status,
    int? lastSeen,
    bool? isBlocked,
  }) {
    return Contact(
      id: id,
      name: name ?? this.name,
      publicKey: publicKey,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      status: status ?? this.status,
      lastSeen: lastSeen ?? this.lastSeen,
      createdAt: createdAt,
      isBlocked: isBlocked ?? this.isBlocked,
    );
  }
}
