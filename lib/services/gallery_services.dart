import 'dart:typed_data';
import 'package:saver_gallery/saver_gallery.dart';

class GalleryService {

  GalleryService._();

  static Future<bool> save(Uint8List bytes) async {
    try {
      final result = await SaverGallery.saveImage(
        bytes,
        fileName: 'QR_${DateTime.now().millisecondsSinceEpoch}',
        skipIfExists: false,
      );
      return result.isSuccess;
    } catch (_) {
      return false;
    }
  }
}