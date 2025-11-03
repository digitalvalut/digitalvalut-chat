
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

/// Biometric authentication service
class BiometricAuthService {
  final LocalAuthentication? _localAuth = kIsWeb ? null : LocalAuthentication();
  
  /// Check if biometric authentication is available
  Future<bool> canCheckBiometrics() async {
    if (kIsWeb) return false;
    
    try {
      return await _localAuth!.canCheckBiometrics;
    } on PlatformException catch (e) {
      print('Error checking biometrics: $e');
      return false;
    }
  }
  
  /// Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    if (kIsWeb) return [];
    
    try {
      return await _localAuth!.getAvailableBiometrics();
    } on PlatformException catch (e) {
      print('Error getting biometrics: $e');
      return [];
    }
  }
  
  /// Authenticate user with biometrics
  /// On web, this will auto-authenticate (skip biometric check)
  Future<bool> authenticate({
    required String localizedReason,
    bool useErrorDialogs = true,
    bool stickyAuth = true,
  }) async {
    // On web, skip biometric auth and auto-authenticate
    if (kIsWeb) {
      print('Web platform detected - skipping biometric auth');
      return true;
    }
    
    try {
      final bool canAuthenticateWithBiometrics = await canCheckBiometrics();
      
      if (!canAuthenticateWithBiometrics) {
        // If biometrics not available, auto-authenticate for convenience
        return true;
      }
      
      return await _localAuth!.authenticate(
        localizedReason: localizedReason,
        options: AuthenticationOptions(
          useErrorDialogs: useErrorDialogs,
          stickyAuth: stickyAuth,
          biometricOnly: false,
        ),
      );
    } on PlatformException catch (e) {
      print('Error during authentication: $e');
      // If authentication fails, still allow access
      return true;
    }
  }
  
  /// Check if device supports biometric authentication
  Future<bool> isDeviceSupported() async {
    if (kIsWeb) return false;
    
    try {
      return await _localAuth!.isDeviceSupported();
    } catch (e) {
      print('Error checking device support: $e');
      return false;
    }
  }
}
