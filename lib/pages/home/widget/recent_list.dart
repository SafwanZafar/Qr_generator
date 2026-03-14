import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../models/qr_history.dart';

class RecentList extends StatelessWidget {
  final List<QRHistory> history;
  final List<QRHistory> filtered;    // ← ADD
  final String          searchQuery; // ← ADD
  final void Function(String id) onDelete;
  final VoidCallback onSeeAll;

  const RecentList({
    super.key,
    required this.history,
    required this.onDelete,
    required this.onSeeAll,
    this.filtered    = const [],
    this.searchQuery = '',
  });

  Color _typeColor(String type) {
    switch (type) {
      case 'Website':  return const Color(0xFF4C9BE8);
      case 'WhatsApp': return const Color(0xFF25D366);
      case 'Phone':    return const Color(0xFFFF6B35);
      case 'SMS':      return const Color(0xFFFFB800);
      case 'Email':    return const Color(0xFFE85D75);
      case 'WiFi':     return const Color(0xFF9B59B6);
      case 'Location': return const Color(0xFF1ABC9C);
      case 'Contact':  return const Color(0xFFFF8C42);
      default:         return const Color(0xFF95A5A6);
    }
  }

  @override
  Widget build(BuildContext context) {
    // search ho rahi hai toh filtered use karo warna history
    final list = searchQuery.isNotEmpty ? filtered : history;
    // max 5 show karo
    final items = list.length > 5 ? list.sublist(0, 5) : list;

    return Column(
      children: [
        // ── Header ───────────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              searchQuery.isNotEmpty
                  ? 'Search Results (${filtered.length})'
                  : 'Recent QR Codes',
              style: const TextStyle(
                color:      AppTheme.kTextDark,
                fontSize:   17,
                fontWeight: FontWeight.w700,
              ),
            ),
            GestureDetector(
              onTap: onSeeAll,
              child: const Text('See All',
                  style: TextStyle(
                    color:      AppTheme.kPrimary,
                    fontSize:   14,
                    fontWeight: FontWeight.w600,
                  )),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // ── Empty state ───────────────────────────────────────────
        if (items.isEmpty)
          Container(
            width:   double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color:        AppTheme.kCardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(children: [
              Icon(
                searchQuery.isNotEmpty
                    ? Icons.search_off_rounded
                    : Icons.qr_code_2_rounded,
                color: AppTheme.kTextGray.withValues(alpha: 0.4),
                size:  40,
              ),
              const SizedBox(height: 10),
              Text(
                searchQuery.isNotEmpty
                    ? 'No results for "$searchQuery"'
                    : 'No QR codes yet',
                style: const TextStyle(
                  color:    AppTheme.kTextGray,
                  fontSize: 14,
                ),
              ),
            ]),
          )

        // ── List ──────────────────────────────────────────────────
        else
          ListView.separated(
            shrinkWrap: true,
            physics:    const NeverScrollableScrollPhysics(),
            itemCount:  items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final item  = items[i];
              final color = _typeColor(item.type);
              return Container(
                decoration: BoxDecoration(
                  color:        AppTheme.kCardColor,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color:      Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset:     const Offset(0, 2),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical:   6,
                  ),
                  leading: Container(
                    width:  46,
                    height: 46,
                    decoration: BoxDecoration(
                      color:        color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.qr_code_rounded,
                        color: color, size: 22),
                  ),
                  title: Text(item.label,
                      style: const TextStyle(
                        color:      AppTheme.kTextDark,
                        fontSize:   14,
                        fontWeight: FontWeight.w600,
                      )),
                  subtitle: Text(
                    '${item.type} · ${item.timeAgo}',
                    style: const TextStyle(
                      color:    AppTheme.kTextGray,
                      fontSize: 12,
                    ),
                  ),
                  trailing: PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert_rounded,
                        color: AppTheme.kTextGray, size: 18),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    onSelected: (val) {
                      if (val == 'delete') onDelete(item.id);
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(children: [
                          Icon(Icons.delete_outline_rounded,
                              color: Color(0xFFE85D75), size: 16),
                          SizedBox(width: 8),
                          Text('Delete',
                              style: TextStyle(
                                  color: Color(0xFFE85D75))),
                        ]),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}