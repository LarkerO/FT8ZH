import 'package:flutter/material.dart';

import '../../shared/widgets/common.dart';

class MapPlaceholderPage extends StatelessWidget {
  const MapPlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const ValueKey('map'),
      padding: const EdgeInsets.all(16),
      children: const [
        SectionIntro(
          title: '地图 / Grid Tracker',
          description: '地图层后续单独做，先把页面和导航边界固定住。',
        ),
        SizedBox(height: 16),
        PlaceholderCard(
          title: '待接能力',
          lines: [
            'Maidenhead 网格展示',
            '通联点位聚合',
            '呼号详情抽屉',
          ],
        ),
      ],
    );
  }
}
