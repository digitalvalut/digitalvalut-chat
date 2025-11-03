import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../services/user_profile_service.dart';

/// Schermata del profilo utente
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserProfile? _userProfile;
  String? _qrCodeData;
  bool _isLoading = true;
  final _nameController = TextEditingController();
  bool _isEditingName = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final userProfileService = Provider.of<UserProfileService>(context, listen: false);
    
    setState(() {
      _isLoading = true;
    });

    try {
      final profile = await userProfileService.getUserProfile();
      final qrData = await userProfileService.getQRCodeData();
      
      setState(() {
        _userProfile = profile;
        _qrCodeData = qrData;
        _nameController.text = profile?.name ?? 'Me';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Errore nel caricamento del profilo: $e')),
        );
      }
    }
  }

  Future<void> _saveName() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Il nome non può essere vuoto')),
      );
      return;
    }

    final userProfileService = Provider.of<UserProfileService>(context, listen: false);
    
    try {
      await userProfileService.setUserName(_nameController.text.trim());
      
      setState(() {
        _isEditingName = false;
      });
      
      // Ricarica il profilo per aggiornare i dati QR
      await _loadProfile();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Nome aggiornato')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Errore nell\'aggiornamento del nome: $e')),
      );
    }
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('✅ $label copiato negli appunti')),
    );
  }

  Future<void> _shareProfile() async {
    if (_qrCodeData == null) return;
    
    final profile = _userProfile;
    if (profile == null) return;

    try {
      await Share.share(
        'Aggiungimi su DigitalValut Chat!\n\n'
        'Nome: ${profile.name}\n'
        'ID: ${profile.id}\n'
        'Chiave Pubblica: ${profile.publicKey}\n\n'
        'Oppure scansiona il mio QR code per aggiungermi rapidamente!',
        subject: 'Aggiungimi su DigitalValut Chat',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Errore nella condivisione: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Il Mio Profilo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _userProfile != null ? _shareProfile : null,
            tooltip: 'Condividi profilo',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _userProfile == null
              ? const Center(
                  child: Text('Errore nel caricamento del profilo'),
                )
              : RefreshIndicator(
                  onRefresh: _loadProfile,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Avatar e Nome
                        Center(
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundColor: Theme.of(context).primaryColor,
                                child: const Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 16),
                              if (_isEditingName)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 200,
                                      child: TextField(
                                        controller: _nameController,
                                        autofocus: true,
                                        textAlign: TextAlign.center,
                                        decoration: const InputDecoration(
                                          hintText: 'Il tuo nome',
                                          isDense: true,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.check, color: Colors.green),
                                      onPressed: _saveName,
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.close, color: Colors.red),
                                      onPressed: () {
                                        setState(() {
                                          _nameController.text = _userProfile?.name ?? 'Me';
                                          _isEditingName = false;
                                        });
                                      },
                                    ),
                                  ],
                                )
                              else
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _userProfile!.name,
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.edit, size: 20),
                                      onPressed: () {
                                        setState(() {
                                          _isEditingName = true;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // QR Code
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              children: [
                                const Text(
                                  'Il tuo QR Code',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Fai scansionare questo codice per essere aggiunto',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.grey, fontSize: 12),
                                ),
                                const SizedBox(height: 16),
                                if (_qrCodeData != null)
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: QrImageView(
                                      data: _qrCodeData!,
                                      version: QrVersions.auto,
                                      size: 200,
                                      backgroundColor: Colors.white,
                                    ),
                                  )
                                else
                                  const CircularProgressIndicator(),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // ID Utente
                        _buildInfoCard(
                          title: 'ID Utente',
                          value: _userProfile!.id,
                          icon: Icons.fingerprint,
                          onCopy: () => _copyToClipboard(_userProfile!.id, 'ID'),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Chiave Pubblica
                        _buildInfoCard(
                          title: 'Chiave Pubblica',
                          value: _userProfile!.publicKey,
                          icon: Icons.vpn_key,
                          onCopy: () => _copyToClipboard(_userProfile!.publicKey, 'Chiave pubblica'),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Info sulla sicurezza
                        Card(
                          color: Colors.blue.withOpacity(0.1),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                const Icon(Icons.info_outline, color: Colors.blue),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Le tue chiavi sono memorizzate in modo sicuro sul dispositivo e non vengono mai condivise.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.blue[900],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String value,
    required IconData icon,
    required VoidCallback onCopy,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      value,
                      style: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'monospace',
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 20),
                    onPressed: onCopy,
                    tooltip: 'Copia',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
