import 'dart:io';

import 'package:package_info_plus/package_info_plus.dart';
import 'package:pub_semver/pub_semver.dart';

import 'common.dart';

extension PackageInfoExtension on PackageInfo {
  String get ua => [
    '$appName/v$version',
    'clash-verge',
    'Platform/${Platform.operatingSystem}',
  ].join(' ');
}

int compareVersions(String version1, String version2) {
  return _parseVersion(version1).compareTo(_parseVersion(version2));
}

Version _parseVersion(String value) {
  final normalized = value.trim().replaceFirst(RegExp(r'^v'), '');
  final match = RegExp(
    r'^(\d+)(?:\.(\d+))?(?:\.(\d+))?([+-].*)?$',
  ).firstMatch(normalized);
  if (match == null) throw FormatException('Invalid version', value);
  final version =
      '${match[1]}.${match[2] ?? '0'}.${match[3] ?? '0'}${match[4] ?? ''}';
  return Version.parse(version.contains('+') ? version : '$version+0');
}

const releaseNotesBeginMarker = '<!-- flclash:changelog:begin -->';
const releaseNotesEndMarker = '<!-- flclash:changelog:end -->';

List<String> parseReleaseBody(String? body) {
  if (body == null) return [];
  final regex = RegExp(r'^[ \t]*-[ \t]+(.*)$', multiLine: true);
  return regex
      .allMatches(scopeReleaseNotes(body))
      .map((match) => match.group(1)?.trim() ?? '')
      .where((item) => item.isNotEmpty)
      .toList();
}

String scopeReleaseNotes(String body) {
  final begin = body.indexOf(releaseNotesBeginMarker);
  if (begin < 0) return body;
  final start = begin + releaseNotesBeginMarker.length;
  final end = body.indexOf(releaseNotesEndMarker, start);
  return end < 0 ? body.substring(start) : body.substring(start, end);
}
