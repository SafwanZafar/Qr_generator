import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/qr_history.dart';
import '../../models/qr_type.dart';
import '../../models/qr_config.dart';
import '../../services/history_service.dart';
import '../../services/qr_builder_service.dart';
import '../../widgets/result_page.dart';

class QRGeneratorPage extends StatefulWidget {
  final QRConfig initialConfig;
  final VoidCallback? onQRGenerated;

  const QRGeneratorPage({
    super.key,
    this.initialConfig = const QRConfig(),
    this.onQRGenerated,
  });

  @override
  State<QRGeneratorPage> createState() => _QRGeneratorPageState();
}

class _QRGeneratorPageState extends State<QRGeneratorPage> {
  final TextEditingController _f1 = TextEditingController();
  final TextEditingController _f2 = TextEditingController();
  final TextEditingController _f3 = TextEditingController();

  QRType _type = QRType.website;
  QRConfig _qrConfig = const QRConfig();

  static const _types = [
    _TypeItem(
        type: QRType.website,
        label: 'URL',
        icon: Icons.link_rounded,
        color: Color(0xFF4C4BE8),
        bg: Color(0xFFEEEEFD)),
    _TypeItem(
        type: QRType.text,
        label: 'Text',
        icon: Icons.text_fields_rounded,
        color: Color(0xFF25A244),
        bg: Color(0xFFEEF9F1)),
    _TypeItem(
        type: QRType.wifi,
        label: 'WiFi',
        icon: Icons.wifi_rounded,
        color: Color(0xFFE84C4C),
        bg: Color(0xFFFFEEEE)),
    _TypeItem(
        type: QRType.email,
        label: 'Email',
        icon: Icons.mail_outline_rounded,
        color: Color(0xFF9B4CE8),
        bg: Color(0xFFF5EEFF)),
    _TypeItem(
        type: QRType.phone,
        label: 'Phone',
        icon: Icons.phone_rounded,
        color: Color(0xFFFFB800),
        bg: Color(0xFFFFF8EE)),
    _TypeItem(
        type: QRType.contact,
        label: 'vCard',
        icon: Icons.person_rounded,
        color: Color(0xFFE84C9B),
        bg: Color(0xFFFFEEF7)),
    _TypeItem(
        type: QRType.whatsapp,
        label: 'WhatsApp',
        icon: Icons.chat_rounded,
        color: Color(0xFF25D366),
        bg: Color(0xFFEEFBF3)),
    _TypeItem(
        type: QRType.sms,
        label: 'SMS',
        icon: Icons.sms_rounded,
        color: Color(0xFFFF6B35),
        bg: Color(0xFFFFF0EB)),
    _TypeItem(
        type: QRType.location,
        label: 'Location',
        icon: Icons.location_on_rounded,
        color: Color(0xFF1ABC9C),
        bg: Color(0xFFEEFAF7)),
  ];

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _qrConfig = widget.initialConfig;
  }

  @override
  void didUpdateWidget(QRGeneratorPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialConfig != widget.initialConfig) {
      setState(() {
        _qrConfig = widget.initialConfig;
        _f1.clear();
        _f2.clear();
        _f3.clear();
      });
    }
  }

  @override
  void dispose() {
    _f1.dispose();
    _f2.dispose();
    _f3.dispose();
    super.dispose();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  _TypeItem get _currentType => _types.firstWhere((t) => t.type == _type);

  void _onTypeChanged(QRType type) {
    setState(() {
      _type = type;
      _f1.clear();
      _f2.clear();
      _f3.clear();
    });
  }

  String _buildLabel() {
    switch (_type) {
      case QRType.website:
        return 'My Website';
      case QRType.wifi:
        return
            'WiFi Network';
      case QRType.contact:
        return  'Contact Card';
      case QRType.whatsapp:
        return  'WhatsApp';
      case QRType.email:
        return  'My Email';
      case QRType.phone:
        return 'My Phone';
      case QRType.sms:
        return  'My SMS';
      case QRType.location:
        return 'My Location';
      case QRType.text:
        final t = _f1.text.trim();
        return t.length > 20 ? '${t.substring(0, 20)}...' : t;
    }
  }
  String _typeLabel(QRType type) {
    switch (type) {
      case QRType.website:
        return 'Website';
      case QRType.whatsapp:
        return 'WhatsApp';
      case QRType.phone:
        return 'Phone';
      case QRType.sms:
        return 'SMS';
      case QRType.email:
        return 'Email';
      case QRType.wifi:
        return 'WiFi';
      case QRType.location:
        return 'Location';
      case QRType.contact:
        return 'Contact';
      case QRType.text:
        return 'Text';
    }
  }

  // ── Generate ───────────────────────────────────────────────────────────────

  Future<void> _generate() async {
    final err = QRBuilderService.validate(
      type: _type,
      f1: _f1.text.trim(),
      f2: _f2.text.trim(),
    );
    if (err != null) {
      _snack(err, error: true);
      return;
    }

    final data = QRBuilderService.build(
      type: _type,
      f1: _f1.text.trim(),
      f2: _f2.text.trim(),
      f3: _f3.text.trim(),
    );

    // save to history
    await HistoryService.save(QRHistory(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: _typeLabel(_type),
      data: data,
      label: _buildLabel(),
      createdAt: DateTime.now(),
    ));

    widget.onQRGenerated?.call();

    // navigate to result screen
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultPage(
            qrData: data,
            color: _currentType.color,
            icon: _currentType.icon,
            label: _currentType.label,
            config: _qrConfig,
            onConfigChanged: (c) => setState(() => _qrConfig = c),
          ),
        ),
      );
    }
  }

  // ── Snack ──────────────────────────────────────────────────────────────────

  void _snack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        Icon(
          error ? Icons.error_outline : Icons.check_circle_outline,
          color: Colors.white,
          size: 18,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(msg, style: const TextStyle(fontSize: 14)),
        ),
      ]),
      backgroundColor: error ? AppTheme.kErrorColor : AppTheme.kSuccessColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    ));
  }

  // ── Input fields ───────────────────────────────────────────────────────────

  Widget _field(
    TextEditingController c,
    String hint,
    IconData icon, {
    TextInputType kb = TextInputType.text,
    bool obscure = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.kCardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.kBorderColor),
      ),
      child: TextField(
        controller: c,
        keyboardType: kb,
        obscureText: obscure,
        style: const TextStyle(
          color: AppTheme.kTextDark,
          fontSize: 15,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: AppTheme.kTextGray.withValues(alpha: 0.7),
            fontSize: 14,
          ),
          prefixIcon: Icon(icon, color: _currentType.color, size: 18),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildFields() {
    switch (_type) {
      case QRType.website:
        return _field(_f1, 'https://www.example.com', Icons.link_rounded,
            kb: TextInputType.url);

      case QRType.text:
        return _field(_f1, 'Type your text here...', Icons.notes_rounded);

      case QRType.wifi:
        return Column(children: [
          _field(_f1, 'Network name (SSID)', Icons.wifi_rounded),
          const SizedBox(height: 10),
          _field(_f2, 'Password', Icons.lock_outline_rounded, obscure: true),
          const SizedBox(height: 10),
          _field(_f3, 'Security (WPA / WEP / nopass)', Icons.security_rounded),
        ]);

      case QRType.email:
        return Column(children: [
          _field(_f1, 'Email address', Icons.mail_outline_rounded,
              kb: TextInputType.emailAddress),
          const SizedBox(height: 10),
          _field(_f2, 'Subject (optional)', Icons.title_rounded),
          const SizedBox(height: 10),
          _field(_f3, 'Message (optional)', Icons.edit_outlined),
        ]);

      case QRType.phone:
        return _field(_f1, '+923001234567', Icons.phone_rounded,
            kb: TextInputType.phone);

      case QRType.contact:
        return Column(children: [
          _field(_f1, 'Full name', Icons.person_outline_rounded),
          const SizedBox(height: 10),
          _field(_f2, 'Phone number', Icons.phone_outlined,
              kb: TextInputType.phone),
          const SizedBox(height: 10),
          _field(_f3, 'Email (optional)', Icons.mail_outline_rounded,
              kb: TextInputType.emailAddress),
        ]);

      case QRType.whatsapp:
        return Column(children: [
          _field(_f1, 'Number e.g. 923001234567', Icons.phone_rounded,
              kb: TextInputType.phone),
          const SizedBox(height: 10),
          _field(_f2, 'Pre-filled message (optional)',
              Icons.chat_bubble_outline_rounded),
        ]);

      case QRType.sms:
        return Column(children: [
          _field(_f1, 'Phone number', Icons.phone_rounded,
              kb: TextInputType.phone),
          const SizedBox(height: 10),
          _field(_f2, 'Message (optional)', Icons.sms_outlined),
        ]);

      case QRType.location:
        return Column(children: [
          _field(_f1, 'Latitude e.g. 31.5204', Icons.explore_rounded,
              kb: TextInputType.number),
          const SizedBox(height: 10),
          _field(_f2, 'Longitude e.g. 74.3587', Icons.explore_outlined,
              kb: TextInputType.number),
        ]);
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final t = _currentType;

    return Scaffold(
      backgroundColor: AppTheme.kBgColor,
      appBar: AppBar(
        backgroundColor: AppTheme.kBgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.maybePop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.kCardColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.kBorderColor),
            ),
            child: const Icon(Icons.arrow_back_rounded,
                color: AppTheme.kTextDark, size: 20),
          ),
        ),
        title: const Text('Create QR Code',
            style: TextStyle(
              color: AppTheme.kTextDark,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            )),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select QR code type',
                style: TextStyle(
                  color: AppTheme.kTextGray,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                )),
            const SizedBox(height: 12),

            // Type grid
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.0,
              children: _types.map((item) {
                final selected = _type == item.type;
                return GestureDetector(
                  onTap: () => _onTypeChanged(item.type),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: AppTheme.kCardColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: selected ? item.color : AppTheme.kBorderColor,
                        width: selected ? 2 : 1,
                      ),
                      boxShadow: selected
                          ? [
                              BoxShadow(
                                color: item.color.withValues(alpha: 0.15),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              )
                            ]
                          : [],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: item.bg,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(item.icon, color: item.color, size: 22),
                        ),
                        const SizedBox(height: 8),
                        Text(item.label,
                            style: TextStyle(
                              color: selected ? item.color : AppTheme.kTextDark,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            )),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            Text('Enter ${t.label}',
                style: const TextStyle(
                  color: AppTheme.kTextDark,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                )),
            const SizedBox(height: 10),

            _buildFields(),

            const SizedBox(height: 20),

            // Continue button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _generate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B5BDB),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text('Continue',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Type item model ────────────────────────────────────────────────────────────

class _TypeItem {
  final QRType type;
  final String label;
  final IconData icon;
  final Color color;
  final Color bg;

  const _TypeItem({
    required this.type,
    required this.label,
    required this.icon,
    required this.color,
    required this.bg,
  });
}
