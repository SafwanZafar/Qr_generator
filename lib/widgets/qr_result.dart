import 'dart:io';
import 'package:flutter/material.dart';
import 'package:qr_code_generator/models/qr_config.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'action_button.dart';

class QRResult extends StatelessWidget {
  final GlobalKey    qrKey;
  final String       qrData;
  final Color        color;
  final IconData     icon;
  final String       label;
  final bool         saving;
  final bool         sharing;
  final QRConfig     config;
  final VoidCallback onSave;
  final VoidCallback onShare;
  final VoidCallback onCustomize;

  const QRResult({
    super.key,
    required this.qrKey,
    required this.qrData,
    required this.color,
    required this.icon,
    required this.label,
    required this.saving,
    required this.sharing,
    required this.config,
    required this.onSave,
    required this.onShare,
    required this.onCustomize,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your QR Code',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 12,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1C),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(children: [

            // QR image
            RepaintBoundary(
              key: qrKey,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: config.backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: QrImageView(
                  data: qrData,
                  version: QrVersions.auto,
                  size: 200,
                  backgroundColor: config.backgroundColor,
                  errorCorrectionLevel: QrErrorCorrectLevel.H,
                  eyeStyle: QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: config.foregroundColor,
                  ),
                  dataModuleStyle: QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: config.foregroundColor,
                  ),
                  embeddedImage: config.logoPath != null
                      ? FileImage(File(config.logoPath!))
                      : null,
                  embeddedImageStyle: QrEmbeddedImageStyle(
                    size: Size(
                      200 * config.logoSize,
                      200 * config.logoSize,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Type tag + data row
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: color, size: 12),
                    const SizedBox(width: 5),
                    Text(label,
                        style: TextStyle(
                          color: color,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        )),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  qrData,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.35),
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ]),

            const SizedBox(height: 16),
            Divider(color: Colors.white.withValues(alpha: 0.06), height: 1),
            const SizedBox(height: 16),

            // Save and Share buttons
            Row(children: [
              Expanded(child: ActionButton(
                label:   saving ? 'Saving...' : 'Save',
                icon:    Icons.download_rounded,
                color:   color,
                filled:  false,
                loading: saving,
                onTap:   onSave,
              )),
              const SizedBox(width: 10),
              Expanded(child: ActionButton(
                label:   sharing ? 'Sharing...' : 'Share',
                icon:    Icons.share_rounded,
                color:   color,
                filled:  true,
                loading: sharing,
                onTap:   onShare,
              )),
            ]),

            const SizedBox(height: 8),

            // Customize Colors full width button
            GestureDetector(
              onTap: onCustomize,
              child: Container(
                width: double.infinity,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFF252525),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: color.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.palette_rounded,
                      color: color,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Customize Colors & Logo',
                      style: TextStyle(
                        color: color,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          ]),
        ),
      ],
    );
  }
}