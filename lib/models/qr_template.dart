import 'package:flutter/material.dart';

class QRTemplate {
  final String id;
  final String name;
  final String category;
  final Color  foreground;
  final Color  background;
  final Color  cardColor;

  const QRTemplate({
    required this.id,
    required this.name,
    required this.category,
    required this.foreground,
    required this.background,
    required this.cardColor,
  });
}

const kTemplates = [
  // Business
  QRTemplate(id: '1',  name: 'Ocean Blue',    category: 'Business', foreground: Color(0xFFFFFFFF), background: Color(0xFF1A6BB5), cardColor: Color(0xFF1A6BB5)),
  QRTemplate(id: '2',  name: 'Midnight',      category: 'Business', foreground: Color(0xFFFFFFFF), background: Color(0xFF1A1A2E), cardColor: Color(0xFF1A1A2E)),
  QRTemplate(id: '3',  name: 'Corporate',     category: 'Business', foreground: Color(0xFF1A1A2E), background: Color(0xFFF0F4FF), cardColor: Color(0xFF3B5BDB)),
  QRTemplate(id: '4',  name: 'Steel',         category: 'Business', foreground: Color(0xFFFFFFFF), background: Color(0xFF455A64), cardColor: Color(0xFF455A64)),

  // Social
  QRTemplate(id: '5',  name: 'WhatsApp',      category: 'Social',   foreground: Color(0xFFFFFFFF), background: Color(0xFF25D366), cardColor: Color(0xFF25D366)),
  QRTemplate(id: '6',  name: 'Instagram',     category: 'Social',   foreground: Color(0xFFFFFFFF), background: Color(0xFFE1306C), cardColor: Color(0xFFE1306C)),
  QRTemplate(id: '7',  name: 'Twitter',       category: 'Social',   foreground: Color(0xFFFFFFFF), background: Color(0xFF1DA1F2), cardColor: Color(0xFF1DA1F2)),
  QRTemplate(id: '8',  name: 'LinkedIn',      category: 'Social',   foreground: Color(0xFFFFFFFF), background: Color(0xFF0077B5), cardColor: Color(0xFF0077B5)),

  // WiFi
  QRTemplate(id: '9',  name: 'Nature Green',  category: 'WiFi',     foreground: Color(0xFFFFFFFF), background: Color(0xFF2ECC71), cardColor: Color(0xFF2ECC71)),
  QRTemplate(id: '10', name: 'Purple Wave',   category: 'WiFi',     foreground: Color(0xFFFFFFFF), background: Color(0xFF9B59B6), cardColor: Color(0xFF9B59B6)),
  QRTemplate(id: '11', name: 'Sky',           category: 'WiFi',     foreground: Color(0xFF1A6BB5), background: Color(0xFFE8F4FD), cardColor: Color(0xFF5DADE2)),
  QRTemplate(id: '12', name: 'Mint',          category: 'WiFi',     foreground: Color(0xFF1E8449), background: Color(0xFFEAF9F1), cardColor: Color(0xFF1ABC9C)),

  // Personal
  QRTemplate(id: '13', name: 'Sunset',        category: 'Personal', foreground: Color(0xFFFFFFFF), background: Color(0xFFE74C3C), cardColor: Color(0xFFE74C3C)),
  QRTemplate(id: '14', name: 'Gold',          category: 'Personal', foreground: Color(0xFF7D6608), background: Color(0xFFFEF9E7), cardColor: Color(0xFFF1C40F)),
  QRTemplate(id: '15', name: 'Rose',          category: 'Personal', foreground: Color(0xFFFFFFFF), background: Color(0xFFE84C9B), cardColor: Color(0xFFE84C9B)),
  QRTemplate(id: '16', name: 'Coral',         category: 'Personal', foreground: Color(0xFFFFFFFF), background: Color(0xFFFF6B35), cardColor: Color(0xFFFF6B35)),

  // Dark
  QRTemplate(id: '17', name: 'Dark Classic',  category: 'Dark',     foreground: Color(0xFFFFFFFF), background: Color(0xFF000000), cardColor: Color(0xFF212121)),
  QRTemplate(id: '18', name: 'Dark Purple',   category: 'Dark',     foreground: Color(0xFFCE93D8), background: Color(0xFF1A0A2E), cardColor: Color(0xFF4A148C)),
  QRTemplate(id: '19', name: 'Dark Gold',     category: 'Dark',     foreground: Color(0xFFFFD700), background: Color(0xFF1A1200), cardColor: Color(0xFF795548)),
  QRTemplate(id: '20', name: 'Dark Teal',     category: 'Dark',     foreground: Color(0xFF80CBC4), background: Color(0xFF0A1628), cardColor: Color(0xFF00695C)),

  // Minimal
  QRTemplate(id: '21', name: 'Classic White', category: 'Minimal',  foreground: Color(0xFF000000), background: Color(0xFFFFFFFF), cardColor: Color(0xFFE0E0E0)),
  QRTemplate(id: '22', name: 'Soft Gray',     category: 'Minimal',  foreground: Color(0xFF424242), background: Color(0xFFF5F5F5), cardColor: Color(0xFF9E9E9E)),
  QRTemplate(id: '23', name: 'Navy',          category: 'Minimal',  foreground: Color(0xFFFFFFFF), background: Color(0xFF1A237E), cardColor: Color(0xFF1A237E)),
  QRTemplate(id: '24', name: 'Forest',        category: 'Minimal',  foreground: Color(0xFFFFFFFF), background: Color(0xFF1B5E20), cardColor: Color(0xFF2E7D32)),

  // Holiday
  QRTemplate(id: '25', name: 'Christmas',     category: 'Holiday',  foreground: Color(0xFFFFFFFF), background: Color(0xFFC0392B), cardColor: Color(0xFF27AE60)),
  QRTemplate(id: '26', name: 'Halloween',     category: 'Holiday',  foreground: Color(0xFFFF6D00), background: Color(0xFF1A1A1A), cardColor: Color(0xFFE65100)),
  QRTemplate(id: '27', name: 'Valentine',     category: 'Holiday',  foreground: Color(0xFFFFFFFF), background: Color(0xFFAD1457), cardColor: Color(0xFFAD1457)),
  QRTemplate(id: '28', name: 'New Year',      category: 'Holiday',  foreground: Color(0xFFFFD700), background: Color(0xFF0D0D0D), cardColor: Color(0xFF4A148C)),
];