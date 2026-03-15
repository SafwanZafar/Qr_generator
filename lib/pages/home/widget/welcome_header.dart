import 'package:flutter/material.dart';
import '../../../core/theme.dart';

class WelcomeHeader extends StatelessWidget {
  const WelcomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Text(
                'Welcome back ',
                style: TextStyle(
                  color:      AppTheme.kTextGray,
                  fontSize:   14,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const Text('👋', style: TextStyle(fontSize: 14)),
            ]),
            const SizedBox(height: 2),
            RichText(
              text: const TextSpan(
                children: [
                  TextSpan(
                    text:  'QR',
                    style: TextStyle(
                      color:      AppTheme.kPrimary,
                      fontSize:   26,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  TextSpan(
                    text:  'Craft',
                    style: TextStyle(
                      color:      AppTheme.kTextDark,
                      fontSize:   26,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}