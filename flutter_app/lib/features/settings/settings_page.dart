import 'package:flutter/material.dart';

import '../../shared/widgets/common.dart';

class SettingsPlaceholderPage extends StatelessWidget {
  const SettingsPlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const ValueKey('settings'),
      padding: const EdgeInsets.all(16),
      children: const [
        SectionIntro(
          title: '设置',
          description: '这里后续接设备、音频、呼号、网格、上传服务等配置项。',
        ),
        SizedBox(height: 16),
        PlaceholderCard(
          title: '首批设置分组',
          lines: [
            '设备连接',
            '音频输入输出',
            '呼号 / 网格 / 功率',
            '第三方上传与同步',
          ],
        ),
      ],
    );
  }
}
