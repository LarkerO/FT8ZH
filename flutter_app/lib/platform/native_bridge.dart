import 'package:flutter/services.dart';

class NativeBridge {
  NativeBridge._();

  static const MethodChannel _channel = MethodChannel('cn.bg7qvu.ft8zh/native');

  static Future<Map<String, dynamic>> getPlatformSummary() async {
    final result = await _channel.invokeMapMethod<String, dynamic>('getPlatformSummary');
    return result ?? const <String, dynamic>{};
  }
}
