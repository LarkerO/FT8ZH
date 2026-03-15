import 'package:flutter_test/flutter_test.dart';

import 'package:ft8zh/app/app.dart';

void main() {
  testWidgets('FT8ZH shell renders main sections', (WidgetTester tester) async {
    await tester.pumpWidget(const Ft8ZhApp());
    await tester.pumpAndSettle();

    expect(find.text('FT8ZH'), findsOneWidget);
    expect(find.text('主控台'), findsOneWidget);
    expect(find.text('当前状态'), findsOneWidget);
    expect(find.text('瀑布图 / 频谱'), findsOneWidget);
  });
}
