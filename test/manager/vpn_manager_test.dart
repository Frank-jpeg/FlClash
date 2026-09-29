import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/common/theme.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/manager/status_manager.dart';
import 'package:fl_clash/manager/vpn_manager.dart';
import 'package:fl_clash/providers/action.dart';
import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/providers/state.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/dashboard/widgets/access_control.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _RestartAction extends CoreAction {
  int calls = 0;
  bool succeeds = true;
  Completer<void>? gate;

  @override
  Future<bool> restartCore() async {
    calls++;
    final submitted = ref.read(vpnStateProvider);
    await gate?.future;
    if (succeeds && ref.mounted) {
      ref.read(startedVpnStateProvider.notifier).value = submitted;
    }
    return succeeds;
  }
}

void main() {
  late ProviderContainer container;
  late _RestartAction restart;

  setUp(() {
    restart = _RestartAction();
    container = ProviderContainer(
      overrides: [coreActionProvider.overrideWith(() => restart)],
    );
    globalState.container = container;
    container.listen(vpnSettingProvider, (_, _) {});
    container.read(startedVpnStateProvider.notifier).value = container.read(
      vpnStateProvider,
    );
  });

  tearDown(() => container.dispose());

  void setAccess(bool enabled) {
    container
        .read(vpnSettingProvider.notifier)
        .update((state) => state.copyWith.accessControlProps(enable: enabled));
  }

  Future<void> pumpVpnManager(
    WidgetTester tester, {
    bool running = true,
  }) async {
    container.read(runTimeProvider.notifier).value = running ? 1 : null;
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          navigatorKey: globalState.navigatorKey,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            ...GlobalMaterialLocalizations.delegates,
          ],
          supportedLocales: AppLocalizations.delegate.supportedLocales,
          builder: (context, child) {
            globalState.measure = Measure.of(context, 1);
            globalState.theme = CommonTheme.of(context, 1);
            return StatusManager(child: VpnManager(child: child!));
          },
          home: const Scaffold(body: AccessControlCard()),
        ),
      ),
    );
    await tester.pump();
  }

  Future<void> finish(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  }

  testWidgets('prompts for enabling and disabling immediately after restart', (
    tester,
  ) async {
    await pumpVpnManager(tester);
    setAccess(true);
    await tester.pumpAndSettle();
    expect(
      find.text(currentAppLocalizations.vpnConfigChangeDetected),
      findsOneWidget,
    );
    expect(find.text(currentAppLocalizations.vpnTip), findsOneWidget);

    await tester.tap(find.text(currentAppLocalizations.restart));
    await tester.pumpAndSettle();
    expect(restart.calls, 1);
    expect(find.text(currentAppLocalizations.vpnTip), findsNothing);
    expect(
      find.text(currentAppLocalizations.vpnConfigChangeDetected),
      findsNothing,
    );

    setAccess(false);
    await tester.pumpAndSettle();
    expect(find.text(currentAppLocalizations.vpnTip), findsOneWidget);
    expect(
      find.text(currentAppLocalizations.vpnConfigChangeDetected),
      findsOneWidget,
    );
    await tester.tap(find.text(currentAppLocalizations.restart));
    await tester.pumpAndSettle();
    expect(restart.calls, 2);
    expect(find.text(currentAppLocalizations.vpnTip), findsNothing);
    await finish(tester);
  });

  testWidgets('reverting settings or stopping clears the pending warning', (
    tester,
  ) async {
    await pumpVpnManager(tester);
    setAccess(true);
    await tester.pumpAndSettle();
    setAccess(false);
    await tester.pumpAndSettle();
    expect(
      find.text(currentAppLocalizations.vpnConfigChangeDetected),
      findsNothing,
    );
    expect(find.text(currentAppLocalizations.vpnTip), findsNothing);

    setAccess(true);
    await tester.pumpAndSettle();
    container.read(runTimeProvider.notifier).value = null;
    await tester.pumpAndSettle();
    expect(
      find.text(currentAppLocalizations.vpnConfigChangeDetected),
      findsNothing,
    );
    await finish(tester);
  });

  testWidgets('does not ask for a restart while stopped', (tester) async {
    await pumpVpnManager(tester, running: false);
    setAccess(true);
    await tester.pumpAndSettle();
    expect(
      find.text(currentAppLocalizations.vpnConfigChangeDetected),
      findsNothing,
    );
    expect(find.text(currentAppLocalizations.vpnTip), findsNothing);
    await finish(tester);
  });

  testWidgets('failed restart keeps changes pending and allows retry', (
    tester,
  ) async {
    await pumpVpnManager(tester);
    restart.succeeds = false;
    setAccess(true);
    await tester.pumpAndSettle();
    await tester.tap(find.text(currentAppLocalizations.restart));
    await tester.pumpAndSettle();
    expect(find.text(currentAppLocalizations.vpnTip), findsOneWidget);
    expect(
      find.text(currentAppLocalizations.vpnConfigChangeDetected),
      findsOneWidget,
    );
    restart.succeeds = true;
    await tester.tap(find.text(currentAppLocalizations.restart));
    await tester.pumpAndSettle();
    expect(restart.calls, 2);
    expect(find.text(currentAppLocalizations.vpnTip), findsNothing);
    await finish(tester);
  });

  testWidgets('changes during restart remain pending and disposal is safe', (
    tester,
  ) async {
    await pumpVpnManager(tester);
    restart.gate = Completer<void>();
    setAccess(true);
    await tester.pumpAndSettle();
    await tester.tap(find.text(currentAppLocalizations.restart));
    await tester.pumpAndSettle();
    expect(find.text(currentAppLocalizations.vpnTip), findsOneWidget);
    setAccess(false);
    await tester.pump();
    restart.gate!.complete();
    await tester.pumpAndSettle();
    expect(restart.calls, 1);
    expect(find.text(currentAppLocalizations.vpnTip), findsOneWidget);
    expect(
      find.text(currentAppLocalizations.vpnConfigChangeDetected),
      findsOneWidget,
    );

    restart.gate = Completer<void>();
    await tester.tap(find.text(currentAppLocalizations.restart));
    await tester.pumpAndSettle();
    await finish(tester);
    restart.gate!.complete();
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
