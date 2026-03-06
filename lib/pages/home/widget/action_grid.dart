import 'package:flutter/material.dart';
import '../../../core/theme.dart';

class ActionGrid extends StatelessWidget {
  final VoidCallback onGenerate;
  final VoidCallback onScan;
  final VoidCallback onTemplates;
  final VoidCallback onMyCodes;

  const ActionGrid({
    super.key,
    required this.onGenerate,
    required this.onScan,
    required this.onTemplates,
    required this.onMyCodes,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(children: [
          Expanded(child: _ActionCard(
            icon:       Icons.qr_code_2_rounded,
            iconColor:  const Color(0xFFE84C4C),
            iconBg:     const Color(0xFFFFEEEE),
            title:      'Generate',
            subtitle:   'Create new',
            onTap:      onGenerate,
          )),
          const SizedBox(width: 12),
          Expanded(child: _ActionCard(
            icon:       Icons.qr_code_scanner_rounded,
            iconColor:  const Color(0xFF25A244),
            iconBg:     const Color(0xFFEEF9F1),
            title:      'Scan QR',
            subtitle:   'Camera scan',
            onTap:      onScan,
          )),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _ActionCard(
            icon:       Icons.dashboard_rounded,
            iconColor:  const Color(0xFF4C9BE8),
            iconBg:     const Color(0xFFEEF4FF),
            title:      'Templates',
            subtitle:   '50+ designs',
            onTap:      onTemplates,
          )),
          const SizedBox(width: 12),
          Expanded(child: _ActionCard(
            icon:       Icons.bookmark_rounded,
            iconColor:  const Color(0xFFFFB800),
            iconBg:     const Color(0xFFFFF8EE),
            title:      'My Codes',
            subtitle:   'Saved codes',
            onTap:      onMyCodes,
          )),
        ]),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData   icon;
  final Color      iconColor;
  final Color      iconBg;
  final String     title;
  final String     subtitle;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppTheme.kCardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(height: 14),
            Text(title,
                style: const TextStyle(
                  color: AppTheme.kTextDark,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                )),
            const SizedBox(height: 3),
            Text(subtitle,
                style: const TextStyle(
                  color: AppTheme.kTextGray,
                  fontSize: 12,
                )),
          ],
        ),
      ),
    );
  }
}