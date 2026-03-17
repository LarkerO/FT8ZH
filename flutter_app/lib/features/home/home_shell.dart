import 'package:flutter/material.dart';

import '../../application/console_controller.dart';
import '../../shared/widgets/common.dart';
import '../console/console_page.dart';
import '../logbook/logbook_page.dart';
import '../map/map_page.dart';
import '../settings/settings_page.dart';

/// Root shell with bottom navigation – mirrors the original MainActivity
/// fragment navigation.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.controller});

  final ConsoleController controller;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentIndex = 0;

  late final List<Widget> _pages = [
    MainConsolePage(controller: widget.controller),
    const LogbookPage(),
    const MapPage(),
    const SettingsPage(),
  ];

  static const _destinations = [
    NavigationDestination(icon: Icon(Icons.graphic_eq), label: '主控台'),
    NavigationDestination(icon: Icon(Icons.list_alt), label: '日志'),
    NavigationDestination(icon: Icon(Icons.public), label: '地图'),
    NavigationDestination(icon: Icon(Icons.settings), label: '设置'),
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final rigState = widget.controller.snapshot.rigState;
        final isConnected = rigState.isConnected;
        final badgeColor = isConnected ? Colors.greenAccent : Colors.orange;
        final badgeLabel = rigState.connectionLabel;

        return Scaffold(
          appBar: AppBar(
            title: const Text('FT8ZH'),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Center(
                  child: ConnectionBadge(label: badgeLabel, color: badgeColor),
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
      },
    );
  }
}
