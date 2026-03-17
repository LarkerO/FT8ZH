import 'package:flutter/material.dart';

import '../../application/settings_controller.dart';
import '../../domain/ft8_constants.dart';
import '../../domain/models.dart';
import '../../domain/operation_band.dart';

/// Full settings / configuration page – mirrors the original ConfigFragment.
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _controller = SettingsController();

  @override
  void initState() {
    super.initState();
    _controller.load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final config = _controller.config;
        if (_controller.isBusy && config.myCallsign.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          key: const ValueKey('settings'),
          padding: const EdgeInsets.all(12),
          children: [
            // ---- User profile ----
            _SectionHeader(title: '台站设置'),
            _TextFieldTile(
              label: '呼号',
              value: config.myCallsign,
              hint: 'BG7QVU',
              onChanged: (v) => _controller.update(
                (c) => c.copyWith(myCallsign: v.toUpperCase()),
              ),
            ),
            _TextFieldTile(
              label: '网格定位',
              value: config.myMaidenGrid,
              hint: 'OL72ce',
              onChanged: (v) => _controller.update(
                (c) => c.copyWith(myMaidenGrid: v),
              ),
            ),
            _TextFieldTile(
              label: 'CQ修饰符',
              value: config.toModifier,
              hint: 'POTA',
              onChanged: (v) => _controller.update(
                (c) => c.copyWith(toModifier: v.toUpperCase()),
              ),
            ),
            const SizedBox(height: 16),

            // ---- Frequency / band ----
            _SectionHeader(title: '频率与波段'),
            _DropdownTile<int>(
              label: '工作频率',
              value: config.bandHz,
              items: OperationBand.defaults
                  .map((b) => DropdownMenuItem(
                        value: b.frequencyHz,
                        child: Text(b.label),
                      ))
                  .toList(),
              onChanged: (v) {
                if (v != null) {
                  _controller.update((c) => c.copyWith(bandHz: v));
                }
              },
            ),
            _TextFieldTile(
              label: '发射音频频率 (Hz)',
              value: config.transmitFrequencyHz.toString(),
              keyboardType: TextInputType.number,
              onChanged: (v) => _controller.update(
                (c) => c.copyWith(transmitFrequencyHz: int.tryParse(v) ?? 1500),
              ),
            ),
            _SwitchTile(
              label: '同步收发频率',
              value: config.synFrequency,
              onChanged: (v) =>
                  _controller.update((c) => c.copyWith(synFrequency: v)),
            ),
            const SizedBox(height: 16),

            // ---- Transmission ----
            _SectionHeader(title: '发射设置'),
            _TextFieldTile(
              label: '发射延迟 (ms)',
              value: config.transmitDelay.toString(),
              keyboardType: TextInputType.number,
              onChanged: (v) => _controller.update(
                (c) => c.copyWith(transmitDelay: int.tryParse(v) ?? 500),
              ),
            ),
            _DropdownTile<int>(
              label: '发射监督时限',
              value: config.launchSupervisionMs,
              items: const [
                DropdownMenuItem(value: 0, child: Text('无限制')),
                DropdownMenuItem(value: 300000, child: Text('5 分钟')),
                DropdownMenuItem(value: 600000, child: Text('10 分钟')),
                DropdownMenuItem(value: 900000, child: Text('15 分钟')),
                DropdownMenuItem(value: 1800000, child: Text('30 分钟')),
              ],
              onChanged: (v) {
                if (v != null) {
                  _controller.update((c) => c.copyWith(launchSupervisionMs: v));
                }
              },
            ),
            _DropdownTile<int>(
              label: '无应答停止',
              value: config.noReplyLimit,
              items: const [
                DropdownMenuItem(value: 0, child: Text('不限')),
                DropdownMenuItem(value: 3, child: Text('3 次')),
                DropdownMenuItem(value: 5, child: Text('5 次')),
                DropdownMenuItem(value: 10, child: Text('10 次')),
              ],
              onChanged: (v) {
                if (v != null) {
                  _controller.update((c) => c.copyWith(noReplyLimit: v));
                }
              },
            ),
            const SizedBox(height: 16),

            // ---- Radio connection ----
            _SectionHeader(title: '电台连接'),
            _DropdownTile<int>(
              label: '连接方式',
              value: config.connectMode,
              items: const [
                DropdownMenuItem(value: 0, child: Text('USB 线缆')),
                DropdownMenuItem(value: 1, child: Text('蓝牙')),
                DropdownMenuItem(value: 2, child: Text('Wi-Fi (ICOM)')),
                DropdownMenuItem(value: 3, child: Text('Flex Network')),
              ],
              onChanged: (v) {
                if (v != null) {
                  _controller.update((c) => c.copyWith(connectMode: v));
                }
              },
            ),
            _DropdownTile<int>(
              label: '控制模式',
              value: config.controlMode,
              items: const [
                DropdownMenuItem(value: 0, child: Text('VOX')),
                DropdownMenuItem(value: 1, child: Text('PTT (CAT)')),
              ],
              onChanged: (v) {
                if (v != null) {
                  _controller.update((c) => c.copyWith(controlMode: v));
                }
              },
            ),
            _DropdownTile<int>(
              label: '协议 (Instruction Set)',
              value: config.instructionSet,
              items: const [
                DropdownMenuItem(value: 0, child: Text('ICOM')),
                DropdownMenuItem(value: 1, child: Text('Yaesu (New CAT)')),
                DropdownMenuItem(value: 2, child: Text('Yaesu (Old CAT)')),
                DropdownMenuItem(value: 3, child: Text('Elecraft')),
                DropdownMenuItem(value: 4, child: Text('Kenwood')),
                DropdownMenuItem(value: 5, child: Text('Xiegu')),
                DropdownMenuItem(value: 6, child: Text('FlexRadio')),
              ],
              onChanged: (v) {
                if (v != null) {
                  _controller.update((c) => c.copyWith(instructionSet: v));
                }
              },
            ),
            _TextFieldTile(
              label: 'CI-V 地址 (十六进制)',
              value: config.civAddress.toRadixString(16).toUpperCase(),
              hint: 'A4',
              onChanged: (v) => _controller.update(
                (c) => c.copyWith(civAddress: int.tryParse(v, radix: 16) ?? 0xA4),
              ),
            ),
            _DropdownTile<int>(
              label: '波特率',
              value: config.baudRate,
              items: const [
                DropdownMenuItem(value: 4800, child: Text('4800')),
                DropdownMenuItem(value: 9600, child: Text('9600')),
                DropdownMenuItem(value: 19200, child: Text('19200')),
                DropdownMenuItem(value: 38400, child: Text('38400')),
                DropdownMenuItem(value: 57600, child: Text('57600')),
                DropdownMenuItem(value: 115200, child: Text('115200')),
              ],
              onChanged: (v) {
                if (v != null) {
                  _controller.update((c) => c.copyWith(baudRate: v));
                }
              },
            ),
            _DropdownTile<int>(
              label: 'PTT 延迟 (ms)',
              value: config.pttDelay,
              items: const [
                DropdownMenuItem(value: 0, child: Text('0')),
                DropdownMenuItem(value: 50, child: Text('50')),
                DropdownMenuItem(value: 100, child: Text('100')),
                DropdownMenuItem(value: 200, child: Text('200')),
                DropdownMenuItem(value: 500, child: Text('500')),
              ],
              onChanged: (v) {
                if (v != null) {
                  _controller.update((c) => c.copyWith(pttDelay: v));
                }
              },
            ),

            // Show ICOM network settings when Wi-Fi mode
            if (config.connectMode == Ft8Constants.connectModeWifi) ...[
              const SizedBox(height: 16),
              _SectionHeader(title: 'ICOM Wi-Fi 设置'),
              _TextFieldTile(
                label: 'IP 地址',
                value: config.icomIp,
                hint: '192.168.0.1',
                onChanged: (v) =>
                    _controller.update((c) => c.copyWith(icomIp: v)),
              ),
              _TextFieldTile(
                label: 'UDP 端口',
                value: config.icomPort.toString(),
                keyboardType: TextInputType.number,
                onChanged: (v) => _controller.update(
                  (c) => c.copyWith(icomPort: int.tryParse(v) ?? 50001),
                ),
              ),
              _TextFieldTile(
                label: '用户名',
                value: config.icomUser,
                onChanged: (v) =>
                    _controller.update((c) => c.copyWith(icomUser: v)),
              ),
              _TextFieldTile(
                label: '密码',
                value: config.icomPassword,
                obscure: true,
                onChanged: (v) =>
                    _controller.update((c) => c.copyWith(icomPassword: v)),
              ),
            ],

            const SizedBox(height: 16),

            // ---- Decode ----
            _SectionHeader(title: '解码设置'),
            _SwitchTile(
              label: '深度解码',
              value: config.deepDecode,
              onChanged: (v) =>
                  _controller.update((c) => c.copyWith(deepDecode: v)),
            ),
            _SwitchTile(
              label: '保存 SWL 消息',
              value: config.saveSWLMessages,
              onChanged: (v) =>
                  _controller.update((c) => c.copyWith(saveSWLMessages: v)),
            ),
            const SizedBox(height: 16),

            // ---- Third-party ----
            _SectionHeader(title: '第三方服务'),
            _SwitchTile(
              label: '启用 Cloudlog',
              value: config.enableCloudlog,
              onChanged: (v) =>
                  _controller.update((c) => c.copyWith(enableCloudlog: v)),
            ),
            if (config.enableCloudlog) ...[
              _TextFieldTile(
                label: 'Cloudlog 服务器地址',
                value: config.cloudlogAddress,
                hint: 'https://cloudlog.example.com',
                onChanged: (v) =>
                    _controller.update((c) => c.copyWith(cloudlogAddress: v)),
              ),
              _TextFieldTile(
                label: 'API Key',
                value: config.cloudlogApiKey,
                obscure: true,
                onChanged: (v) =>
                    _controller.update((c) => c.copyWith(cloudlogApiKey: v)),
              ),
              _TextFieldTile(
                label: 'Station ID',
                value: config.cloudlogStationId,
                onChanged: (v) =>
                    _controller.update((c) => c.copyWith(cloudlogStationId: v)),
              ),
            ],
            _SwitchTile(
              label: '启用 QRZ.com',
              value: config.enableQrz,
              onChanged: (v) =>
                  _controller.update((c) => c.copyWith(enableQrz: v)),
            ),
            if (config.enableQrz)
              _TextFieldTile(
                label: 'QRZ API Key',
                value: config.qrzApiKey,
                obscure: true,
                onChanged: (v) =>
                    _controller.update((c) => c.copyWith(qrzApiKey: v)),
              ),
            const SizedBox(height: 16),

            // ---- Filter ----
            _SectionHeader(title: '过滤'),
            _TextFieldTile(
              label: '排除呼号前缀',
              value: config.excludedCallsigns,
              hint: '逗号分隔',
              onChanged: (v) =>
                  _controller.update((c) => c.copyWith(excludedCallsigns: v)),
            ),
            const SizedBox(height: 16),

            // ---- Volume ----
            _SectionHeader(title: '音频'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.volume_down),
                  Expanded(
                    child: Slider(
                      value: config.volumePercent,
                      onChanged: (v) =>
                          _controller.update((c) => c.copyWith(volumePercent: v)),
                    ),
                  ),
                  const Icon(Icons.volume_up),
                  const SizedBox(width: 8),
                  Text('${(config.volumePercent * 100).round()}%'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ---- Save button ----
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: FilledButton.icon(
                onPressed: _controller.isDirty ? _controller.save : null,
                icon: const Icon(Icons.save),
                label: const Text('保存设置'),
              ),
            ),
            const SizedBox(height: 32),
          ],
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Helper tiles
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}

class _TextFieldTile extends StatelessWidget {
  const _TextFieldTile({
    required this.label,
    required this.value,
    required this.onChanged,
    this.hint,
    this.keyboardType,
    this.obscure = false,
  });

  final String label;
  final String value;
  final String? hint;
  final TextInputType? keyboardType;
  final bool obscure;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: TextFormField(
        initialValue: value,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        keyboardType: keyboardType,
        obscureText: obscure,
        onChanged: onChanged,
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(label),
      value: value,
      onChanged: onChanged,
      dense: true,
    );
  }
}

class _DropdownTile<T> extends StatelessWidget {
  const _DropdownTile({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            value: items.any((item) => item.value == value) ? value : null,
            isExpanded: true,
            isDense: true,
            items: items,
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }
}
