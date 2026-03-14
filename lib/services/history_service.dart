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

  // ── Bookmark toggle ──────────────────────────────────────────
  static Future<void> toggleBookmark(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final list  = prefs.getStringList(_key) ?? [];
    final updated = list.map((e) {
      final map = jsonDecode(e) as Map<String, dynamic>;
      if (map['id'] == id) {
        map['isBookmarked'] = !(map['isBookmarked'] ?? false);
        return jsonEncode(map);
      }
      return e;
    }).toList();
    await prefs.setStringList(_key, updated);
  }

  // ── Load only bookmarked ─────────────────────────────────────
  static Future<List<QRHistory>> loadBookmarked() async {
    final all = await load();
    return all.where((e) => e.isBookmarked).toList();
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}