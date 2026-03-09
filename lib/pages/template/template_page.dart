import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/theme.dart';
import '../../models/qr_config.dart';
import '../../models/qr_template.dart';
import '../../template/template_bloc.dart';
import '../../template/template_event.dart';
import '../../template/template_state.dart';

class TemplatePage extends StatelessWidget {
  final String       qrData;
  final void Function(QRConfig config) onApply;

  const TemplatePage({
    super.key,
    required this.qrData,
    required this.onApply,
  });

  static const _filters = [
    'All', 'Business', 'Social',
    'WiFi', 'Personal', 'Dark',
    'Minimal', 'Holiday',
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TemplateBloc(),
      child: _TemplateView(
        qrData:  qrData,
        onApply: onApply,
      ),
    );
  }
}

class _TemplateView extends StatelessWidget {
  final String                      qrData;
  final void Function(QRConfig) onApply;

  const _TemplateView({
    required this.qrData,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.kBgColor,
      body: SafeArea(
        child: Column(
          children: [

            // ── App Bar ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(children: [
                GestureDetector(
                  onTap: () => Navigator.maybePop(context),
                  child: Container(
                    width:  40,
                    height: 40,
                    decoration: BoxDecoration(
                      color:        AppTheme.kCardColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: AppTheme.kBorderColor),
                    ),
                    child: const Icon(
                        Icons.arrow_back_rounded,
                        color: AppTheme.kTextDark,
                        size:  20),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text('Templates',
                      style: TextStyle(
                        color:      AppTheme.kTextDark,
                        fontSize:   20,
                        fontWeight: FontWeight.w800,
                      )),
                ),

                // Search button
                GestureDetector(
                  onTap: () => _showSearch(context),
                  child: Container(
                    width:  40,
                    height: 40,
                    decoration: BoxDecoration(
                      color:        AppTheme.kCardColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: AppTheme.kBorderColor),
                    ),
                    child: const Icon(
                        Icons.search_rounded,
                        color: AppTheme.kTextDark,
                        size:  20),
                  ),
                ),
              ]),
            ),

            const SizedBox(height: 16),

            // ── Filter chips ─────────────────────────────────────────
            BlocBuilder<TemplateBloc, TemplateState>(
              builder: (context, state) {
                final active = state is TemplateLoaded
                    ? state.activeFilter : 'All';
                return SizedBox(
                  height: 38,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16),
                    itemCount: TemplatePage._filters.length,
                    separatorBuilder: (_, __) =>
                    const SizedBox(width: 8),
                    itemBuilder: (context, i) {
                      final f        = TemplatePage._filters[i];
                      final selected = active == f;
                      return GestureDetector(
                        onTap: () => context
                            .read<TemplateBloc>()
                            .add(TemplateFilterEvent(f)),
                        child: AnimatedContainer(
                          duration: const Duration(
                              milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppTheme.kPrimary
                                : AppTheme.kCardColor,
                            borderRadius:
                            BorderRadius.circular(20),
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

            // ── Grid ─────────────────────────────────────────────────
            Expanded(
              child: BlocBuilder<TemplateBloc, TemplateState>(
                builder: (context, state) {
                  if (state is! TemplateLoaded) {
                    return const Center(
                      child: CircularProgressIndicator(
                          color: AppTheme.kPrimary),
                    );
                  }

                  if (state.filtered.isEmpty) {
                    return const _EmptyState();
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.fromLTRB(
                        16, 4, 16, 24),
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount:   2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing:  12,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: state.filtered.length,
                    itemBuilder: (context, i) {
                      final t = state.filtered[i];
                      return _TemplateCard(
                        template: t,
                        qrData:   qrData,
                        onApply:  () => _applyTemplate(
                            context, t),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _applyTemplate(BuildContext context, QRTemplate t) {
    final config = QRConfig(
      foregroundColor: t.foreground,
      backgroundColor: t.background,
    );
    onApply(config);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('${t.name} template applied!'),
      backgroundColor: AppTheme.kSuccessColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    ));
  }

  void _showSearch(BuildContext context) {
    showModalBottomSheet(
      context:           context,
      isScrollControlled: true,
      backgroundColor:   Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<TemplateBloc>(),
        child: const _SearchSheet(),
      ),
    );
  }
}

// ── Template card ─────────────────────────────────────────────────────────────

class _TemplateCard extends StatelessWidget {
  final QRTemplate   template;
  final String       qrData;
  final VoidCallback onApply;

  const _TemplateCard({
    required this.template,
    required this.qrData,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onApply,
      child: Container(
        decoration: BoxDecoration(
          color:        AppTheme.kCardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color:      Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset:     const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // QR preview area
            Expanded(
              child: Stack(
                children: [
                  // Colored background
                  Container(
                    width:        double.infinity,
                    decoration: BoxDecoration(
                      color:        template.background,
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16)),
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: QrImageView(
                          data:            qrData.isEmpty
                              ? 'https://example.com'
                              : qrData,
                          version:         QrVersions.auto,
                          size:            120,
                          backgroundColor: template.background,
                          eyeStyle: QrEyeStyle(
                            eyeShape: QrEyeShape.square,
                            color:    template.foreground,
                          ),
                          dataModuleStyle: QrDataModuleStyle(
                            dataModuleShape:
                            QrDataModuleShape.square,
                            color: template.foreground,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Free badge
                  Positioned(
                    top:   10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color:        Colors.white
                            .withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle_rounded,
                              color: Color(0xFF25A244),
                              size:  12),
                          SizedBox(width: 3),
                          Text('Free',
                              style: TextStyle(
                                color:      Color(0xFF25A244),
                                fontSize:   10,
                                fontWeight: FontWeight.w700,
                              )),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Name + category
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(template.name,
                      style: const TextStyle(
                        color:      AppTheme.kTextDark,
                        fontSize:   14,
                        fontWeight: FontWeight.w700,
                      )),
                  const SizedBox(height: 4),
                  Row(children: [
                    Icon(Icons.check_rounded,
                        color: AppTheme.kSuccessColor,
                        size:  12),
                    const SizedBox(width: 4),
                    Text('Free',
                        style: const TextStyle(
                          color:      AppTheme.kSuccessColor,
                          fontSize:   11,
                          fontWeight: FontWeight.w600,
                        )),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: template.cardColor
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(template.category,
                          style: TextStyle(
                            color:      template.cardColor,
                            fontSize:   9,
                            fontWeight: FontWeight.w600,
                          )),
                    ),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Search sheet ──────────────────────────────────────────────────────────────

class _SearchSheet extends StatelessWidget {
  const _SearchSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        left:   20,
        right:  20,
        top:    20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width:  40,
            height: 4,
            decoration: BoxDecoration(
              color:        AppTheme.kBorderColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            autofocus: true,
            onChanged: (q) => context
                .read<TemplateBloc>()
                .add(TemplateSearchEvent(q)),
            decoration: InputDecoration(
              hintText:  'Search templates...',
              hintStyle: TextStyle(
                  color: AppTheme.kTextGray
                      .withValues(alpha: 0.6)),
              prefixIcon: const Icon(Icons.search_rounded,
                  color: AppTheme.kTextGray),
              filled:      true,
              fillColor:   AppTheme.kBgColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:   BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

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
              color:        AppTheme.kPrimary
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.dashboard_rounded,
                color: AppTheme.kPrimary, size: 36),
          ),
          const SizedBox(height: 16),
          const Text('No templates found',
              style: TextStyle(
                color:      AppTheme.kTextDark,
                fontSize:   16,
                fontWeight: FontWeight.w600,
              )),
          const SizedBox(height: 8),
          const Text('Try a different search or filter',
              style: TextStyle(
                color:    AppTheme.kTextGray,
                fontSize: 13,
              )),
        ],
      ),
    );
  }
}