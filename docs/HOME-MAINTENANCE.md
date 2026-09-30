# 安卓首页版维护说明

## 仓库与交付基线

| 项目 | 2026-09-30 核对结果 |
| --- | --- |
| Fork | `Frank-jpeg/FlClash`，公开仓库，账号拥有管理员权限 |
| 上游 | `chen08209/FlClash` |
| 本地 remote | `origin` 指向 Fork，`upstream` 指向原项目 |
| 定制分支 | `feature/android-home-tailscale` |
| 默认分支 | `main`；首页有定制 APK 直链，尚未合入定制功能 |
| 上游基线 | `v0.8.98`，发布于 2026-09-14 |
| 源码应用版本 | `0.8.98-home.3+2026092903` |
| APK versionCode | ARM64：`2026094903`；x86_64：`2026096903`（Flutter 按 ABI 加偏移） |
| Android 包名 | `com.follow.clash.home`；debug 构建另有 `.dev` 后缀 |
| 已发布 APK 对应代码 | `24225ad0de6c7bdacdb2259f8555ca743de846d4`（home.3） |
| 更新源修复 | `8cc4ca2`：Fork Release 地址及 home 版本比较 |
| VPN 提醒修复 | `b9fa81d`：启动快照、双向开关提示及原生停止后重启 |
| 新包构建提交 | `24225ad`：应用名单常驻搜索框，递增 home/build 版本 |

home.1（`552585e`）之后，home.2 加入更新源与重启提醒修正，home.3 将应用名单搜索框常驻顶部。
当前 [v0.8.98-home.3](https://github.com/Frank-jpeg/FlClash/releases/tag/v0.8.98-home.3)
已由云端构建、使用原密钥签署并自动发布。
默认分支和定制分支的中英 README 均直接链接 Release APK，无需登录 GitHub 或解压。
Actions artifact 仍是使用临时 debug 签名的原始构建产物，与固定签名的 Release APK 分开。
使用 `gh` 时显式指定 `-R Frank-jpeg/FlClash`，避免 Fork 环境默认查询上游仓库。

## 构建与签名

以 `.github/workflows/build-home-apk.yml` 为 Android Home APK 的工具链依据：
Flutter 3.47.4、Go 1.26.4、JDK 17、NDK r28c（28.2.13676358）。
Rust 版本及目标由 `plugins/rust_api/rust/rust-toolchain.toml` 固定为 1.95.0。
`build.yaml` 的常规检查仍用 Flutter 3.47.1，两个工作流的职责和 SDK 版本不同。

设置 `JAVA_HOME`、Android SDK 路径以及指向 r28c 的 `ANDROID_NDK_HOME`，并确认 Flutter、Go、
Cargo 和宿主机 C/C++ 链接工具可用。Windows 上的 Rust MSVC 构建脚本需要 Visual C++ 和 Windows SDK。
不要仅根据 PATH 中的旧 Flutter 就判断本机无法编译 APK；先核对已安装工具及实际缺项。

```sh
git submodule update --init --recursive
flutter pub get
flutter build apk --release --dart-define=APP_ENV=stable --split-per-abi --target-platform android-arm64,android-x64
```

产物在 `build/app/outputs/flutter-apk/`。两个 `build_assets` 开关必须为 `true`。
纯 Dart/Flutter 测试可临时将其设为 `false`，务必用 `finally` 恢复并保留测试退出码。
生成代码使用仓库生成器；生成后仍需 `dart format`，不手动改写生成文件。

默认关闭 Firebase 构建插件。只有设置 Gradle 属性 `enableFirebase=true`，且提供匹配定制包名的
`android/app/google-services.json` 才启用；上游自带的占位文件不匹配定制包名。

没有个人签名配置时，CI APK 使用 runner 的 debug 签名，不能保证两次构建使用同一证书。
交付版本需用已保存的固定密钥签署，再运行 `apksigner verify --verbose --print-certs`。
2026-09-29 交付证书 SHA-256：

```text
d09e03af6407a2a0041c60bc07055680d4da39861b7a5b3cd82dbcb8c2d1d555
```

覆盖升级需保持包名和证书一致，并递增 `pubspec.yaml` 中的 build number。
独立发行同时递增 home 序号，然后重新编译和签名。工作流 artifact 名称为 `FlClash-home-<提交 SHA>`，
下载时核对 run 的提交 SHA，不按同名文件推断版本。
私钥、签名密码、Tailscale Auth Key 和含密钥的配置备份均不得提交到公开仓库。

## 外观与构建标识

- 安卓名称来自 `android/common/src/main/res/values/strings.xml`，当前为“FlClash 首页版”。
  曾提出的“自改版”更名尚未实施；不能把文档收尾当成已经完成更名。
- 桌面图标和控制中心快捷磁贴图标保持原样，取消换色或改轮廓的计划。
- `lib/bootstrap.dart` 的 `APP_ENV` 默认值为 `pre`，`globalState.isPre` 控制红色 `PRE` 标记。
  home.4 起 Home 构建工作流固定传入 `--dart-define=APP_ENV=stable`，去除 PRE 和红色斜条；本机交付构建也需带此参数。
  此标记与 GitHub Release 的 prerelease 字段、密钥告警分别独立。

## 跟进上游

1. 确认工作区干净，保存当前分支及已交付版本的回退点。
2. 用 `gh release view -R chen08209/FlClash` 核对目标正式版，运行 `git fetch upstream --tags`。
3. 在定制分支合并核实后的 release tag，再更新子模块；处理冲突时保留首页入口、Google 组件
   过滤和名单保留、Tailscale 配置/路由、定制包名及签名行为。
4. 检查上游是否已原生实现某项定制，移除重复实现前核对功能语义。按新版本调整工具链，
   生成模型与翻译，做改动所需的自动化检查，再打包并用原固定密钥签署。
5. 更新版本、文档、安装包校验值，交付覆盖安装。`main` 可用于同步上游，不能用它覆盖定制分支。

GitHub 的 Sync fork 不会自动处理定制冲突，也不会保证产物使用固定签名。
当前源码通过 `lib/common/constant.dart` 的 `repository` 统一使用 `Frank-jpeg/FlClash`，
手动及自动检查请求 `/repos/Frank-jpeg/FlClash/releases/latest`，发现新版后打开该 Fork 的下载页。
版本比较支持前导 `v`、`-home.N` 和数字 build number；发布时递增 home 序号和 Android build number，
例如 home.3 之后使用 `v0.8.98-home.4`。GitHub Release 应标为正式发布，预发布不会被 `releases/latest` 返回。
发布时附上固定签名的 APK；上游 `.github/release_template.md` 仍含上游下载地址，不能直接用作定制版下载页。
home.3 已作为正式 Release 发布；应用没有自动下载安装或自动合并上游的功能。

## 在线发布与排障

`publish-home-apk.yml` 监听定制分支 `Build home APK` 的成功结果，在线下载该次构建产物，
使用 Actions Secrets 中的既有首页版签名，核对证书、包名、版本和架构后自动发布 Release APK。
工作流需同时保留在默认 `main` 分支（接收 `workflow_run` 事件）和定制分支。
仓库 Secrets 为 `HOME_ANDROID_KEYSTORE_BASE64`、`HOME_ANDROID_SIGNING_PASSWORD`，不提交凭据文件。
该流程仅接受本仓库定制分支的成功构建，不检出或运行产物中的脚本。

正常发布：递增 `pubspec.yaml` 的 home 序号及 build number，再推送定制分支。
匹配的源码变更触发编译，成功后自动签名发布；仅修改 README 或维护文档不会生成新 APK。
发布流程不等待独立的 `build.yaml` 检查，维护者需核对同一源码提交的检查结果。
Release 资产保持 `FlClash-home-arm64-v8a.apk`、`FlClash-home-x86_64.apk` 和 `SHA256SUMS.txt`
命名，新版本设为 latest，使首页 `/releases/latest/download/` 直链继续有效；重试旧版本不回退 latest。

编译已成功而发布失败时，查看 [Publish home APK](https://github.com/Frank-jpeg/FlClash/actions/workflows/publish-home-apk.yml)
的失败步骤。在 `main` 上手动触发，填成功构建的 run ID；例如复用 home.3：

```sh
gh workflow run publish-home-apk.yml -R Frank-jpeg/FlClash --ref main -f run_id=36593607481
```

| 失败位置 | 处理方式 |
| --- | --- |
| 来源校验或下载 | 确认 run 属于本仓库定制分支，编译成功且 artifact 未过期；过期才需重新编译 |
| 签名或证书校验 | 检查上述 Secrets；使用原密钥备份恢复，不新建密钥或跳过证书校验 |
| 同名 tag 指向不同源码 | 递增 home/build 版本后重新构建，不移动已有 Release tag |
| 上传或发布 | 修复权限或网络后复用原 run；同一源码可重试上传 |

## 实现导航

状态流及路由注入位置见[架构说明](../.agents/architecture.md#android-home-customizations)。
使用和联网前提见[使用说明](HOME-ANDROID.md)。保持以下行为：

- 首页开关复用原 VPN 设置；应用名单搜索框常驻顶部，按名称或包名筛选，清空后恢复列表。
  搜索和保存不得丢失隐藏应用的既有选择。
- Tailscale 规则在最终覆写完成后注入，DNS policy 保留订阅原有项，节点名冲突时追加后缀。
- 私网绕过模式下仍捕获 Tailscale 和显式子网；不添加出口节点，不允许默认路由 `/0`。
- Android VPN 生命周期仍由原服务管理；页面“已启用”只代表配置状态。

## 验证与交接

- [home.3 APK 构建](https://github.com/Frank-jpeg/FlClash/actions/runs/36593607481)与
  [自动签名发布](https://github.com/Frank-jpeg/FlClash/actions/runs/36594918515)成功，2026-09-30 00:04（UTC+8）发布。
  来源、固定证书、包名、版本和 ABI 检查通过，tag 指向 `24225ad`；ARM64 直链免登录返回 HTTP 200、APK 类型。
  本轮验证了推送触发构建、`workflow_run` 自动触发签名发布的完整流程。
- home.3 的[首次完整检查](https://github.com/Frank-jpeg/FlClash/actions/runs/36593607414)：Flutter 1873 项通过、
  3 项跳过、1 项失败；失败项是旧测试要求应用页搜索框随页面失活消失。`3cc583c` 已将其改为
  常驻搜索及返回行为检查，本机相关 30 项通过；该提交仅改测试，APK 的应用源码与依赖完全不变。
  同次 Android、Go、Rust、插件及 Windows Helper 检查通过；不得将首次完整检查称为全绿。
  测试适配后的[云端复检](https://github.com/Frank-jpeg/FlClash/actions/runs/36595514462)已通过。
- 前一版 home.2 的[完整检查](https://github.com/Frank-jpeg/FlClash/actions/runs/36576531340)通过，
  [云端签名发布](https://github.com/Frank-jpeg/FlClash/actions/runs/36581215822)曾手动复用成功构建完成。
- 本机相关 Flutter 测试通过；原生编译检查因 Gradle 下载或离线依赖缺失未完成。
  本机一次全量 Flutter 测试有 Windows 路径相关失败，不能称本机全绿；详细记录留在本机交接文档。
- MuMu 已验证安装启动、首页入口、下载管理器显示和部分快捷选择。快速保存后立即强制停止
  的一次检查没有保留所选状态，原因尚未确认，不能据此宣布名单持久化实机测试通过。
- VPN 启动、Google Play 登录/下载、Tailscale 登录、真实 NAS 连通性尚无逐项实机通过记录。
  2026-09-29 用户接手后续设备测试；没有新要求时，不继续操作模拟器或扩展测试。
- GitHub 密钥扫描命中过测试占位文本，已替换并将告警 #1 关闭为误报；它从未是真实凭据。

`docs/` 默认被上游 `.gitignore` 忽略，新增共享文档需逐文件显式加入版本控制。
若存在 `HOME-LOCAL.md`，它保存本机目录、签名材料位置和交接状态，只留本地。
