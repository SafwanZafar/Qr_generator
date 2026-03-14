import 'package:flutter/material.dart';

enum ScannerStatus { idle, scanning, success }

class ScannerProvider extends ChangeNotifier {

  ScannerStatus _status      = ScannerStatus.idle;
  String        _scannedCode = '';
  bool          _torchOn     = false;

  ScannerStatus get status      => _status;
  String        get scannedCode => _scannedCode;
  bool          get torchOn     => _torchOn;
  bool          get hasResult   =>
      _scannedCode.isNotEmpty && _status == ScannerStatus.success;

  void startScanning() {
    _status = ScannerStatus.scanning;
    notifyListeners();
  }

  void codeDetected(String code) {
    _scannedCode = code;
    _status      = ScannerStatus.success;
    notifyListeners();
  }

  void toggleTorch() {
    _torchOn = !_torchOn;
    notifyListeners();
  }

  void reset() {
    _status      = ScannerStatus.idle;
    _scannedCode = '';
    notifyListeners();
  }
}