import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ShareService {
  ShareService._();

  static Future<void> shareImage(Uint8List bytes) async {
    final dir  = await getTemporaryDirectory();
    final file = File('${dir.path}/qr_code.png')
      ..writeAsBytesSync(bytes);
    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Here is my QR code!',
    );
  }
}