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
                  color: AppTheme.kTextGray,
                  fontSize: 14,
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
                    text: 'QR',
                    style: TextStyle(
                      color: AppTheme.kPrimary,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  TextSpan(
                    text: 'Craft',
                    style: TextStyle(
                      color: AppTheme.kTextDark,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        // Action icons
        Row(children: [
          _IconBtn(
            icon: Icons.search_rounded,
            onTap: () {},
          ),
          const SizedBox(width: 8),
          _IconBtn(
            icon: Icons.notifications_rounded,
            onTap: () {},
            badge: true,
          ),
        ]),
      ],
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool badge;

  const _IconBtn({
    required this.icon,
    required this.onTap,
    this.badge = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppTheme.kCardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon,
                color: AppTheme.kTextDark, size: 20),
          ),
          if (badge)
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFFE85D75),
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}