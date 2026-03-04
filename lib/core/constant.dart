import 'package:flutter/material.dart';
import '../models/qr_type.dart';

const Map<QRType, Color> kTypeColors = {
  QRType.website:  Color(0xFF4C9BE8),
  QRType.whatsapp: Color(0xFF25D366),
  QRType.phone:    Color(0xFFFF6B35),
  QRType.sms:      Color(0xFFFFB800),
  QRType.email:    Color(0xFFE85D75),
  QRType.wifi:     Color(0xFF9B59B6),
  QRType.location: Color(0xFF1ABC9C),
  QRType.contact:  Color(0xFFFF8C42),
  QRType.text:     Color(0xFF95A5A6),
};

const Map<QRType, IconData> kTypeIcons = {
  QRType.website:  Icons.language_rounded,
  QRType.whatsapp: Icons.chat_bubble_rounded,
  QRType.phone:    Icons.call_rounded,
  QRType.sms:      Icons.sms_rounded,
  QRType.email:    Icons.mail_rounded,
  QRType.wifi:     Icons.wifi_rounded,
  QRType.location: Icons.location_on_rounded,
  QRType.contact:  Icons.person_rounded,
  QRType.text:     Icons.notes_rounded,
};

const Map<QRType, String> kTypeLabels = {
  QRType.website:  'Website',
  QRType.whatsapp: 'WhatsApp',
  QRType.phone:    'Phone',
  QRType.sms:      'SMS',
  QRType.email:    'Email',
  QRType.wifi:     'WiFi',
  QRType.location: 'Location',
  QRType.contact:  'Contact',
  QRType.text:     'Text',
};

// App colors
const kBgColor      = Color(0xFF141414);
const kCardColor    = Color(0xFF1C1C1C);
const kBtnColor     = Color(0xFF252525);
const kSuccessColor = Color(0xFF25D366);
const kErrorColor   = Color(0xFFE85D75);