import 'package:flutter/material.dart';
import '../models/qr_config.dart';

class CustomizeProvider extends ChangeNotifier {

  QRConfig _config = const QRConfig();

  QRConfig get config => _config;

  void updateColor(Color color) {
    _config = _config.copyWith(foregroundColor: color);
    notifyListeners();
  }

  void updateStyle(QRStyle style) {
    _config = _config.copyWith(style: style);
    notifyListeners();
  }

  void updateLogo(String? path) {
    if (path == null) {
      _config = _config.copyWith(clearLogo: true);
    } else {
      _config = _config.copyWith(logoPath: path);
    }
    notifyListeners();
  }

  void updateLogoSize(double size) {
    _config = _config.copyWith(logoSize: size);
    notifyListeners();
  }

  void loadConfig(QRConfig config) {
    _config = config;
    notifyListeners();
  }

  void reset() {
    _config = const QRConfig();
    notifyListeners();
  }
}