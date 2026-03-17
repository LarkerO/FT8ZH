import 'package:flutter/material.dart';

import '../../application/console_controller.dart';
import '../../domain/models.dart';
import '../../shared/widgets/common.dart';

class MainConsolePage extends StatelessWidget {
  const MainConsolePage({super.key, required this.controller});

  final ConsoleController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final snapshot = controller.snapshot;
        final timerState = snapshot.timerState;
        final rigState = snapshot.rigState;
        final messageCount = snapshot.messages.length;

        return ListView(
          key: const ValueKey('main-console'),
          padding: const EdgeInsets.all(16),
          children: [
            if (controller.error case final error?) ...[
              ErrorBanner(message: error),
              const SizedBox(height: 16),
            ],
            StatusOverviewCard(
              rigState: rigState,
              timerState: timerState,
              platformSummary: controller.platformSummary,
            ),
            const SizedBox(height: 16),
            WaterfallPreviewCard(
              bars: controller.spectrumPreview,
              timerState: timerState,
              isListening: rigState.isListening,
            ),
            const SizedBox(height: 16),
            MessageListCard(messages: snapshot.messages),
            const SizedBox(height: 16),
            TransmitControlCard(
              isBusy: controller.isBusy,
              isListening: rigState.isListening,
              messageCount: messageCount,
              onToggleListening: controller.toggleListening,
            ),
          ],
        );
      },
    );
  }
}

class StatusOverviewCard extends StatelessWidget {
  const StatusOverviewCard({
    super.key,
    required this.rigState,
    required this.timerState,
    required this.platformSummary,
  });

  final RigState rigState;
  final TimerState timerState;
  final Map<String, dynamic> platformSummary;

  @override
  Widget build(BuildContext context) {
    final model = platformSummary['model'] as String? ?? '--';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('当前状态', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                MetricChip(label: '模式', value: rigState.mode),
                MetricChip(label: '频率', value: rigState.frequencyText),
                MetricChip(label: '时钟', value: timerState.utcLabel),
                MetricChip(label: '音频', value: rigState.audioSource),
                MetricChip(
                  label: '时隙',
                  value: timerState.remaining.inSeconds.toString(),
                ),
                MetricChip(label: '设备', value: model),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class WaterfallPreviewCard extends StatelessWidget {
  const WaterfallPreviewCard({
    super.key,
    required this.bars,
    required this.timerState,
    required this.isListening,
  });

  final List<double> bars;
  final TimerState timerState;
  final bool isListening;

  @override
  Widget build(BuildContext context) {
    final activeColor = isListening ? const Color(0xFF4DD0E1) : Colors.grey;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '简化频谱 / 瀑布',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                ConnectionBadge(
                  label: isListening ? '监听中' : '待机',
                  color: isListening ? Colors.greenAccent : Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 220,
              child: DecoratedBox(
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
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '时隙进度 ${(timerState.slotProgress * 100).toStringAsFixed(0)}%',
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            for (final value in bars)
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 1,
                                  ),
                                  child: Align(
                                    alignment: Alignment.bottomCenter,
                                    child: FractionallySizedBox(
                                      heightFactor: value,
                                      child: DecoratedBox(
                                        decoration: BoxDecoration(
                                          color: activeColor.withValues(
                                            alpha: 0.85,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text('第一阶段先用原生时钟驱动预览，后面再接真实 DSP/解码数据流。'),
                    ],
                  ),
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
  const MessageListCard({super.key, required this.messages});

  final List<DecodeMessage> messages;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('解码消息', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            if (messages.isEmpty)
              const Text('桥接基础已接好，真实解码流下一批接入。')
            else
              for (final message in messages)
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    message.isWeakSignal ? Icons.radar : Icons.message_outlined,
                  ),
                  title: Text(message.text),
                  subtitle: Text(
                    'SNR ${message.snr} dB · ${message.offsetHz} Hz',
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class TransmitControlCard extends StatelessWidget {
  const TransmitControlCard({
    super.key,
    required this.isBusy,
    required this.isListening,
    required this.messageCount,
    required this.onToggleListening,
  });

  final bool isBusy;
  final bool isListening;
  final int messageCount;
  final Future<void> Function() onToggleListening;

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
                    onPressed: isBusy ? null : onToggleListening,
                    icon: Icon(isListening ? Icons.stop : Icons.play_arrow),
                    label: Text(isListening ? '停止监听' : '开始监听'),
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
            Text('当前解码条数：$messageCount'),
            const SizedBox(height: 8),
            const Text('本批完成 bridge 基础层；decode stream、真实 rig state、发射队列下一批接入。'),
          ],
        ),
      ),
    );
  }
}

class ErrorBanner extends StatelessWidget {
  const ErrorBanner({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.errorContainer,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.error_outline),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }
}
