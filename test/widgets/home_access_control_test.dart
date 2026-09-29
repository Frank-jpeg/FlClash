import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/dashboard/widgets/access_control.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/test_app.dart';

void main() {
  for (final enabled in [false, true]) {
    testWidgets('restart hint tracks changes from enabled=$enabled', (
      tester,
    ) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      globalState.container = container;
      container.listen(vpnSettingProvider, (_, _) {});
      final notifier = container.read(vpnSettingProvider.notifier);
      notifier.value = VpnProps(
        accessControlProps: AccessControlProps(enable: enabled),
      );
      final started = container.read(vpnStateProvider);
      container.read(startedVpnStateProvider.notifier).value = started;
      container.read(runTimeProvider.notifier).value = 1;
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const TestApp(child: Scaffold(body: AccessControlCard())),
        ),
      );
      final hint = find.text(currentAppLocalizations.vpnTip);
      expect(hint, findsNothing);

      await tester.tap(
        find.byKey(const ValueKey('home-access-control-switch')),
      );
      await tester.pump();
      expect(hint, findsOneWidget);

      await tester.tap(
        find.byKey(const ValueKey('home-access-control-switch')),
      );
      await tester.pump();
      expect(hint, findsNothing);

      await tester.tap(
        find.byKey(const ValueKey('home-access-control-switch')),
      );
      await tester.pump();
      container.read(startedVpnStateProvider.notifier).value = container.read(
        vpnStateProvider,
      );
      await tester.pump();
      expect(hint, findsNothing);

      await tester.tap(
        find.byKey(const ValueKey('home-access-control-switch')),
      );
      await tester.pump();
      expect(hint, findsOneWidget);
      container.read(runTimeProvider.notifier).value = null;
      await tester.pump();
      expect(hint, findsNothing);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }

  testWidgets('home switch preserves both lists and follows settings changes', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    globalState.container = container;
    container.listen(vpnSettingProvider, (_, _) {});
    final notifier = container.read(vpnSettingProvider.notifier);
    notifier.value = const VpnProps(
      accessControlProps: AccessControlProps(
        mode: AccessControlMode.acceptSelected,
        acceptList: ['com.android.vending'],
        rejectList: ['local.app'],
      ),
    );
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(child: Scaffold(body: AccessControlCard())),
      ),
    );
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('home-access-control-switch')));
    await tester.pump();
    expect(
      container.read(vpnSettingProvider).accessControlProps.enable,
      isTrue,
    );
    expect(container.read(vpnSettingProvider).accessControlProps.acceptList, [
      'com.android.vending',
    ]);
    expect(container.read(vpnSettingProvider).accessControlProps.rejectList, [
      'local.app',
    ]);
    notifier.update(
      (state) => state.copyWith.accessControlProps(enable: false),
    );
    await tester.pump();
    expect(
      tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value,
      isFalse,
    );
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
