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
                'connectionLabel': '桥接待机',
                'isConnected': true,
                'isListening': false,
                'mode': 'FT8',
                'frequencyHz': 14074000,
                'audioSource': 'IDLE',
                'platform': 'android',
              },
              'timerState': <String, dynamic>{
                'utcMillis': 0,
                'slotProgress': 0.0,
                'sequential': 0,
                'slotLengthSeconds': 15,
              },
              'messages': <Map<String, dynamic>>[],
            };
          default:
            return null;
        }
      },
    );

    // Mock timer and state event channels so subscribing doesn't throw.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('cn.bg7qvu.ft8zh/timer', (ByteData? message) async {
      return const StandardMethodCodec().encodeSuccessEnvelope(null);
    });
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('cn.bg7qvu.ft8zh/state', (ByteData? message) async {
      return const StandardMethodCodec().encodeSuccessEnvelope(null);
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('cn.bg7qvu.ft8zh/native'),
      null,
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('cn.bg7qvu.ft8zh/timer', null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('cn.bg7qvu.ft8zh/state', null);
  });

  testWidgets('FT8ZH shell renders main sections', (WidgetTester tester) async {
    await tester.pumpWidget(const Ft8ZhApp());
    await tester.pumpAndSettle();

    expect(find.text('FT8ZH'), findsOneWidget);
    expect(find.text('主控台'), findsOneWidget);
    expect(find.text('当前状态'), findsOneWidget);
    expect(find.text('简化频谱 / 瀑布'), findsOneWidget);
  });
}
