import 'package:flutter/material.dart';

class QRInputField extends StatelessWidget {
  final TextEditingController controller;
  final String     hint;
  final IconData   icon;
  final Color      accentColor;
  final TextInputType keyboard;
  final bool       obscure;

  const QRInputField({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    required this.accentColor,
    this.keyboard = TextInputType.text,
    this.obscure  = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        keyboardType: keyboard,
        obscureText: obscure,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.white.withValues(alpha:0.25),
            fontSize: 13,
          ),
          filled: true,
          fillColor: const Color(0xFF1C1C1C),
          prefixIcon: Icon(icon, color: accentColor, size: 18),
          border: _border(),
          enabledBorder: _border(),
          focusedBorder: _border(color: accentColor, width: 1.5),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 13,
          ),
        ),
      ),
    );
  }

  OutlineInputBorder _border({Color? color, double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(
        color: color ?? Colors.white.withValues(alpha:0.06),
        width: width,
      ),
    );
  }
}