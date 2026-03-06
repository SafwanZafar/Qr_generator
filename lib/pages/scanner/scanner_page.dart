import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage>
    with SingleTickerProviderStateMixin {

  final MobileScannerController _controller = MobileScannerController();

  String?  _scannedValue;
  String?  _scannedType;
  bool     _torchOn      = false;
  bool     _paused       = false;
  bool     _pickingImage = false;

  // Scan line animation
  late final AnimationController _lineCtrl = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat(reverse: true);

  late final Animation<double> _line =
  CurvedAnimation(parent: _lineCtrl, curve: Curves.easeInOut);

  @override
  void dispose() {
    _controller.dispose();
    _lineCtrl.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_paused) return;
    final value = capture.barcodes.first.rawValue;
    if (value == null) return;
    setState(() {
      _paused       = true;
      _scannedValue = value;
      _scannedType  = _detectType(value);
    });
    _controller.stop();
    _showResultSheet(value);
  }

  String _detectType(String value) {
    if (value.startsWith('https://wa.me') ||
        value.contains('api.whatsapp'))    return 'WhatsApp';
    if (value.startsWith('http'))          return 'Website';
    if (value.startsWith('tel:'))          return 'Phone';
    if (value.startsWith('mailto:'))       return 'Email';
    if (value.startsWith('WIFI:'))         return 'WiFi';
    if (value.startsWith('geo:'))          return 'Location';
    if (value.startsWith('MECARD:') ||
        value.startsWith('BEGIN:VCARD'))   return 'Contact';
    if (value.startsWith('sms:'))          return 'SMS';
    return 'Text';
  }

  void _rescan() {
    setState(() {
      _paused       = false;
      _scannedValue = null;
      _scannedType  = null;
    });
    _controller.start();
  }

  Future<void> _pickFromGallery() async {
    setState(() => _pickingImage = true);
    try {
      final picker = ImagePicker();
      final file   = await picker.pickImage(source: ImageSource.gallery);
      if (file == null) return;
      final result = await _controller.analyzeImage(file.path);
      if (result == null || result.barcodes.isEmpty) {
        _snack('No QR code found in image');
        return;
      }
      final value = result.barcodes.first.rawValue;
      if (value == null) return;
      setState(() {
        _paused       = true;
        _scannedValue = value;
        _scannedType  = _detectType(value);
      });
      _showResultSheet(value);
    } catch (_) {
      _snack('Could not read QR code');
    } finally {
      if (mounted) setState(() => _pickingImage = false);
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: const Color(0xFF25D366),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    ));
  }

  Future<void> _openLink(String value) async {
    final uri = Uri.tryParse(value);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      _snack('Cannot open this link');
    }
  }

  void _showResultSheet(String value) {
    final type  = _detectType(value);
    final color = _typeColor(type);
    final icon  = _typeIcon(type);

    showModalBottomSheet(
      context:           context,
      isScrollControlled: true,
      backgroundColor:   Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color:        Color(0xFF1A1A2E),
          borderRadius: BorderRadius.vertical(
              top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            // Drag handle
            Container(
              width:  40,
              height: 4,
              decoration: BoxDecoration(
                color:        Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // Type header
            Row(children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color:        color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(type,
                      style: TextStyle(
                        color:      color,
                        fontSize:   13,
                        fontWeight: FontWeight.w600,
                      )),
                  const Text('Scanned successfully',
                      style: TextStyle(
                        color:    Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      )),
                ],
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  _rescan();
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color:        Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.close_rounded,
                      color: Colors.white, size: 18),
                ),
              ),
            ]),

            const SizedBox(height: 16),

            // Value box
            Container(
              width:   double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color:        Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Text(
                value,
                style: const TextStyle(
                  color:      Colors.white,
                  fontSize:   13,
                  fontFamily: 'monospace',
                ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            const SizedBox(height: 16),

            // Action buttons
            Row(children: [
              Expanded(child: _SheetBtn(
                icon:  Icons.copy_rounded,
                label: 'Copy',
                color: Colors.white,
                bg:    Colors.white.withValues(alpha: 0.1),
                onTap: () {
                  Clipboard.setData(ClipboardData(text: value));
                  Navigator.pop(context);
                  _rescan();
                  _snack('Copied!');
                },
              )),
              const SizedBox(width: 10),
              Expanded(child: _SheetBtn(
                icon:  Icons.open_in_new_rounded,
                label: 'Open',
                color: color,
                bg:    color.withValues(alpha: 0.15),
                onTap: () {
                  Navigator.pop(context);
                  _openLink(value);
                  _rescan();
                },
              )),
              const SizedBox(width: 10),
              Expanded(child: _SheetBtn(
                icon:  Icons.share_rounded,
                label: 'Share',
                color: Colors.white,
                bg:    Colors.white.withValues(alpha: 0.1),
                onTap: () {
                  Navigator.pop(context);
                  Share.share(value);
                  _rescan();
                },
              )),
            ]),

            const SizedBox(height: 12),

            // Scan again
            SizedBox(
              width:  double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _rescan();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                  foregroundColor: Colors.white,
                  elevation:       0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Scan Again',
                    style: TextStyle(
                      fontSize:   15,
                      fontWeight: FontWeight.w700,
                    )),
              ),
            ),
          ],
        ),
      ),
    ).whenComplete(_rescan);
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'Website':  return const Color(0xFF4C9BE8);
      case 'WhatsApp': return const Color(0xFF25D366);
      case 'Phone':    return const Color(0xFFFF6B35);
      case 'Email':    return const Color(0xFFE85D75);
      case 'WiFi':     return const Color(0xFF9B59B6);
      case 'Location': return const Color(0xFF1ABC9C);
      case 'Contact':  return const Color(0xFFFF8C42);
      case 'SMS':      return const Color(0xFFFFB800);
      default:         return const Color(0xFF95A5A6);
    }
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'Website':  return Icons.language_rounded;
      case 'WhatsApp': return Icons.chat_rounded;
      case 'Phone':    return Icons.phone_rounded;
      case 'Email':    return Icons.mail_rounded;
      case 'WiFi':     return Icons.wifi_rounded;
      case 'Location': return Icons.location_on_rounded;
      case 'Contact':  return Icons.person_rounded;
      case 'SMS':      return Icons.sms_rounded;
      default:         return Icons.notes_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      body: Stack(
        children: [

          // ── Full screen camera ─────────────────────────────────────────
          Positioned.fill(
            child: MobileScanner(
              controller: _controller,
              onDetect:   _onDetect,
            ),
          ),

          // ── Dark overlay outside scan frame ────────────────────────────
          Positioned.fill(
            child: CustomPaint(
              painter: _OverlayPainter(),
            ),
          ),

          // ── Scan frame corners ─────────────────────────────────────────
          Center(
            child: SizedBox(
              width:  260,
              height: 260,
              child:  CustomPaint(
                painter: _CornerPainter(),
              ),
            ),
          ),

          // ── Animated scan line ─────────────────────────────────────────
          Center(
            child: AnimatedBuilder(
              animation: _line,
              builder: (_, __) => Transform.translate(
                offset: Offset(0, (_line.value * 2 - 1) * 120),
                child: Container(
                  width:  220,
                  height: 2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        const Color(0xFF25D366).withValues(alpha: 0.8),
                        const Color(0xFF25D366),
                        const Color(0xFF25D366).withValues(alpha: 0.8),
                        Colors.transparent,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color:      const Color(0xFF25D366)
                            .withValues(alpha: 0.5),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Top bar ────────────────────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  // Back button
                  _TopBtn(
                    icon:  Icons.arrow_back_rounded,
                    onTap: () => Navigator.maybePop(context),
                  ),

                  // Title
                  const Text(
                    'Scan QR Code',
                    style: TextStyle(
                      color:      Colors.white,
                      fontSize:   17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  // Torch button
                  _TopBtn(
                    icon:  _torchOn
                        ? Icons.flash_on_rounded
                        : Icons.flash_off_rounded,
                    onTap: () {
                      setState(() => _torchOn = !_torchOn);
                      _controller.toggleTorch();
                    },
                    active: _torchOn,
                  ),
                ],
              ),
            ),
          ),

          // ── Bottom hint + buttons ──────────────────────────────────────
          Positioned(
            bottom: 0,
            left:   0,
            right:  0,
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  // Hint text
                  const Text(
                    'Point your camera at a QR code',
                    style: TextStyle(
                      color:      Colors.white,
                      fontSize:   14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Gallery + Auto Scan buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      // Gallery button
                      _BottomBtn(
                        icon:    Icons.image_rounded,
                        label:   'Gallery',
                        active:  false,
                        loading: _pickingImage,
                        onTap:   _pickFromGallery,
                      ),

                      const SizedBox(width: 24),

                      // Auto Scan button
                      _BottomBtn(
                        icon:   Icons.qr_code_scanner_rounded,
                        label:  'Auto Scan',
                        active: true,
                        onTap:  () {},
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Top icon button ────────────────────────────────────────────────────────────

class _TopBtn extends StatelessWidget {
  final IconData     icon;
  final VoidCallback onTap;
  final bool         active;

  const _TopBtn({
    required this.icon,
    required this.onTap,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width:  44,
        height: 44,
        decoration: BoxDecoration(
          color:        active
              ? const Color(0xFF25D366).withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon,
            color: active
                ? const Color(0xFF25D366)
                : Colors.white,
            size: 20),
      ),
    );
  }
}

// ── Bottom action button ───────────────────────────────────────────────────────

class _BottomBtn extends StatelessWidget {
  final IconData     icon;
  final String       label;
  final bool         active;
  final bool         loading;
  final VoidCallback onTap;

  const _BottomBtn({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width:  60,
            height: 60,
            decoration: BoxDecoration(
              color:        active
                  ? const Color(0xFF25D366)
                  : Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(18),
            ),
            child: loading
                ? const CircularProgressIndicator(
              color:       Colors.white,
              strokeWidth: 2,
            )
                : Icon(icon, color: Colors.white, size: 26),
          ),
          const SizedBox(height: 8),
          Text(label,
              style: TextStyle(
                color:      active
                    ? const Color(0xFF25D366)
                    : Colors.white.withValues(alpha: 0.7),
                fontSize:   12,
                fontWeight: FontWeight.w600,
              )),
        ],
      ),
    );
  }
}

// ── Result sheet action button ─────────────────────────────────────────────────

class _SheetBtn extends StatelessWidget {
  final IconData     icon;
  final String       label;
  final Color        color;
  final Color        bg;
  final VoidCallback onTap;

  const _SheetBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.bg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color:        bg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(
                  color:      color,
                  fontSize:   11,
                  fontWeight: FontWeight.w600,
                )),
          ],
        ),
      ),
    );
  }
}

// ── Scan overlay painter ───────────────────────────────────────────────────────

class _OverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.55);

    const frameSize = 260.0;
    final cx = size.width  / 2;
    final cy = size.height / 2;
    final left   = cx - frameSize / 2;
    final top    = cy - frameSize / 2;
    final right  = cx + frameSize / 2;
    final bottom = cy + frameSize / 2;

    // Draw 4 dark rectangles around the frame
    canvas.drawRect(Rect.fromLTRB(0, 0, size.width, top), paint);
    canvas.drawRect(Rect.fromLTRB(0, bottom, size.width, size.height), paint);
    canvas.drawRect(Rect.fromLTRB(0, top, left, bottom), paint);
    canvas.drawRect(Rect.fromLTRB(right, top, size.width, bottom), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ── Corner frame painter ───────────────────────────────────────────────────────

class _CornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color       = const Color(0xFF25D366)
      ..strokeWidth = 3.5
      ..style       = PaintingStyle.stroke
      ..strokeCap   = StrokeCap.round;

    const len    = 40.0;
    const radius = 8.0;
    final w = size.width;
    final h = size.height;

    // Top-left corner
    canvas.drawPath(Path()
      ..moveTo(0 + radius, 0)
      ..lineTo(len, 0)
      ..moveTo(0, 0 + radius)
      ..lineTo(0, len), paint);

    // Top-right corner
    canvas.drawPath(Path()
      ..moveTo(w - len, 0)
      ..lineTo(w - radius, 0)
      ..moveTo(w, 0 + radius)
      ..lineTo(w, len), paint);

    // Bottom-left corner
    canvas.drawPath(Path()
      ..moveTo(0, h - len)
      ..lineTo(0, h - radius)
      ..moveTo(0 + radius, h)
      ..lineTo(len, h), paint);

    // Bottom-right corner
    canvas.drawPath(Path()
      ..moveTo(w - len, h)
      ..lineTo(w - radius, h)
      ..moveTo(w, h - len)
      ..lineTo(w, h - radius), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}