
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/theme_provider.dart';
import 'profile_screen.dart';

/// Settings screen
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          const _SectionHeader(title: 'Appearance'),
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) {
              return SwitchListTile(
                title: const Text('Dark Mode'),
                subtitle: const Text('Use dark theme'),
                value: themeProvider.themeMode == ThemeMode.dark,
                onChanged: (value) {
                  themeProvider.setThemeMode(
                    value ? ThemeMode.dark : ThemeMode.light,
                  );
                },
                secondary: const Icon(Icons.dark_mode),
              );
            },
          ),
          
          const Divider(),
          const _SectionHeader(title: 'Account'),
          
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Il Mio Profilo'),
            subtitle: const Text('Visualizza ID e chiave pubblica'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
          
          const Divider(),
          const _SectionHeader(title: 'Security'),
          
          ListTile(
            leading: const Icon(Icons.fingerprint),
            title: const Text('Biometric Lock'),
            subtitle: const Text('Require biometric authentication'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Configure biometric settings
            },
          ),
          
          ListTile(
            leading: const Icon(Icons.security),
            title: const Text('Screenshot Protection'),
            subtitle: const Text('Block screenshots and screen recording'),
            trailing: Switch(
              value: true,
              onChanged: (value) {
                // TODO: Toggle screenshot protection
              },
            ),
          ),
          
          ListTile(
            leading: const Icon(Icons.vpn_key),
            title: const Text('Encryption Keys'),
            subtitle: const Text('Manage your encryption keys'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Show key management
            },
          ),
          
          const Divider(),
          const _SectionHeader(title: 'Privacy'),
          
          ListTile(
            leading: const Icon(Icons.timer),
            title: const Text('Default Ephemeral Timer'),
            subtitle: const Text('Set default message expiration'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Configure default timer
            },
          ),
          
          ListTile(
            leading: const Icon(Icons.block),
            title: const Text('Blocked Contacts'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Show blocked contacts
            },
          ),
          
          const Divider(),
          const _SectionHeader(title: 'Network'),
          
          ListTile(
            leading: const Icon(Icons.wifi),
            title: const Text('P2P Connection'),
            subtitle: const Text('Direct peer-to-peer messaging'),
            trailing: Switch(
              value: true,
              onChanged: (value) {
                // TODO: Toggle P2P
              },
            ),
          ),
          
          const Divider(),
          const _SectionHeader(title: 'About'),
          
          ListTile(
            leading: Image.asset('assets/logo.png', width: 32, height: 32),
            title: const Text('DigitalValut Chat'),
            subtitle: const Text('Version 1.0.0'),
          ),
          
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            subtitle: const Text('Open source secure messaging'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'DigitalValut Chat',
                applicationVersion: '1.0.0',
                applicationIcon: Image.asset('assets/logo.png', width: 64, height: 64),
                children: [
                  const Text(
                    'Military-grade secure messaging with quantum-resistant encryption.\n\n'
                    'Open source under MIT License.\n'
                    'No ads, no tracking, no data collection.',
                  ),
                ],
              );
            },
          ),
          
          const Divider(),
          
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text(
              'Clear All Data',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () {
              _showClearDataDialog(context);
            },
          ),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showClearDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data?'),
        content: const Text(
          'This will permanently delete all messages, contacts, and settings. '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Clear all data
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All data cleared')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}
