import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/views/access.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'card.dart';

/// The home-screen switch for the per-app VPN list.
///
/// The access page itself lives under Tools; this card puts the switch and the
/// way into the list one tap from the dashboard.
class AccessControlCard extends ConsumerWidget {
  const AccessControlCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accessControl = ref.watch(
      vpnSettingProvider.select((state) => state.accessControlProps),
    );
    final appLocalizations = context.appLocalizations;
    final mode = accessControl.mode == AccessControlMode.acceptSelected
        ? appLocalizations.accessControlAllowDesc
        : appLocalizations.accessControlNotAllowDesc;
    return DashboardCard(
      semanticLabel: appLocalizations.appAccessControl,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DashboardCardHeader(
            glyph: AppGlyphs.appsList,
            title: appLocalizations.appAccessControl,
            trailing: [
              Switch(
                value: accessControl.enable,
                onChanged: (enable) {
                  ref
                      .read(vpnSettingProvider.notifier)
                      .update(
                        (state) => state.copyWith.accessControlProps(
                          enable: enable,
                        ),
                      );
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          ListItem.open(
            title: Text(mode),
            subtitle: Text(
              appLocalizations.accessControlSelectedCount(
                accessControl.currentList.length,
              ),
            ),
            minVerticalPadding: 8,
            widget: const AccessView(),
          ),
        ],
      ),
    );
  }
}
