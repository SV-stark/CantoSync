import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
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

    test('handles unequal version segments correctly in both directions', () {
      expect(service.isNewerVersion('1.0', '1.0.1'), isTrue);
      expect(service.isNewerVersion('1.0.1', '1.0'), isFalse);
      expect(service.isNewerVersion('2.0', '2.0.0.1'), isTrue);
      expect(service.isNewerVersion('2.0.0.1', '2.0'), isFalse);
    });
  });

  group('UpdateService.checkForUpdates with MockClient', () {
    test('200 response with newer tag returns UpdateInfo with v stripped', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          json.encode({
            'tag_name': 'v2.1.0',
            'html_url': 'https://github.com/SV-stark/CantoSync/releases/tag/v2.1.0',
            'body': 'Exciting new features and bug fixes!',
          }),
          200,
        );
      });

      final service = UpdateService(
        client: mockClient,
        currentVersionOverride: '1.0.0',
      );

      final update = await service.checkForUpdates();
      expect(update, isNotNull);
      expect(update!.latestVersion, '2.1.0');
      expect(update.downloadUrl, 'https://github.com/SV-stark/CantoSync/releases/tag/v2.1.0');
      expect(update.releaseNotes, 'Exciting new features and bug fixes!');
    });

    test('200 response with older or same version returns null', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          json.encode({
            'tag_name': 'v1.0.0',
            'html_url': 'https://github.com/SV-stark/CantoSync/releases/tag/v1.0.0',
          }),
          200,
        );
      });

      final service = UpdateService(
        client: mockClient,
        currentVersionOverride: '1.0.0',
      );

      final update = await service.checkForUpdates();
      expect(update, isNull);
    });

    test('non-200 HTTP status code returns null', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Rate limit exceeded', 403);
      });

      final service = UpdateService(
        client: mockClient,
        currentVersionOverride: '1.0.0',
      );

      final update = await service.checkForUpdates();
      expect(update, isNull);
    });

    test('malformed JSON response body returns null (swallowed gracefully)', () async {
      final mockClient = MockClient((request) async {
        return http.Response('{not valid json at all', 200);
      });

      final service = UpdateService(
        client: mockClient,
        currentVersionOverride: '1.0.0',
      );

      final update = await service.checkForUpdates();
      expect(update, isNull);
    });

    test('unexpected json structure returns null', () async {
      final mockClient = MockClient((request) async {
        return http.Response('["array", "instead", "of", "map"]', 200);
      });

      final service = UpdateService(
        client: mockClient,
        currentVersionOverride: '1.0.0',
      );

      final update = await service.checkForUpdates();
      expect(update, isNull);
    });
  });
}
