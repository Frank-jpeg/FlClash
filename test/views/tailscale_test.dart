import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/tailscale.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/test_app.dart';

void main() {
  testWidgets('small screen masks the key and rejects a default subnet route', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final container = ProviderContainer();
    addTearDown(container.dispose);
    globalState.container = container;
    container.listen(tailscaleSettingProvider, (_, _) {});
    container.read(tailscaleSettingProvider.notifier).value =
        const TailscaleProps(authKey: 'tskey-auth-test-placeholder');
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(
          locale: Locale('zh', 'CN'),
          child: TailscaleView(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    final fields = find.byType(TextFormField);
    final keyInput = find.descendant(
      of: fields.at(1),
      matching: find.byType(EditableText),
    );
    expect(tester.widget<EditableText>(keyInput).obscureText, isTrue);
    await tester.ensureVisible(fields.at(2));
    await tester.enterText(fields.at(2), '0.0.0.0/0');
    final form = tester.state<FormState>(find.byType(Form));
    expect(form.validate(), isFalse);
    await tester.pumpAndSettle();
    expect(container.read(tailscaleSettingProvider).subnets, isEmpty);
    await tester.enterText(fields.at(2), '192.168.7.0/24');
    expect(form.validate(), isTrue);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
