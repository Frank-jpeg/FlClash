# FlClash 首页版（Android）

基于上游正式版 v0.8.98，保留上游 GPL-3.0 许可证。定制版包名为
`com.follow.clash.home`，可与原版同时安装，两者配置独立。

## 安装与更新

普通安卓手机：[直接下载 ARM64 APK](https://github.com/Frank-jpeg/FlClash/releases/latest/download/FlClash-home-arm64-v8a.apk)。
x86_64 模拟器：[直接下载 x86_64 APK](https://github.com/Frank-jpeg/FlClash/releases/latest/download/FlClash-home-x86_64.apk)。
无需解压或登录 GitHub；仓库首页也提供相同入口。

当前发布版本为 `0.8.98-home.3+2026092903`，源码对应 `24225ad`。Release 中的两个 APK
沿用首页版固定签名，可覆盖此前固定签名的 home.1/home.2，通常可保留配置。首次使用需自行导入配置或订阅。
[更新记录与校验文件](https://github.com/Frank-jpeg/FlClash/releases/latest)。

APK 由 [GitHub Actions 自动构建](https://github.com/Frank-jpeg/FlClash/actions/runs/36593607481)，
由 `Publish home APK` 在云端使用原密钥签署并自动发布到 Releases。
Actions 中的原始 ZIP 使用临时 debug 签名，且有保存期限；日常安装请选择上述 Release APK。

源码位于公开仓库 [Frank-jpeg/FlClash](https://github.com/Frank-jpeg/FlClash) 的
[`feature/android-home-tailscale`](https://github.com/Frank-jpeg/FlClash/tree/feature/android-home-tailscale) 分支。
仓库 README 中保留的原版下载链接不包含本定制功能。
当前源码的手动、自动检查更新及更新下载页均指向本 Fork 的 GitHub Releases，支持 `-home.N`
版本号。发现新版后打开下载页，由用户下载安装。
旧 home.1（`552585e`）不包含更新源和重启提醒修正，需通过上述 APK 直链手动升级。
上游更新仍需合并、重新打包并使用固定签名发布，应用不会自动合并上游代码。
构建方式及上游同步步骤见[维护说明](HOME-MAINTENANCE.md)。

## 应用分流

首页的“应用访问控制”可直接开关，并进入应用名单。白名单模式下，选中的应用进入
VPN；黑名单模式下，选中的应用绕过 VPN。运行中打开或关闭此功能、修改名单均需重启。
home.2 起会在存在未应用设置时显示提醒，重启提交成功或改回原设置后清除提醒；未运行时下次启动生效。
重启失败时保留待处理状态，允许重试。旧 home.1 需升级后获得这些修正。

应用列表始终显示已安装的 Google Play 商店、Google Play 服务、Google 服务框架和
下载管理器，即使开启了隐藏系统应用。工具栏的 Google Play 快捷按钮会把这些组件加入
VPN 范围；操作后仍需保存名单。隐藏应用的已有选择不会再因为保存而被清除。

home.3 起，应用名单顶部常驻搜索框，无需打开“更多”菜单；支持按应用名或包名搜索，
忽略大小写和首尾空格。点击输入框右侧的清空按钮恢复列表，搜索和清空不会删除已选应用。

进入 VPN 只表示交给 FlClash 处理，最终是否走代理还取决于订阅规则和节点可用性。

## 规则编辑

首页“出站模式 → 规则”使用当前配置的规则。添加自己的规则：
**配置 → 当前订阅右侧 ⋮ → 更多 → 覆写 → 标准 → 附加规则 → 添加**。
订阅原有规则可在该菜单的“预览”中查看 `rules`；修改覆写规则后保存。

## Tailscale 内网

1. 导入或选择可用的 FlClash 配置。
2. 关闭独立 Tailscale 应用的 VPN，打开首页“Tailscale 内网”。
3. 开启功能，在页面链接指向的 Tailscale 管理后台创建 Auth Key，并在应用中填写。
4. 仅访问已经安装 Tailscale 的设备时，不需要填写子网；使用 `100.x.x.x` 地址，或完整的
   `设备名.网络名.ts.net` 域名。
5. 访问家里或公司的其他局域网设备时，填写对应网段，例如 `192.168.1.0/24`。
   网络中需已有 Tailscale 子网路由器，路由需在管理后台批准，访问权限需允许该设备。
6. 保存后切换到规则模式。启动 FlClash VPN，访问内网地址会触发 Tailscale 连接。
   修改子网或应用名单后，请重启 VPN。

用于访问内网的浏览器、远程桌面或 NAS 应用需要包含在 FlClash 的 VPN 应用范围内。
此功能只分流 Tailscale 地址和填写的子网，其余流量遵循原订阅规则，不使用出口节点。
启用“绕过私有网络”时，仍会把 Tailscale 地址和明确填写的子网纳入 VPN。

设备加入网络后可以清空 Auth Key 并保存，连接会复用本机保存的身份。
Auth Key 在输入时隐藏；未清空前会随本应用配置保存，导出的配置备份也可能包含它。
不要公开带密钥的配置或备份。页面“已启用”表示设置开启，不代表已完成登录或连通性验证。

## 名称、图标与 PRE 标记

安卓应用目前显示为“FlClash 首页版”。桌面图标和控制中心快捷磁贴图标保持原样。
home.4 起，Home 自动构建指定 `--dart-define=APP_ENV=stable`，不再显示右上角的 `PRE` 和红色斜条。
旧版本的角标只是预发布环境标记，和密钥扫描告警无关；需安装 home.4 或更新版本后去除。

## 验证范围

home.3 的搜索、清空、名单保存、返回操作及首页相关本机测试共 30 项通过。
云端 APK 构建、自动签名发布及下载直链均已验证。全量检查中一项沿用旧搜索行为的测试
已同步修改，具体检查结果与验证边界见[维护说明](HOME-MAINTENANCE.md)。
MuMu 已完成安装、启动、首页入口显示、系统下载管理器显示及快捷选择的部分检查。
用户已接手后续测试；尚无 VPN 启动、真实 Google Play 登录/下载、Tailscale 登录与 NAS 连通性的
逐项实机通过记录。自动化测试通过不代表这些真实网络场景已经验证。
