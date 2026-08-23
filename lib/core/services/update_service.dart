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
  return UpdateService();
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
      final currentVersion = currentVersionOverride ??
          (await PackageInfo.fromPlatform()).version;

      final url = Uri.parse(
        'https://api.github.com/repos/$repoOwner/$repoName/releases/latest',
      );
      final response = await _client.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is! Map<String, dynamic>) return null;
        final tagName = data['tag_name']?.toString();
        if (tagName == null) return null;
        final latestVersion = tagName.replaceAll('v', '');

        if (isNewerVersion(currentVersion, latestVersion)) {
          return UpdateInfo(
            latestVersion: latestVersion,
            downloadUrl: data['html_url'] as String? ?? '',
            releaseNotes: data['body'] as String?,
          );
        }
      }
    } catch (e) {
      logger.e('Error checking for updates', error: e);
    }
    return null;
  }

  bool isNewerVersion(String current, String latest) {
    try {
      final currentParts = current.split('.').map(int.parse).toList();
      final latestParts = latest.split('.').map(int.parse).toList();

      for (var i = 0; i < latestParts.length; i++) {
        if (i >= currentParts.length) return true;
        if (latestParts[i] > currentParts[i]) return true;
        if (latestParts[i] < currentParts[i]) return false;
      }
    } catch (_) {}
    return false;
  }
}
