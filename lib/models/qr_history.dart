import 'dart:convert';
import 'package:equatable/equatable.dart';

class QRHistory extends Equatable {
  final String id;
  final String type;
  final String data;
  final String label;
  final DateTime createdAt;

  const QRHistory({
    required this.id,
    required this.type,
    required this.data,
    required this.label,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'id':        id,
    'type':      type,
    'data':      data,
    'label':     label,
    'createdAt': createdAt.toIso8601String(),
  };

  factory QRHistory.fromMap(Map<String, dynamic> map) => QRHistory(
    id:        map['id'],
    type:      map['type'],
    data:      map['data'],
    label:     map['label'],
    createdAt: DateTime.parse(map['createdAt']),
  );

  String toJson() => jsonEncode(toMap());
  factory QRHistory.fromJson(String source) =>
      QRHistory.fromMap(jsonDecode(source));

  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 1)  return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24)   return '${diff.inHours} hour ago';
    if (diff.inDays == 1)    return 'Yesterday';
    return '${diff.inDays} days ago';
  }

  @override
  List<Object?> get props => [id, type, data, label, createdAt];
}