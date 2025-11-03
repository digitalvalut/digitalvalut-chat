
import 'package:flutter/material.dart';

/// Dialog for incoming call notification
class IncomingCallDialog extends StatelessWidget {
  final String callerName;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  
  const IncomingCallDialog({
    super.key,
    required this.callerName,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Avatar
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).primaryColor.withOpacity(0.2),
              ),
              child: Center(
                child: Text(
                  callerName[0].toUpperCase(),
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Caller name
            Text(
              callerName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Call type
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.call, size: 16),
                const SizedBox(width: 4),
                const Text('Voice Call'),
                const SizedBox(width: 8),
                Icon(Icons.lock, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Encrypted',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Reject button
                Column(
                  children: [
                    Material(
                      color: Colors.red,
                      shape: const CircleBorder(),
                      child: InkWell(
                        onTap: onReject,
                        customBorder: const CircleBorder(),
                        child: Container(
                          width: 60,
                          height: 60,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.call_end,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Decline',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                
                // Accept button
                Column(
                  children: [
                    Material(
                      color: Colors.green,
                      shape: const CircleBorder(),
                      child: InkWell(
                        onTap: onAccept,
                        customBorder: const CircleBorder(),
                        child: Container(
                          width: 60,
                          height: 60,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.call,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Accept',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

