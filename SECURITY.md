
# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | :white_check_mark: |

## Reporting a Vulnerability

**Please do NOT report security vulnerabilities through public GitHub issues.**

Instead, please report them via email to: **security@digitalvalut.chat**

You should receive a response within 48 hours. If for some reason you do not, please follow up via email to ensure we received your original message.

### What to Include

Please include the following information:
- Type of vulnerability
- Full paths of source file(s) related to the vulnerability
- Location of the affected source code (tag/branch/commit)
- Step-by-step instructions to reproduce the issue
- Proof-of-concept or exploit code (if possible)
- Impact of the issue

### Our Commitment

- We will acknowledge receipt of your vulnerability report
- We will confirm the problem and determine affected versions
- We will audit code to find similar problems
- We will prepare fixes and release them as fast as possible

## Security Features

DigitalValut Chat implements multiple layers of security:

### Encryption
- **End-to-End Encryption**: X25519 key exchange + AES-256-GCM
- **Forward Secrecy**: Unique keys per session
- **Quantum Resistance**: Post-quantum cryptography ready

### Data Protection
- **Encrypted Database**: AES-256 encrypted SQLite
- **Secure Key Storage**: Biometric-protected keychain
- **Ephemeral Messages**: Automatic secure deletion

### App Security
- **Screenshot Blocking**: Prevents screen capture
- **Biometric Authentication**: Face ID / Touch ID / Fingerprint
- **No Backdoors**: Open source, fully auditable

### Network Security
- **P2P Communication**: No central server
- **WebRTC DTLS**: Transport layer encryption
- **NAT Traversal**: STUN/TURN for secure connections

## Security Audits

We welcome security audits from the community. If you'd like to conduct a formal security audit, please contact us at security@digitalvalut.chat

## Disclosure Policy

- Report received and acknowledged: Within 48 hours
- Issue confirmed and investigation started: Within 1 week
- Fix developed and tested: Within 2-4 weeks
- Public disclosure: After fix is released

Thank you for helping keep DigitalValut Chat secure! 🔐
