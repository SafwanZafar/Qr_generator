import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_code_generator/pages/home/widget/action_grid.dart';
import 'package:qr_code_generator/pages/home/widget/quick_action_banner.dart';
import 'package:qr_code_generator/pages/home/widget/recent_list.dart';
import 'package:qr_code_generator/pages/home/widget/welcome_header.dart';
import '../../bloc/home/home_bloc.dart';
import '../../bloc/home/home_event.dart';
import '../../bloc/home/home_state.dart';
import '../../core/theme.dart';

class HomePage extends StatelessWidget {
  final VoidCallback onGenerate;
  final VoidCallback onScan;
  final VoidCallback onMyCodes;
  final VoidCallback onTemplates;  // ← ADD
  final VoidCallback onSeeAll;     // ← ADD

  const HomePage({
    super.key,
    required this.onGenerate,
    required this.onScan,
    required this.onMyCodes,
    required this.onTemplates,  // ← ADD
    required this.onSeeAll,     // ← ADD

  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeBloc()..add(const HomeLoadEvent()),
      child: Scaffold(
        backgroundColor: AppTheme.kBgColor,
        body: SafeArea(
          child: RefreshIndicator(
            color: AppTheme.kPrimary,
            onRefresh: () async =>
                context.read<HomeBloc>().add(const HomeLoadEvent()),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        // ── Header ──────────────────────────────
                        const WelcomeHeader(),
                        const SizedBox(height: 20),

                        // ── Banner ───────────────────────────────
                        QuickActionBanner(onTap: onGenerate),
                        const SizedBox(height: 20),

                        // ── Action grid ──────────────────────────
                        ActionGrid(
                          onGenerate:  onGenerate,
                          onScan:      onScan,
                          onTemplates: onTemplates,
                          onMyCodes:   onMyCodes,
                        ),
                        const SizedBox(height: 24),

                        // ── Recent list ──────────────────────────
                        BlocBuilder<HomeBloc, HomeState>(
                          builder: (context, state) {
                            if (state is HomeLoading) {
                              return const Center(
                                child: CircularProgressIndicator(
                                  color: AppTheme.kPrimary,
                                ),
                              );
                            }
                            if (state is HomeLoaded) {
                              return RecentList(
                                history:  state.history,
                                onDelete: (id) => context
                                    .read<HomeBloc>()
                                    .add(HomeDeleteHistoryEvent(id)),
                                onSeeAll:onSeeAll,
                              );
                            }
                            return const SizedBox();
                          },
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}