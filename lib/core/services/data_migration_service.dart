import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:canto_sync/core/constants/app_constants.dart';

class DataMigrationService {
  static const String _versionKey = 'schemaVersion';

  static Future<void> runMigrations() async {
    final versionBox = await Hive.openBox<int>(AppConstants.schemaVersionBox);
    final currentVersion = versionBox.get(_versionKey, defaultValue: 0)!;
    final targetVersion = AppConstants.currentSchemaVersion;

    if (currentVersion >= targetVersion) {
      await versionBox.close();
      return;
    }

    debugPrint('Data migration: v$currentVersion -> v$targetVersion');

    for (
      int version = currentVersion + 1;
      version <= targetVersion;
      version++
    ) {
      debugPrint('Running migration to v$version');
      await _runMigration(version);
      await versionBox.put(_versionKey, version);
    }

    await versionBox.close();
    debugPrint('Data migration complete');
  }

  static Future<void> _runMigration(int version) async {
    switch (version) {
      case 1:
        await _migrationV1();
        break;
      default:
        debugPrint('No migration defined for v$version');
    }
  }

  static Future<void> _migrationV1() async {
    // Initial migration - no data structure changes needed yet.
    // Future migrations should be added here as new versions are defined.
    // Example:
    // final booksBox = Hive.box<Book>(AppConstants.booksBox);
    // for (final book in booksBox.values) {
    //   if (book.newField == null) {
    //     book.newField = 'default';
    //     await book.save();
    //   }
    // }
  }
}
