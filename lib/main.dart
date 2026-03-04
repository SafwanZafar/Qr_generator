import 'package:flutter/material.dart';
import 'core/constant.dart';
import 'pages/qr_generator_page.dart' hide SizedBox;
import 'pages/qr_scanner_page.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR Generator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4C9BE8),
          brightness: Brightness.dark,
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index = 0;

  static const _pages = [
    QRGeneratorPage(),
    QRScannerPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgColor,
      body: IndexedStack(
        index: _index,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1C),
          border: Border(
            top: BorderSide(
                color: Colors.white.withValues(alpha: 0.06)
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 10,
            ),
            child: Row(
              children: [
                _NavItem(
                  icon:     Icons.qr_code_rounded,
                  label:    'Generate',
                  selected: _index == 0,
                  color:    const Color(0xFF4C9BE8),
                  onTap:    () => setState(() => _index = 0),
                ),
                _NavItem(
                  icon:     Icons.qr_code_scanner_rounded,
                  label:    'Scanner',
                  selected: _index == 1,
                  color:    const Color(0xFF25D366),
                  onTap:    () => setState(() => _index = 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData   icon;
  final String     label;
  final bool       selected;
  final Color      color;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? color.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon,
                  color: selected
                      ? color
                      : Colors.white.withValues(alpha: 0.3),
                  size: 22),
              const SizedBox(height: 4),
              Text(label,
                  style: TextStyle(
                    color: selected
                        ? color
                        : Colors.white.withValues(alpha: 0.3),
                    fontSize: 11,
                    fontWeight: selected
                        ? FontWeight.w600
                        : FontWeight.w400,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}