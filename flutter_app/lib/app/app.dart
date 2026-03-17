import 'package:flutter/material.dart';

import '../application/console_controller.dart';
import '../features/home/home_shell.dart';

class Ft8ZhApp extends StatefulWidget {
  const Ft8ZhApp({super.key});

  @override
  State<Ft8ZhApp> createState() => _Ft8ZhAppState();
}

class _Ft8ZhAppState extends State<Ft8ZhApp> {
  late final ConsoleController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ConsoleController()..initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
      home: HomeShell(controller: _controller),
    );
  }
}
