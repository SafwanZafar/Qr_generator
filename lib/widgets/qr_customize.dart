import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/qr_config.dart';

class QRCustomizer extends StatefulWidget {
  final String    qrData;
  final QRConfig  config;
  final ValueChanged<QRConfig> onChanged;

  const QRCustomizer({
    super.key,
    required this.qrData,
    required this.config,
    required this.onChanged,
  });

  @override
  State<QRCustomizer> createState() => _QRCustomizerState();
}

class _QRCustomizerState extends State<QRCustomizer> {
  late QRConfig _config;

  @override
  void initState() {
    super.initState();
    _config = widget.config;
  }

  void _update(QRConfig c) {
    setState(() => _config = c);
    widget.onChanged(c);
  }

  Future<void> _pickLogo() async {
    final picker = ImagePicker();
    final file   = await picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;
    _update(_config.copyWith(logoPath: file.path));
  }

  void _removeLogo() {
    _update(_config.copyWith(clearLogo: true));
  }

  void _pickColor({required bool isForeground}) {
    Color temp = isForeground
        ? _config.foregroundColor
        : _config.backgroundColor;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1C1C1C),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            isForeground ? 'QR Color' : 'Background Color',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: temp,
              onColorChanged: (c) {
                setDialogState(() => temp = c);
              },
              labelTypes: const [],
              pickerAreaHeightPercent: 0.7,
              hexInputBar: true,
              displayThumbColor: true,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4))),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                if (isForeground) {
                  _update(_config.copyWith(foregroundColor: temp));
                } else {
                  _update(_config.copyWith(backgroundColor: temp));
                }
              },
              child: const Text('Apply',
                  style: TextStyle(color: Color(0xFF4C9BE8))),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Header
          Row(children: [
            Container(
              width: 3,
              height: 16,
              decoration: BoxDecoration(
                color: const Color(0xFF4C9BE8),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            const Text('Customize',
                style: TextStyle(
                  color: Color(0xFF4C9BE8),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                )),
          ]),

          const SizedBox(height: 16),

          // QR Preview
          Center(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _config.backgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
              child: QrImageView(
                data: widget.qrData,
                version: QrVersions.auto,
                size: 180,
                backgroundColor: _config.backgroundColor,
                eyeStyle: QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: _config.foregroundColor,
                ),
                dataModuleStyle: QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: _config.foregroundColor,
                ),
                embeddedImage: _config.logoPath != null
                    ? FileImage(File(_config.logoPath!))
                    : null,
                embeddedImageStyle: QrEmbeddedImageStyle(
                  size: Size(
                    180 * _config.logoSize,
                    180 * _config.logoSize,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),
          Divider(color: Colors.white.withValues(alpha: 0.06), height: 1),
          const SizedBox(height: 20),

          // Color options
          _sectionLabel('Colors'),
          const SizedBox(height: 12),

          Row(children: [
            Expanded(child: _ColorTile(
              label: 'QR Color',
              color: _config.foregroundColor,
              onTap: () => _pickColor(isForeground: true),
            )),
            const SizedBox(width: 10),
            Expanded(child: _ColorTile(
              label: 'Background',
              color: _config.backgroundColor,
              onTap: () => _pickColor(isForeground: false),
            )),
          ]),

          const SizedBox(height: 20),

          // Presets
          _sectionLabel('Presets'),
          const SizedBox(height: 12),
          _ColorPresets(
            onSelected: (fg, bg) => _update(
              _config.copyWith(
                foregroundColor: fg,
                backgroundColor: bg,
              ),
            ),
          ),

          const SizedBox(height: 20),
          Divider(color: Colors.white.withValues(alpha: 0.06), height: 1),
          const SizedBox(height: 20),

          // Logo section
          _sectionLabel('Logo / Icon'),
          const SizedBox(height: 12),

          if (_config.logoPath != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF141414),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
              child: Row(children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(_config.logoPath!),
                    width: 44,
                    height: 44,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Logo added',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          )),
                      const SizedBox(height: 2),
                      Text('Tap remove to clear',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.35),
                            fontSize: 11,
                          )),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: _removeLogo,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE85D75).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.close_rounded,
                        color: Color(0xFFE85D75), size: 16),
                  ),
                ),
              ]),
            ),

            const SizedBox(height: 10),

            // Logo size slider
            Row(children: [
              Text('Size',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 12,
                  )),
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 2,
                    thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 8),
                    overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 16),
                    activeTrackColor: const Color(0xFF4C9BE8),
                    inactiveTrackColor: Colors.white.withValues(alpha: 0.1),
                    thumbColor: const Color(0xFF4C9BE8),
                    overlayColor:
                    const Color(0xFF4C9BE8).withValues(alpha: 0.2),
                  ),
                  child: Slider(
                    value: _config.logoSize,
                    min: 0.1,
                    max: 0.35,
                    onChanged: (v) =>
                        _update(_config.copyWith(logoSize: v)),
                  ),
                ),
              ),
              Text('${(_config.logoSize * 100).toInt()}%',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 12,
                  )),
            ]),
          ] else ...[
            GestureDetector(
              onTap: _pickLogo,
              child: Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFF141414),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_photo_alternate_rounded,
                        color: Colors.white.withValues(alpha: 0.4),
                        size: 20),
                    const SizedBox(width: 8),
                    Text('Add logo from gallery',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.4),
                          fontSize: 13,
                        )),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 20),

          // Reset button
          GestureDetector(
            onTap: () => _update(const QRConfig()),
            child: Container(
              width: double.infinity,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF141414),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.refresh_rounded,
                      color: Colors.white.withValues(alpha: 0.35),
                      size: 16),
                  const SizedBox(width: 6),
                  Text('Reset to default',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.35),
                        fontSize: 13,
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(
    text,
    style: TextStyle(
      color: Colors.white.withValues(alpha: 0.4),
      fontSize: 11,
      letterSpacing: 0.5,
    ),
  );
}

// ── Color tile ────────────────────────────────────────────────────────────────

class _ColorTile extends StatelessWidget {
  final String       label;
  final Color        color;
  final VoidCallback onTap;

  const _ColorTile({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF141414),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Row(children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.15),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 11,
                    )),
                Text(
                  '#${color.value.toRadixString(16).substring(2).toUpperCase()}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.edit_rounded,
              color: Colors.white.withValues(alpha: 0.25), size: 14),
        ]),
      ),
    );
  }
}

// ── Color presets ─────────────────────────────────────────────────────────────

class _ColorPresets extends StatelessWidget {
  final void Function(Color fg, Color bg) onSelected;

  const _ColorPresets({required this.onSelected});

  static const _presets = [
    {'label': 'Classic', 'fg': Color(0xFF000000), 'bg': Color(0xFFFFFFFF)},
    {'label': 'Night',   'fg': Color(0xFFFFFFFF), 'bg': Color(0xFF141414)},
    {'label': 'Ocean',   'fg': Color(0xFF1A6B9A), 'bg': Color(0xFFE8F4FD)},
    {'label': 'Forest',  'fg': Color(0xFF1E5C2E), 'bg': Color(0xFFE8F5E9)},
    {'label': 'Sunset',  'fg': Color(0xFFBF360C), 'bg': Color(0xFFFFF3E0)},
    {'label': 'Purple',  'fg': Color(0xFF4A148C), 'bg': Color(0xFFF3E5F5)},
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _presets.map((p) {
        final fg = p['fg'] as Color;
        final bg = p['bg'] as Color;
        return GestureDetector(
          onTap: () => onSelected(fg, bg),
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: fg,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 6),
              Text(p['label'] as String,
                  style: TextStyle(
                    color: fg,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  )),
            ]),
          ),
        );
      }).toList(),
    );
  }
}