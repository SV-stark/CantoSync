import 'package:canto_sync/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App renders Library and Player navigation items', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: CantoSyncApp()));

    expect(find.text('Library'), findsOneWidget);
    expect(find.text('Player'), findsOneWidget);
    expect(find.text('Statistics'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });
}
