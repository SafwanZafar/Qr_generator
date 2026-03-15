import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_generator/providers/navigation_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/onboarding/onboarding_page.dart';
import 'pages/main_page.dart';
import 'providers/generator_provider.dart';
import 'providers/customize_provider.dart';
import 'providers/scanner_provider.dart';

void main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: binding);

  final prefs = await SharedPreferences.getInstance();
  final done  = prefs.getBool('onboarding_done') ?? false;

  FlutterNativeSplash.remove();

  runApp(MyApp(showOnboarding: !done));
}

class MyApp extends StatelessWidget {
  final bool showOnboarding;
  const MyApp({super.key, required this.showOnboarding});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GeneratorProvider()),
        ChangeNotifierProvider(create: (_) => CustomizeProvider()),
        ChangeNotifierProvider(create: (_) => ScannerProvider()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),  // ← ADD

      ],

      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'QRCraft',
        home: showOnboarding
            ? const OnboardingPage()
            : const MainPage(),
      ),
    );
  }
}