import 'package:canto_sync/main.dart';
import 'package:canto_sync/core/constants/app_constants.dart';
import 'package:canto_sync/features/library/data/book.dart';
import 'package:canto_sync/features/stats/data/listening_stats.dart';
import 'package:canto_sync/core/data/keyboard_shortcuts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await Hive.initFlutter();

    Hive.registerAdapter(BookAdapter());
    Hive.registerAdapter(BookmarkAdapter());
    Hive.registerAdapter(FileMetadataAdapter());
    Hive.registerAdapter(DailyListeningStatsAdapter());
    Hive.registerAdapter(AuthorStatsAdapter());
    Hive.registerAdapter(BookCompletionStatsAdapter());
    Hive.registerAdapter(ListeningSpeedPreferenceAdapter());
    Hive.registerAdapter(KeyboardShortcutAdapter());

    await Hive.openBox<Book>(AppConstants.libraryBox);
    await Hive.openBox<Book>(AppConstants.booksBox);
    await Hive.openBox(AppConstants.settingsBox);
    await Hive.openBox<DailyListeningStats>(AppConstants.dailyStatsBox);
    await Hive.openBox<AuthorStats>(AppConstants.authorStatsBox);
    await Hive.openBox<BookCompletionStats>(AppConstants.bookStatsBox);
    await Hive.openBox<ListeningSpeedPreference>(AppConstants.speedStatsBox);
    await Hive.openBox<KeyboardShortcut>(AppConstants.keyboardShortcutsBox);
    await Hive.openBox<int>(AppConstants.schemaVersionBox);
  });

  tearDownAll(() async {
    await Hive.close();
  });

  testWidgets('App renders Library and Player navigation items', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: CantoSyncApp()));
    await tester.pumpAndSettle();

    expect(find.text('Library'), findsOneWidget);
    expect(find.text('Player'), findsOneWidget);
    expect(find.text('Statistics'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });
}
