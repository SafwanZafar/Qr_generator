import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'core/theme.dart';
import 'pages/main_page.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR Generator',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const MainPage(),
    );
  }
}