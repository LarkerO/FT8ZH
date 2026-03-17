import 'package:flutter/material.dart';

import '../../application/log_controller.dart';
import '../../domain/models.dart';
import '../../shared/widgets/common.dart';

/// QSO logbook page – mirrors the original LogFragment.
///
/// Features: search, paginated list, swipe to delete, export.
class LogbookPage extends StatefulWidget {
  const LogbookPage({super.key});

  @override
  State<LogbookPage> createState() => _LogbookPageState();
}

class _LogbookPageState extends State<LogbookPage> {
  final _controller = LogController();
  final _searchCtrl = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.load();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchCtrl.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  static const double _paginationThreshold = 200.0;

  void _onScroll() {
    if (_scrollController.position.extentAfter < _paginationThreshold &&
        !_controller.isBusy) {
      _controller.loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: SearchBar(
                controller: _searchCtrl,
                hintText: '搜索呼号...',
                leading: const Icon(Icons.search),
                trailing: [
                  if (_searchCtrl.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchCtrl.clear();
                        _controller.search('');
                      },
                    ),
                ],
                onSubmitted: _controller.search,
              ),
            ),

            // Count + actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    '共 ${_controller.totalCount} 条记录',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    tooltip: '刷新',
                    onPressed: _controller.load,
                  ),
                ],
              ),
            ),

            // Error
            if (_controller.error case final error?)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Material(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(error),
                  ),
                ),
              ),

            // Record list
            Expanded(
              child: _controller.records.isEmpty && !_controller.isBusy
                  ? const EmptyState(
                      icon: Icons.book_outlined,
                      message: '暂无 QSO 日志记录',
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: _controller.records.length +
                          (_controller.isBusy ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index >= _controller.records.length) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        final record = _controller.records[index];
                        return _QslRecordTile(
                          record: record,
                          onDelete: () =>
                              _controller.deleteRecord(record.id),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _QslRecordTile extends StatelessWidget {
  const _QslRecordTile({
    required this.record,
    required this.onDelete,
  });

  final QslRecord record;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(record.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: Colors.red.shade700,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => onDelete(),
      child: Card(
        margin: const EdgeInsets.only(bottom: 4),
        child: ListTile(
          dense: true,
          leading: CircleAvatar(
            radius: 16,
            backgroundColor: record.isConfirmed
                ? Colors.green.shade700
                : Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Text(
              record.mode.isEmpty ? 'FT8' : record.mode,
              style: const TextStyle(fontSize: 10),
            ),
          ),
          title: Text(
            '${record.myCallsign} ↔ ${record.toCallsign}',
            style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
          ),
          subtitle: Text(
            '${record.startTimeLabel} · ${record.frequencyMhzLabel} MHz'
            '${record.band.isNotEmpty ? ' (${record.band})' : ''}'
            ' · ${record.reportSent >= 0 ? '+' : ''}${record.reportSent}'
            '/${record.reportReceived >= 0 ? '+' : ''}${record.reportReceived}',
            style: const TextStyle(fontSize: 11),
          ),
          trailing: record.isConfirmed
              ? const Icon(Icons.verified, size: 18, color: Colors.green)
              : null,
        ),
      ),
    );
  }
}
