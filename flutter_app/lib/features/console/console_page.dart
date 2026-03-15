import 'package:flutter/material.dart';

import '../../shared/widgets/common.dart';

class MainConsolePage extends StatelessWidget {
  const MainConsolePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const ValueKey('main-console'),
      padding: const EdgeInsets.all(16),
      children: const [
        StatusOverviewCard(),
        SizedBox(height: 16),
        WaterfallPlaceholderCard(),
        SizedBox(height: 16),
        MessageListCard(),
        SizedBox(height: 16),
        TransmitControlCard(),
      ],
    );
  }
}

class StatusOverviewCard extends StatelessWidget {
  const StatusOverviewCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('当前状态', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            const Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                MetricChip(label: '模式', value: 'FT8'),
                MetricChip(label: '频率', value: '14.074 MHz'),
                MetricChip(label: '时隙', value: '00.0s'),
                MetricChip(label: '音频', value: '待接入'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class WaterfallPlaceholderCard extends StatelessWidget {
  const WaterfallPlaceholderCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('瀑布图 / 频谱', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Container(
              height: 220,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF1A237E),
                    Color(0xFF0D47A1),
                    Color(0xFF00695C),
                    Color(0xFF1B5E20),
                  ],
                ),
              ),
              child: const Center(
                child: Text(
                  '后续接入原生频谱/瀑布数据流',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageListCard extends StatelessWidget {
  const MessageListCard({super.key});

  @override
  Widget build(BuildContext context) {
    const messages = [
      'CQ BG7QVU OL72',
      'JA1ABC BG7QVU -12',
      'BG7QVU JA1ABC R-09',
      'JA1ABC BG7QVU RR73',
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('解码消息', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            for (final message in messages)
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.message_outlined),
                title: Text(message),
                subtitle: const Text('占位数据，后续接 EventChannel 实时流'),
              ),
          ],
        ),
      ),
    );
  }
}

class TransmitControlCard extends StatelessWidget {
  const TransmitControlCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('发射控制', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: null,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('开始监听'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: null,
                    icon: const Icon(Icons.upload),
                    label: const Text('准备发射'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text('下一步接入：设备连接状态、发射消息队列、时隙同步。'),
          ],
        ),
      ),
    );
  }
}
