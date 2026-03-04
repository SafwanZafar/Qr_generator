import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../core/constant.dart';
import '../models/qr_type.dart';
import '../models/qr_config.dart';
import '../services/gallery_services.dart';
import '../services/qr_builder_service.dart';
import '../services/share_services.dart';
import '../widgets/qr_customize.dart';
import '../widgets/type_grid.dart';
import '../widgets/qr_result.dart';
import '../widgets/empty_state.dart';
import '../widgets/input_field.dart';



class QRGeneratorPage extends StatefulWidget {
  const QRGeneratorPage({super.key});

  @override
  State<QRGeneratorPage> createState() => _QRGeneratorPageState();
}

class _QRGeneratorPageState extends State<QRGeneratorPage>
    with SingleTickerProviderStateMixin {

  final GlobalKey             _qrKey = GlobalKey();
  final TextEditingController _f1    = TextEditingController();
  final TextEditingController _f2    = TextEditingController();
  final TextEditingController _f3    = TextEditingController();

  late final AnimationController _animCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
  );
  late final Animation<double> _fade  =
  CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
  late final Animation<double> _scale =
  Tween(begin: 0.93, end: 1.0).animate(
      CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));

  QRType _type    = QRType.website;
  String _qrData  = '';
  bool   _saving  = false;
  bool   _sharing = false;
  QRConfig _qrConfig       = const QRConfig();   // ← ADD THIS
  bool     _showCustomizer = false;              // ← ADD THIS

  Color get _color => kTypeColors[_type]!;

  @override
  void dispose() {
    _f1.dispose();
    _f2.dispose();
    _f3.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  void _onTypeChanged(QRType type) {
    setState(() {
      _type   = type;
      _qrData = '';
      _f1.clear();
      _f2.clear();
      _f3.clear();
    });
  }

  // ← ADD THIS METHOD
  void _toggleCustomizer() {
    setState(() => _showCustomizer = !_showCustomizer);
  }

  void _generate() {
    final err = QRBuilderService.validate(
      type: _type,
      f1: _f1.text.trim(),
      f2: _f2.text.trim(),
    );
    if (err != null) { _snack(err, error: true); return; }

    setState(() {
      _qrData = QRBuilderService.build(
        type: _type,
        f1: _f1.text.trim(),
        f2: _f2.text.trim(),
        f3: _f3.text.trim(),
      );
    });
    _animCtrl.forward(from: 0);
  }

  Future<Uint8List?> _capture() async {
    try {
      final boundary = _qrKey.currentContext!.findRenderObject()!
      as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
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
      _snack(ok ? 'Saved to gallery!' : 'Could not save', error: !ok);
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
      backgroundColor: error ? kErrorColor : kSuccessColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    ));
  }

  Widget _buildFields() {
    Widget f(TextEditingController c, String hint, IconData icon, {
      TextInputType kb = TextInputType.text,
      bool obscure = false,
    }) =>
        QRInputField(
          controller:  c,
          hint:        hint,
          icon:        icon,
          accentColor: _color,
          keyboard:    kb,
          obscure:     obscure,
        );

    switch (_type) {
      case QRType.website:
        return f(_f1, 'https://example.com',
            Icons.link_rounded, kb: TextInputType.url);
      case QRType.whatsapp:
        return Column(children: [
          f(_f1, 'Number e.g. 923001234567',
              Icons.phone_rounded, kb: TextInputType.phone),
          f(_f2, 'Pre-filled message (optional)',
              Icons.chat_bubble_outline_rounded),
        ]);
      case QRType.phone:
        return f(_f1, '+923001234567',
            Icons.call_rounded, kb: TextInputType.phone);
      case QRType.sms:
        return Column(children: [
          f(_f1, 'Phone number',
              Icons.phone_rounded, kb: TextInputType.phone),
          f(_f2, 'Message (optional)', Icons.sms_outlined),
        ]);
      case QRType.email:
        return Column(children: [
          f(_f1, 'Email address', Icons.mail_outline_rounded,
              kb: TextInputType.emailAddress),
          f(_f2, 'Subject (optional)', Icons.title_rounded),
          f(_f3, 'Message body (optional)', Icons.edit_outlined),
        ]);
      case QRType.wifi:
        return Column(children: [
          f(_f1, 'Network name (SSID)', Icons.wifi_rounded),
          f(_f2, 'Password', Icons.lock_outline_rounded),
          f(_f3, 'Security (WPA / WEP / nopass)', Icons.security_rounded),
        ]);
      case QRType.location:
        return Column(children: [
          f(_f1, 'Latitude e.g. 31.5204',
              Icons.explore_rounded, kb: TextInputType.number),
          f(_f2, 'Longitude e.g. 74.3587',
              Icons.explore_outlined, kb: TextInputType.number),
        ]);
      case QRType.contact:
        return Column(children: [
          f(_f1, 'Full name', Icons.person_outline_rounded),
          f(_f2, 'Phone number', Icons.phone_outlined,
              kb: TextInputType.phone),
          f(_f3, 'Email (optional)', Icons.mail_outline_rounded,
              kb: TextInputType.emailAddress),
        ]);
      case QRType.text:
        return f(_f1, 'Type anything...', Icons.notes_rounded);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgColor,
      body: CustomScrollView(
        slivers: [

          SliverAppBar(
            expandedHeight: 100,
            pinned: true,
            backgroundColor: kBgColor,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 14),
              title: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('QR Generator',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      )),
                  Text('Create • Save • Share',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.35),
                        fontSize: 11,
                        letterSpacing: 1,
                      )),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text('What are you making?',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 12,
                        letterSpacing: 0.4,
                      )),
                  const SizedBox(height: 10),

                  QRTypeGrid(
                    selected: _type,
                    onTap:    _onTypeChanged,
                  ),

                  const SizedBox(height: 20),

                  Row(children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 3, height: 16,
                      decoration: BoxDecoration(
                        color: _color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(kTypeLabels[_type]!,
                        style: TextStyle(
                          color: _color,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        )),
                  ]),
                  const SizedBox(height: 10),

                  _buildFields(),
                  const SizedBox(height: 6),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _generate,
                      icon: const Icon(Icons.qr_code_rounded, size: 18),
                      label: const Text('Generate QR Code',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            letterSpacing: 0.2,
                          )),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _color,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Result or empty state ──────────────────────
                  if (_qrData.isNotEmpty) ...[
                    FadeTransition(
                      opacity: _fade,
                      child: ScaleTransition(
                        scale: _scale,
                        child: QRResult(
                          qrKey:       _qrKey,
                          qrData:      _qrData,
                          color:       _color,
                          icon:        kTypeIcons[_type]!,
                          label:       kTypeLabels[_type]!,
                          saving:      _saving,
                          sharing:     _sharing,
                          config:      _qrConfig,        // ← ADD THIS
                          onSave:      _save,
                          onShare:     _share,
                          onCustomize: _toggleCustomizer, // ← ADD THIS
                        ),
                      ),
                    ),

                    // ← ADD THIS BLOCK below QRResult
                    if (_showCustomizer) ...[
                      const SizedBox(height: 16),
                      QRCustomizer(
                        qrData:    _qrData,
                        config:    _qrConfig,
                        onChanged: (c) => setState(() => _qrConfig = c),
                      ),
                    ],
                  ] else
                    const EmptyState(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}