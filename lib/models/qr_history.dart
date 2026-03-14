import 'dart:convert';
import 'package:equatable/equatable.dart';

class QRHistory extends Equatable {
  final String   id;
  final String   type;
  final String   data;
  final String   label;
  final DateTime createdAt;
  final bool     isBookmarked;

  const QRHistory({
    required this.id,
    required this.type,
    required this.data,
    required this.label,
    required this.createdAt,
    this.isBookmarked = false,
  });

  QRHistory copyWith({
    String?   id,
    String?   type,
    String?   data,
    String?   label,
    DateTime? createdAt,
    bool?     isBookmarked,
  }) =>
      QRHistory(
        id:           id           ?? this.id,
        type:         type         ?? this.type,
        data:         data         ?? this.data,
        label:        label        ?? this.label,
        createdAt:    createdAt    ?? this.createdAt,
        isBookmarked: isBookmarked ?? this.isBookmarked,
      );

  Map<String, dynamic> toMap() => {
    'id':           id,
    'type':         type,
    'data':         data,
    'label':        label,
    'createdAt':    createdAt.toIso8601String(),
    'isBookmarked': isBookmarked,
  };

  factory QRHistory.fromMap(Map<String, dynamic> map) => QRHistory(
    id:           map['id'],
    type:         map['type'],
    data:         map['data'],
    label:        map['label'],
    createdAt:    DateTime.parse(map['createdAt']),
    isBookmarked: map['isBookmarked'] ?? false,
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
  List<Object?> get props => [id, type, data, label, createdAt, isBookmarked];
}