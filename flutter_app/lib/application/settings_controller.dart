import 'package:flutter/foundation.dart';

import '../domain/models.dart';
import '../platform_bridge/native_bridge.dart';

/// Controller for the settings / configuration page.
class SettingsController extends ChangeNotifier {
  SettingsController();

  AppConfig _config = const AppConfig();
  bool _isBusy = false;
  String? _error;
  bool _isDirty = false;

  AppConfig get config => _config;
  bool get isBusy => _isBusy;
  String? get error => _error;
  bool get isDirty => _isDirty;

  Future<void> load() async {
    _isBusy = true;
    notifyListeners();
    try {
      _config = await NativeBridge.loadConfig();
      _error = null;
      _isDirty = false;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  void update(AppConfig Function(AppConfig) updater) {
    _config = updater(_config);
    _isDirty = true;
    notifyListeners();
  }

  Future<void> save() async {
    _isBusy = true;
    notifyListeners();
    try {
      await NativeBridge.saveConfig(_config);
      _isDirty = false;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
