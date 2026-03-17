import 'package:flutter/foundation.dart';

import '../domain/models.dart';
import '../platform_bridge/native_bridge.dart';

/// Controller for the QSO logbook page.
class LogController extends ChangeNotifier {
  LogController();

  List<QslRecord> _records = const [];
  int _totalCount = 0;
  bool _isBusy = false;
  String? _error;
  String _searchQuery = '';

  static const int _pageSize = 50;

  List<QslRecord> get records => _records;
  int get totalCount => _totalCount;
  bool get isBusy => _isBusy;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  bool get hasMore => _records.length < _totalCount;

  Future<void> load() async {
    _isBusy = true;
    notifyListeners();
    try {
      _totalCount = await NativeBridge.getLogCount();
      _records = await NativeBridge.queryLogs(
        callsign: _searchQuery.isEmpty ? null : _searchQuery,
        limit: _pageSize,
        offset: 0,
      );
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (_isBusy || !hasMore) return;
    _isBusy = true;
    notifyListeners();
    try {
      final more = await NativeBridge.queryLogs(
        callsign: _searchQuery.isEmpty ? null : _searchQuery,
        limit: _pageSize,
        offset: _records.length,
      );
      _records = [..._records, ...more];
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  Future<void> search(String query) async {
    _searchQuery = query;
    await load();
  }

  Future<void> deleteRecord(int id) async {
    try {
      await NativeBridge.deleteLog(id);
      _records = _records.where((r) => r.id != id).toList();
      _totalCount = (_totalCount - 1).clamp(0, _totalCount);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
