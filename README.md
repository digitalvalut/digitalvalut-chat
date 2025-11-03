# DigitalValut Chat 🔐

**Military-Grade Secure Messaging with Quantum-Resistant Encryption**

<div align="center">
  <img src="logo.png" alt="DigitalValut Logo" width="200"/>
</div>

[![Flutter CI/CD](https://github.com/digitalvalut/digitalvalut-chat/actions/workflows/flutter-ci.yml/badge.svg)](https://github.com/digitalvalut/digitalvalut-chat/actions)
[![License: MIT](https://upload.wikimedia.org/wikipedia/commons/thumb/c/c3/License_icon-mit.svg/1024px-License_icon-mit.svg.png)
[![Flutter](https://i.ytimg.com/vi/-mYLjTYn4ZA/sddefault.jpg)
[![Platform](https://i.ytimg.com/vi/nk6ixe_1OV0/maxresdefault.jpg)

---

## 📋 Table of Contents

- [Overview](#overview)
- [Key Features](#key-features)
- [Security Features](#security-features)
- [Quick Start](#quick-start)
- [Deployment Guide](#deployment-guide)
- [Building for Production](#building-for-production)
- [Project Structure](#project-structure)
- [Contributing](#contributing)
- [License](#license)

---

## 🌟 Overview

**DigitalValut Chat** is an open-source, military-grade secure messaging application that provides true end-to-end encryption with quantum-resistant cryptography. Unlike traditional messaging apps, DigitalValut offers:

- ✅ **True Privacy**: No servers, no data collection, no tracking
- ✅ **Quantum-Resistant**: Post-quantum cryptography ready for the future
- ✅ **P2P Communication**: Direct peer-to-peer messaging via WebRTC
- ✅ **Ephemeral Messages**: Self-destructing messages that leave no trace
- ✅ **Blockchain Identity**: TON blockchain wallet integration
- ✅ **Local AI**: On-device LLM for translation and spam detection
- ✅ **Open Source**: Fully auditable code under MIT License

---

## 🔑 Key Features

### 🔐 Military-Grade Encryption
- **Hybrid Cryptography**: Combines X25519 key exchange with AES-256-GCM
- **End-to-End Encryption**: Messages encrypted on your device, decrypted only by recipient
- **Forward Secrecy**: Each session uses unique encryption keys
- **Secure Key Storage**: Biometric-protected keychain storage

### 🌐 P2P Messaging
- **No Central Server**: Direct device-to-device communication
- **WebRTC Data Channels**: Real-time encrypted messaging
- **NAT Traversal**: STUN/TURN support for global connectivity
- **Offline Mode**: Messages queued and synced when back online

### ⏱️ Ephemeral Messages
- **Self-Destructing**: Set messages to auto-delete after viewing
- **Customizable Timers**: 10 seconds to 30 days
- **Secure Deletion**: Encryption keys wiped from memory
- **No Traces**: Messages permanently deleted

### 💰 TON Blockchain Integration (Planned)
- **Decentralized Identity**: Use TON wallet address as user ID
- **Micropayments**: Send cryptocurrency in messages
- **NFT Verification**: Mint important messages as NFTs
- **Spam Prevention**: Stake required to message new contacts

### 🤖 Local AI Features (Planned)
- **Auto-Translation**: Real-time message translation (50+ languages)
- **Spam Detection**: AI-powered phishing/malware detection
- **Chat Summaries**: Instant conversation summaries
- **Smart Replies**: Contextual quick response suggestions

### 🔒 Security Protections
- **Screenshot Blocking**: Prevent screen capture
- **Biometric Authentication**: Face ID / Touch ID / Fingerprint
- **Encrypted Database**: Local SQLite database with AES-256
- **Screen Recording Detection**: Alerts when recording detected

---

## 🛡️ Security Features

DigitalValut implements **defense in depth** with multiple security layers:

1. **Transport Layer**: WebRTC DTLS 1.3 encryption
2. **Key Exchange**: X25519 elliptic curve Diffie-Hellman
3. **Message Encryption**: AES-256-GCM authenticated encryption
4. **Local Storage**: Encrypted SQLite database
5. **Key Management**: Flutter Secure Storage with biometric protection
6. **UI Security**: Screenshot blocking and screen recording detection

---

## 🚀 Quick Start

### Prerequisites

Before you begin, ensure you have the following installed:

- **Flutter SDK** (3.0 or higher): [Install Flutter](https://docs.flutter.dev/get-started/install)
- **Android Studio** (for Android development): [Download Android Studio](https://developer.android.com/studio)
- **Xcode** (for iOS development, macOS only): [Download Xcode](https://developer.apple.com/xcode/)
- **Git**: [Install Git](https://git-scm.com/downloads)

### Installation Steps

#### 1. Clone the Repository

```bash
# Clone this repository to your local machine
git clone https://github.com/digitalvalut/digitalvalut_chat.git
cd digitalvalut_chat
```

#### 2. Install Dependencies

```bash
# Get all Flutter packages
flutter pub get
```

#### 3. Run on Android Emulator/Device

```bash
# List available devices
flutter devices

# Run the app
flutter run
```

#### 4. Run on iOS Simulator/Device (macOS only)

```bash
# Open iOS simulator
open -a Simulator

# Run the app
flutter run
```

---

## 📦 Deployment Guide

### For Non-Programmers

This guide will help you build DigitalValut Chat from source and install it on your device without using app stores.

#### Step 1: Install Flutter

**Windows:**
1. Download Flutter SDK from https://docs.flutter.dev/get-started/install/windows
2. Extract the zip file to `C:\src\flutter`
3. Add Flutter to your PATH:
   - Search "Environment Variables" in Windows
   - Edit "Path" variable
   - Add `C:\src\flutter\bin`
4. Open Command Prompt and run: `flutter doctor`

**macOS:**
1. Open Terminal
2. Run: `brew install flutter` (install Homebrew first if needed)
3. Run: `flutter doctor`

**Linux:**
1. Download Flutter SDK from https://docs.flutter.dev/get-started/install/linux
2. Extract to `/usr/local/flutter`
3. Add to PATH: `export PATH="$PATH:/usr/local/flutter/bin"`
4. Run: `flutter doctor`

#### Step 2: Install Android Studio (for Android)

1. Download from https://developer.android.com/studio
2. Install Android Studio
3. Open Android Studio
4. Go to Settings → Appearance & Behavior → System Settings → Android SDK
5. Install latest Android SDK
6. Install Android SDK Command-line Tools

#### Step 3: Set Up Your Device

**Android:**
1. Enable Developer Options on your phone:
   - Go to Settings → About Phone
   - Tap "Build Number" 7 times
2. Enable USB Debugging:
   - Go to Settings → Developer Options
   - Turn on "USB Debugging"
3. Connect phone to computer via USB
4. Run: `flutter devices` (should see your phone listed)

**iOS (macOS only):**
1. Open Xcode
2. Go to Preferences → Accounts → Add Apple ID
3. Connect iPhone via USB
4. Trust the computer on your iPhone
5. Run: `flutter devices`

#### Step 4: Build the App

**For Android (APK):**

```bash
# Navigate to project folder
cd digitalvalut_chat

# Build APK
flutter build apk --release

# APK will be at: build/app/outputs/flutter-apk/app-release.apk
```

**For iOS (IPA - macOS only):**

```bash
# Build iOS app
flutter build ios --release

# You'll need to sign with your Apple Developer account
# Open in Xcode: ios/Runner.xcworkspace
# Select your team in Signing & Capabilities
# Archive and export IPA
```

#### Step 5: Install on Your Device

**Android:**
1. Copy `app-release.apk` to your phone
2. Open the APK file
3. Allow "Install from Unknown Sources" if prompted
4. Tap "Install"

**iOS:**
1. Install via Xcode:
   - Open Xcode
   - Window → Devices and Simulators
   - Select your device
   - Drag the .app file to Installed Apps
2. Or use TestFlight for beta distribution

---

## ☁️ Cloud Build & Deploy (FREE - Recommended)

### 🚀 Automatic Build with GitHub Actions

This repository includes **GitHub Actions workflows** that automatically build your app whenever you push code. No local Flutter installation needed!

#### What Gets Built Automatically:
- ✅ **Android APK** (Release) - Ready to install
- ✅ **Flutter Web** (Release) - Ready for Netlify
- ✅ **Code Analysis** - Automated testing
- ✅ **Artifacts Storage** - 30-day retention

#### How to Use:

1. **Push code to GitHub**:
```bash
git add .
git commit -m "Update app"
git push origin master
```

2. **Download builds**:
   - Go to: https://github.com/digitalvalut/digitalvalut-chat/actions
   - Click latest workflow run
   - Download artifacts:
     - `android-release-apk` → APK file for Android
     - `flutter-web-build` → Web files for Netlify

#### Build Status:
Check your builds at: https://github.com/digitalvalut/digitalvalut-chat/actions

---

### 🌐 Deploy to Netlify (FREE Hosting)

Deploy your Flutter web app to the internet in 2 minutes - completely FREE!

#### Option 1: Drag & Drop (Easiest)

1. **Get the web build**:
   - Download `flutter-web-build` artifact from GitHub Actions
   - Extract the ZIP file

2. **Deploy to Netlify**:
   - Visit: https://app.netlify.com/drop
   - Drag the `build/web` folder
   - Your app is live! 🎉

3. **Get your link**:
   - Netlify gives you: `https://[random-name].netlify.app`
   - Custom domain available (optional)

#### Option 2: Connect GitHub (Auto-Deploy)

1. **Sign up** at https://netlify.com (free account)

2. **New Site from Git**:
   - Click "Add new site" → "Import existing project"
   - Connect GitHub
   - Select `digitalvalut-chat` repository

3. **Configure build**:
   - Build command: `flutter build web --release`
   - Publish directory: `build/web`
   - Click "Deploy site"

4. **Auto-deploy enabled**:
   - Every push = automatic deployment
   - Live in 2-3 minutes

#### Your Live App:
- **Web Demo**: https://digitalvalut-chat.netlify.app
- **Download APK**: Available on website
- **Share Link**: Send to friends/investors

---

### 📲 GitHub Releases (APK Distribution)

Share your Android APK with users:

1. **Create Release**:
   - Go to: https://github.com/digitalvalut/digitalvalut-chat/releases/new
   - Tag: `v1.0.0`
   - Title: `DigitalValut Chat v1.0.0`

2. **Upload APK**:
   - Attach `app-release.apk` from GitHub Actions
   - Add changelog
   - Publish release

3. **Share download link**:
   - Direct APK link for users
   - Installation instructions included

---

## 🏗️ Building for Production

### Android Production Build

```bash
# Create app bundle for Google Play (if needed)
flutter build appbundle --release

# Or create APK for sideloading
flutter build apk --release --split-per-abi
```

**Signing Your APK:**

1. Create a keystore:
```bash
keytool -genkey -v -keystore ~/digitalvalut-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias digitalvalut
```

2. Reference keystore in `android/key.properties`:
```
storePassword=your_password
keyPassword=your_password
keyAlias=digitalvalut
storeFile=/path/to/digitalvalut-key.jks
```

3. Build signed APK:
```bash
flutter build apk --release
```

### iOS Production Build

```bash
# Build for App Store or TestFlight
flutter build ios --release

# Open in Xcode for archiving
open ios/Runner.xcworkspace
```

**Steps in Xcode:**
1. Select "Any iOS Device" as target
2. Product → Archive
3. Distribute App → Choose distribution method
4. Sign with your Apple Developer certificate
5. Export IPA

---

## 📁 Project Structure

```
digitalvalut_chat/
├── lib/
│   ├── main.dart                    # App entry point
│   ├── crypto/                      # Encryption modules
│   │   ├── encryption_service.dart  # Hybrid encryption
│   │   └── key_manager.dart         # Key storage
│   ├── network/                     # P2P networking
│   │   └── p2p_manager.dart         # WebRTC manager
│   ├── database/                    # Local database
│   │   └── database_service.dart    # SQLite service
│   ├── models/                      # Data models
│   │   ├── contact.dart
│   │   ├── conversation.dart
│   │   └── message.dart
│   ├── ui/                          # User interface
│   │   ├── auth_screen.dart         # Authentication
│   │   ├── chat_list_screen.dart    # Conversation list
│   │   ├── chat_screen.dart         # Chat interface
│   │   ├── settings_screen.dart     # Settings
│   │   └── add_contact_screen.dart  # Add contacts
│   ├── security/                    # Security features
│   │   └── biometric_auth.dart      # Biometric auth
│   ├── blockchain/                  # TON integration
│   │   └── ton_wallet.dart          # TON wallet
│   ├── llm/                         # AI features
│   │   └── local_llm.dart           # Local LLM
│   └── services/                    # App services
│       └── theme_provider.dart      # Theme management
├── assets/                          # Assets
│   └── logo.png                     # App logo
├── android/                         # Android config
├── ios/                             # iOS config
├── pubspec.yaml                     # Dependencies
└── README.md                        # This file
```

---

## 🔧 Development

### Running Tests

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage
```

### Code Quality

```bash
# Analyze code
flutter analyze

# Format code
flutter format lib/
```

### Debugging

```bash
# Run in debug mode
flutter run --debug

# Run with verbose logging
flutter run -v
```

---

## 🤝 Contributing

We welcome contributions from the community! Here's how you can help:

1. **Fork the repository**
2. **Create a feature branch**: `git checkout -b feature/amazing-feature`
3. **Commit your changes**: `git commit -m 'Add amazing feature'`
4. **Push to the branch**: `git push origin feature/amazing-feature`
5. **Open a Pull Request**

### Development Guidelines

- Follow the [Flutter Style Guide](https://github.com/flutter/flutter/wiki/Style-guide-for-Flutter-repo)
- Write tests for new features
- Update documentation
- Ensure all tests pass before submitting PR

---

## 🔐 Security Considerations

### For Users

- **Verify App Integrity**: Always download from official sources
- **Backup Your Keys**: Store encryption keys securely
- **Use Strong Biometrics**: Enable Face ID/Touch ID/Fingerprint
- **Update Regularly**: Keep app updated for security patches

### For Developers

- **Code Audits**: Security audits welcome
- **Report Vulnerabilities**: Please report security issues privately to security@digitalvalut.chat
- **No Backdoors**: This app contains no backdoors or surveillance features

---

## 📱 Platform Support

| Feature | Android | iOS |
|---------|---------|-----|
| End-to-End Encryption | ✅ | ✅ |
| P2P Messaging | ✅ | ✅ |
| Ephemeral Messages | ✅ | ✅ |
| Biometric Auth | ✅ | ✅ |
| Screenshot Blocking | ✅ | ✅ |
| TON Wallet | 🚧 | 🚧 |
| Local LLM | 🚧 | 🚧 |

✅ = Implemented | 🚧 = In Development

---

## 🐛 Troubleshooting

### Common Issues

**"Flutter command not found"**
- Add Flutter to your PATH
- Run `flutter doctor` to diagnose

**"Unable to connect device"**
- Enable USB Debugging (Android)
- Trust computer (iOS)
- Check cable connection

**"Build failed"**
- Run `flutter clean`
- Run `flutter pub get`
- Delete `build` folder
- Try again

**"Permission denied"**
- Grant required permissions in Settings
- Check AndroidManifest.xml (Android)
- Check Info.plist (iOS)

### Getting Help

- **Documentation**: https://digitalvalut.chat/docs
- **Issues**: https://github.com/digitalvalut/digitalvalut_chat/issues
- **Community**: https://discord.gg/digitalvalut
- **Email**: support@digitalvalut.chat

---

## 📄 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

```
MIT License

Copyright (c) 2025 DigitalValut

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

---

## 🙏 Acknowledgments

- **Flutter Team** for the amazing framework
- **Cryptography Community** for post-quantum algorithms
- **WebRTC Project** for P2P communication
- **TON Foundation** for blockchain integration
- **Open Source Community** for continuous support

---

## 🌍 Links

- **Website**: https://digitalvalut.chat
- **GitHub**: https://github.com/digitalvalut/digitalvalut_chat
- **Twitter**: https://twitter.com/digitalvalut
- **LinkedIn**: https://linkedin.com/company/digitalvalut
- **Documentation**: https://docs.digitalvalut.chat

---

## 📊 Roadmap

### Version 1.0 (Current)
- ✅ End-to-end encryption
- ✅ P2P messaging
- ✅ Ephemeral messages
- ✅ Biometric authentication
- ✅ Screenshot blocking

### Version 1.1 (Q2 2025)
- 🚧 TON blockchain wallet
- 🚧 Local LLM integration
- 🚧 Voice/Video calls
- 🚧 Group chats

### Version 2.0 (Q3 2025)
- 🚧 File sharing
- 🚧 Message reactions
- 🚧 Desktop apps
- 🚧 Multi-device sync

---

## 💬 Contact

For questions, suggestions, or support:

- **Email**: contact@digitalvalut.chat
- **Twitter**: @digitalvalut
- **Discord**: https://discord.gg/digitalvalut

---

**Made with ❤️ by the DigitalValut Team**

*Secure your conversations. Own your privacy. Trust no one.*
