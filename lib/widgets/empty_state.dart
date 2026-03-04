import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha:0.05)),
      ),
      child: Column(children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha:0.05),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            Icons.qr_code_2_rounded,
            size: 36,
            color: Colors.white.withValues(alpha:0.2),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Your QR code will appear here',
          style: TextStyle(
            color: Colors.white.withValues(alpha:0.25),
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Fill in the details above and tap generate',
          style: TextStyle(
            color: Colors.white.withValues(alpha:0.15),
            fontSize: 11,
          ),
        ),
      ]),
    );
  }
}