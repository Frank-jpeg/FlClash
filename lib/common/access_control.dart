import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';

/// The Google components a player looks for in the app list even when system
/// apps are hidden.
const googlePlayPackages = {
  'com.android.vending',
  'com.google.android.gms',
  'com.google.android.gsf',
  'com.android.providers.downloads',
};

/// Whether an app belongs in the access-control list under the current
/// filters.
///
/// A Google component stays visible: hiding system apps would otherwise take
/// away the one place a player adds Play services to the VPN.
bool showAccessControlPackage(
  Package package, {
  required bool filterSystem,
  required bool filterOffline,
}) {
  if (googlePlayPackages.contains(package.packageName)) return true;
  return (!filterSystem || !package.system) &&
      (!filterOffline || package.internet);
}

/// Puts every installed Google component into the VPN, or takes them out
/// again, depending on which list the mode works with.
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
