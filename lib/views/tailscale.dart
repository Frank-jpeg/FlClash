import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/features/form/form.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/ui/ui.dart';
import 'package:fl_clash/views/dashboard/widgets/card.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prism_ui/banner.dart';

/// Entry row for the Tailscale settings, opened as a page from the dashboard.
class TailscaleCard extends ConsumerWidget {
  const TailscaleCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(tailscaleSettingProvider);
    return DashboardCard(
      semanticLabel: 'Tailscale 内网',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const DashboardCardHeader(
            glyph: AppGlyphs.devices,
            title: 'Tailscale 内网',
          ),
          const SizedBox(height: 8),
          ListItem.open(
            title: Text(settings.enable ? '已启用' : '未启用'),
            subtitle: Text(settings.hostname),
            minVerticalPadding: 8,
            widget: const TailscaleView(),
          ),
        ],
      ),
    );
  }
}

class TailscaleView extends ConsumerStatefulWidget {
  const TailscaleView({super.key});

  @override
  ConsumerState<TailscaleView> createState() => _TailscaleViewState();
}

class _TailscaleViewState extends ConsumerState<TailscaleView> {
  late final TextEditingController _hostname;
  late final TextEditingController _authKey;
  late final TextEditingController _subnets;
  late bool _enable;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(tailscaleSettingProvider);
    _enable = settings.enable;
    _hostname = TextEditingController(text: settings.hostname);
    _authKey = TextEditingController(text: settings.authKey);
    _subnets = TextEditingController(text: settings.subnets.join('\n'));
  }

  @override
  void dispose() {
    _hostname.dispose();
    _authKey.dispose();
    _subnets.dispose();
    super.dispose();
  }

  List<String> _parseSubnets(String value) => value
      .split(RegExp(r'[\s,;]+'))
      .where((item) => item.isNotEmpty)
      .toSet()
      .toList();

  bool _validSubnets() {
    final subnets = _parseSubnets(_subnets.text);
    return subnets.every(isTailscaleSubnet);
  }

  Future<void> _save() async {
    if (_saving) return;
    if (!_validSubnets()) {
      dialogs.showBanner('子网格式不对，应为 192.168.1.0/24 这种写法', level: BannerLevel.error);
      return;
    }
    setState(() => _saving = true);
    try {
      ref.read(tailscaleSettingProvider.notifier).value = TailscaleProps(
        enable: _enable,
        hostname: _hostname.text.trim().isEmpty
            ? 'flclash-home'
            : _hostname.text.trim(),
        authKey: _authKey.text.trim(),
        subnets: _parseSubnets(_subnets.text),
      );
      if (_enable) {
        ref
            .read(patchClashConfigProvider.notifier)
            .update((state) => state.copyWith(mode: Mode.rule));
      }
      await preferences.saveConfig(ref.read(configProvider));
      if (!mounted) return;
      if (ref.read(currentProfileIdProvider) != null) {
        final applied = await ref
            .read(setupActionProvider.notifier)
            .applyProfile(force: true);
        if (!applied) {
          throw MessageException('Tailscale 配置没能应用，请重试');
        }
      }
      if (mounted) dialogs.showBanner('Tailscale 设置已保存');
    } catch (error) {
      if (mounted) {
        dialogs.showBanner(error.toString(), level: BannerLevel.error);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      title: 'Tailscale 内网',
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          generateSection(
            items: [
              ListItem(
                leading: const GlyphIcon(AppGlyphs.vpn),
                title: const Text('启用 Tailscale'),
                subtitle: const Text('走内核自带的 tailscale 出站，不用另装 App'),
                trailing: Switch(
                  value: _enable,
                  onChanged: (value) => setState(() => _enable = value),
                ),
              ),
              FormRow(
                title: const Text('设备名'),
                trailing: FormRowTextField(
                  controller: _hostname,
                  hintText: 'flclash-home',
                  autocorrect: false,
                  textInputAction: TextInputAction.next,
                ),
              ),
              FormRow(
                title: const Text('Auth Key'),
                trailing: FormRowSecretTextField(
                  controller: _authKey,
                  hintText: 'tskey-auth-…（可留空用交互登录）',
                  autocorrect: false,
                  textInputAction: TextInputAction.next,
                ),
              ),
              FormRow(
                title: const Text('子网路由'),
                trailing: FormRowTextField(
                  controller: _subnets,
                  hintText: '192.168.1.0/24，多个用换行或逗号分开',
                  autocorrect: false,
                  textInputAction: TextInputAction.done,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: ListItem(
              title: Text(_saving ? '正在保存…' : '保存并应用'),
              leading: const GlyphIcon(AppGlyphs.check),
              onTap: _saving ? null : _save,
            ),
          ),
        ],
      ),
    );
  }
}
