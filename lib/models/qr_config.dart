import 'package:flutter/material.dart';

class QRConfig {
  final Color   foregroundColor;
  final Color   backgroundColor;
  final String? logoPath;
  final double  logoSize;

  const QRConfig({
    this.foregroundColor = Colors.black,
    this.backgroundColor = Colors.white,
    this.logoPath,
    this.logoSize = 0.2,
  });

  QRConfig copyWith({
    Color?   foregroundColor,
    Color?   backgroundColor,
    String?  logoPath,
    double?  logoSize,
    bool     clearLogo = false,
  }) {
    return QRConfig(
      foregroundColor: foregroundColor ?? this.foregroundColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      logoPath:        clearLogo ? null : (logoPath ?? this.logoPath),
      logoSize:        logoSize ?? this.logoSize,
    );
  }
}