
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';

/// Biometric authentication service
class BiometricAuthService {
  final LocalAuthentication _localAuth = LocalAuthentication();
  
  /// Check if biometric authentication is available
  Future<bool> canCheckBiometrics() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } on PlatformException catch (e) {
      print('Error checking biometrics: $e');
      return false;
    }
  }
  
  /// Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      print('Error getting biometrics: $e');
      return [];
    }
  }
  
  /// Authenticate user with biometrics
  Future<bool> authenticate({
    required String localizedReason,
    bool useErrorDialogs = true,
    bool stickyAuth = true,
  }) async {
    try {
      final bool canAuthenticateWithBiometrics = await canCheckBiometrics();
      
      if (!canAuthenticateWithBiometrics) {
        return false;
      }
      
      return await _localAuth.authenticate(
        localizedReason: localizedReason,
        options: AuthenticationOptions(
          useErrorDialogs: useErrorDialogs,
          stickyAuth: stickyAuth,
          biometricOnly: false,
        ),
      );
    } on PlatformException catch (e) {
      print('Error during authentication: $e');
      return false;
    }
  }
  
  /// Check if device supports biometric authentication
  Future<bool> isDeviceSupported() async {
    try {
      return await _localAuth.isDeviceSupported();
    } catch (e) {
      print('Error checking device support: $e');
      return false;
    }
  }
}
