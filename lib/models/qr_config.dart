import 'dart:ui';
import 'package:flutter/material.dart';

enum QRStyle { square, rounded, dots, classy }

class QRConfig {
  final Color    foregroundColor;
  final Color    backgroundColor;
  final String?  logoPath;
  final double   logoSize;
  final QRStyle  style;

  const QRConfig({
    this.foregroundColor = const Color(0xFF000000),
    this.backgroundColor = const Color(0xFFFFFFFF),
    this.logoPath,
    this.logoSize = 0.2,
    this.style    = QRStyle.square,
  });

  QRConfig copyWith({
    Color?   foregroundColor,
    Color?   backgroundColor,
    String?  logoPath,
    double?  logoSize,
    QRStyle? style,
    bool     clearLogo = false,
  }) =>
      QRConfig(
        foregroundColor: foregroundColor ?? this.foregroundColor,
        backgroundColor: backgroundColor ?? this.backgroundColor,
        logoPath:        clearLogo ? null : (logoPath ?? this.logoPath),
        logoSize:        logoSize        ?? this.logoSize,
        style:           style           ?? this.style,
      );
}