import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/qr_history.dart';

class HistoryService {
  static const _key = 'qr_history';

  static Future<List<QRHistory>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw   = prefs.getStringList(_key) ?? [];
    return raw
        .map((e) => QRHistory.fromJson(e))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  static Future<void> save(QRHistory item) async {
    final prefs = await SharedPreferences.getInstance();
    final list  = prefs.getStringList(_key) ?? [];
    list.insert(0, item.toJson());
    // keep only last 50
    if (list.length > 50) list.removeLast();
    await prefs.setStringList(_key, list);
  }

  static Future<void> delete(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final list  = prefs.getStringList(_key) ?? [];
    list.removeWhere((e) {
      final map = jsonDecode(e) as Map<String, dynamic>;
      return map['id'] == id;
    });
    await prefs.setStringList(_key, list);
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}