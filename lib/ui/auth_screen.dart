
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../security/biometric_auth.dart';
import 'chat_list_screen.dart';

/// Authentication screen with biometric verification
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final BiometricAuthService _authService = BiometricAuthService();
  bool _isAuthenticating = true;

  @override
  void initState() {
    super.initState();
    _authenticate();
  }

  Future<void> _authenticate() async {
    final authenticated = await _authService.authenticate(
      localizedReason: 'Authenticate to access DigitalValut Chat',
    );
    
    setState(() {
      _isAuthenticating = false;
    });
    
    if (authenticated) {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const ChatListScreen()),
        );
      }
    } else {
      _showAuthenticationError();
    }
  }

  void _showAuthenticationError() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Authentication Failed'),
        content: const Text(
          'Biometric authentication is required to access DigitalValut Chat.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _authenticate();
            },
            child: const Text('Retry'),
          ),
          TextButton(
            onPressed: () {
              SystemNavigator.pop();
            },
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display logo
            Image.asset(
              'assets/logo.png',
              width: 120,
              height: 120,
            ),
            const SizedBox(height: 24),
            
            const Text(
              'DigitalValut Chat',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 8),
            
            const Text(
              'Military-Grade Secure Messaging',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            
            const SizedBox(height: 48),
            
            if (_isAuthenticating)
              const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
