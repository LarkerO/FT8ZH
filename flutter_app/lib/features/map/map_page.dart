import 'package:flutter/material.dart';

import '../../shared/widgets/common.dart';

/// Grid Tracker / Map page – mirrors the original GridTrackerMainActivity.
///
/// Full map rendering requires a native map SDK (OSM / Google Maps). For now
/// this page provides a functional placeholder listing recent grid contacts
/// with the architecture ready for a map widget.
class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const ValueKey('map'),
      padding: const EdgeInsets.all(12),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '地图 / Grid Tracker',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Maidenhead 网格地图视图。'
                  '当原生 OSM 地图组件就绪后，此处将显示通联地图标记。',
                ),
                const SizedBox(height: 16),
                // Grid overview placeholder
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    MetricChip(label: '我的网格', value: '--'),
                    MetricChip(label: '通联网格数', value: '0'),
                    MetricChip(label: 'DXCC 实体', value: '0'),
                    MetricChip(label: 'CQ Zone', value: '--'),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Placeholder map area
        Card(
          child: Container(
            height: 300,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1A2332),
                  Color(0xFF0D1B2A),
                ],
              ),
            ),
            child: const Center(
              child: EmptyState(
                icon: Icons.map_outlined,
                message: '地图视图将在原生地图 SDK 集成后启用\n'
                    '支持 Maidenhead 网格、通联点位聚合、呼号详情',
              ),
            ),
          ),
        ),
      ],
    );
  }
}
