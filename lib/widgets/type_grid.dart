import 'package:flutter/material.dart';
import '../core/constant.dart';
import '../models/qr_type.dart';

class QRTypeGrid extends StatelessWidget {
  final QRType selected;
  final ValueChanged<QRType> onTap;

  const QRTypeGrid({
    super.key,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount:  3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1.5,
      ),
      itemCount: QRType.values.length,
      itemBuilder: (_, i) {
        final type  = QRType.values[i];
        final color = kTypeColors[type]!;
        final isSel = selected == type;
        return GestureDetector(
          onTap: () => onTap(type),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSel
                  ? color.withValues(alpha:0.15)
                  : const Color(0xFF1C1C1C),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSel ? color : Colors.white.withValues(alpha:0.06),
                width: isSel ? 1.5 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(kTypeIcons[type],
                    size: 20,
                    color: isSel
                        ? color
                        : Colors.white.withValues(alpha:0.35)),
                const SizedBox(height: 4),
                Text(
                  kTypeLabels[type]!,
                  style: TextStyle(
                    color: isSel
                        ? color
                        : Colors.white.withValues(alpha:0.35),
                    fontSize: 10,
                    fontWeight: isSel
                        ? FontWeight.w600
                        : FontWeight.w400,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}