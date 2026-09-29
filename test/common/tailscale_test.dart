import 'dart:convert';

import 'package:fl_clash/common/tailscale.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Map<String, dynamic> profile() => {
    'mode': 'rule',
    'proxies': [
      {'name': 'existing', 'type': 'direct'},
    ],
    'proxy-groups': [
      {
        'name': 'PROXY',
        'type': 'select',
        'proxies': ['existing'],
      },
    ],
    'dns': {
      'enable': true,
      'nameserver-policy': {'example.org': 'system://'},
    },
    'rules': ['GEOIP,LAN,DIRECT', 'MATCH,PROXY'],
  };

  test('disabled Tailscale leaves the profile untouched', () {
    final config = profile();
    expect(applyTailscaleConfig(config, const TailscaleProps()), same(config));
  });

  test(
    'private routes precede LAN bypass and preserve existing proxies and DNS',
    () {
      final config = profile();
      final before = jsonEncode(config);
      final applied = applyTailscaleConfig(
        config,
        const TailscaleProps(
          enable: true,
          subnets: ['192.168.7.0/24', 'fd12::/64'],
        ),
      );
      expect(jsonEncode(config), before);
      expect(applied['proxies'], hasLength(2));
      final proxy = (applied['proxies'] as List).last as Map;
      expect(proxy['type'], 'tailscale');
      expect(proxy['accept-routes'], isTrue);
      expect(proxy['exit-node'], isNull);
      expect(proxy['auth-key'], isNull);
      expect(proxy['state-dir'], 'tailscale/flclash-home');
      expect((applied['rules'] as List).take(3), [
        'DOMAIN-SUFFIX,ts.net,TAILSCALE-HOME',
        'IP-CIDR,100.64.0.0/10,TAILSCALE-HOME,no-resolve',
        'IP-CIDR6,fd7a:115c:a1e0::/48,TAILSCALE-HOME,no-resolve',
      ]);
      expect((applied['rules'] as List).last, 'MATCH,PROXY');
      expect(applied['dns']['nameserver-policy']['example.org'], 'system://');
      expect(
        applied['dns']['nameserver-policy']['+.ts.net'],
        'tailscale://TAILSCALE-HOME',
      );
      expect(applied['mode'], 'rule');
    },
  );

  test('does not overwrite a subscription proxy with the same name', () {
    final config = profile();
    (config['proxies'] as List).add({
      'name': 'TAILSCALE-HOME',
      'type': 'direct',
    });
    final applied = applyTailscaleConfig(
      config,
      const TailscaleProps(enable: true),
    );
    expect((applied['proxies'] as List).last['name'], 'TAILSCALE-HOME-2');
    expect(
      (applied['rules'] as List).first,
      'DOMAIN-SUFFIX,ts.net,TAILSCALE-HOME-2',
    );
  });

  test('settings survive JSON save and legacy configs default to disabled', () {
    const settings = TailscaleProps(
      enable: true,
      hostname: 'test-device',
      subnets: ['10.2.0.0/16'],
    );
    final config = Config.realFromJson(null).copyWith(tailscale: settings);
    final restored = Config.fromJson(jsonDecode(jsonEncode(config.toJson())));
    expect(restored.tailscale, settings);
    expect(Config.realFromJson(null).tailscale.enable, isFalse);
  });

  test('rejects malformed CIDRs, default routes and rule injection', () {
    for (final value in [
      '0.0.0.0/0',
      '::/0',
      '192.168.1.0/33',
      'fd00::/129',
      'bad',
      '10.0.0.0/8,PROXY',
    ]) {
      expect(isTailscaleSubnet(value), isFalse, reason: value);
    }
    expect(isTailscaleSubnet('192.168.1.0/24'), isTrue);
    expect(isTailscaleSubnet('fd00::/64'), isTrue);
    expect(
      () => applyTailscaleConfig(
        {},
        const TailscaleProps(enable: true, subnets: ['0.0.0.0/0']),
      ),
      throwsFormatException,
    );
  });
}
