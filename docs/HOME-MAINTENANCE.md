# 安卓首页版维护说明

## 仓库与交付基线

| 项目 | 2026-09-29 核对结果 |
| --- | --- |
| Fork | `Frank-jpeg/FlClash`，公开仓库，账号拥有管理员权限 |
| 上游 | `chen08209/FlClash` |
| 本地 remote | `origin` 指向 Fork，`upstream` 指向原项目 |
| 定制分支 | `feature/android-home-tailscale` |
| 默认分支 | `main`；该日期尚未合入定制功能 |
| 上游基线 | `v0.8.98`，发布于 2026-09-14 |
| 源码应用版本 | `0.8.98-home.2+2026092902` |
| Android 包名 | `com.follow.clash.home`；debug 构建另有 `.dev` 后缀 |
| 已交付 APK 对应代码 | `552585ee503b56984be0fcb1edf71eb19d478c3c` |
| 更新源修复 | `8cc4ca2`：Fork Release 地址及 home 版本比较 |
| VPN 提醒修复 | `b9fa81d`：启动快照、双向开关提示及原生停止后重启 |
| 新包构建提交 | `a84c30c`：递增 home/build 版本并按 SHA 命名构建产物 |

`6991d06` 和 `adeaec3` 只调整文档和测试；`8cc4ca2`、`b9fa81d` 已改变应用代码，尚未交付新安装包。
旧 APK 使用 `0.8.98-home.1+2026092901`；新版递增为 `0.8.98-home.2+2026092902`。
APK 已本地签署并交付，尚未创建定制版 GitHub Release；Actions artifact 是临时保存的构建产物。
home.2 提供 Actions 构建下载入口，尚未本地下载或用原密钥重签；不能将它标为已签名覆盖升级包。
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
flutter build apk --release --split-per-abi --target-platform android-arm64,android-x64
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
  Home 构建工作流没有覆盖该值。若发行时决定使用稳定版环境，传入 `--dart-define=APP_ENV=stable`。
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
例如下一版 `v0.8.98-home.3`。GitHub Release 应标为正式发布，预发布不会被 `releases/latest` 返回。
发布时附上固定签名的 APK；上游 `.github/release_template.md` 仍含上游下载地址，不能直接用作定制版下载页。
目前没有定制版 Release，也没有自动下载安装或自动合并上游的功能。已交付的旧 APK 尚未包含此修正。

## 实现导航

状态流及路由注入位置见[架构说明](../.agents/architecture.md#android-home-customizations)。
使用和联网前提见[使用说明](HOME-ANDROID.md)。保持以下行为：

- 首页开关复用原 VPN 设置；隐藏应用的已选名单不能在保存时丢失。
- Tailscale 规则在最终覆写完成后注入，DNS policy 保留订阅原有项，节点名冲突时追加后缀。
- 私网绕过模式下仍捕获 Tailscale 和显式子网；不添加出口节点，不允许默认路由 `/0`。
- Android VPN 生命周期仍由原服务管理；页面“已启用”只代表配置状态。

## 验证与交接

- [APK 构建](https://github.com/Frank-jpeg/FlClash/actions/runs/36564426025)成功产出 arm64 和 x86_64。
- [自动化检查](https://github.com/Frank-jpeg/FlClash/actions/runs/36565065823)通过：Flutter 1862 项通过、
  3 项跳过，总覆盖率 79.42%；安卓原生、Go、Rust、插件和 Windows Helper 检查通过。
- `b9fa81d` 本地相关 Flutter 测试通过：更新/提醒等 139 项，补充启动快照、消息队列与桥接等 72 项；
  两批包含重复测试，不相加为独立用例数。静态分析没有错误或警告，剩余一条既有 const 建议。
- `b9fa81d` 的[完整检查](https://github.com/Frank-jpeg/FlClash/actions/runs/36574920340)通过：
  Flutter 1874 项通过、3 项跳过，覆盖率 79.50%，Android、Go、Rust、插件及 Windows Helper 检查通过。
  原 APK 构建已被 home.2 构建取代；新构建和验证分别为
  [home.2 APK](https://github.com/Frank-jpeg/FlClash/actions/runs/36576531323)及
  [home.2 检查](https://github.com/Frank-jpeg/FlClash/actions/runs/36576531340)。
  下载入口在构建页的 Artifacts，名称 `FlClash-home-a84c30cb5b7095474ddd141d5425880ef8013f0e`；
  仅在成功上传后可用，运行状态以链接为准。
  2026-09-29 21:47（UTC+8）核对：home.2 完整检查已通过，APK 构建仍在运行，尚未上传 artifact。
- 本机有 Flutter/Android/JDK 环境；此次原生编译检查未完成，缓存的 Gradle 9.3.1 离线缺少
  `org.gradle.kotlin.kotlin-dsl:6.4.2`，仓库所需 Gradle 9.2.1 也未完成下载。不是源码编译通过记录。
- Windows 本地较早一次全量测试出现 6 个路径分隔符相关失败，不能称其全绿；
  相关定制测试通过，完整 Linux CI 的通过记录见上方链接。
- MuMu 已验证安装启动、首页入口、下载管理器显示和部分快捷选择。快速保存后立即强制停止
  的一次检查没有保留所选状态，原因尚未确认，不能据此宣布名单持久化实机测试通过。
- VPN 启动、Google Play 登录/下载、Tailscale 登录、真实 NAS 连通性尚无逐项实机通过记录。
  2026-09-29 用户接手后续设备测试；没有新要求时，不继续操作模拟器或扩展测试。
- GitHub 密钥扫描命中过测试占位文本，已替换并将告警 #1 关闭为误报；它从未是真实凭据。

`docs/` 默认被上游 `.gitignore` 忽略，新增共享文档需逐文件显式加入版本控制。
若存在 `HOME-LOCAL.md`，它保存本机目录、签名材料位置和交接状态，只留本地。
