import '../models/qr_type.dart';

class QRBuilderService {
  QRBuilderService._();

  static String build({
    required QRType type,
    required String f1,
    required String f2,
    required String f3,
  }) {
    switch (type) {
      case QRType.website:
        return f1.startsWith('http') ? f1 : 'https://$f1';

      case QRType.whatsapp:
        final n = f1.replaceAll(RegExp(r'[+ ]'), '');
        return 'https://wa.me/$n'
            '${f2.isNotEmpty ? '?text=${Uri.encodeComponent(f2)}' : ''}';

      case QRType.phone:
        return 'tel:$f1';

      case QRType.sms:
        return 'sms:$f1'
            '${f2.isNotEmpty ? '?body=${Uri.encodeComponent(f2)}' : ''}';

      case QRType.email:
        return 'mailto:$f1'
            '${f2.isNotEmpty ? '?subject=${Uri.encodeComponent(f2)}' : ''}'
            '${f3.isNotEmpty ? '&body=${Uri.encodeComponent(f3)}' : ''}';

      case QRType.wifi:
        return 'WIFI:S:$f1;T:${f3.isEmpty ? 'WPA' : f3};P:$f2;;';

      case QRType.location:
        return 'geo:$f1,$f2';

      case QRType.contact:
        return 'MECARD:N:$f1;TEL:$f2;'
            '${f3.isNotEmpty ? 'EMAIL:$f3;' : ''}';

      case QRType.text:
        return f1;
    }
  }

  static String? validate({
    required QRType type,
    required String f1,
    required String f2,
  }) {
    switch (type) {
      case QRType.website:
        if (f1.isEmpty) return 'Please enter a URL';
        break;
      case QRType.whatsapp:
      case QRType.phone:
      case QRType.sms:
        if (f1.isEmpty) return 'Please enter a phone number';
        break;
      case QRType.email:
        if (f1.isEmpty) return 'Please enter an email';
        break;
      case QRType.wifi:
        if (f1.isEmpty) return 'Please enter WiFi name';
        break;
      case QRType.location:
        if (f1.isEmpty || f2.isEmpty) {
          return 'Please enter latitude and longitude';
        }
        break;
      case QRType.contact:
        if (f1.isEmpty) return 'Please enter a name';
        break;
      case QRType.text:
        if (f1.isEmpty) return 'Please enter some text';
        break;
    }
    return null;
  }
}