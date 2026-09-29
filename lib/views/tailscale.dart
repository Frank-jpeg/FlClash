import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/common/tailscale.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

class TailscaleCard extends ConsumerWidget {
  const TailscaleCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(tailscaleSettingProvider);
    final strings = context.appLocalizations;
    return CommonCard(
      child: ListItem.open(
        leading: const Icon(Icons.hub_outlined),
        title: Text(strings.tailscaleTitle),
        subtitle: Text(
          settings.enable
              ? strings.tailscaleEnabled
              : strings.tailscaleDisabled,
        ),
        widget: const TailscaleView(),
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
  final _formKey = GlobalKey<FormState>();
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

  Future<void> _save() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    final strings = context.appLocalizations;
    setState(() => _saving = true);
    try {
      ref.read(tailscaleSettingProvider.notifier).value = TailscaleProps(
        enable: _enable,
        hostname: _hostname.text.trim(),
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
          throw MessageException(strings.tailscaleApplyFailed);
        }
      }
      if (mounted) dialogs.showNotifier(strings.tailscaleSaved);
    } catch (error) {
      if (mounted) {
        dialogs.showNotifier(error.toString(), level: MessageLevel.error);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(tailscaleSettingProvider);
    final strings = context.appLocalizations;
    return CommonScaffold(
      title: strings.tailscaleTitle,
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SwitchListTile(
              key: const ValueKey('tailscale-enable'),
              contentPadding: EdgeInsets.zero,
              title: Text(strings.tailscaleEnable),
              value: _enable,
              onChanged: _saving
                  ? null
                  : (value) => setState(() => _enable = value),
            ),
            Text(strings.tailscaleHelp),
            const SizedBox(height: 24),
            TextFormField(
              controller: _hostname,
              enabled: !_saving,
              decoration: InputDecoration(labelText: strings.tailscaleHostname),
              validator: (value) =>
                  RegExp(
                    r'^[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?$',
                  ).hasMatch(value?.trim() ?? '')
                  ? null
                  : strings.tailscaleInvalidHostname,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _authKey,
              enabled: !_saving,
              obscureText: true,
              autocorrect: false,
              enableSuggestions: false,
              decoration: InputDecoration(
                labelText: strings.tailscaleAuthKey,
                helperText: strings.tailscaleAuthKeyHelp,
                helperMaxLines: 4,
              ),
              validator: (value) =>
                  value == null ||
                      value.trim().isEmpty ||
                      value.trim().startsWith('tskey-auth-')
                  ? null
                  : strings.tailscaleInvalidKey,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => launchUrl(
                  Uri.parse('https://login.tailscale.com/admin/settings/keys'),
                  mode: LaunchMode.externalApplication,
                ),
                icon: const Icon(Icons.open_in_new),
                label: Text(strings.tailscaleCreateKey),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _subnets,
              enabled: !_saving,
              minLines: 2,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: strings.tailscaleSubnets,
                hintText: '192.168.1.0/24',
                helperText: strings.tailscaleSubnetsHelp,
                helperMaxLines: 4,
              ),
              validator: (value) =>
                  _parseSubnets(value ?? '').every(isTailscaleSubnet)
                  ? null
                  : strings.tailscaleInvalidSubnet,
            ),
            const SizedBox(height: 24),
            Text(strings.tailscaleAppsHint),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: const Icon(Icons.save_outlined),
              label: Text(strings.tailscaleSave),
            ),
          ],
        ),
      ),
    );
  }
}
