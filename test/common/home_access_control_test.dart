import 'package:fl_clash/common/access_control.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

Package package(String name, {bool system = true, bool internet = true}) =>
    Package(
      packageName: name,
      label: name,
      system: system,
      internet: internet,
      lastUpdateTime: 0,
    );

void main() {
  final google = googlePlayPackages.map((name) => package(name)).toList();
  test('Google Play components remain visible through both filter paths', () {
    final packages = [...google, package('android.settings')];
    final visible = packages.getViewList(
      pinedList: [],
      sortType: AccessSortType.none,
      isFilterSystemApp: true,
      isFilterNonInternetApp: true,
    );
    expect(visible, google);
    expect(
      PackageListSelectorState(
        packages: packages,
        accessControlProps: const AccessControlProps(),
      ).list,
      google,
    );
  });

  test(
    'whitelist shortcut includes installed components and preserves others',
    () {
      const original = AccessControlProps(
        enable: true,
        mode: AccessControlMode.acceptSelected,
        acceptList: ['my.browser'],
        rejectList: ['other.app'],
      );
      final updated = includeGooglePlayInVpn(original, google.take(2));
      expect(
        updated.acceptList,
        containsAll(['my.browser', ...googlePlayPackages.take(2)]),
      );
      expect(updated.acceptList, hasLength(3));
      expect(updated.rejectList, original.rejectList);
      expect(updated.enable, isTrue);
      expect(includeGooglePlayInVpn(updated, google.take(2)), updated);
    },
  );

  test('blacklist shortcut removes only installed Google components', () {
    const original = AccessControlProps(
      rejectList: [...googlePlayPackages, 'other.app'],
    );
    final updated = includeGooglePlayInVpn(original, google);
    expect(updated.rejectList, ['other.app']);
    expect(updated.enable, isFalse);
    expect(updated.mode, original.mode);
  });
}
