import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/theme.dart';
import '../../models/qr_config.dart';
import '../../providers/customize_provider.dart';
import '../../services/gallery_services.dart';
import '../../services/share_services.dart';
import '../pages/customize/customize_screen.dart';
import '../services/history_service.dart';

class ResultPage extends StatefulWidget {
  final String                  historyId;      // ← ADD
  final String                  qrData;
  final Color                   color;
  final IconData                icon;
  final String                  label;
  final QRConfig                config;
  final void Function(QRConfig) onConfigChanged;

  const ResultPage({
    required this.historyId,      // ← ADD
    super.key,
    required this.qrData,
    required this.color,
    required this.icon,
    required this.label,
    required this.config,
    required this.onConfigChanged,
  });

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  final GlobalKey _qrKey  = GlobalKey();
  bool            _saving  = false;
  bool            _sharing = false;
  bool            _bookmarked = false;  // ← ADD


  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    // load initial config into CustomizeProvider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomizeProvider>().loadConfig(widget.config);
    });
  }

  // ── Title ──────────────────────────────────────────────────────────────────

  String get _title => switch (widget.label) {
    'URL'      => 'My Website QR',
    'Text'     => 'My Text QR',
    'WiFi'     => 'My WiFi QR',
    'Email'    => 'My Email QR',
    'Phone'    => 'My Phone QR',
    'vCard'    => 'My Contact QR',
    'WhatsApp' => 'My WhatsApp QR',
    'SMS'      => 'My SMS QR',
    'Location' => 'My Location QR',
    _          => 'My QR Code',
  };

  // ── Capture ────────────────────────────────────────────────────────────────

  Future<Uint8List?> _capture() async {
    try {
      final boundary = _qrKey.currentContext!
          .findRenderObject()! as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final bytes = await image.toByteData(
          format: ui.ImageByteFormat.png);
      return bytes == null ? null : Uint8List.view(bytes.buffer);
    } catch (_) {
      return null;
    }
  }

  // ----history ----------------

  Future<void> _bookmark() async {
    await HistoryService.toggleBookmark(widget.historyId);
    setState(() => _bookmarked = !_bookmarked);
    _snack(_bookmarked ? 'Bookmarked!' : 'Bookmark removed');
  }

  // ── Save ───────────────────────────────────────────────────────────────────

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

  // ── Share ──────────────────────────────────────────────────────────────────

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

  // ── Customize ──────────────────────────────────────────────────────────────

  void _customize() {
    final currentConfig = context.read<CustomizeProvider>().config;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: context.read<CustomizeProvider>(),
          child: CustomizePage(
            qrData:    widget.qrData,
            config:    currentConfig,
            onChanged: (c) {
              context.read<CustomizeProvider>().loadConfig(c);
              widget.onConfigChanged(c);
            },
          ),
        ),
      ),
    );
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

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // only watch config from provider
    final config = context.watch<CustomizeProvider>().config;

    return Scaffold(
      backgroundColor: AppTheme.kBgColor,

      // ── AppBar ─────────────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor:       AppTheme.kBgColor,
        elevation:              0,
        scrolledUnderElevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
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
        title: const Text('Your QR Code',
            style: TextStyle(
              color:      AppTheme.kTextDark,
              fontSize:   18,
              fontWeight: FontWeight.w700,
            )),
      ),

      // ── Body ───────────────────────────────────────────────────────
      body: Column(
        children: [

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(children: [

                // ── QR Card ──────────────────────────────────────────
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color:        AppTheme.kCardColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color:      Colors.black.withValues(alpha: 0.06),
                        blurRadius: 20,
                        offset:     const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(children: [

                    // QR preview
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                      child: RepaintBoundary(
                        key: _qrKey,
                        child: Container(
                          width:   double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color:        config.backgroundColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppTheme.kBorderColor,
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: QrImageView(
                              data:                widget.qrData,
                              version:             QrVersions.auto,
                              size:                220,
                              backgroundColor:     config.backgroundColor,
                              errorCorrectionLevel: QrErrorCorrectLevel.H,
                              eyeStyle: QrEyeStyle(
                                eyeShape: QrEyeShape.square,
                                color:    config.foregroundColor,
                              ),
                              dataModuleStyle: QrDataModuleStyle(
                                dataModuleShape: QrDataModuleShape.square,
                                color:           config.foregroundColor,
                              ),
                              embeddedImage: config.logoPath != null
                                  ? FileImage(File(config.logoPath!))
                                  : null,
                              embeddedImageStyle: QrEmbeddedImageStyle(
                                size: Size(
                                  220 * config.logoSize,
                                  220 * config.logoSize,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Title + data
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(children: [
                        Text(_title,
                            style: const TextStyle(
                              color:      AppTheme.kTextDark,
                              fontSize:   18,
                              fontWeight: FontWeight.w800,
                            )),
                        const SizedBox(height: 6),
                        Text(
                          widget.qrData,
                          style: const TextStyle(
                            color:    AppTheme.kTextGray,
                            fontSize: 13,
                          ),
                          maxLines:  1,
                          overflow:  TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ]),
                    ),

                    const SizedBox(height: 24),

                    // Action buttons
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _CircleAction(
                            icon:    Icons.share_rounded,
                            label:   'Share',
                            color:   const Color(0xFF4C9BE8),
                            bg:      const Color(0xFFEEF4FF),
                            loading: _sharing,
                            onTap:   _share,
                          ),
                          _CircleAction(
                            icon:    Icons.download_rounded,
                            label:   'Save',
                            color:   const Color(0xFF25A244),
                            bg:      const Color(0xFFEEF9F1),
                            loading: _saving,
                            onTap:   _save,
                          ),
                          _CircleAction(
                            icon:  Icons.bookmark_rounded,
                            label: 'Bookmark',
                            color: const Color(0xFFE84C4C),
                            bg:    const Color(0xFFFFEEEE),
                            onTap: _bookmark,
                          ),
                          _CircleAction(
                            icon:  Icons.palette_rounded,
                            label: 'Customize',
                            color: widget.color,
                            bg:    widget.color.withValues(alpha: 0.12),
                            onTap: _customize,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),
                  ]),
                ),
              ]),
            ),
          ),

          // ── Bottom button ───────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: SizedBox(
              width:  double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B5BDB),
                  foregroundColor: Colors.white,
                  elevation:       0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text('Create New QR',
                    style: TextStyle(
                      fontSize:   16,
                      fontWeight: FontWeight.w700,
                    )),
              ),
            ),
          ),

        ],
      ),
    );
  }
}

// ── Circle action button ──────────────────────────────────────────────────────

class _CircleAction extends StatelessWidget {
  final IconData     icon;
  final String       label;
  final Color        color;
  final Color        bg;
  final bool         loading;
  final VoidCallback onTap;

  const _CircleAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.bg,
    required this.onTap,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width:  60,
            height: 60,
            decoration: BoxDecoration(
              color: bg,
              shape: BoxShape.circle,
            ),
            child: loading
                ? Padding(
              padding: const EdgeInsets.all(16),
              child: CircularProgressIndicator(
                color:       color,
                strokeWidth: 2,
              ),
            )
                : Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(label,
              style: const TextStyle(
                color:      AppTheme.kTextGray,
                fontSize:   12,
                fontWeight: FontWeight.w500,
              )),
        ],
      ),
    );
  }
}