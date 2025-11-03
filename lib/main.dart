
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';

import 'database/database_service.dart';
import 'ui/auth_screen.dart';
import 'ui/chat_list_screen.dart';
import 'services/theme_provider.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Lock device orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Enable screenshot protection globally
  await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
  
  // Initialize database
  final databaseService = DatabaseService();
  await databaseService.initialize();
  
  // Run the app
  runApp(
    MultiProvider(
      providers: [
        Provider<DatabaseService>.value(value: databaseService),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
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
