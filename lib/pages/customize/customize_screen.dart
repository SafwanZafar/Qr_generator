import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/theme.dart';
import '../../models/qr_config.dart';

class CustomizePage extends StatefulWidget {
  final String   qrData;
  final QRConfig config;
  final void Function(QRConfig) onChanged;

  const CustomizePage({
    super.key,
    required this.qrData,
    required this.config,
    required this.onChanged,
  });

  @override
  State<CustomizePage> createState() => _CustomizePageState();
}

class _CustomizePageState extends State<CustomizePage> {
  late QRConfig _config;

  // preset colors
  static const _colors = [
    Color(0xFF3B5BDB),  // blue
    Color(0xFFE03131),  // red
    Color(0xFF2F9E44),  // green
    Color(0xFF1A1A2E),  // dark
    Color(0xFFE67700),  // orange
    Color(0xFF7048E8),  // purple
  ];

  static const _styles = [
    _StyleItem(label: 'Square',  style: QRStyle.square),
    _StyleItem(label: 'Rounded', style: QRStyle.rounded),
    _StyleItem(label: 'Dots',    style: QRStyle.dots),
    _StyleItem(label: 'Classy',  style: QRStyle.classy),
  ];

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

  void _removeLogo() => _update(_config.copyWith(clearLogo: true));

  // get eye style based on QRStyle
  QrEyeStyle _eyeStyle() {
    switch (_config.style) {
      case QRStyle.rounded:
        return QrEyeStyle(
          eyeShape: QrEyeShape.circle,
          color:    _config.foregroundColor,
        );
      default:
        return QrEyeStyle(
          eyeShape: QrEyeShape.square,
          color:    _config.foregroundColor,
        );
    }
  }

  // get data module style based on QRStyle
  QrDataModuleStyle _moduleStyle() {
    switch (_config.style) {
      case QRStyle.rounded:
        return QrDataModuleStyle(
          dataModuleShape: QrDataModuleShape.circle,
          color:           _config.foregroundColor,
        );
      case QRStyle.dots:
        return QrDataModuleStyle(
          dataModuleShape: QrDataModuleShape.circle,
          color:           _config.foregroundColor,
        );
      default:
        return QrDataModuleStyle(
          dataModuleShape: QrDataModuleShape.square,
          color:           _config.foregroundColor,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.kBgColor,

      // ── AppBar ─────────────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor:        AppTheme.kBgColor,
        elevation:               0,
        scrolledUnderElevation:  0,
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
        title: const Text('Customize',
            style: TextStyle(
              color:      AppTheme.kTextDark,
              fontSize:   18,
              fontWeight: FontWeight.w700,
            )),
        actions: [
          // Reset button
          GestureDetector(
            onTap: () => _update(const QRConfig()),
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color:        AppTheme.kPrimary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('Reset',
                  style: TextStyle(
                    color:      AppTheme.kPrimary,
                    fontSize:   13,
                    fontWeight: FontWeight.w600,
                  )),
            ),
          ),
        ],
      ),

      // ── Body ───────────────────────────────────────────────────────
      body: Column(
        children: [

          // ── QR Preview ─────────────────────────────────────────────
          Container(
            width:  double.infinity,
            color:  AppTheme.kBgColor,
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Container(
                width:   200,
                height:  200,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color:        _config.backgroundColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppTheme.kBorderColor,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:      Colors.black.withValues(alpha: 0.08),
                      blurRadius: 20,
                      offset:     const Offset(0, 4),
                    ),
                  ],
                ),
                child: QrImageView(
                  data:            widget.qrData.isEmpty
                      ? 'https://example.com'
                      : widget.qrData,
                  version:         QrVersions.auto,
                  size:            168,
                  backgroundColor: _config.backgroundColor,
                  eyeStyle:        _eyeStyle(),
                  dataModuleStyle: _moduleStyle(),
                  embeddedImage: _config.logoPath != null
                      ? FileImage(File(_config.logoPath!))
                      : null,
                  embeddedImageStyle: QrEmbeddedImageStyle(
                    size: Size(
                      168 * _config.logoSize,
                      168 * _config.logoSize,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Sections ───────────────────────────────────────────────
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color:        AppTheme.kCardColor,
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color:      Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset:     const Offset(0, -2),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ── Colors ───────────────────────────────────────
                    const Text('Colors',
                        style: TextStyle(
                          color:      AppTheme.kTextDark,
                          fontSize:   16,
                          fontWeight: FontWeight.w700,
                        )),
                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: _colors.map((color) {
                        final selected =
                            _config.foregroundColor == color;
                        return GestureDetector(
                          onTap: () => _update(
                              _config.copyWith(
                                  foregroundColor: color)),
                          child: AnimatedContainer(
                            duration: const Duration(
                                milliseconds: 200),
                            width:  48,
                            height: 48,
                            decoration: BoxDecoration(
                              color:        color,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: selected
                                    ? color
                                    : Colors.transparent,
                                width: 3,
                              ),
                              boxShadow: selected
                                  ? [BoxShadow(
                                color:      color
                                    .withValues(alpha: 0.4),
                                blurRadius: 12,
                                offset:     const Offset(0, 4),
                              )]
                                  : [],
                            ),
                            child: selected
                                ? const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size:  22,
                            )
                                : null,
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 28),
                    Divider(
                        color: AppTheme.kBorderColor,
                        height: 1),
                    const SizedBox(height: 28),

                    // ── Style ────────────────────────────────────────
                    const Text('Style',
                        style: TextStyle(
                          color:      AppTheme.kTextDark,
                          fontSize:   16,
                          fontWeight: FontWeight.w700,
                        )),
                    const SizedBox(height: 16),

                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _styles.map((item) {
                          final selected =
                              _config.style == item.style;
                          return GestureDetector(
                            onTap: () => _update(
                                _config.copyWith(style: item.style)),
                            child: AnimatedContainer(
                              duration: const Duration(
                                  milliseconds: 200),
                              margin: const EdgeInsets.only(right: 10),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(
                                color: selected
                                    ? AppTheme.kPrimary
                                    : AppTheme.kBgColor,
                                borderRadius:
                                BorderRadius.circular(20),
                                border: Border.all(
                                  color: selected
                                      ? AppTheme.kPrimary
                                      : AppTheme.kBorderColor,
                                ),
                              ),
                              child: Text(item.label,
                                  style: TextStyle(
                                    color: selected
                                        ? Colors.white
                                        : AppTheme.kTextGray,
                                    fontSize:   14,
                                    fontWeight: selected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                  )),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 28),
                    Divider(
                        color: AppTheme.kBorderColor,
                        height: 1),
                    const SizedBox(height: 28),

                    // ── Add Logo ─────────────────────────────────────
                    const Text('Add Logo',
                        style: TextStyle(
                          color:      AppTheme.kTextDark,
                          fontSize:   16,
                          fontWeight: FontWeight.w700,
                        )),
                    const SizedBox(height: 16),

                    if (_config.logoPath != null) ...[
                      // Logo preview
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color:        AppTheme.kBgColor,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: AppTheme.kBorderColor),
                        ),
                        child: Row(children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(_config.logoPath!),
                              width:  50,
                              height: 50,
                              fit:    BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                const Text('Logo added',
                                    style: TextStyle(
                                      color:      AppTheme.kTextDark,
                                      fontSize:   14,
                                      fontWeight: FontWeight.w600,
                                    )),
                                const SizedBox(height: 4),
                                Text('Tap remove to clear',
                                    style: TextStyle(
                                      color:    AppTheme.kTextGray
                                          .withValues(alpha: 0.7),
                                      fontSize: 12,
                                    )),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: _removeLogo,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFEEEE),
                                borderRadius:
                                BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                  Icons.delete_outline_rounded,
                                  color: Color(0xFFE84C4C),
                                  size:  18),
                            ),
                          ),
                        ]),
                      ),

                      const SizedBox(height: 16),

                      // Logo size slider
                      Row(children: [
                        const Text('Size',
                            style: TextStyle(
                              color:    AppTheme.kTextGray,
                              fontSize: 13,
                            )),
                        Expanded(
                          child: SliderTheme(
                            data: SliderThemeData(
                              trackHeight:  2,
                              thumbShape:   const RoundSliderThumbShape(
                                  enabledThumbRadius: 8),
                              overlayShape: const RoundSliderOverlayShape(
                                  overlayRadius: 16),
                              activeTrackColor:   AppTheme.kPrimary,
                              inactiveTrackColor: AppTheme.kBorderColor,
                              thumbColor:         AppTheme.kPrimary,
                              overlayColor: AppTheme.kPrimary
                                  .withValues(alpha: 0.2),
                            ),
                            child: GestureDetector(
                              onHorizontalDragUpdate: (_) {},
                              child: Slider(
                                value:    _config.logoSize,
                                min:      0.1,
                                max:      0.35,
                                onChanged: (v) => _update(
                                    _config.copyWith(logoSize: v)),
                              ),
                            ),
                          ),
                        ),
                        Text(
                          '${(_config.logoSize * 100).toInt()}%',
                          style: const TextStyle(
                            color:    AppTheme.kTextGray,
                            fontSize: 13,
                          ),
                        ),
                      ]),

                    ] else ...[
                      // Upload box
                      GestureDetector(
                        onTap: _pickLogo,
                        child: Container(
                          width:  double.infinity,
                          height: 120,
                          decoration: BoxDecoration(
                            color:        AppTheme.kBgColor,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppTheme.kBorderColor,
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment:
                            MainAxisAlignment.center,
                            children: [
                              Container(
                                width:  48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: AppTheme.kPrimary
                                      .withValues(alpha: 0.1),
                                  borderRadius:
                                  BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                    Icons.image_outlined,
                                    color: AppTheme.kPrimary,
                                    size:  24),
                              ),
                              const SizedBox(height: 10),
                              const Text('Tap to upload logo',
                                  style: TextStyle(
                                    color:      AppTheme.kTextDark,
                                    fontSize:   14,
                                    fontWeight: FontWeight.w600,
                                  )),
                              const SizedBox(height: 4),
                              const Text('PNG, JPG up to 2MB',
                                  style: TextStyle(
                                    color:    AppTheme.kTextGray,
                                    fontSize: 12,
                                  )),
                            ],
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 28),

                    // ── Apply button ─────────────────────────────────
                    SizedBox(
                      width:  double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.kPrimary,
                          foregroundColor: Colors.white,
                          elevation:       0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text('Apply',
                            style: TextStyle(
                              fontSize:   16,
                              fontWeight: FontWeight.w700,
                            )),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Style item ────────────────────────────────────────────────────────────────

class _StyleItem {
  final String   label;
  final QRStyle  style;
  const _StyleItem({required this.label, required this.style});
}