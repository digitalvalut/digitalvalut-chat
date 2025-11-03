
import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import '../models/message.dart';
import '../models/contact.dart';
import '../models/conversation.dart';

/// Database service for local data storage
class DatabaseService {
  static Database? _database;
  
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initialize();
    return _database!;
  }
  
  /// Initialize the database
  Future<Database> initialize() async {
    final Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final String path = join(documentsDirectory.path, 'digitalvalut.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }
  
  /// Create database tables
  Future<void> _onCreate(Database db, int version) async {
    // Contacts table
    await db.execute('''
      CREATE TABLE contacts (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        public_key TEXT NOT NULL,
        avatar_url TEXT,
        status TEXT,
        last_seen INTEGER,
        created_at INTEGER NOT NULL,
        is_blocked INTEGER DEFAULT 0
      )
    ''');
    
    // Conversations table
    await db.execute('''
      CREATE TABLE conversations (
        id TEXT PRIMARY KEY,
        contact_id TEXT NOT NULL,
        last_message TEXT,
        last_message_time INTEGER,
        unread_count INTEGER DEFAULT 0,
        is_archived INTEGER DEFAULT 0,
        is_muted INTEGER DEFAULT 0,
        ephemeral_timer INTEGER DEFAULT 0,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (contact_id) REFERENCES contacts (id) ON DELETE CASCADE
      )
    ''');
    
    // Messages table
    await db.execute('''
      CREATE TABLE messages (
        id TEXT PRIMARY KEY,
        conversation_id TEXT NOT NULL,
        sender_id TEXT NOT NULL,
        receiver_id TEXT NOT NULL,
        content TEXT NOT NULL,
        encrypted_content TEXT NOT NULL,
        message_type TEXT NOT NULL,
        status TEXT NOT NULL,
        timestamp INTEGER NOT NULL,
        expires_at INTEGER,
        is_read INTEGER DEFAULT 0,
        is_deleted INTEGER DEFAULT 0,
        reply_to_id TEXT,
        FOREIGN KEY (conversation_id) REFERENCES conversations (id) ON DELETE CASCADE
      )
    ''');
    
    // Create indexes for better performance
    await db.execute('CREATE INDEX idx_messages_conversation ON messages(conversation_id)');
    await db.execute('CREATE INDEX idx_messages_timestamp ON messages(timestamp)');
    await db.execute('CREATE INDEX idx_conversations_contact ON conversations(contact_id)');
  }
  
  /// Handle database upgrades
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database migrations here
  }
  
  // CONTACTS
  
  Future<int> insertContact(Contact contact) async {
    final db = await database;
    return await db.insert('contacts', contact.toMap());
  }
  
  Future<List<Contact>> getAllContacts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('contacts');
    return List.generate(maps.length, (i) => Contact.fromMap(maps[i]));
  }
  
  Future<Contact?> getContact(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'contacts',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isEmpty) return null;
    return Contact.fromMap(maps.first);
  }
  
  Future<int> updateContact(Contact contact) async {
    final db = await database;
    return await db.update(
      'contacts',
      contact.toMap(),
      where: 'id = ?',
      whereArgs: [contact.id],
    );
  }
  
  Future<int> deleteContact(String id) async {
    final db = await database;
    return await db.delete(
      'contacts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  // CONVERSATIONS
  
  Future<int> insertConversation(Conversation conversation) async {
    final db = await database;
    return await db.insert('conversations', conversation.toMap());
  }
  
  Future<List<Conversation>> getAllConversations() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'conversations',
      orderBy: 'last_message_time DESC',
    );
    return List.generate(maps.length, (i) => Conversation.fromMap(maps[i]));
  }
  
  Future<Conversation?> getConversation(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'conversations',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isEmpty) return null;
    return Conversation.fromMap(maps.first);
  }
  
  Future<Conversation?> getConversationByContactId(String contactId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'conversations',
      where: 'contact_id = ?',
      whereArgs: [contactId],
    );
    
    if (maps.isEmpty) return null;
    return Conversation.fromMap(maps.first);
  }
  
  Future<int> updateConversation(Conversation conversation) async {
    final db = await database;
    return await db.update(
      'conversations',
      conversation.toMap(),
      where: 'id = ?',
      whereArgs: [conversation.id],
    );
  }
  
  Future<int> deleteConversation(String id) async {
    final db = await database;
    return await db.delete(
      'conversations',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  // MESSAGES
  
  Future<int> insertMessage(Message message) async {
    final db = await database;
    return await db.insert('messages', message.toMap());
  }
  
  Future<List<Message>> getMessagesForConversation(String conversationId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'messages',
      where: 'conversation_id = ? AND is_deleted = 0',
      whereArgs: [conversationId],
      orderBy: 'timestamp ASC',
    );
    return List.generate(maps.length, (i) => Message.fromMap(maps[i]));
  }
  
  Future<Message?> getMessage(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'messages',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isEmpty) return null;
    return Message.fromMap(maps.first);
  }
  
  Future<int> updateMessage(Message message) async {
    final db = await database;
    return await db.update(
      'messages',
      message.toMap(),
      where: 'id = ?',
      whereArgs: [message.id],
    );
  }
  
  Future<int> deleteMessage(String id) async {
    final db = await database;
    return await db.update(
      'messages',
      {'is_deleted': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  /// Delete expired ephemeral messages
  Future<int> deleteExpiredMessages() async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;
    
    return await db.delete(
      'messages',
      where: 'expires_at IS NOT NULL AND expires_at < ?',
      whereArgs: [now],
    );
  }
  
  /// Mark messages as read
  Future<int> markMessagesAsRead(String conversationId) async {
    final db = await database;
    return await db.update(
      'messages',
      {'is_read': 1},
      where: 'conversation_id = ? AND is_read = 0',
      whereArgs: [conversationId],
    );
  }
  
  /// Get unread message count
  Future<int> getUnreadCount(String conversationId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM messages WHERE conversation_id = ? AND is_read = 0',
      [conversationId],
    );
    
    return Sqflite.firstIntValue(result) ?? 0;
  }
  
  /// Clear all data
  Future<void> clearDatabase() async {
    final db = await database;
    await db.delete('messages');
    await db.delete('conversations');
    await db.delete('contacts');
  }
}
