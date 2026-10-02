import 'dart:convert';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:canto_sync/core/utils/logger.dart';

part 'update_service.freezed.dart';
part 'update_service.g.dart';

@freezed
abstract class UpdateInfo with _$UpdateInfo {
  const factory UpdateInfo({
    required String latestVersion,
    required String downloadUrl,
    String? releaseNotes,
  }) = _UpdateInfo;
}

@Riverpod(keepAlive: true)
UpdateService updateService(Ref ref) {
  final service = UpdateService();
  ref.onDispose(service.dispose);
  return service;
}

class UpdateService {
  UpdateService({
    http.Client? client,
    this.currentVersionOverride,
  }) : _client = client ?? http.Client();

  final http.Client _client;
  final String? currentVersionOverride;
  final String repoOwner = 'SV-stark';
  final String repoName = 'CantoSync';

  Future<UpdateInfo?> checkForUpdates() async {
    try {
      final currentVersion =
          currentVersionOverride ?? (await PackageInfo.fromPlatform()).version;

      final url = Uri.parse(
        'https://api.github.com/repos/$repoOwner/$repoName/releases/latest',
      );
      final response = await _client.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is! Map<String, dynamic>) return null;
        final tagName = data['tag_name']?.toString();
        if (tagName == null) return null;
        final latestVersion = tagName.replaceFirst(RegExp('^v'), '');

        if (isNewerVersion(currentVersion, latestVersion)) {
          return UpdateInfo(
            latestVersion: latestVersion,
            downloadUrl: data['html_url'] as String? ?? '',
            releaseNotes: data['body'] as String?,
          );
        }
      } else {
        logger.w('Update check returned HTTP ${response.statusCode}');
      }
    } catch (e, stack) {
      logger.e(
        'Error checking for updates',
        error: e,
        stackTrace: stack,
      );
    }
    return null;
  }

  /// Compares two semver-ish version strings.
  ///
  /// Returns false for anything it cannot parse rather than throwing or
  /// guessing: a pre-release build string such as `1.2.0-beta.3` must not be
  /// reported as outdated, and a malformed tag must not crash the caller.
  bool isNewerVersion(String current, String latest) {
    final currentParts = _parseVersion(current);
    final latestParts = _parseVersion(latest);
    if (currentParts == null || latestParts == null) {
      logger.w(
        'Could not compare versions: current=$current latest=$latest',
      );
      return false;
    }

    final length = currentParts.length > latestParts.length
        ? currentParts.length
        : latestParts.length;
    for (var i = 0; i < length; i++) {
      // A missing component is treated as 0, so 1.2 == 1.2.0.
      final c = i < currentParts.length ? currentParts[i] : 0;
      final l = i < latestParts.length ? latestParts[i] : 0;
      if (l > c) return true;
      if (l < c) return false;
    }
    return false;
  }

  /// Extracts the leading dot-separated integers from [version], ignoring any
  /// pre-release/build suffix. Returns null if there is no leading integer.
  static List<int>? _parseVersion(String version) {
    final parts = <int>[];
    for (final raw in version.trim().split('.')) {
      final match = RegExp(r'^(\d+)').firstMatch(raw.trim());
      if (match == null) break;
      parts.add(int.parse(match.group(1)!));
    }
    return parts.isEmpty ? null : parts;
  }

  void dispose() => _client.close();
}
