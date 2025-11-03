# Changelog

All notable changes to DigitalValut Chat will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-11-03

### Added

#### Security Features
- ✅ End-to-end encryption with X25519 + AES-256-GCM
- ✅ Hybrid post-quantum cryptography support
- ✅ Biometric authentication (Face ID, Touch ID, Fingerprint)
- ✅ Screenshot blocking and screen recording detection
- ✅ Encrypted SQLite database with AES-256
- ✅ Secure key storage with Flutter Secure Storage

#### Messaging Features
- ✅ P2P (Peer-to-Peer) messaging via WebRTC
- ✅ Real-time encrypted messaging
- ✅ Ephemeral (self-destructing) messages
- ✅ Customizable message expiration timers (10s to 30 days)
- ✅ Message status indicators (sending, sent, delivered, read)
- ✅ Offline message queueing

#### User Interface
- ✅ Modern Material Design 3 UI
- ✅ Dark mode / Light mode support
- ✅ Chat list with unread counts
- ✅ Individual chat screens
- ✅ Contact management
- ✅ QR code contact sharing
- ✅ Settings screen
- ✅ Biometric authentication screen

#### Platform Support
- ✅ Android support (API 21+)
- ✅ iOS support (iOS 12+)
- ✅ Portrait and landscape orientations
- ✅ Tablet support

#### Developer Features
- ✅ Complete Flutter project structure
- ✅ Modular architecture
- ✅ Clean code with documentation
- ✅ MIT License (Open Source)
- ✅ Comprehensive README
- ✅ Deployment guides
- ✅ Contributing guidelines

### Planned for Future Releases

#### Version 1.1 (Q2 2025)
- 🚧 TON blockchain wallet integration
- 🚧 Decentralized identity (DID)
- 🚧 Micropayments in chat
- 🚧 Local LLM integration for:
  - Auto-translation (50+ languages)
  - Spam detection
  - Chat summaries
  - Smart reply suggestions

#### Version 1.2 (Q2 2025)
- 🚧 Voice calls over P2P
- 🚧 Video calls over P2P
- 🚧 Group chats
- 🚧 File sharing

#### Version 2.0 (Q3 2025)
- 🚧 Desktop apps (Windows, macOS, Linux)
- 🚧 Multi-device synchronization
- 🚧 Message reactions
- 🚧 Stickers and GIFs
- 🚧 Voice messages
- 🚧 Location sharing

### Technical Details

#### Dependencies
- Flutter 3.0+
- cryptography: ^2.7.0 (Encryption)
- flutter_webrtc: ^0.9.48 (P2P Communication)
- sqflite: ^2.3.3 (Database)
- flutter_secure_storage: ^9.2.2 (Key Storage)
- local_auth: ^2.3.0 (Biometric Auth)
- flutter_windowmanager: ^0.2.0 (Screenshot Protection)

#### Architecture
- MVVM pattern
- Provider state management
- Modular code structure
- Clean architecture principles

#### Security Standards
- NIST-compliant encryption
- OWASP Mobile Top 10 compliance
- Zero-knowledge architecture
- No data collection or tracking

---

## Version History

- **1.0.0** (2025-11-03) - Initial release

---

## How to Update

### For Users

1. Download the latest APK/IPA from https://digitalvalut.chat/download
2. Install over existing version (data will be preserved)
3. Grant any new permissions if requested

### For Developers

```bash
git pull origin main
flutter pub get
flutter clean
flutter build [apk|ios] --release
```

---

## Breaking Changes

None (initial release)

---

## Known Issues

- TON wallet integration is placeholder only
- Local LLM features not yet implemented
- Group chats not yet available
- Desktop apps not yet available

Report issues at: https://github.com/yourusername/digitalvalut_chat/issues

---

## Contributors

- DigitalValut Team
- Community Contributors (see CONTRIBUTING.md)

---

## License

MIT License - see LICENSE file for details

---

**Stay Updated:**
- Website: https://digitalvalut.chat
- Twitter: @digitalvalut
- Discord: https://discord.gg/digitalvalut
