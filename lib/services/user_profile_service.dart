import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';
import '../crypto/encryption_service.dart';

/// Servizio per gestire il profilo dell'utente e le chiavi crittografiche
class UserProfileService {
  static const String _userIdKey = 'user_id';
  static const String _userPublicKeyKey = 'user_public_key';
  static const String _userNameKey = 'user_name';
  static const String _isInitializedKey = 'is_initialized';
  
  final _secureStorage = const FlutterSecureStorage();
  final _encryptionService = EncryptionService();
  final _uuid = const Uuid();
  
  /// Verifica se il profilo utente è stato inizializzato
  Future<bool> isInitialized() async {
    final initialized = await _secureStorage.read(key: _isInitializedKey);
    return initialized == 'true';
  }
  
  /// Inizializza il profilo utente al primo avvio
  Future<void> initializeProfile() async {
    if (await isInitialized()) {
      return; // Già inizializzato
    }
    
    try {
      // Genera un nuovo ID utente
      final userId = _uuid.v4();
      
      // Genera una nuova coppia di chiavi
      final keyPair = await _encryptionService.generateKeyPair();
      await _encryptionService.storeKeyPair(userId, keyPair);
      
      // Ottieni la chiave pubblica in formato base64
      final publicKey = await keyPair.extractPublicKey();
      final publicKeyBase64 = base64Encode(publicKey.bytes);
      
      // Salva ID utente e chiave pubblica
      await _secureStorage.write(key: _userIdKey, value: userId);
      await _secureStorage.write(key: _userPublicKeyKey, value: publicKeyBase64);
      
      // Imposta il nome predefinito
      await _secureStorage.write(key: _userNameKey, value: 'Me');
      
      // Marca come inizializzato
      await _secureStorage.write(key: _isInitializedKey, value: 'true');
      
      print('✅ Profilo utente inizializzato con successo');
    } catch (e) {
      print('❌ Errore nell\'inizializzazione del profilo: $e');
      throw Exception('Impossibile inizializzare il profilo utente');
    }
  }
  
  /// Ottieni l'ID dell'utente
  Future<String?> getUserId() async {
    return await _secureStorage.read(key: _userIdKey);
  }
  
  /// Ottieni la chiave pubblica dell'utente (in formato base64)
  Future<String?> getPublicKey() async {
    return await _secureStorage.read(key: _userPublicKeyKey);
  }
  
  /// Ottieni il nome dell'utente
  Future<String?> getUserName() async {
    return await _secureStorage.read(key: _userNameKey);
  }
  
  /// Imposta il nome dell'utente
  Future<void> setUserName(String name) async {
    await _secureStorage.write(key: _userNameKey, value: name);
  }
  
  /// Ottieni i dati completi del profilo utente
  Future<UserProfile?> getUserProfile() async {
    final userId = await getUserId();
    final publicKey = await getPublicKey();
    final userName = await getUserName();
    
    if (userId == null || publicKey == null) {
      return null;
    }
    
    return UserProfile(
      id: userId,
      name: userName ?? 'Me',
      publicKey: publicKey,
    );
  }
  
  /// Genera i dati QR code con le informazioni dell'utente
  Future<String?> getQRCodeData() async {
    final profile = await getUserProfile();
    if (profile == null) return null;
    
    // Formato: digitalvalut://add_contact?id=USER_ID&name=NAME&key=PUBLIC_KEY
    final uri = Uri(
      scheme: 'digitalvalut',
      host: 'add_contact',
      queryParameters: {
        'id': profile.id,
        'name': profile.name,
        'key': profile.publicKey,
      },
    );
    
    return uri.toString();
  }
  
  /// Parsa i dati da un QR code scansionato
  static ContactData? parseQRCodeData(String qrData) {
    try {
      final uri = Uri.parse(qrData);
      
      // Verifica che sia un QR code valido di DigitalValut
      if (uri.scheme != 'digitalvalut' || uri.host != 'add_contact') {
        return null;
      }
      
      final id = uri.queryParameters['id'];
      final name = uri.queryParameters['name'];
      final key = uri.queryParameters['key'];
      
      if (id == null || key == null) {
        return null;
      }
      
      return ContactData(
        id: id,
        name: name ?? 'Unknown',
        publicKey: key,
      );
    } catch (e) {
      print('Errore nel parsing del QR code: $e');
      return null;
    }
  }
  
  /// Resetta il profilo utente (per test o reset completo)
  Future<void> resetProfile() async {
    final userId = await getUserId();
    if (userId != null) {
      await _encryptionService.deleteKeyPair(userId);
    }
    
    await _secureStorage.delete(key: _userIdKey);
    await _secureStorage.delete(key: _userPublicKeyKey);
    await _secureStorage.delete(key: _userNameKey);
    await _secureStorage.delete(key: _isInitializedKey);
    
    print('✅ Profilo utente resettato');
  }
}

/// Modello per il profilo utente
class UserProfile {
  final String id;
  final String name;
  final String publicKey;
  
  UserProfile({
    required this.id,
    required this.name,
    required this.publicKey,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'publicKey': publicKey,
    };
  }
  
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      name: json['name'],
      publicKey: json['publicKey'],
    );
  }
}

/// Modello per i dati di contatto da QR code
class ContactData {
  final String id;
  final String name;
  final String publicKey;
  
  ContactData({
    required this.id,
    required this.name,
    required this.publicKey,
  });
}
