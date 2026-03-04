import 'package:flutter/material.dart';

class ActionButton extends StatelessWidget {
  final String       label;
  final IconData     icon;
  final Color        color;
  final bool         filled;
  final bool         loading;
  final VoidCallback onTap;

  const ActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.filled,
    required this.loading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: filled ? color : const Color(0xFF252525),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            loading
                ? SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: filled ? Colors.white : color,
              ),
            )
                : Icon(icon,
                color: filled ? Colors.white : color,
                size: 18),
            const SizedBox(width: 7),
            Text(
              label,
              style: TextStyle(
                color: filled ? Colors.white : color,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}