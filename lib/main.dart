
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
// import 'package:flutter_windowmanager/flutter_windowmanager.dart';  // Temporarily disabled

import 'database/database_service.dart';
import 'ui/auth_screen.dart';
import 'ui/chat_list_screen.dart';
import 'services/theme_provider.dart';
import 'services/user_profile_service.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Platform-specific initialization (mobile only)
  if (!kIsWeb) {
    // Lock device orientation to portrait
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    
    // Enable screenshot protection globally (Android only)
    // Temporarily disabled flutter_windowmanager due to namespace issues
    // try {
    //   await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
    // } catch (e) {
    //   // Ignore error on iOS or other platforms
    //   debugPrint('Screenshot protection not available: $e');
    // }
  }
  
  // Initialize database (conditional for web)
  DatabaseService? databaseService;
  if (!kIsWeb) {
    databaseService = DatabaseService();
    await databaseService.initialize();
  }
  
  // Initialize user profile (genera chiavi se al primo avvio)
  final userProfileService = UserProfileService();
  try {
    await userProfileService.initializeProfile();
    debugPrint('✅ Profilo utente inizializzato');
  } catch (e) {
    debugPrint('❌ Errore nell\'inizializzazione del profilo: $e');
  }
  
  // Run the app
  runApp(
    MultiProvider(
      providers: [
        if (databaseService != null)
          Provider<DatabaseService>.value(value: databaseService),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        Provider<UserProfileService>.value(value: userProfileService),
      ],
      child: const DigitalValutApp(),
    ),
  );
}

class DigitalValutApp extends StatelessWidget {
  const DigitalValutApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'DigitalValut Chat',
          debugShowCheckedModeBanner: false,
          
          // Theme configuration
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF2C3E50), // Dark blue from logo
              brightness: Brightness.light,
            ),
            appBarTheme: const AppBarTheme(
              centerTitle: true,
              elevation: 0,
            ),
          ),
          
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF2C3E50),
              brightness: Brightness.dark,
            ),
            appBarTheme: const AppBarTheme(
              centerTitle: true,
              elevation: 0,
            ),
          ),
          
          themeMode: themeProvider.themeMode,
          
          // Initial route with biometric authentication
          home: const AuthScreen(),
        );
      },
    );
  }
}
