import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/manager/status_manager.dart';
import 'package:fl_clash/providers/action.dart';
import 'package:fl_clash/providers/state.dart';
import 'package:fl_clash/state.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VpnManager extends ConsumerStatefulWidget {
  final Widget child;

  const VpnManager({super.key, required this.child});

  @override
  ConsumerState<VpnManager> createState() => _VpnContainerState();
}

class _VpnContainerState extends ConsumerState<VpnManager> {
  bool _restarting = false;

  @override
  void initState() {
    super.initState();
    ref.listenManual(vpnStateProvider, (prev, next) {
      if (prev != next) {
        _updateTip();
      }
    });
    ref.listenManual(vpnRestartRequiredProvider, (_, _) => _updateTip());
  }

  void _updateTip() {
    final text = currentAppLocalizations.vpnConfigChangeDetected;
    if (!ref.read(vpnRestartRequiredProvider) || _restarting) {
      context.findAncestorStateOfType<StatusManagerState>()?.dismissMessage(
        text,
      );
      return;
    }
    dialogs.showNotifier(
      text,
      level: MessageLevel.warning,
      actionState: MessageActionState(
        actionText: currentAppLocalizations.restart,
        action: _restart,
      ),
    );
  }

  Future<void> _restart() async {
    if (_restarting || !ref.read(vpnRestartRequiredProvider)) return;
    _restarting = true;
    try {
      await globalState.safeRun(
        () => ref.read(coreActionProvider.notifier).restartCore(),
      );
    } finally {
      if (mounted) {
        _restarting = false;
        _updateTip();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
