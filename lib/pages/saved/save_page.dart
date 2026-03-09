import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../bloc/saved/saved_bloc.dart';
import '../../bloc/saved/saved_event.dart';
import '../../bloc/saved/saved_state.dart';
import '../../core/theme.dart';
import '../../models/qr_history.dart';
import '../../services/gallery_services.dart';

class SavedPage extends StatelessWidget {
  const SavedPage({super.key});

  static const _filters = [
    'All', 'Website', 'WiFi', 'Contact',
    'Text', 'Email', 'Phone', 'WhatsApp',
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SavedBloc()..add(const SavedLoadEvent()),
      child: const _SavedView(),
    );
  }
}

class _SavedView extends StatefulWidget {
  const _SavedView({super.key});

  @override
  State<_SavedView> createState() => _SavedViewState();
}

class _SavedViewState extends State<_SavedView> {

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    context.read<SavedBloc>().add(const SavedLoadEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.kBgColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── App Bar ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: BlocBuilder<SavedBloc, SavedState>(
                builder: (context, state) {
                  final count = state is SavedLoaded
                      ? state.all.length : 0;
                  return Row(children: [
                    GestureDetector(
                      onTap: () => Navigator.maybePop(context),
                      child: Container(
                        width:  40,
                        height: 40,
                        decoration: BoxDecoration(
                          color:        AppTheme.kCardColor,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppTheme.kBorderColor),
                        ),
                        child: const Icon(Icons.arrow_back_rounded,
                            color: AppTheme.kTextDark, size: 20),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text('Saved QR Codes',
                          style: TextStyle(
                            color:      AppTheme.kTextDark,
                            fontSize:   20,
                            fontWeight: FontWeight.w800,
                          )),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color:        AppTheme.kPrimary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('$count',
                          style: const TextStyle(
                            color:      Colors.white,
                            fontSize:   13,
                            fontWeight: FontWeight.w700,
                          )),
                    ),
                  ]);
                },
              ),
            ),

            const SizedBox(height: 16),

            // ── Filter chips ─────────────────────────────────────────
            BlocBuilder<SavedBloc, SavedState>(
              builder: (context, state) {
                final active = state is SavedLoaded
                    ? state.activeFilter : 'All';
                return SizedBox(
                  height: 38,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: SavedPage._filters.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, i) {
                      final f        = SavedPage._filters[i];
                      final selected = active == f;
                      return GestureDetector(
                        onTap: () => context
                            .read<SavedBloc>()
                            .add(SavedFilterEvent(f)),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppTheme.kPrimary
                                : AppTheme.kCardColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: selected
                                  ? AppTheme.kPrimary
                                  : AppTheme.kBorderColor,
                            ),
                          ),
                          child: Text(f,
                              style: TextStyle(
                                color: selected
                                    ? Colors.white
                                    : AppTheme.kTextGray,
                                fontSize:   13,
                                fontWeight: selected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              )),
                        ),
                      );
                    },
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            // ── List ─────────────────────────────────────────────────
            Expanded(
              child: BlocBuilder<SavedBloc, SavedState>(
                builder: (context, state) {
                  if (state is SavedLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                          color: AppTheme.kPrimary),
                    );
                  }
                  if (state is SavedLoaded) {
                    if (state.filtered.isEmpty) {
                      return _EmptyState(filter: state.activeFilter);
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                      itemCount: state.filtered.length,
                      separatorBuilder: (_, __) =>
                      const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        final item = state.filtered[i];
                        return _QRCard(
                          item:    item,
                          saving:  state.savingIds.contains(item.id),
                          sharing: state.sharingIds.contains(item.id),
                        );
                      },
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── QR Card ───────────────────────────────────────────────────────────────────

class _QRCard extends StatelessWidget {
  final QRHistory item;
  final bool      saving;
  final bool      sharing;

  _QRCard({
    required this.item,
    required this.saving,
    required this.sharing,
  });

  final GlobalKey _qrKey = GlobalKey();

  Color _typeColor(String type) {
    switch (type) {
      case 'Website':  return const Color(0xFF4C9BE8);
      case 'WhatsApp': return const Color(0xFF25D366);
      case 'Phone':    return const Color(0xFFFF6B35);
      case 'Email':    return const Color(0xFFE85D75);
      case 'WiFi':     return const Color(0xFF9B59B6);
      case 'Location': return const Color(0xFF1ABC9C);
      case 'Contact':  return const Color(0xFFFF8C42);
      case 'SMS':      return const Color(0xFFFFB800);
      default:         return const Color(0xFF95A5A6);
    }
  }

  String _typeShortLabel(String type) {
    switch (type) {
      case 'Website': return 'URL';
      case 'Contact': return 'vCard';
      default:        return type;
    }
  }

  Future<Uint8List?> _capture() async {
    try {
      final boundary = _qrKey.currentContext!
          .findRenderObject()! as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      return bytes == null ? null : Uint8List.view(bytes.buffer);
    } catch (_) {
      return null;
    }
  }

  Future<void> _save(BuildContext context) async {
    final bytes = await _capture();
    if (bytes == null) return;
    final ok = await GalleryService.save(bytes);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ok ? 'Saved!' : 'Could not save'),
        backgroundColor: ok
            ? AppTheme.kSuccessColor
            : AppTheme.kErrorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)),
        margin:   const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ));
    }
  }

  Future<void> _share(BuildContext context) async {
    final bytes = await _capture();
    if (bytes == null) return;
    context.read<SavedBloc>().add(SavedShareImageEvent(item.id, bytes));
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete QR Code?',
            style: TextStyle(
              color:      AppTheme.kTextDark,
              fontSize:   16,
              fontWeight: FontWeight.w700,
            )),
        content: const Text('This will be permanently deleted.',
            style: TextStyle(
              color:    AppTheme.kTextGray,
              fontSize: 14,
            )),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: AppTheme.kTextGray)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<SavedBloc>().add(SavedDeleteEvent(item.id));
            },
            child: const Text('Delete',
                style: TextStyle(color: Color(0xFFE84C4C))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = _typeColor(item.type);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:        AppTheme.kCardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color:      Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset:     const Offset(0, 2),
          ),
        ],
      ),
      child: Row(children: [

        // QR thumbnail
        RepaintBoundary(
          key: _qrKey,
          child: Container(
            width:   64,
            height:  64,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color:        color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: QrImageView(
              data:            item.data,
              version:         QrVersions.auto,
              size:            56,
              backgroundColor: Colors.transparent,
              eyeStyle: QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color:    color,
              ),
              dataModuleStyle: QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color:           color,
              ),
            ),
          ),
        ),

        const SizedBox(width: 14),

        // Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.label,
                style: const TextStyle(
                  color:      AppTheme.kTextDark,
                  fontSize:   15,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                '${_typeShortLabel(item.type)} · ${item.timeAgo}',
                style: const TextStyle(
                  color:    AppTheme.kTextGray,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 8),

        // Share
        _ActionBtn(
          icon:    Icons.share_rounded,
          color:   const Color(0xFF4C9BE8),
          bg:      const Color(0xFFEEF4FF),
          loading: sharing,
          onTap:   () => _share(context),
        ),

        const SizedBox(width: 8),

        // Download
        _ActionBtn(
          icon:    Icons.download_rounded,
          color:   const Color(0xFF25A244),
          bg:      const Color(0xFFEEF9F1),
          loading: saving,
          onTap:   () => _save(context),
        ),

        const SizedBox(width: 8),

        // Delete
        GestureDetector(
          onTap: () => _confirmDelete(context),
          child: Container(
            width:  34,
            height: 34,
            decoration: BoxDecoration(
              color:        const Color(0xFFFFEEEE),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.delete_outline_rounded,
              color: Color(0xFFE84C4C),
              size:  16,
            ),
          ),
        ),
      ]),
    );
  }
}

// ── Action button ─────────────────────────────────────────────────────────────

class _ActionBtn extends StatelessWidget {
  final IconData     icon;
  final Color        color;
  final Color        bg;
  final bool         loading;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.icon,
    required this.color,
    required this.bg,
    required this.loading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width:  38,
        height: 38,
        decoration: BoxDecoration(
          color:        bg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: loading
            ? Padding(
          padding: const EdgeInsets.all(10),
          child: CircularProgressIndicator(
            color:       color,
            strokeWidth: 2,
          ),
        )
            : Icon(icon, color: color, size: 18),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final String filter;
  const _EmptyState({required this.filter});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width:  80,
            height: 80,
            decoration: BoxDecoration(
              color:        AppTheme.kPrimary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.bookmark_outline_rounded,
                color: AppTheme.kPrimary, size: 36),
          ),
          const SizedBox(height: 16),
          Text(
            filter == 'All'
                ? 'No saved QR codes yet'
                : 'No $filter QR codes found',
            style: const TextStyle(
              color:      AppTheme.kTextDark,
              fontSize:   16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Generate a QR code and it will\nappear here automatically',
            textAlign: TextAlign.center,
            style: TextStyle(
              color:    AppTheme.kTextGray,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}