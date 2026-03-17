import 'package:flutter/material.dart';

import '../../application/console_controller.dart';
import '../../domain/models.dart';
import '../../shared/widgets/common.dart';

/// Main console page – decoded messages, spectrum preview, transmit controls.
///
/// Mirrors the original CallingListFragment + SpectrumFragment combined view.
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
        final messages = snapshot.messages;

        return ListView(
          key: const ValueKey('main-console'),
          padding: const EdgeInsets.all(12),
          children: [
            if (controller.error case final error?) ...[
              _ErrorBanner(
                message: error,
                onDismiss: controller.clearError,
              ),
              const SizedBox(height: 12),
            ],

            // ---- Status bar ----
            _StatusBar(
              rigState: rigState,
              timerState: timerState,
              platformSummary: controller.platformSummary,
            ),
            const SizedBox(height: 12),

            // ---- Spectrum / Waterfall preview ----
            _SpectrumCard(
              bars: controller.spectrumBars,
              timerState: timerState,
              isListening: rigState.isListening,
              isDecoding: rigState.isDecoding,
            ),
            const SizedBox(height: 12),

            // ---- Transmit controls ----
            _TransmitControlBar(
              isBusy: controller.isBusy,
              isListening: rigState.isListening,
              isTransmitting: rigState.isTransmitting,
              decodedCount: snapshot.decodedCount,
              onToggleListening: controller.toggleListening,
              onStopTransmit: controller.stopTransmit,
              onClearMessages: controller.clearMessages,
            ),
            const SizedBox(height: 12),

            // ---- Decoded messages ----
            _MessageList(
              messages: messages,
              onCallStation: controller.callStation,
            ),
          ],
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Status bar
// ---------------------------------------------------------------------------

class _StatusBar extends StatelessWidget {
  const _StatusBar({
    required this.rigState,
    required this.timerState,
    required this.platformSummary,
  });

  final RigState rigState;
  final TimerState timerState;
  final Map<String, dynamic> platformSummary;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('当前状态', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                MetricChip(label: '模式', value: rigState.mode),
                MetricChip(label: '频率', value: rigState.frequencyText),
                MetricChip(label: '波段', value: rigState.bandText),
                MetricChip(label: 'UTC', value: timerState.utcLabel),
                MetricChip(
                  label: '时隙',
                  value: '${timerState.remaining.inSeconds}s',
                ),
                MetricChip(
                  label: '音频',
                  value: rigState.audioSource,
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Slot progress indicator
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: timerState.slotProgress,
                minHeight: 6,
                backgroundColor: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Spectrum / Waterfall card
// ---------------------------------------------------------------------------

class _SpectrumCard extends StatelessWidget {
  const _SpectrumCard({
    required this.bars,
    required this.timerState,
    required this.isListening,
    required this.isDecoding,
  });

  final List<double> bars;
  final TimerState timerState;
  final bool isListening;
  final bool isDecoding;

  @override
  Widget build(BuildContext context) {
    final activeColor = isListening ? const Color(0xFF4DD0E1) : Colors.grey;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '频谱 / 瀑布',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                if (isDecoding)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ConnectionBadge(
                      label: '解码中',
                      color: Colors.amberAccent,
                    ),
                  ),
                ConnectionBadge(
                  label: isListening ? '监听中' : '待机',
                  color: isListening ? Colors.greenAccent : Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 140,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF0D1B2A),
                      Color(0xFF1B2838),
                      Color(0xFF0D3B4E),
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      for (final value in bars)
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 0.5),
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: FractionallySizedBox(
                                heightFactor: value.clamp(0.02, 1.0),
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: activeColor.withValues(alpha: 0.85),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
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

// ---------------------------------------------------------------------------
// Transmit control bar
// ---------------------------------------------------------------------------

class _TransmitControlBar extends StatelessWidget {
  const _TransmitControlBar({
    required this.isBusy,
    required this.isListening,
    required this.isTransmitting,
    required this.decodedCount,
    required this.onToggleListening,
    required this.onStopTransmit,
    required this.onClearMessages,
  });

  final bool isBusy;
  final bool isListening;
  final bool isTransmitting;
  final int decodedCount;
  final Future<void> Function() onToggleListening;
  final Future<void> Function() onStopTransmit;
  final Future<void> Function() onClearMessages;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            // Listen toggle
            Expanded(
              child: FilledButton.icon(
                onPressed: isBusy ? null : onToggleListening,
                icon: Icon(isListening ? Icons.stop : Icons.play_arrow),
                label: Text(isListening ? '停止' : '监听'),
              ),
            ),
            const SizedBox(width: 8),
            // Transmit stop
            Expanded(
              child: isTransmitting
                  ? FilledButton.icon(
                      onPressed: onStopTransmit,
                      icon: const Icon(Icons.pause),
                      label: const Text('停止发射'),
                    )
                  : OutlinedButton.icon(
                      onPressed: null,
                      icon: const Icon(Icons.upload),
                      label: const Text('发射'),
                    ),
            ),
            const SizedBox(width: 8),
            // Clear + count
            IconButton(
              tooltip: '清空消息',
              onPressed: onClearMessages,
              icon: const Icon(Icons.delete_outline),
            ),
            Text(
              '$decodedCount',
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Decoded message list
// ---------------------------------------------------------------------------

class _MessageList extends StatelessWidget {
  const _MessageList({
    required this.messages,
    required this.onCallStation,
  });

  final List<DecodeMessage> messages;
  final Future<void> Function(String) onCallStation;

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return const Card(
        child: EmptyState(
          icon: Icons.graphic_eq,
          message: '暂无解码消息\n请先点击"监听"按钮开始接收信号',
        ),
      );
    }

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: Text(
              '解码消息 (${messages.length})',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            itemCount: messages.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final msg = messages[index];
              return _MessageTile(
                message: msg,
                onCall: () => onCallStation(msg.callsignFrom),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _MessageTile extends StatelessWidget {
  const _MessageTile({
    required this.message,
    required this.onCall,
  });

  final DecodeMessage message;
  final VoidCallback onCall;

  @override
  Widget build(BuildContext context) {
    final isCQ = message.isCQ;
    final color = isCQ
        ? Colors.green
        : message.isWeakSignal
            ? Colors.orange
            : null;

    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      leading: Icon(
        isCQ
            ? Icons.campaign
            : message.isWeakSignal
                ? Icons.radar
                : Icons.message_outlined,
        color: color,
        size: 20,
      ),
      title: Text(
        message.text,
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: 13,
          color: color,
          fontWeight: isCQ ? FontWeight.bold : null,
        ),
      ),
      subtitle: Text(
        'SNR ${message.snr} dB · ${message.offsetHz} Hz'
        '${message.callsignFrom.isNotEmpty ? ' · ${message.callsignFrom}' : ''}',
        style: const TextStyle(fontSize: 11),
      ),
      trailing: message.callsignFrom.isNotEmpty
          ? IconButton(
              icon: const Icon(Icons.call, size: 18),
              tooltip: '呼叫 ${message.callsignFrom}',
              onPressed: onCall,
            )
          : null,
    );
  }
}

// ---------------------------------------------------------------------------
// Error banner
// ---------------------------------------------------------------------------

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({
    required this.message,
    required this.onDismiss,
  });

  final String message;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.errorContainer,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.error_outline),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
            IconButton(
              icon: const Icon(Icons.close, size: 18),
              onPressed: onDismiss,
            ),
          ],
        ),
      ),
    );
  }
}
