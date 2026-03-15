import 'package:flutter/material.dart';

import '../../shared/widgets/common.dart';

class LogbookPage extends StatelessWidget {
  const LogbookPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const ValueKey('logbook'),
      padding: EdgeInsets.all(16),
      children: [
        SectionIntro(
          title: '日志 / QSO',
          description: '先把日志页框架立起来，后面接原生数据库或导出接口。',
        ),
        SizedBox(height: 16),
        PlaceholderCard(
          title: '最近通联',
          lines: [
            'BG7QVU · JA1ABC · FT8 · 14.074',
            'BG7QVU · VK2XYZ · FT8 · 7.074',
            'BG7QVU · K1TEST · FT8 · 21.074',
          ],
        ),
      ],
    );
  }
}
