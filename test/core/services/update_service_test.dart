import 'package:flutter_test/flutter_test.dart';
import 'package:canto_sync/core/services/update_service.dart';

void main() {
  group('UpdateService.isNewerVersion', () {
    final service = UpdateService();

    test('detects higher major version', () {
      expect(service.isNewerVersion('1.0.0', '2.0.0'), isTrue);
    });

    test('detects higher minor version', () {
      expect(service.isNewerVersion('1.2.0', '1.3.0'), isTrue);
    });

    test('detects higher patch version', () {
      expect(service.isNewerVersion('1.2.3', '1.2.4'), isTrue);
    });

    test('returns false when latest is older', () {
      expect(service.isNewerVersion('2.0.0', '1.9.9'), isFalse);
      expect(service.isNewerVersion('1.5.2', '1.5.1'), isFalse);
    });

    test('returns false when versions are identical', () {
      expect(service.isNewerVersion('1.0.0', '1.0.0'), isFalse);
      expect(service.isNewerVersion('2.3.4', '2.3.4'), isFalse);
    });

    test('handles unequal version segments correctly', () {
      expect(service.isNewerVersion('1.0', '1.0.1'), isTrue);
      expect(service.isNewerVersion('1.0.1', '1.0'), isFalse);
    });
  });
}
