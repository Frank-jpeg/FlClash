import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/views/access.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

class AccessControlCard extends ConsumerWidget {
  const AccessControlCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final access = ref.watch(
      vpnSettingProvider.select((state) => state.accessControlProps),
    );
    final strings = context.appLocalizations;
    final mode = access.mode == AccessControlMode.acceptSelected
        ? strings.whitelistMode
        : strings.blacklistMode;
    return CommonCard(
      isSelected: access.enable,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SwitchListTile(
            key: const ValueKey('home-access-control-switch'),
            secondary: const Icon(Icons.apps_outlined),
            title: Text(strings.appAccessControl),
            value: access.enable,
            onChanged: (enable) {
              ref
                  .read(vpnSettingProvider.notifier)
                  .update(
                    (state) =>
                        state.copyWith.accessControlProps(enable: enable),
                  );
            },
          ),
          ListItem.open(
            key: const ValueKey('home-access-control-apps'),
            title: Text(strings.accessControlDesc),
            subtitle: Text(
              '$mode · ${strings.selectedCountTitle(access.currentList.length)}',
            ),
            minVerticalPadding: 8,
            widget: const AccessView(),
          ),
          if (ref.watch(vpnRestartRequiredProvider))
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Text(strings.vpnTip, style: context.textTheme.bodySmall),
            ),
        ],
      ),
    );
  }
}
