import 'package:flutter/material.dart';

import '../../shared/widgets/common.dart';
import '../console/console_page.dart';
import '../logbook/logbook_page.dart';
import '../map/map_page.dart';
import '../settings/settings_page.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentIndex = 0;

  static const _pages = [
    MainConsolePage(),
    LogbookPage(),
    MapPlaceholderPage(),
    SettingsPlaceholderPage(),
  ];

  static const _destinations = [
    NavigationDestination(icon: Icon(Icons.graphic_eq), label: '主控台'),
    NavigationDestination(icon: Icon(Icons.list_alt), label: '日志'),
    NavigationDestination(icon: Icon(Icons.public), label: '地图'),
    NavigationDestination(icon: Icon(Icons.settings), label: '设置'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FT8ZH'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Center(
              child: ConnectionBadge(
                label: '未连接',
                color: Colors.orange,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: _pages[_currentIndex],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        destinations: _destinations,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
      ),
    );
  }
}
