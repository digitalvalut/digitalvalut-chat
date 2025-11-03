
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cryptography/cryptography.dart';

/// Manages cryptographic keys securely
class KeyManager {
  final _secureStorage = const FlutterSecureStorage();
  
  /// Store a symmetric key
  Future<void> storeSymmetricKey(String keyId, SecretKey key) async {
    final keyBytes = await key.extractBytes();
    await _secureStorage.write(
      key: 'symmetric_$keyId',
      value: base64Encode(keyBytes),
    );
  }
  
  /// Retrieve a symmetric key
  Future<SecretKey?> retrieveSymmetricKey(String keyId) async {
    final keyStr = await _secureStorage.read(key: 'symmetric_$keyId');
    if (keyStr == null) return null;
    
    final keyBytes = base64Decode(keyStr);
    return SecretKey(keyBytes);
  }
  
  /// Delete a symmetric key
  Future<void> deleteSymmetricKey(String keyId) async {
    await _secureStorage.delete(key: 'symmetric_$keyId');
  }
  
  /// Store a public key
  Future<void> storePublicKey(String userId, SimplePublicKey publicKey) async {
    await _secureStorage.write(
      key: 'public_$userId',
      value: base64Encode(publicKey.bytes),
    );
  }
  
  /// Retrieve a public key
  Future<SimplePublicKey?> retrievePublicKey(String userId) async {
    final keyStr = await _secureStorage.read(key: 'public_$userId');
    if (keyStr == null) return null;
    
    final keyBytes = base64Decode(keyStr);
    return SimplePublicKey(keyBytes, type: KeyPairType.x25519);
  }
  
  /// Delete a public key
  Future<void> deletePublicKey(String userId) async {
    await _secureStorage.delete(key: 'public_$userId');
  }
  
  /// Clear all keys
  Future<void> clearAllKeys() async {
    await _secureStorage.deleteAll();
  }
  
  /// Generate a unique conversation key ID
  String generateConversationKeyId(String userId1, String userId2) {
    final sorted = [userId1, userId2]..sort();
    return 'conv_${sorted[0]}_${sorted[1]}';
  }
}
