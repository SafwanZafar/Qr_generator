import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../models/qr_type.dart';
import '../../models/qr_config.dart';
import '../../providers/generator_provider.dart';
import '../../widgets/result_page.dart';

class QRGeneratorPage extends StatefulWidget {
  final QRConfig      initialConfig;
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
  final TextEditingController _title = TextEditingController(); // ← title field
  final TextEditingController _f1    = TextEditingController();
  final TextEditingController _f2    = TextEditingController();
  final TextEditingController _f3    = TextEditingController();

  static const _types = [
    _TypeItem(type: QRType.website,  label: 'URL',      icon: Icons.link_rounded,          color: Color(0xFF4C4BE8), bg: Color(0xFFEEEEFD)),
    _TypeItem(type: QRType.text,     label: 'Text',     icon: Icons.text_fields_rounded,   color: Color(0xFF25A244), bg: Color(0xFFEEF9F1)),
    _TypeItem(type: QRType.wifi,     label: 'WiFi',     icon: Icons.wifi_rounded,          color: Color(0xFFE84C4C), bg: Color(0xFFFFEEEE)),
    _TypeItem(type: QRType.email,    label: 'Email',    icon: Icons.mail_outline_rounded,  color: Color(0xFF9B4CE8), bg: Color(0xFFF5EEFF)),
    _TypeItem(type: QRType.phone,    label: 'Phone',    icon: Icons.phone_rounded,         color: Color(0xFFFFB800), bg: Color(0xFFFFF8EE)),
    _TypeItem(type: QRType.contact,  label: 'vCard',    icon: Icons.person_rounded,        color: Color(0xFFE84C9B), bg: Color(0xFFFFEEF7)),
    _TypeItem(type: QRType.whatsapp, label: 'WhatsApp', icon: Icons.chat_rounded,          color: Color(0xFF25D366), bg: Color(0xFFEEFBF3)),
    _TypeItem(type: QRType.sms,      label: 'SMS',      icon: Icons.sms_rounded,           color: Color(0xFFFF6B35), bg: Color(0xFFFFF0EB)),
    _TypeItem(type: QRType.location, label: 'Location', icon: Icons.location_on_rounded,   color: Color(0xFF1ABC9C), bg: Color(0xFFEEFAF7)),
  ];

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GeneratorProvider>()
          .applyTemplate(widget.initialConfig);
    });
  }

  @override
  void didUpdateWidget(QRGeneratorPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialConfig != widget.initialConfig) {
      _title.clear();
      _f1.clear();
      _f2.clear();
      _f3.clear();
      context.read<GeneratorProvider>()
          .applyTemplate(widget.initialConfig);
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _f1.dispose();
    _f2.dispose();
    _f3.dispose();
    super.dispose();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  _TypeItem _typeItem(QRType type) =>
      _types.firstWhere((t) => t.type == type);

  void _onTypeChanged(QRType type) {
    _title.clear();
    _f1.clear();
    _f2.clear();
    _f3.clear();
    context.read<GeneratorProvider>().changeType(type);
  }

  // title hint per type
  String _titleHint(QRType type) {
    switch (type) {
      case QRType.website:  return 'Title e.g. My Website';
      case QRType.wifi:     return 'Network name (SSID)';
      case QRType.whatsapp: return 'Contact name e.g. Ali';
      case QRType.phone:    return 'Contact name e.g. Ali';
      case QRType.email:    return 'Email name e.g. Work Email';
      case QRType.contact:  return 'Full name';
      default:              return 'Title (optional)';
    }
  }

  // build label from title or fallback
  String _buildLabel(QRType type) {
    final t = _title.text.trim();
    if (t.isNotEmpty) return t;
    switch (type) {
      case QRType.website:  return 'My Website';
      case QRType.wifi:     return 'WiFi Network';
      case QRType.whatsapp: return 'WhatsApp';
      case QRType.phone:    return 'My Phone';
      case QRType.email:    return 'My Email';
      case QRType.contact:  return _f1.text.trim().isNotEmpty
          ? _f1.text.trim() : 'My Contact';
      case QRType.sms:      return 'My SMS';
      case QRType.location: return 'My Location';
      case QRType.text:     return _f1.text.trim().length > 20
          ? '${_f1.text.trim().substring(0, 20)}...'
          : _f1.text.trim();
    }
  }

  // ── Generate ───────────────────────────────────────────────────────────────

  Future<void> _generate() async {
    final provider  = context.read<GeneratorProvider>();
    final item      = _typeItem(provider.type);
    final historyId = DateTime.now().millisecondsSinceEpoch.toString();

    final success = await provider.generate(
      f1:        _f1.text.trim(),
      f2:        _f2.text.trim(),
      f3:        _f3.text.trim(),
      historyId: historyId,
      label:     _buildLabel(provider.type),
    );

    if (!success) {
      if (mounted) {
        _snack(provider.error ?? 'Validation error', error: true);
      }
      return;
    }

    // ── Clear all fields after generate ──────────────────────
    _title.clear();
    _f1.clear();
    _f2.clear();
    _f3.clear();

    widget.onQRGenerated?.call();

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultPage(
            qrData:          provider.qrData,
            color:           item.color,
            icon:            item.icon,
            label:           item.label,
            config:          provider.config,
            onConfigChanged: (c) =>
                context.read<GeneratorProvider>().updateConfig(c),
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
          size:  18,
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(msg,
            style: const TextStyle(fontSize: 14))),
      ]),
      backgroundColor: error
          ? AppTheme.kErrorColor
          : AppTheme.kSuccessColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10)),
      margin:   const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    ));
  }

  // ── Input fields ───────────────────────────────────────────────────────────

  Widget _field(
      TextEditingController c,
      String hint,
      IconData icon,
      Color typeColor, {
        TextInputType kb = TextInputType.text,
        bool obscure     = false,
      }) {
    return Container(
      decoration: BoxDecoration(
        color:        AppTheme.kCardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.kBorderColor),
      ),
      child: TextField(
        controller:   c,
        keyboardType: kb,
        obscureText:  obscure,
        style: const TextStyle(
          color:    AppTheme.kTextDark,
          fontSize: 15,
        ),
        decoration: InputDecoration(
          hintText:  hint,
          hintStyle: TextStyle(
            color:    AppTheme.kTextGray.withValues(alpha: 0.7),
            fontSize: 14,
          ),
          prefixIcon: Icon(icon, color: typeColor, size: 18),
          border:         InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  // title field with label badge
  Widget _titleField(QRType type, Color typeColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          const Text('Name / Title',
              style: TextStyle(
                color:      AppTheme.kTextDark,
                fontSize:   15,
                fontWeight: FontWeight.w700,
              )),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color:        typeColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text('optional',
                style: TextStyle(
                  color:    typeColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                )),
          ),
        ]),
        const SizedBox(height: 8),
        _field(_title, _titleHint(type),
            Icons.label_outline_rounded, typeColor),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildFields(QRType type, Color typeColor) {
    // types that have title field
    final hasTitle = [
      QRType.website,
      QRType.wifi,
      QRType.whatsapp,
      QRType.phone,
      QRType.email,
      QRType.contact,
    ].contains(type);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // ── Title field for supported types ───────────────────
        if (hasTitle) _titleField(type, typeColor),

        // ── Type label ─────────────────────────────────────────
        Text(
          type == QRType.website  ? 'Website URL' :
          type == QRType.wifi     ? 'WiFi Details' :
          type == QRType.whatsapp ? 'WhatsApp Number' :
          type == QRType.phone    ? 'Phone Number' :
          type == QRType.email    ? 'Email Details' :
          type == QRType.contact  ? 'Contact Details' :
          'Details',
          style: const TextStyle(
            color:      AppTheme.kTextDark,
            fontSize:   15,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),

        // ── Fields per type ────────────────────────────────────
        _fieldsForType(type, typeColor),
      ],
    );
  }

  Widget _fieldsForType(QRType type, Color typeColor) {
    switch (type) {
      case QRType.website:
        return _field(_f1, 'https://www.example.com',
            Icons.link_rounded, typeColor, kb: TextInputType.url);

      case QRType.text:
        return _field(_f1, 'Type your text here...',
            Icons.notes_rounded, typeColor);

      case QRType.wifi:
        return Column(children: [
          _field(_f2, 'Password',
              Icons.lock_outline_rounded, typeColor, obscure: true),
          const SizedBox(height: 10),
          _field(_f3, 'Security (WPA / WEP / nopass)',
              Icons.security_rounded, typeColor),
        ]);

      case QRType.email:
        return Column(children: [
          _field(_f1, 'Email address',
              Icons.mail_outline_rounded, typeColor,
              kb: TextInputType.emailAddress),
          const SizedBox(height: 10),
          _field(_f2, 'Subject (optional)',
              Icons.title_rounded, typeColor),
          const SizedBox(height: 10),
          _field(_f3, 'Message (optional)',
              Icons.edit_outlined, typeColor),
        ]);

      case QRType.phone:
        return _field(_f1, '+923001234567',
            Icons.phone_rounded, typeColor, kb: TextInputType.phone);

      case QRType.contact:
        return Column(children: [
          _field(_f2, 'Phone number',
              Icons.phone_outlined, typeColor,
              kb: TextInputType.phone),
          const SizedBox(height: 10),
          _field(_f3, 'Email (optional)',
              Icons.mail_outline_rounded, typeColor,
              kb: TextInputType.emailAddress),
        ]);

      case QRType.whatsapp:
        return Column(children: [
          _field(_f1, 'Number e.g. 923001234567',
              Icons.phone_rounded, typeColor,
              kb: TextInputType.phone),
          const SizedBox(height: 10),
          _field(_f2, 'Pre-filled message (optional)',
              Icons.chat_bubble_outline_rounded, typeColor),
        ]);

      case QRType.sms:
        return Column(children: [
          _field(_f1, 'Phone number',
              Icons.phone_rounded, typeColor,
              kb: TextInputType.phone),
          const SizedBox(height: 10),
          _field(_f2, 'Message (optional)',
              Icons.sms_outlined, typeColor),
        ]);

      case QRType.location:
        return Column(children: [
          _field(_f1, 'Latitude e.g. 31.5204',
              Icons.explore_rounded, typeColor,
              kb: TextInputType.number),
          const SizedBox(height: 10),
          _field(_f2, 'Longitude e.g. 74.3587',
              Icons.explore_outlined, typeColor,
              kb: TextInputType.number),
        ]);
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final type   = context.select<GeneratorProvider, QRType>(
            (p) => p.type);
    final status = context.select<GeneratorProvider, GeneratorStatus>(
            (p) => p.status);
    final item   = _typeItem(type);

    return Scaffold(
      backgroundColor: AppTheme.kBgColor,
      appBar: AppBar(
        backgroundColor:        AppTheme.kBgColor,
        elevation:              0,
        scrolledUnderElevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.maybePop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color:        AppTheme.kCardColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.kBorderColor),
            ),
            child: const Icon(Icons.arrow_back_rounded,
                color: AppTheme.kTextDark, size: 20),
          ),
        ),
        title: const Text('Create QR Code',
            style: TextStyle(
              color:      AppTheme.kTextDark,
              fontSize:   18,
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
                  color:      AppTheme.kTextGray,
                  fontSize:   13,
                  fontWeight: FontWeight.w500,
                )),
            const SizedBox(height: 12),

            // ── Type grid ──────────────────────────────────────────
            GridView.count(
              crossAxisCount:   3,
              shrinkWrap:       true,
              physics:          const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing:  10,
              childAspectRatio: 1.0,
              children: _types.map((t) {
                final selected = type == t.type;
                return GestureDetector(
                  onTap: () => _onTypeChanged(t.type),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color:        AppTheme.kCardColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: selected
                            ? t.color : AppTheme.kBorderColor,
                        width: selected ? 2 : 1,
                      ),
                      boxShadow: selected
                          ? [BoxShadow(
                        color:      t.color.withValues(alpha: 0.15),
                        blurRadius: 10,
                        offset:     const Offset(0, 3),
                      )]
                          : [],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width:  46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: t.bg,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(t.icon,
                              color: t.color, size: 22),
                        ),
                        const SizedBox(height: 8),
                        Text(t.label,
                            style: TextStyle(
                              color: selected
                                  ? t.color : AppTheme.kTextDark,
                              fontSize:   12,
                              fontWeight: FontWeight.w600,
                            )),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // ── Fields ─────────────────────────────────────────────
            _buildFields(type, item.color),

            const SizedBox(height: 20),

            // ── Continue button ────────────────────────────────────
            SizedBox(
              width:  double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: status == GeneratorStatus.loading
                    ? null : _generate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B5BDB),
                  foregroundColor: Colors.white,
                  elevation:       0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: status == GeneratorStatus.loading
                    ? const SizedBox(
                  width:  20,
                  height: 20,
                  child:  CircularProgressIndicator(
                    color:       Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : const Text('Continue',
                    style: TextStyle(
                      fontSize:      16,
                      fontWeight:    FontWeight.w700,
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
  final QRType   type;
  final String   label;
  final IconData icon;
  final Color    color;
  final Color    bg;

  const _TypeItem({
    required this.type,
    required this.label,
    required this.icon,
    required this.color,
    required this.bg,
  });
}