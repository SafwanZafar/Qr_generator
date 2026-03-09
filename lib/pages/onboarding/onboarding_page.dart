import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main_page.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with TickerProviderStateMixin {

  final PageController _pageCtrl = PageController();
  int _currentPage = 0;

  static const _slides = [
    _Slide(
      color:       Color(0xFFE84C4C),
      bgColor:     Color(0xFFFFEEEE),
      circleColor: Color(0xFFFFCCCC),
      titleStart:  'Create ',
      titleAccent: 'Stunning',
      titleEnd:    '\nQR Codes',
      subtitle:    'Design beautiful QR codes with custom colors, logos, and templates in seconds',
      type:        _SlideType.qr,
    ),
    _Slide(
      color:       Color(0xFF7B4CE8),
      bgColor:     Color(0xFFF0EEFF),
      circleColor: Color(0xFFD8CCFF),
      titleStart:  'Scan ',
      titleAccent: 'Any',
      titleEnd:    '\nQR Code',
      subtitle:    'Instantly scan any QR code with your camera or pick from your gallery',
      type:        _SlideType.scan,
    ),
    _Slide(
      color:       Color(0xFF3B5BDB),
      bgColor:     Color(0xFFEEF1FF),
      circleColor: Color(0xFFCCD5FF),
      titleStart:  '',
      titleAccent: 'Share',
      titleEnd:    ' With\nEveryone',
      subtitle:    'Share your QR codes instantly via social media, email, or save to gallery',
      type:        _SlideType.share,
    ),
  ];

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainPage()),
      );
    }
  }

  void _next() {
    if (_currentPage < 2) {
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 350),
        curve:    Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  @override
  Widget build(BuildContext context) {
    final slide = _slides[_currentPage];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [

            // ── Skip ──────────────────────────────────────────────
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: _finish,
                child: const Padding(
                  padding: EdgeInsets.fromLTRB(0, 16, 24, 0),
                  child: Text('Skip',
                      style: TextStyle(
                        color:      Color(0xFF8E8E93),
                        fontSize:   16,
                        fontWeight: FontWeight.w500,
                      )),
                ),
              ),
            ),

            // ── Page view ─────────────────────────────────────────
            Expanded(
              child: PageView.builder(
                controller: _pageCtrl,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _slides.length,
                itemBuilder: (context, i) =>
                    _SlidePage(slide: _slides[i]),
              ),
            ),

            // ── Dots ──────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_slides.length, (i) {
                final selected = i == _currentPage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width:  selected ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: selected
                        ? slide.color
                        : slide.color.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),

            const SizedBox(height: 32),

            // ── Button ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: SizedBox(
                width:  double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _next,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: slide.color,
                    foregroundColor: Colors.white,
                    elevation:       0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    _currentPage == 2 ? 'Get Started' : 'Next',
                    style: const TextStyle(
                      fontSize:   18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}

// ── Slide page ────────────────────────────────────────────────────────────────

class _SlidePage extends StatelessWidget {
  final _Slide slide;
  const _SlidePage({required this.slide});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          // ── Illustration ───────────────────────────────────────
          Stack(
            alignment: Alignment.center,
            children: [
              // outer circle
              Container(
                width:  220,
                height: 220,
                decoration: BoxDecoration(
                  color:  slide.circleColor,
                  shape:  BoxShape.circle,
                ),
              ),
              // icon card
              Container(
                width:   140,
                height:  140,
                decoration: BoxDecoration(
                  color:        Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color:      slide.color.withValues(alpha: 0.15),
                      blurRadius: 20,
                      offset:     const Offset(0, 8),
                    ),
                  ],
                ),
                child: Center(child: _buildIcon(slide)),
              ),
            ],
          ),

          const SizedBox(height: 48),

          // ── Title ─────────────────────────────────────────────
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: const TextStyle(
                fontSize:   28,
                fontWeight: FontWeight.w800,
                height:     1.2,
              ),
              children: [
                TextSpan(
                  text:  slide.titleStart,
                  style: const TextStyle(color: Color(0xFF1A1A2E)),
                ),
                TextSpan(
                  text:  slide.titleAccent,
                  style: TextStyle(color: slide.color),
                ),
                TextSpan(
                  text:  slide.titleEnd,
                  style: const TextStyle(color: Color(0xFF1A1A2E)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Subtitle ──────────────────────────────────────────
          Text(
            slide.subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color:       Color(0xFF8E8E93),
              fontSize:    16,
              height:      1.5,
              fontWeight:  FontWeight.w400,
            ),
          ),

        ],
      ),
    );
  }

  Widget _buildIcon(_Slide slide) {
    switch (slide.type) {
      case _SlideType.qr:
        return QrImageView(
          data:    'https://example.com',
          version: QrVersions.auto,
          size:    80,
          eyeStyle: QrEyeStyle(
            eyeShape: QrEyeShape.square,
            color:    slide.color,
          ),
          dataModuleStyle: QrDataModuleStyle(
            dataModuleShape: QrDataModuleShape.square,
            color:           slide.color,
          ),
        );
      case _SlideType.scan:
        return Icon(Icons.qr_code_scanner_rounded,
            color: slide.color, size: 64);
      case _SlideType.share:
        return Icon(Icons.share_rounded,
            color: slide.color, size: 64);
    }
  }
}

// ── Models ────────────────────────────────────────────────────────────────────

enum _SlideType { qr, scan, share }

class _Slide {
  final Color      color;
  final Color      bgColor;
  final Color      circleColor;
  final String     titleStart;
  final String     titleAccent;
  final String     titleEnd;
  final String     subtitle;
  final _SlideType type;

  const _Slide({
    required this.color,
    required this.bgColor,
    required this.circleColor,
    required this.titleStart,
    required this.titleAccent,
    required this.titleEnd,
    required this.subtitle,
    required this.type,
  });
}