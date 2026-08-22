import 'package:isar_community/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'isar_provider.g.dart';

@Riverpod(keepAlive: true)
Isar isar(Ref ref) {
  throw UnimplementedError(
    'Isar must be initialized in main.dart and overridden in ProviderScope',
  );
}
