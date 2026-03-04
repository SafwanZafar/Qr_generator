import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../core/constant.dart';

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage>
    with SingleTickerProviderStateMixin {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  late final AnimationController _animCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
  );
  late final Animation<double> _fade =
  CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
  late final Animation<double> _slide =
  Tween(begin: 60.0, end: 0.0).animate(
      CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));

  String? _scannedValue;
  String? _scannedType;
  bool    _torchOn      = false;
  bool    _paused       = false;
  bool    _scanMode     = true;
  bool    _pickingImage = false;

  @override
  void dispose() {
    _controller.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  // ── Detect ────────────────────────────────────────────────────────────────

  void _onDetect(BarcodeCapture capture) {
    final barcode = capture.barcodes.firstOrNull;
    if (barcode == null || barcode.rawValue == null) return;
    final value = barcode.rawValue!;
    if (value == _scannedValue) return;

    HapticFeedback.mediumImpact();
    _controller.stop();

    setState(() {
      _scannedValue = value;
      _scannedType  = _detectType(value);
      _paused       = true;
    });
    _animCtrl.forward(from: 0);
  }

  Future<void> _pickFromGallery() async {
    if (_pickingImage) return;
    setState(() => _pickingImage = true);
    try {
      final picker = ImagePicker();
      final file   = await picker.pickImage(source: ImageSource.gallery);
      if (file == null) {
        setState(() => _pickingImage = false);
        return;
      }
      final result = await _controller.analyzeImage(file.path);
      if (result == null || result.barcodes.isEmpty) {
        _snack('No QR code found in image', error: true);
        setState(() => _pickingImage = false);
        return;
      }
      final value = result.barcodes.first.rawValue;
      if (value == null) {
        _snack('Could not read QR code', error: true);
        setState(() => _pickingImage = false);
        return;
      }
      HapticFeedback.mediumImpact();
      setState(() {
        _scannedValue = value;
        _scannedType  = _detectType(value);
        _paused       = true;
        _pickingImage = false;
      });
      _animCtrl.forward(from: 0);
    } catch (_) {
      _snack('Something went wrong', error: true);
      setState(() => _pickingImage = false);
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _detectType(String value) {
    if (value.startsWith('https://wa.me') ||
        value.startsWith('https://api.whatsapp')) return 'WhatsApp';
    if (value.startsWith('http://') ||
        value.startsWith('https://'))    return 'Website';
    if (value.startsWith('tel:'))        return 'Phone';
    if (value.startsWith('sms:'))        return 'SMS';
    if (value.startsWith('mailto:'))     return 'Email';
    if (value.startsWith('WIFI:'))       return 'WiFi';
    if (value.startsWith('geo:'))        return 'Location';
    if (value.startsWith('MECARD:') ||
        value.startsWith('BEGIN:VCARD')) return 'Contact';
    return 'Text';
  }

  Color _typeColor(String? type) {
    switch (type) {
      case 'Website':  return const Color(0xFF4C9BE8);
      case 'WhatsApp': return const Color(0xFF25D366);
      case 'Phone':    return const Color(0xFFFF6B35);
      case 'SMS':      return const Color(0xFFFFB800);
      case 'Email':    return const Color(0xFFE85D75);
      case 'WiFi':     return const Color(0xFF9B59B6);
      case 'Location': return const Color(0xFF1ABC9C);
      case 'Contact':  return const Color(0xFFFF8C42);
      default:         return const Color(0xFF95A5A6);
    }
  }

  IconData _typeIcon(String? type) {
    switch (type) {
      case 'Website':  return Icons.language_rounded;
      case 'WhatsApp': return Icons.chat_bubble_rounded;
      case 'Phone':    return Icons.call_rounded;
      case 'SMS':      return Icons.sms_rounded;
      case 'Email':    return Icons.mail_rounded;
      case 'WiFi':     return Icons.wifi_rounded;
      case 'Location': return Icons.location_on_rounded;
      case 'Contact':  return Icons.person_rounded;
      default:         return Icons.notes_rounded;
    }
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  void _rescan() {
    setState(() {
      _scannedValue = null;
      _scannedType  = null;
      _paused       = false;
    });
    _animCtrl.reset();
    if (_scanMode) _controller.start();
  }

  void _copyToClipboard() {
    if (_scannedValue == null) return;
    Clipboard.setData(ClipboardData(text: _scannedValue!));
    _snack('Copied to clipboard!');
  }

  Future<void> _openLink() async {
    if (_scannedValue == null) return;
    try {
      final uri = Uri.parse(_scannedValue!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _snack('Cannot open this link', error: true);
      }
    } catch (_) {
      _snack('Cannot open this link', error: true);
    }
  }

  Future<void> _shareValue() async {
    if (_scannedValue == null) return;
    await Share.share(_scannedValue!);
  }

  void _snack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        Icon(
          error ? Icons.error_outline : Icons.check_circle_outline,
          color: Colors.white,
          size: 16,
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(msg,
            style: const TextStyle(fontSize: 13))),
      ]),
      backgroundColor: error
          ? const Color(0xFFE85D75)
          : const Color(0xFF25D366),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    ));
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgColor,
      body: Stack(
        children: [

          // Camera
          if (!_paused && _scanMode)
            MobileScanner(
              controller: _controller,
              onDetect: _onDetect,
            ),

          // Gallery mode
          if (!_paused && !_scanMode)
            _GalleryMode(
              loading: _pickingImage,
              onPick: _pickFromGallery,
            ),

          // Paused bg
          if (_paused)
            Container(color: kBgColor),

          // Scan overlay
          if (!_paused && _scanMode)
            _ScanOverlay(torchOn: _torchOn),

          // Top bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  // Title + torch
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('QR Scanner',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.5,
                              )),
                          Text(
                            _paused
                                ? 'Scan complete'
                                : _scanMode
                                ? 'Point camera at QR code'
                                : 'Pick image from gallery',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.4),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      if (!_paused && _scanMode)
                        _TorchButton(
                          on: _torchOn,
                          onTap: () {
                            _controller.toggleTorch();
                            setState(() => _torchOn = !_torchOn);
                          },
                        ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Mode toggle
                  if (!_paused)
                    _ModeToggle(
                      cameraSelected: _scanMode,
                      onCamera: () {
                        if (!_scanMode) {
                          setState(() => _scanMode = true);
                          _controller.start();
                        }
                      },
                      onGallery: () {
                        if (_scanMode) {
                          setState(() => _scanMode = false);
                          _controller.stop();
                        }
                      },
                    ),
                ],
              ),
            ),
          ),

          // Result card slides up from bottom
          if (_paused && _scannedValue != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: FadeTransition(
                opacity: _fade,
                child: AnimatedBuilder(
                  animation: _slide,
                  builder: (_, child) => Transform.translate(
                    offset: Offset(0, _slide.value),
                    child: child,
                  ),
                  child: _ResultCard(
                    value:    _scannedValue!,
                    type:     _scannedType,
                    color:    _typeColor(_scannedType),
                    icon:     _typeIcon(_scannedType),
                    onCopy:   _copyToClipboard,
                    onOpen:   _openLink,
                    onShare:  _shareValue,
                    onCancel: _rescan,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Gallery mode ──────────────────────────────────────────────────────────────

class _GalleryMode extends StatelessWidget {
  final bool loading;
  final VoidCallback onPick;

  const _GalleryMode({required this.loading, required this.onPick});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kBgColor,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C1C),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: const Color(0xFF4C9BE8).withValues(alpha: 0.3),
                ),
              ),
              child: loading
                  ? const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF4C9BE8),
                    strokeWidth: 2,
                  ))
                  : const Icon(
                Icons.photo_library_rounded,
                color: Color(0xFF4C9BE8),
                size: 44,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              loading ? 'Reading QR from image...' : 'Select an image\ncontaining a QR code',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.45),
                fontSize: 14,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 28),

            if (!loading)
              GestureDetector(
                onTap: onPick,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 28, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4C9BE8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.photo_rounded,
                          color: Colors.white, size: 18),
                      SizedBox(width: 8),
                      Text('Choose from Gallery',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          )),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Torch button ──────────────────────────────────────────────────────────────

class _TorchButton extends StatelessWidget {
  final bool on;
  final VoidCallback onTap;
  const _TorchButton({required this.on, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: on
              ? const Color(0xFFFFB800).withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: on
                ? const Color(0xFFFFB800).withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.08),
          ),
        ),
        child: Icon(
          on ? Icons.flashlight_on_rounded : Icons.flashlight_off_rounded,
          color: on
              ? const Color(0xFFFFB800)
              : Colors.white.withValues(alpha: 0.5),
          size: 20,
        ),
      ),
    );
  }
}

// ── Mode toggle ───────────────────────────────────────────────────────────────

class _ModeToggle extends StatelessWidget {
  final bool cameraSelected;
  final VoidCallback onCamera;
  final VoidCallback onGallery;

  const _ModeToggle({
    required this.cameraSelected,
    required this.onCamera,
    required this.onGallery,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1C),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
        ),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _ModeTab(
            label: 'Camera',
            icon: Icons.camera_alt_rounded,
            selected: cameraSelected,
            onTap: onCamera,
          ),
          _ModeTab(
            label: 'Gallery',
            icon: Icons.photo_library_rounded,
            selected: !cameraSelected,
            onTap: onGallery,
          ),
        ],
      ),
    );
  }
}

class _ModeTab extends StatelessWidget {
  final String     label;
  final IconData   icon;
  final bool       selected;
  final VoidCallback onTap;

  const _ModeTab({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFF4C9BE8).withValues(alpha: 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            border: selected
                ? Border.all(
                color: const Color(0xFF4C9BE8).withValues(alpha: 0.35))
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 15,
                  color: selected
                      ? const Color(0xFF4C9BE8)
                      : Colors.white.withValues(alpha: 0.3)),
              const SizedBox(width: 6),
              Text(label,
                  style: TextStyle(
                    color: selected
                        ? const Color(0xFF4C9BE8)
                        : Colors.white.withValues(alpha: 0.3),
                    fontSize: 12,
                    fontWeight: selected
                        ? FontWeight.w600
                        : FontWeight.w400,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Scan overlay ──────────────────────────────────────────────────────────────

class _ScanOverlay extends StatefulWidget {
  final bool torchOn;
  const _ScanOverlay({required this.torchOn});

  @override
  State<_ScanOverlay> createState() => _ScanOverlayState();
}

class _ScanOverlayState extends State<_ScanOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat(reverse: true);

  late final Animation<double> _line =
  Tween(begin: 0.0, end: 1.0).animate(_ctrl);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final box  = size.width * 0.65;

    return Stack(
      children: [
        ColorFiltered(
          colorFilter: ColorFilter.mode(
            Colors.black.withValues(alpha: 0.55),
            BlendMode.srcOut,
          ),
          child: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Colors.black,
                  backgroundBlendMode: BlendMode.dstOut,
                ),
              ),
              Center(
                child: Container(
                  width: box,
                  height: box,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
        ),

        Center(
          child: SizedBox(
            width: box,
            height: box,
            child: CustomPaint(painter: _CornerPainter()),
          ),
        ),

        Center(
          child: SizedBox(
            width: box,
            height: box,
            child: AnimatedBuilder(
              animation: _line,
              builder: (_, __) => Align(
                alignment: Alignment(0, _line.value * 2 - 1),
                child: Container(
                  width: box * 0.85,
                  height: 2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        const Color(0xFF4C9BE8).withValues(alpha: 0.8),
                        Colors.transparent,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
            ),
          ),
        ),

        Positioned(
          bottom: 60,
          left: 0,
          right: 0,
          child: Text(
            'Align QR code within the frame',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Corner painter ────────────────────────────────────────────────────────────

class _CornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF4C9BE8)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const len    = 24.0;
    const radius = 12.0;
    final w = size.width;
    final h = size.height;

    canvas.drawPath(Path()
      ..moveTo(0, len + radius)
      ..arcToPoint(Offset(radius, radius),
          radius: const Radius.circular(radius))
      ..lineTo(len + radius, radius), paint);

    canvas.drawPath(Path()
      ..moveTo(w - len - radius, radius)
      ..arcToPoint(Offset(w - radius, radius),
          radius: const Radius.circular(radius))
      ..lineTo(w - radius, len + radius), paint);

    canvas.drawPath(Path()
      ..moveTo(radius, h - len - radius)
      ..arcToPoint(Offset(radius, h - radius),
          radius: const Radius.circular(radius))
      ..lineTo(len + radius, h - radius), paint);

    canvas.drawPath(Path()
      ..moveTo(w - len - radius, h - radius)
      ..arcToPoint(Offset(w - radius, h - radius),
          radius: const Radius.circular(radius))
      ..lineTo(w - radius, h - len - radius), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ── Result card ───────────────────────────────────────────────────────────────

class _ResultCard extends StatelessWidget {
  final String     value;
  final String?    type;
  final Color      color;
  final IconData   icon;
  final VoidCallback onCopy;
  final VoidCallback onOpen;
  final VoidCallback onShare;
  final VoidCallback onCancel;

  const _ResultCard({
    required this.value,
    required this.type,
    required this.color,
    required this.icon,
    required this.onCopy,
    required this.onOpen,
    required this.onShare,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1C),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24),
        ),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          // Drag handle
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header row
          Row(children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(type ?? 'QR Code',
                      style: TextStyle(
                        color: color,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      )),
                  Text('Scanned successfully',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.35),
                        fontSize: 11,
                      )),
                ],
              ),
            ),
            // Success badge
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF25D366).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF25D366).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_rounded,
                      color: Color(0xFF25D366), size: 13),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: onCancel,
                    child: const Text('Done',
                        style: TextStyle(
                          color: Color(0xFF25D366),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        )),
                  ),
                ],
              ),
            ),
          ]),

          const SizedBox(height: 14),

          // Value box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF141414),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
            child: Text(
              value,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.75),
                fontSize: 13,
                height: 1.5,
                fontFamily: 'monospace',
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          const SizedBox(height: 16),

          // Three action buttons
          Row(children: [
            Expanded(child: _ActionCard(
              icon:  Icons.copy_rounded,
              label: 'Copy',
              color: const Color(0xFF4C9BE8),
              onTap: onCopy,
            )),
            const SizedBox(width: 8),
            Expanded(child: _ActionCard(
              icon:  Icons.open_in_new_rounded,
              label: 'Open',
              color: color,
              onTap: onOpen,
            )),
            const SizedBox(width: 8),
            Expanded(child: _ActionCard(
              icon:  Icons.share_rounded,
              label: 'Share',
              color: const Color(0xFF1ABC9C),
              onTap: onShare,
            )),
          ]),

          const SizedBox(height: 10),

          // Cancel full width
          GestureDetector(
            onTap: onCancel,
            child: Container(
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.qr_code_scanner_rounded,
                      color: Colors.white.withValues(alpha: 0.4),
                      size: 18),
                  const SizedBox(width: 8),
                  Text('Scan Again',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Action card button ────────────────────────────────────────────────────────

class _ActionCard extends StatelessWidget {
  final IconData   icon;
  final String     label;
  final Color      color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.25),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 5),
            Text(label,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                )),
          ],
        ),
      ),
    );
  }
}