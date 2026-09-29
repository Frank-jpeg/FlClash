# FlClash 首页版（Android）

基于上游正式版 v0.8.98，保留上游 GPL-3.0 许可证。定制版包名为
`com.follow.clash.home`，可与原版同时安装，两者配置独立。

## 应用分流

首页的“应用访问控制”可直接开关，并进入应用名单。白名单模式下，选中的应用进入
VPN；黑名单模式下，选中的应用绕过 VPN。修改后，正在运行的 VPN 需要停止再启动。

应用列表始终显示已安装的 Google Play 商店、Google Play 服务、Google 服务框架和
下载管理器，即使开启了隐藏系统应用。工具栏的 Google Play 快捷按钮会把这些组件加入
VPN 范围；操作后仍需保存名单。隐藏应用的已有选择不会再因为保存而被清除。

进入 VPN 只表示交给 FlClash 处理，最终是否走代理还取决于订阅规则和节点可用性。

## Tailscale 内网

1. 导入或选择可用的 FlClash 配置。
2. 关闭独立 Tailscale 应用的 VPN，打开首页“Tailscale 内网”。
3. 开启功能，在页面链接指向的 Tailscale 管理后台创建 Auth Key，并在应用中填写。
4. 仅访问已经安装 Tailscale 的设备时，不需要填写子网；使用 `100.x.x.x` 地址，或完整的
   `设备名.网络名.ts.net` 域名。
5. 访问家里或公司的其他局域网设备时，填写对应网段，例如 `192.168.1.0/24`。
   网络中需已有 Tailscale 子网路由器，路由需在管理后台批准，访问权限需允许该设备。
6. 保存后切换到规则模式。启动 FlClash VPN，访问内网地址会触发 Tailscale 连接。
   如果刚修改了子网或应用名单，请重启 VPN。

用于访问内网的浏览器、远程桌面或 NAS 应用需要包含在 FlClash 的 VPN 应用范围内。
此功能只分流 Tailscale 地址和填写的子网，其余流量遵循原订阅规则，不使用出口节点。
启用“绕过私有网络”时，仍会把 Tailscale 地址和明确填写的子网纳入 VPN。

设备加入网络后可以清空 Auth Key 并保存，连接会复用本机保存的身份。
Auth Key 在输入时隐藏；未清空前会随本应用配置保存，导出的配置备份也可能包含它。
不要公开带密钥的配置或备份。页面“已启用”表示设置开启，不代表已完成登录或连通性验证。

## 构建

工作流 `.github/workflows/build-home-apk.yml` 编译 arm64 手机 APK 和 x86_64 模拟器 APK。
工具链为 Flutter 3.47.4、Go 1.26.4、JDK 17、NDK r28c，并安装 Rust。
运行构建时将 `ANDROID_NDK_HOME` 指向 r28c，确保原生构建钩子使用正确 NDK。

```sh
git submodule update --init --recursive
flutter pub get
flutter build apk --release --split-per-abi --target-platform android-arm64,android-x64
```

`pubspec.yaml` 的两个 `build_assets` 开关必须为 `true`，才能包含 Go 内核和 Rust 库。
运行不加载原生库的 Flutter 测试时可以临时改为 `false`，测试后恢复，不能提交关闭状态。

默认不启用 Firebase 构建插件。只有提供匹配定制版包名的 `google-services.json`，并显式
设置 Gradle 属性 `enableFirebase=true` 时才启用。现成的上游占位配置不能用于此包名。
没有个人签名配置时，CI 产物使用临时 debug 签名；交付手机的版本应统一使用本地保存的
签名重新签署，以便后续覆盖升级。签名私钥和密码不得提交到仓库。

## 验证范围

相关自动化测试覆盖应用名单保留、Google 组件过滤与快捷选择、首页开关同步、Tailscale
配置持久化、路由与 DNS 合并、最终 YAML 优先级及小屏表单校验。
真实 NAS 连通性需要用户自己的 Tailscale 授权和设备；没有实际连接证据时不视为通过。
