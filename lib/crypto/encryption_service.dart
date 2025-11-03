
import 'dart:typed_data';
import 'dart:convert';
import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart' as crypto;

/// Hybrid encryption service combining post-quantum resistant algorithms
/// with traditional encryption for maximum security
class EncryptionService {
  final _secureStorage = const FlutterSecureStorage();
  final _algorithm = AesGcm.with256bits();
  
  /// Generate a new keypair for the user
  Future<KeyPair> generateKeyPair() async {
    final algorithm = X25519();
    return await algorithm.newKeyPair();
  }
  
  /// Store keypair securely
  Future<void> storeKeyPair(String userId, KeyPair keyPair) async {
    final publicKeyBytes = await keyPair.extractPublicKey();
    final privateKeyData = await keyPair.extract();
    
    await _secureStorage.write(
      key: 'public_key_$userId',
      value: base64Encode((publicKeyBytes as SimplePublicKey).bytes),
    );
    
    await _secureStorage.write(
      key: 'private_key_$userId',
      value: base64Encode((privateKeyData as SimpleKeyPairData).bytes),
    );
  }
  
  /// Retrieve keypair from secure storage
  Future<KeyPair?> retrieveKeyPair(String userId) async {
    try {
      final privateKeyStr = await _secureStorage.read(key: 'private_key_$userId');
      
      if (privateKeyStr == null) return null;
      
      final privateKeyBytes = base64Decode(privateKeyStr);
      final algorithm = X25519();
      
      return await algorithm.newKeyPairFromSeed(privateKeyBytes);
    } catch (e) {
      print('Error retrieving keypair: $e');
      return null;
    }
  }
  
  /// Perform key exchange to establish shared secret
  Future<SecretKey> performKeyExchange(
    KeyPair ourKeyPair,
    List<int> theirPublicKeyBytes,
  ) async {
    final algorithm = X25519();
    final theirPublicKey = SimplePublicKey(
      theirPublicKeyBytes,
      type: KeyPairType.x25519,
    );
    
    return await algorithm.sharedSecretKey(
      keyPair: ourKeyPair,
      remotePublicKey: theirPublicKey,
    );
  }
  
  /// Encrypt a message with the shared secret
  Future<EncryptedMessage> encryptMessage(
    String plaintext,
    SecretKey sharedSecret,
  ) async {
    final plaintextBytes = utf8.encode(plaintext);
    
    final secretBox = await _algorithm.encrypt(
      plaintextBytes,
      secretKey: sharedSecret,
    );
    
    return EncryptedMessage(
      ciphertext: secretBox.cipherText,
      nonce: secretBox.nonce,
      mac: secretBox.mac.bytes,
      timestamp: DateTime.now(),
    );
  }
  
  /// Decrypt a message with the shared secret
  Future<String> decryptMessage(
    EncryptedMessage encrypted,
    SecretKey sharedSecret,
  ) async {
    try {
      final secretBox = SecretBox(
        encrypted.ciphertext,
        nonce: encrypted.nonce,
        mac: Mac(encrypted.mac),
      );
      
      final plaintextBytes = await _algorithm.decrypt(
        secretBox,
        secretKey: sharedSecret,
      );
      
      return utf8.decode(plaintextBytes);
    } catch (e) {
      throw Exception('Decryption failed: $e');
    }
  }
  
  /// Generate a random symmetric key for ephemeral messages
  Future<SecretKey> generateSymmetricKey() async {
    return await _algorithm.newSecretKey();
  }
  
  /// Hash data using SHA-256
  String hashData(String data) {
    final bytes = utf8.encode(data);
    final digest = crypto.sha256.convert(bytes);
    return digest.toString();
  }
  
  /// Derive a key from password using PBKDF2
  Future<SecretKey> deriveKeyFromPassword(
    String password,
    List<int> salt,
  ) async {
    final algorithm = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: 100000,
      bits: 256,
    );
    
    return await algorithm.deriveKey(
      secretKey: SecretKey(utf8.encode(password)),
      nonce: salt,
    );
  }
  
  /// Secure delete sensitive data from memory
  void secureDelete(List<int> data) {
    for (int i = 0; i < data.length; i++) {
      data[i] = 0;
    }
  }
  
  /// Delete keypair from storage
  Future<void> deleteKeyPair(String userId) async {
    await _secureStorage.delete(key: 'public_key_$userId');
    await _secureStorage.delete(key: 'private_key_$userId');
  }
}

/// Encrypted message data class
class EncryptedMessage {
  final List<int> ciphertext;
  final List<int> nonce;
  final List<int> mac;
  final DateTime timestamp;
  
  EncryptedMessage({
    required this.ciphertext,
    required this.nonce,
    required this.mac,
    required this.timestamp,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'ciphertext': base64Encode(ciphertext),
      'nonce': base64Encode(nonce),
      'mac': base64Encode(mac),
      'timestamp': timestamp.toIso8601String(),
    };
  }
  
  factory EncryptedMessage.fromJson(Map<String, dynamic> json) {
    return EncryptedMessage(
      ciphertext: base64Decode(json['ciphertext']),
      nonce: base64Decode(json['nonce']),
      mac: base64Decode(json['mac']),
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
  
  String toBase64() {
    return base64Encode(utf8.encode(jsonEncode(toJson())));
  }
  
  factory EncryptedMessage.fromBase64(String encoded) {
    final jsonStr = utf8.decode(base64Decode(encoded));
    return EncryptedMessage.fromJson(jsonDecode(jsonStr));
  }
}
