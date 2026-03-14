import 'package:flutter/material.dart';
import '../models/qr_config.dart';
import '../models/qr_history.dart';
import '../models/qr_type.dart';
import '../services/history_service.dart';
import '../services/qr_builder_service.dart';

enum GeneratorStatus { initial, loading, success, error }

class GeneratorProvider extends ChangeNotifier {

  QRType          _type    = QRType.website;
  QRConfig        _config  = const QRConfig();
  String          _qrData  = '';
  GeneratorStatus _status  = GeneratorStatus.initial;
  String?         _error;

  QRType          get type      => _type;
  QRConfig        get config    => _config;
  String          get qrData    => _qrData;
  GeneratorStatus get status    => _status;
  String?         get error     => _error;
  bool            get hasResult =>
      _qrData.isNotEmpty && _status == GeneratorStatus.success;

  void changeType(QRType type) {
    _type   = type;
    _qrData = '';
    _status = GeneratorStatus.initial;
    _error  = null;
    notifyListeners();
  }

  void updateConfig(QRConfig config) {
    _config = config;
    notifyListeners();
  }

  void applyTemplate(QRConfig config) {
    _config = config;
    _qrData = '';
    _status = GeneratorStatus.initial;
    notifyListeners();
  }

  void reset() {
    _type   = QRType.website;
    _config = const QRConfig();
    _qrData = '';
    _status = GeneratorStatus.initial;
    _error  = null;
    notifyListeners();
  }

  Future<bool> generate({
    required String f1,
    required String f2,
    required String f3,
    required String historyId,
    required String label,      // ← ADD
  }) async {
    final err = QRBuilderService.validate(
      type: _type,
      f1:   f1,
      f2:   f2,
    );

    if (err != null) {
      _status = GeneratorStatus.error;
      _error  = err;
      notifyListeners();
      return false;
    }

    _status = GeneratorStatus.loading;
    notifyListeners();

    final data = QRBuilderService.build(
      type: _type,
      f1:   f1,
      f2:   f2,
      f3:   f3,
    );

    await HistoryService.save(QRHistory(
      id:        historyId,
      type:      _typeLabel(_type),
      data:      data,
      label:     label,          // ← user ka label use karo
      createdAt: DateTime.now(),
    ));

    _qrData = data;
    _status = GeneratorStatus.success;
    _error  = null;
    notifyListeners();
    return true;
  }

  String _typeLabel(QRType type) {
    switch (type) {
      case QRType.website:  return 'Website';
      case QRType.whatsapp: return 'WhatsApp';
      case QRType.phone:    return 'Phone';
      case QRType.sms:      return 'SMS';
      case QRType.email:    return 'Email';
      case QRType.wifi:     return 'WiFi';
      case QRType.location: return 'Location';
      case QRType.contact:  return 'Contact';
      case QRType.text:     return 'Text';
    }
  }
}