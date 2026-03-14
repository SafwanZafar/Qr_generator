import 'package:flutter/material.dart';
import 'package:qr_code_generator/pages/generator/generator_page.dart';
import 'package:qr_code_generator/pages/saved/save_page.dart';
import 'package:qr_code_generator/pages/scanner/scanner_page.dart';
import 'package:qr_code_generator/pages/template/template_page.dart';
import '../core/theme.dart';
import '../models/qr_config.dart';
import 'home/home_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int      _index          = 0;
  int      _savedRefresh   = 0;   // ← forces SavedPage rebuild
  QRConfig _selectedConfig = const QRConfig();

  void _goToGenerator() => setState(() => _index = 1);
  void _goToScanner()   => setState(() => _index = 2);

  void _onTemplateApply(QRConfig config) {
    setState(() {
      _selectedConfig = config;
      _index          = 1;
    });
  }

  void _onQRGenerated() {
    // called after QR is generated — refresh saved page
    setState(() => _savedRefresh++);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.kBgColor,
      body: IndexedStack(
        index: _index,
        children: [
          HomePage(                              // 0 - Home
            onGenerate: _goToGenerator,
            onScan:     _goToScanner, onMyCodes: () {  },
          ),
          QRGeneratorPage(                       // 1 - Create
            initialConfig:  _selectedConfig,
            onQRGenerated:  _onQRGenerated,      // ← notify main
          ),
          const QRScannerPage(),                 // 2 - Scan
          SavedPage(key: ValueKey(_savedRefresh)), // 3 - Saved
          TemplatePage(                          // 4 - Templates
            qrData:  'https://example.com',
            onApply: _onTemplateApply,
          ),
        ],
      ),
      bottomNavigationBar: _BottomNav(
        index: _index,
        onTap: (i) {
          setState(() {
            _index = i;
            if (i == 3) _savedRefresh++;  // ← also refresh on tab tap
          });
        },
      ),
    );
  }
}

class _PlaceholderPage extends StatelessWidget {
  final String label;
  const _PlaceholderPage({required this.label});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.kBgColor,
      body: Center(
        child: Text(label,
            style: const TextStyle(
              color:    AppTheme.kTextGray,
              fontSize: 18,
            )),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int                index;
  final void Function(int) onTap;

  const _BottomNav({required this.index, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color:      Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset:     const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              _NavItem(
                icon:    Icons.home_rounded,
                label:   'Home',
                index:   0,
                current: index,
                onTap:   onTap,
              ),
              _NavItem(
                icon:    Icons.add_circle_outline_rounded,
                label:   'Create',
                index:   1,
                current: index,
                onTap:   onTap,
              ),
              _ScanNavItem(onTap: () => onTap(2)),
              _NavItem(
                icon:    Icons.bookmark_rounded,
                label:   'Saved',
                index:   3,
                current: index,
                onTap:   onTap,
              ),
              _NavItem(
                icon:    Icons.dashboard_rounded,
                label:   'Templates',
                index:   4,
                current: index,
                onTap:   onTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData           icon;
  final String             label;
  final int                index;
  final int                current;
  final void Function(int) onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.current,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final selected = index == current;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        child: Container(
          color: Colors.transparent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size:  22,
                  color: selected
                      ? AppTheme.kPrimary
                      : AppTheme.kTextGray),
              const SizedBox(height: 4),
              Text(label,
                  style: TextStyle(
                    fontSize:   10,
                    fontWeight: selected
                        ? FontWeight.w600
                        : FontWeight.w400,
                    color: selected
                        ? AppTheme.kPrimary
                        : AppTheme.kTextGray,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScanNavItem extends StatelessWidget {
  final VoidCallback onTap;
  const _ScanNavItem({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width:  50,
              height: 50,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF4C4BE8),
                    Color(0xFF9B4CE8),
                  ],
                  begin: Alignment.topLeft,
                  end:   Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color:      const Color(0xFF4C4BE8)
                        .withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset:     const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.qr_code_scanner_rounded,
                color: Colors.white,
                size:  24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}