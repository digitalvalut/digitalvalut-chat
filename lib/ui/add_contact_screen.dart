
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import '../database/database_service.dart';
import '../models/contact.dart';
import '../models/conversation.dart';
import '../services/user_profile_service.dart';

/// Add contact screen with QR code support
class AddContactScreen extends StatefulWidget {
  const AddContactScreen({super.key});

  @override
  State<AddContactScreen> createState() => _AddContactScreenState();
}

class _AddContactScreenState extends State<AddContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _publicKeyController = TextEditingController();
  final _uuid = const Uuid();
  
  int _selectedTab = 0;
  String? _qrCodeData;

  @override
  void initState() {
    super.initState();
    _loadQRCodeData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _publicKeyController.dispose();
    super.dispose();
  }

  Future<void> _loadQRCodeData() async {
    final userProfileService = Provider.of<UserProfileService>(context, listen: false);
    final qrData = await userProfileService.getQRCodeData();
    setState(() {
      _qrCodeData = qrData;
    });
  }

  Future<void> _addContact() async {
    if (!_formKey.currentState!.validate()) return;
    
    try {
      final dbService = Provider.of<DatabaseService>(context, listen: false);
      
      // Create contact
      final contact = Contact(
        id: _uuid.v4(),
        name: _nameController.text.trim(),
        publicKey: _publicKeyController.text.trim(),
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );
      
      await dbService.insertContact(contact);
      
      // Create conversation
      final conversation = Conversation(
        id: _uuid.v4(),
        contactId: contact.id,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );
      
      await dbService.insertConversation(conversation);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Contact added successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Failed to add contact: $e')),
      );
    }
  }

  Future<void> _openQRScanner() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const QRScannerScreen()),
    );
    
    if (result != null) {
      _handleQRCodeScanned(result);
    }
  }

  void _handleQRCodeScanned(String qrData) {
    final contactData = UserProfileService.parseQRCodeData(qrData);
    
    if (contactData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ QR code non valido')),
      );
      return;
    }
    
    // Compila i campi del form con i dati scansionati
    setState(() {
      _nameController.text = contactData.name;
      _publicKeyController.text = contactData.publicKey;
      _selectedTab = 0; // Torna alla tab manuale
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Dati contatto acquisiti dal QR code')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Contact'),
      ),
      body: Column(
        children: [
          // Tab selector
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTab = 0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _selectedTab == 0
                            ? Theme.of(context).primaryColor
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Text(
                        'Manual',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _selectedTab == 0 ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTab = 1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _selectedTab == 1
                            ? Theme.of(context).primaryColor
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Text(
                        'QR Code',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _selectedTab == 1 ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Content
          Expanded(
            child: _selectedTab == 0
                ? _buildManualEntry()
                : _buildQRCodeView(),
          ),
        ],
      ),
    );
  }

  Widget _buildManualEntry() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Contact Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _publicKeyController,
              decoration: const InputDecoration(
                labelText: 'Public Key',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.vpn_key),
                helperText: 'Ask your contact to share their public key',
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a public key';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 24),
            
            ElevatedButton(
              onPressed: _addContact,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
              child: const Text('Add Contact'),
            ),
            
            const SizedBox(height: 16),
            
            OutlinedButton.icon(
              onPressed: _openQRScanner,
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Scansiona QR Code'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQRCodeView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            'Condividi il tuo QR code',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          
          const SizedBox(height: 16),
          
          const Text(
            'Fai scansionare questo codice al tuo contatto per aggiungerti',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          
          const SizedBox(height: 32),
          
          if (_qrCodeData != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: QrImageView(
                data: _qrCodeData!,
                version: QrVersions.auto,
                size: 250,
                backgroundColor: Colors.white,
              ),
            )
          else
            const CircularProgressIndicator(),
          
          const SizedBox(height: 32),
          
          ElevatedButton.icon(
            onPressed: _openQRScanner,
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text('Scansiona QR Code del contatto'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(16),
            ),
          ),
        ],
      ),
    );
  }
}

/// QR Scanner Screen
class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool hasScanned = false;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (!hasScanned && scanData.code != null) {
        setState(() {
          hasScanned = true;
        });
        controller.pauseCamera();
        Navigator.pop(context, scanData.code);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scansiona QR Code'),
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: Theme.of(context).primaryColor,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: 300,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.black,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Posiziona il QR code nel riquadro',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () async {
                            await controller?.toggleFlash();
                            setState(() {});
                          },
                          icon: FutureBuilder<bool?>(
                            future: controller?.getFlashStatus(),
                            builder: (context, snapshot) {
                              return Icon(
                                snapshot.data == true
                                    ? Icons.flash_on
                                    : Icons.flash_off,
                                color: Colors.white,
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        IconButton(
                          onPressed: () async {
                            await controller?.flipCamera();
                            setState(() {});
                          },
                          icon: const Icon(
                            Icons.flip_camera_ios,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
