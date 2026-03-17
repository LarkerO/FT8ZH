import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ft8zh/app/app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // Mock the native method channel so tests don't depend on the platform.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('cn.bg7qvu.ft8zh/native'),
      (MethodCall methodCall) async {
        switch (methodCall.method) {
          case 'getPlatformSummary':
            return <String, dynamic>{
              'platform': 'android',
              'brand': 'Test',
              'device': 'test',
              'manufacturer': 'Test',
              'model': 'Test Device',
              'sdkInt': 34,
              'release': '14',
            };
          case 'getInitialSnapshot':
            return <String, dynamic>{
              'rigState': <String, dynamic>{
                'connectionLabel': '待机',
                'isConnected': true,
                'isListening': false,
                'isTransmitting': false,
                'isDecoding': false,
                'isRecording': false,
                'mode': 'FT8',
                'frequencyHz': 14074000,
                'audioSource': 'IDLE',
                'platform': 'android',
                'connectMode': 0,
                'rigName': '',
              },
              'timerState': <String, dynamic>{
                'utcMillis': 0,
                'slotProgress': 0.0,
                'sequential': 0,
                'slotLengthSeconds': 15,
              },
              'messages': <Map<String, dynamic>>[],
              'config': <String, dynamic>{},
            };
          case 'loadConfig':
            return <String, dynamic>{};
          case 'getLogCount':
            return 0;
          case 'queryLogs':
            return <Map<String, dynamic>>[];
          default:
            return null;
        }
      },
    );

    // Mock event channels so subscribing doesn't throw.
    for (final channel in [
      'cn.bg7qvu.ft8zh/timer',
      'cn.bg7qvu.ft8zh/state',
      'cn.bg7qvu.ft8zh/decode',
      'cn.bg7qvu.ft8zh/spectrum',
    ]) {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler(channel, (ByteData? message) async {
        return const StandardMethodCodec().encodeSuccessEnvelope(null);
      });
    }
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('cn.bg7qvu.ft8zh/native'),
      null,
    );
    for (final channel in [
      'cn.bg7qvu.ft8zh/timer',
      'cn.bg7qvu.ft8zh/state',
      'cn.bg7qvu.ft8zh/decode',
      'cn.bg7qvu.ft8zh/spectrum',
    ]) {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler(channel, null);
    }
  });

  testWidgets('FT8ZH shell renders main sections', (WidgetTester tester) async {
    await tester.pumpWidget(const Ft8ZhApp());
    await tester.pumpAndSettle();

    // App title
    expect(find.text('FT8ZH'), findsOneWidget);
    // Bottom nav tabs
    expect(find.text('主控台'), findsOneWidget);
    expect(find.text('日志'), findsOneWidget);
    expect(find.text('地图'), findsOneWidget);
    expect(find.text('设置'), findsOneWidget);
    // Console status section
    expect(find.text('当前状态'), findsOneWidget);
    // Spectrum section
    expect(find.text('频谱 / 瀑布'), findsOneWidget);
  });

  testWidgets('Can navigate between tabs', (WidgetTester tester) async {
    await tester.pumpWidget(const Ft8ZhApp());
    await tester.pumpAndSettle();

    // Tap logbook tab
    await tester.tap(find.text('日志'));
    await tester.pumpAndSettle();
    expect(find.text('搜索呼号...'), findsOneWidget);

    // Tap map tab
    await tester.tap(find.text('地图'));
    await tester.pumpAndSettle();
    expect(find.text('地图 / Grid Tracker'), findsOneWidget);

    // Tap settings tab
    await tester.tap(find.text('设置'));
    await tester.pumpAndSettle();
    expect(find.text('台站设置'), findsOneWidget);

    // Back to console
    await tester.tap(find.text('主控台'));
    await tester.pumpAndSettle();
    expect(find.text('当前状态'), findsOneWidget);
  });
}
