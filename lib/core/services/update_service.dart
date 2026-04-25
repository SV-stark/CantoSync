import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final updateServiceProvider = Provider<UpdateService>((ref) {
  return UpdateService();
});

class UpdateService {
  final String repoOwner = 'SV-stark';
  final String repoName = 'CantoSync';

  Future<UpdateInfo?> checkForUpdates() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      final url = Uri.parse(
        'https://api.github.com/repos/$repoOwner/$repoName/releases/latest',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final latestVersion = (data['tag_name'] as String).replaceAll('v', '');

        if (_isNewerVersion(currentVersion, latestVersion)) {
          return UpdateInfo(
            latestVersion: latestVersion,
            downloadUrl: data['html_url'] as String,
            releaseNotes: data['body'] as String?,
          );
        }
      }
    } catch (e) {
      debugPrint('Error checking for updates: $e');
    }
    return null;
  }

  bool _isNewerVersion(String current, String latest) {
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

class UpdateInfo {

  UpdateInfo({
    required this.latestVersion,
    required this.downloadUrl,
    this.releaseNotes,
  });
  final String latestVersion;
  final String downloadUrl;
  final String? releaseNotes;
}
