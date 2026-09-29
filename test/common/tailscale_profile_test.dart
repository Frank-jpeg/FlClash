import 'package:fl_clash/common/task.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

void main() {
  test(
    'final YAML keeps tailnet routing ahead of a custom MATCH rule',
    () async {
      final result = await makeRealProfileTask(
        const MakeRealProfileState(
          profilesPath: '/profiles',
          profileId: 1,
          rawConfig: {
            'dns': {'enable': true},
            'proxies': [],
            'rules': ['MATCH,DIRECT'],
          },
          realPatchConfig: PatchClashConfig(),
          overrideDns: true,
          appendSystemDns: true,
          proxyGroups: [],
          rules: [Rule(ruleAction: RuleAction.MATCH, ruleTarget: 'DIRECT')],
          addedRules: [],
          defaultUA: 'FlClash-Test',
          tailscale: TailscaleProps(enable: true),
        ),
      );
      final config = loadYaml(result.yaml) as YamlMap;
      expect(config['rules'].first, 'DOMAIN-SUFFIX,ts.net,TAILSCALE-HOME');
      expect(config['rules'].last, 'MATCH,DIRECT');
      expect(config['proxies'].single['type'], 'tailscale');
      expect(
        config['dns']['nameserver-policy']['+.ts.net'],
        'tailscale://TAILSCALE-HOME',
      );
    },
  );
}
