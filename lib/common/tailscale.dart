import 'dart:io';

import 'package:fl_clash/models/models.dart';

List<String> tailscaleRouteAddresses(
  List<String> routes,
  TailscaleProps settings,
) {
  if (!settings.enable || routes.isEmpty) return routes;
  return {
    ...routes,
    '100.64.0.0/10',
    'fd7a:115c:a1e0::/48',
    ...settings.subnets,
  }.toList();
}

bool isTailscaleSubnet(String value) {
  final parts = value.trim().split('/');
  if (parts.length != 2) return false;
  final address = InternetAddress.tryParse(parts[0]);
  final prefix = int.tryParse(parts[1]);
  if (address == null || prefix == null || prefix <= 0) return false;
  return prefix <= (address.type == InternetAddressType.IPv4 ? 32 : 128);
}

Map<String, dynamic> applyTailscaleConfig(
  Map<String, dynamic> config,
  TailscaleProps settings,
) {
  if (!settings.enable) return config;
  if (settings.subnets.any((subnet) => !isTailscaleSubnet(subnet))) {
    throw const FormatException('Invalid Tailscale subnet');
  }
  final proxies = List<dynamic>.from(config['proxies'] as List? ?? []);
  final names = [
    ...proxies,
    ...(config['proxy-groups'] as List? ?? []),
  ].whereType<Map>().map((proxy) => proxy['name']).toSet();
  var name = 'TAILSCALE-HOME';
  for (var suffix = 2; names.contains(name); suffix++) {
    name = 'TAILSCALE-HOME-$suffix';
  }
  proxies.add({
    'name': name,
    'type': 'tailscale',
    'hostname': settings.hostname,
    if (settings.authKey.isNotEmpty) 'auth-key': settings.authKey,
    'state-dir': 'tailscale/flclash-home',
    'accept-routes': true,
    'udp': true,
  });
  final dns = Map<String, dynamic>.from(config['dns'] as Map? ?? {});
  final policy = Map<String, dynamic>.from(
    dns['nameserver-policy'] as Map? ?? {},
  );
  policy['+.ts.net'] = 'tailscale://$name';
  dns['nameserver-policy'] = policy;
  final tun = Map<String, dynamic>.from(config['tun'] as Map? ?? {});
  tun['route-address'] = tailscaleRouteAddresses(
    List<String>.from(tun['route-address'] as List? ?? []),
    settings,
  );
  final tailnetRules = [
    'DOMAIN-SUFFIX,ts.net,$name',
    'IP-CIDR,100.64.0.0/10,$name,no-resolve',
    'IP-CIDR6,fd7a:115c:a1e0::/48,$name,no-resolve',
    for (final subnet in settings.subnets.toSet())
      '${subnet.contains(':') ? 'IP-CIDR6' : 'IP-CIDR'},$subnet,$name,no-resolve',
  ];
  return {
    ...config,
    'proxies': proxies,
    'dns': dns,
    'tun': tun,
    'rules': [...tailnetRules, ...(config['rules'] as List? ?? [])],
  };
}
