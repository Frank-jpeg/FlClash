import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';

const googlePlayPackages = {
  'com.android.vending',
  'com.google.android.gms',
  'com.google.android.gsf',
  'com.android.providers.downloads',
};

bool showAccessControlPackage(
  Package package, {
  required bool filterSystem,
  required bool filterOffline,
}) {
  if (googlePlayPackages.contains(package.packageName)) return true;
  return (!filterSystem || !package.system) &&
      (!filterOffline || package.internet);
}

AccessControlProps includeGooglePlayInVpn(
  AccessControlProps accessControl,
  Iterable<Package> packages,
) {
  final installed = packages
      .map((package) => package.packageName)
      .where(googlePlayPackages.contains)
      .toSet();
  return switch (accessControl.mode) {
    AccessControlMode.acceptSelected => accessControl.copyWith(
      acceptList: {...accessControl.acceptList, ...installed}.toList()..sort(),
    ),
    AccessControlMode.rejectSelected => accessControl.copyWith(
      rejectList: accessControl.rejectList
          .where((name) => !installed.contains(name))
          .toList(),
    ),
  };
}
