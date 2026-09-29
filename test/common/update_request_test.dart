import 'package:dio/dio.dart';
import 'package:fl_clash/common/request.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    globalState.packageInfo = PackageInfo(
      appName: 'FlClash',
      packageName: 'com.follow.clash.home',
      version: '0.8.98-home.1',
      buildNumber: '2026092901',
    );
  });

  Future<Map<String, dynamic>?> check(Object? tag, {int status = 200}) async {
    final client = Request();
    addTearDown(() => client.dio.close(force: true));
    client.dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          expect(
            options.uri.toString(),
            'https://api.github.com/repos/Frank-jpeg/FlClash/releases/latest',
          );
          handler.resolve(
            Response(
              requestOptions: options,
              statusCode: status,
              data: <String, dynamic>{'tag_name': tag, 'body': '- Fixes'},
            ),
          );
        },
      ),
    );
    return client.checkForUpdate();
  }

  test('discovers newer custom releases from the fork', () async {
    for (final tag in ['v0.8.98-home.2', 'v0.8.98-home.10', 'v0.8.99-home.1']) {
      expect((await check(tag))?['tag_name'], tag);
    }
  });

  test('does not offer equal, older or malformed releases', () async {
    for (final tag in [
      'v0.8.98-home.1',
      'v0.8.97-home.9',
      'latest',
      null,
      123,
    ]) {
      expect(await check(tag), isNull);
    }
  });

  test('handles a fork with no releases', () async {
    expect(await check(null, status: 404), isNull);
  });
}
