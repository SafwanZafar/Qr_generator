import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../../core/theme.dart';
import '../../models/qr_type.dart';
import '../../models/qr_config.dart';
import '../../services/gallery_services.dart';
import '../../services/qr_builder_service.dart';
import '../../services/share_services.dart';
import '../../widgets/qr_customize.dart';
import '../../widgets/qr_result.dart';

class QRGeneratorPage extends StatefulWidget {
  const QRGeneratorPage({super.key});

  @override
  State<QRGeneratorPage> createState() => _QRGeneratorPageState();
}

class _QRGeneratorPageState extends State<QRGeneratorPage>
    with SingleTickerProviderStateMixin {

  final GlobalKey             _qrKey  = GlobalKey();
  final TextEditingController _f1     = TextEditingController();
  final TextEditingController _f2     = TextEditingController();
  final TextEditingController _f3     = TextEditingController();
  final ScrollController      _scroll = ScrollController();

  late final AnimationController _animCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
  );
  late final Animation<double> _fade  =
  CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
  late final Animation<double> _scale =
  Tween(begin: 0.93, end: 1.0).animate(
      CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));

  QRType   _type           = QRType.website;
  String   _qrData         = '';
  bool     _saving         = false;
  bool     _sharing        = false;
  bool     _showResult     = false;
  bool     _showCustomizer = false;
  QRConfig _qrConfig       = const QRConfig();

  // QR type display config
  static const _types = [
    _TypeItem(type: QRType.website,  label: 'URL',    icon: Icons.link_rounded,          color: Color(0xFF4C4BE8), bg: Color(0xFFEEEEFD)),
    _TypeItem(type: QRType.text,     label: 'Text',   icon: Icons.text_fields_rounded,   color: Color(0xFF25A244), bg: Color(0xFFEEF9F1)),
    _TypeItem(type: QRType.wifi,     label: 'WiFi',   icon: Icons.wifi_rounded,          color: Color(0xFFE84C4C), bg: Color(0xFFFFEEEE)),
    _TypeItem(type: QRType.email,    label: 'Email',  icon: Icons.mail_outline_rounded,  color: Color(0xFF9B4CE8), bg: Color(0xFFF5EEFF)),
    _TypeItem(type: QRType.phone,    label: 'Phone',  icon: Icons.phone_rounded,         color: Color(0xFFFFB800), bg: Color(0xFFFFF8EE)),
    _TypeItem(type: QRType.contact,  label: 'vCard',  icon: Icons.person_rounded,        color: Color(0xFFE84C9B), bg: Color(0xFFFFEEF7)),
    _TypeItem(type: QRType.whatsapp, label: 'WhatsApp', icon: Icons.chat_rounded,        color: Color(0xFF25D366), bg: Color(0xFFEEFBF3)),
    _TypeItem(type: QRType.sms,      label: 'SMS',    icon: Icons.sms_rounded,           color: Color(0xFFFF6B35), bg: Color(0xFFFFF0EB)),
    _TypeItem(type: QRType.location, label: 'Location', icon: Icons.location_on_rounded, color: Color(0xFF1ABC9C), bg: Color(0xFFEEFAF7)),
  ];

  @override
  void dispose() {
    _f1.dispose();
    _f2.dispose();
    _f3.dispose();
    _scroll.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  _TypeItem get _currentType =>
      _types.firstWhere((t) => t.type == _type);

  void _onTypeChanged(QRType type) {
    setState(() {
      _type        = type;
      _qrData      = '';
      _showResult  = false;
      _f1.clear();
      _f2.clear();
      _f3.clear();
    });
  }

  void _toggleCustomizer() =>
      setState(() => _showCustomizer = !_showCustomizer);

  void _generate() {
    final err = QRBuilderService.validate(
      type: _type,
      f1:   _f1.text.trim(),
      f2:   _f2.text.trim(),
    );
    if (err != null) { _snack(err, error: true); return; }

    setState(() {
      _qrData     = QRBuilderService.build(
        type: _type,
        f1:   _f1.text.trim(),
        f2:   _f2.text.trim(),
        f3:   _f3.text.trim(),
      );
      _showResult = true;
    });
    _animCtrl.forward(from: 0);

    // scroll to result
    Future.delayed(const Duration(milliseconds: 300), () {
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
    });
  }

  Future<Uint8List?> _capture() async {
    try {
      final boundary = _qrKey.currentContext!.findRenderObject()!
      as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final bytes = await image.toByteData(
          format: ui.ImageByteFormat.png);
      return bytes == null ? null : Uint8List.view(bytes.buffer);
    } catch (_) {
      return null;
    }
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final bytes = await _capture();
      if (bytes == null) throw Exception();
      final ok = await GalleryService.save(bytes);
      _snack(ok ? 'Saved to gallery!' : 'Could not save',
          error: !ok);
    } catch (_) {
      _snack('Something went wrong', error: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _share() async {
    if (_sharing) return;
    setState(() => _sharing = true);
    try {
      final bytes = await _capture();
      if (bytes == null) throw Exception();
      await ShareService.shareImage(bytes);
    } catch (_) {
      _snack('Could not share', error: true);
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  void _snack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        Icon(
          error ? Icons.error_outline : Icons.check_circle_outline,
          color: Colors.white,
          size: 18,
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
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    ));
  }

  // ── Input fields per type ──────────────────────────────────────────────────

  Widget _field(
      TextEditingController c,
      String hint,
      IconData icon, {
        TextInputType kb    = TextInputType.text,
        bool obscure        = false,
      }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.kCardColor,
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
          prefixIcon: Icon(icon,
              color: _currentType.color, size: 18),
          border:         InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildFields() {
    switch (_type) {
      case QRType.website:
        return _field(_f1, 'https://www.example.com',
            Icons.link_rounded, kb: TextInputType.url);

      case QRType.text:
        return _field(_f1, 'Type your text here...',
            Icons.notes_rounded);

      case QRType.wifi:
        return Column(children: [
          _field(_f1, 'Network name (SSID)', Icons.wifi_rounded),
          const SizedBox(height: 10),
          _field(_f2, 'Password', Icons.lock_outline_rounded,
              obscure: true),
          const SizedBox(height: 10),
          _field(_f3, 'Security (WPA / WEP / nopass)',
              Icons.security_rounded),
        ]);

      case QRType.email:
        return Column(children: [
          _field(_f1, 'Email address',
              Icons.mail_outline_rounded,
              kb: TextInputType.emailAddress),
          const SizedBox(height: 10),
          _field(_f2, 'Subject (optional)',
              Icons.title_rounded),
          const SizedBox(height: 10),
          _field(_f3, 'Message (optional)',
              Icons.edit_outlined),
        ]);

      case QRType.phone:
        return _field(_f1, '+923001234567',
            Icons.phone_rounded, kb: TextInputType.phone);

      case QRType.contact:
        return Column(children: [
          _field(_f1, 'Full name',
              Icons.person_outline_rounded),
          const SizedBox(height: 10),
          _field(_f2, 'Phone number', Icons.phone_outlined,
              kb: TextInputType.phone),
          const SizedBox(height: 10),
          _field(_f3, 'Email (optional)',
              Icons.mail_outline_rounded,
              kb: TextInputType.emailAddress),
        ]);

      case QRType.whatsapp:
        return Column(children: [
          _field(_f1, 'Number e.g. 923001234567',
              Icons.phone_rounded, kb: TextInputType.phone),
          const SizedBox(height: 10),
          _field(_f2, 'Pre-filled message (optional)',
              Icons.chat_bubble_outline_rounded),
        ]);

      case QRType.sms:
        return Column(children: [
          _field(_f1, 'Phone number',
              Icons.phone_rounded, kb: TextInputType.phone),
          const SizedBox(height: 10),
          _field(_f2, 'Message (optional)',
              Icons.sms_outlined),
        ]);

      case QRType.location:
        return Column(children: [
          _field(_f1, 'Latitude e.g. 31.5204',
              Icons.explore_rounded, kb: TextInputType.number),
          const SizedBox(height: 10),
          _field(_f2, 'Longitude e.g. 74.3587',
              Icons.explore_outlined, kb: TextInputType.number),
        ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = _currentType;

    return Scaffold(
      backgroundColor: AppTheme.kBgColor,

      // ── App Bar ────────────────────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: AppTheme.kBgColor,
        elevation: 0,
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
        title: const Text(
          'Create QR Code',
          style: TextStyle(
            color:      AppTheme.kTextDark,
            fontSize:   18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // ── Body ───────────────────────────────────────────────────────────────
      body: SingleChildScrollView(
        controller: _scroll,
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Type selector ──────────────────────────────────────────────
            const Text(
              'Select QR code type',
              style: TextStyle(
                color:      AppTheme.kTextGray,
                fontSize:   13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),

            GridView.count(
              crossAxisCount:     3,
              shrinkWrap:         true,
              physics:            const NeverScrollableScrollPhysics(),
              crossAxisSpacing:   10,
              mainAxisSpacing:    10,
              childAspectRatio:   1.0,
              children: _types.map((item) {
                final selected = _type == item.type;
                return GestureDetector(
                  onTap: () => _onTypeChanged(item.type),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color:        AppTheme.kCardColor,
                      borderRadius: BorderRadius.circular(14),
                      border:       Border.all(
                        color: selected
                            ? item.color
                            : AppTheme.kBorderColor,
                        width: selected ? 2 : 1,
                      ),
                      boxShadow: selected
                          ? [BoxShadow(
                        color:      item.color.withValues(alpha: 0.15),
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
                            color:  item.bg,
                            shape:  BoxShape.circle,
                          ),
                          child: Icon(item.icon,
                              color: item.color, size: 22),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item.label,
                          style: TextStyle(
                            color:      selected
                                ? item.color
                                : AppTheme.kTextDark,
                            fontSize:   12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // ── Input fields ───────────────────────────────────────────────
            Text(
              'Enter ${t.label}',
              style: const TextStyle(
                color:      AppTheme.kTextDark,
                fontSize:   15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),

            _buildFields(),

            const SizedBox(height: 20),

            // ── Continue button ────────────────────────────────────────────
            SizedBox(
              width:  double.infinity,
              height: 52,
              child:  ElevatedButton(
                onPressed: _generate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B5BDB),
                  foregroundColor: Colors.white,
                  elevation:       0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(
                    fontSize:   16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),

            // ── QR Result ──────────────────────────────────────────────────
            if (_showResult && _qrData.isNotEmpty) ...[
              const SizedBox(height: 24),
              FadeTransition(
                opacity: _fade,
                child: ScaleTransition(
                  scale: _scale,
                  child: QRResult(
                    qrKey:       _qrKey,
                    qrData:      _qrData,
                    color:       t.color,
                    icon:        t.icon,
                    label:       t.label,
                    saving:      _saving,
                    sharing:     _sharing,
                    config:      _qrConfig,
                    onSave:      _save,
                    onShare:     _share,
                    onCustomize: _toggleCustomizer,
                  ),
                ),
              ),

              if (_showCustomizer) ...[
                const SizedBox(height: 16),
                QRCustomizer(
                  qrData:    _qrData,
                  config:    _qrConfig,
                  onChanged: (c) => setState(() => _qrConfig = c),
                ),
              ],
            ],

          ],
        ),
      ),
    );
  }
}

// ── Type item model ────────────────────────────────────────────────────────────

class _TypeItem {
  final QRType  type;
  final String  label;
  final IconData icon;
  final Color   color;
  final Color   bg;

  const _TypeItem({
    required this.type,
    required this.label,
    required this.icon,
    required this.color,
    required this.bg,
  });
}