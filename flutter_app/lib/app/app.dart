import 'package:flutter/material.dart';

import '../features/home/home_shell.dart';

class Ft8ZhApp extends StatelessWidget {
  const Ft8ZhApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF1565C0),
      brightness: Brightness.dark,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FT8ZH',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: const Color(0xFF0B1220),
        cardTheme: const CardThemeData(margin: EdgeInsets.zero),
      ),
      home: const HomeShell(),
    );
  }
}
