# FlClash 自改版

**基于 [chen08209/FlClash](https://github.com/chen08209/FlClash) v0.8.98 的 Android 个人改版，由 [Frank-jpeg](https://github.com/Frank-jpeg) 维护，非上游官方发行版。**

主要改进分应用控制的使用体验，并加入 Tailscale 内网配置入口。原项目及相关依赖的版权、作者署名和 GPL-3.0 许可证继续保留。

An independently maintained Android fork of FlClash v0.8.98, with easier per-app VPN controls and Tailscale private-network settings.

[仓库首页 / 中文与 English](README.md) · [上游 FlClash](https://github.com/chen08209/FlClash) · [GPL-3.0](LICENSE)

## 下载自改版 APK

### [⬇ 下载安卓手机 APK（ARM64）](https://github.com/Frank-jpeg/FlClash/releases/latest/download/FlClash-home-arm64-v8a.apk)

[x86_64 模拟器 APK](https://github.com/Frank-jpeg/FlClash/releases/latest/download/FlClash-home-x86_64.apk) · [版本记录与校验文件](https://github.com/Frank-jpeg/FlClash/releases/latest)

直接下载 APK，无需解压或登录 GitHub。线上构建成功后自动使用固定密钥签名并发布，下载链接始终指向最新发布版。

Direct APK downloads; no ZIP or GitHub sign-in required. Release APKs retain the same signing key for upgrades.

## 相比原版改了什么

| 改动 | 具体内容 |
| --- | --- |
| 首页分应用控制 | 首页直接开关“应用访问控制”，一键进入应用名单。 |
| 搜索框前置 | 应用名单顶部常驻搜索框，支持应用名、包名搜索，忽略大小写和首尾空格，并可一键清空。 |
| Google 组件显示 | 隐藏系统应用时，仍显示已安装的 Play 商店、Play 服务、服务框架和下载管理器；可一键加入 VPN 范围。 |
| 名单保存修正 | 保存时保留被筛选隐藏的应用选择，避免已有名单丢失。 |
| Tailscale 内网入口 | 应用内配置 tailnet 设备和显式子网的分流，可访问家里或公司的电脑、NAS 等设备。 |
| 重启提醒修正 | 运行中开关分应用控制、修改名单后提示重启；重启提交成功或撤销修改后清除提醒，失败时保留待处理状态。 |
| 自改版更新源 | 应用内检查更新指向本仓库，使用云端构建、固定签名和 APK 直链发布。 |
| 去除 PRE 角标 | home.4 起使用正式版环境，不再显示右上角的 PRE 和红色斜条。 |

Tailscale 通道复用 mihomo 已有能力，本改版增加的是设置入口与路由集成。保留原有订阅、规则分流、主题等功能。

The fork adds home-screen per-app controls, visible app search, Google component visibility, selection preservation, Tailscale settings/routing, corrected restart hints, fork update checks, and stable release banners. The Tailscale transport itself comes from mihomo.

## 自改版更新记录

| 版本 | 内容 |
| --- | --- |
| home.4 | 去除 PRE 和红色角标，固定使用正式版构建环境。 |
| home.3 | 应用名单搜索框前置，支持名称、包名搜索和一键清空。 |
| home.2 | 检查更新改为本仓库，修正分应用控制的重启提示。 |
| home.1 | 基于 v0.8.98 加入首页分应用控制、Google 组件显示与快捷选择、Tailscale 内网设置。 |

后续功能变更和新版本发布会同步更新本页说明及上表；完整发布信息见 [Releases](https://github.com/Frank-jpeg/FlClash/releases)。

## 安装与使用

- 当前发布 **Android ARM64 和 x86_64 APK**。APK 内显示名称暂为“FlClash 首页版”，包名 `com.follow.clash.home`；仓库展示名为“FlClash 自改版”。
- 可与原版同时安装，两者配置独立；首次使用需自行导入订阅或配置。后续同签名自改版可覆盖升级。
- 桌面图标和控制中心图标保留原样。
- 白名单中选中的应用进入 VPN，黑名单中选中的应用绕过 VPN；最终是否走代理由配置规则决定。修改名单后保存，VPN 运行中需重启生效。
- 搜不到手机自带浏览器时：**应用访问控制 → ⋮ → 设置 → 来源 → 点亮“系统应用”**。
- 内置 Tailscale 使用规则模式，访问内网的应用需包含在 VPN 范围内，并关闭独立 Tailscale App 的 VPN。访问其他局域网设备还需配置并批准子网路由。

[详细使用说明](https://github.com/Frank-jpeg/FlClash/blob/feature/android-home-tailscale/docs/HOME-ANDROID.md)

## 源码、构建与上游更新

默认 `main` 分支用于仓库首页展示和上游同步，**定制源码在 [feature/android-home-tailscale](https://github.com/Frank-jpeg/FlClash/tree/feature/android-home-tailscale) 分支**。构建自改版请使用该分支，默认分支不包含全部定制代码。

上游更新需合并、检查并重新构建，再使用固定签名发布；应用不会自动合并上游代码。

[构建环境、签名、上游更新步骤与验证记录](https://github.com/Frank-jpeg/FlClash/blob/feature/android-home-tailscale/docs/HOME-MAINTENANCE.md)

## 致谢与许可证

感谢 [chen08209/FlClash](https://github.com/chen08209/FlClash)、[mihomo](https://github.com/MetaCubeX/mihomo) 及相关开源项目。本仓库继续遵循 [GNU GPL v3.0](LICENSE)，保留原有版权和作者署名。

## 原版 FlClash 首页（保留内容）

下方保留原首页内容，其中的上游徽章、截图及原版安装说明属于原项目。本自改版的下载、功能和构建说明以上文为准。

<details>
<summary>展开原版首页 / Original upstream README</summary>

## FlClash

[![Downloads](https://img.shields.io/github/downloads/chen08209/FlClash/total?style=flat-square&logo=github)](https://github.com/chen08209/FlClash/releases/)[![Last Version](https://img.shields.io/github/release/chen08209/FlClash/all.svg?style=flat-square)](https://github.com/chen08209/FlClash/releases/)[![License](https://img.shields.io/github/license/chen08209/FlClash?style=flat-square)](LICENSE)

[![Channel](https://img.shields.io/badge/Telegram-Channel-blue?style=flat-square&logo=telegram)](https://t.me/FlClash)

基于ClashMeta的多平台代理客户端，简单易用，开源无广告。

<p align="center">
    <picture>
        <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/Frank-jpeg/FlClash/17e7e174c8256797ec4aa6ed99fcfd5c2f81ba83/snapshots/preview-dark.png">
        <img alt="FlClash on desktop and mobile" src="https://raw.githubusercontent.com/Frank-jpeg/FlClash/17e7e174c8256797ec4aa6ed99fcfd5c2f81ba83/snapshots/preview.png" width="90%">
    </picture>
</p>

## Features

✈️ 多平台: Android, Windows, macOS and Linux

💻 自适应多个屏幕尺寸,多种颜色主题可供选择

💡 基本 Material You 设计, 类[Surfboard](https://github.com/getsurfboard/surfboard)用户界面

☁️ 支持通过WebDAV同步数据

✨ 支持一键导入订阅, 深色模式

## Use

### Linux

⚠️ 使用前请确保安装以下依赖

   ```bash
    sudo apt-get install libayatana-appindicator3-dev
   ```

### Android

支持下列操作

   ```bash
    com.follow.clash.action.START
    
    com.follow.clash.action.STOP
    
    com.follow.clash.action.TOGGLE
   ```

## Download

[**下载安卓首页版 APK（ARM64）**](https://github.com/Frank-jpeg/FlClash/releases/latest/download/FlClash-home-arm64-v8a.apk)

### 上游原版 FlClash

<a href="https://chen08209.github.io/FlClash-fdroid-repo/repo?fingerprint=789D6D32668712EF7672F9E58DEEB15FBD6DCEEC5AE7A4371EA72F2AAE8A12FD"><img alt="Get it on F-Droid" src="snapshots/get-it-on-fdroid.svg" width="200px"/></a> <a href="https://github.com/chen08209/FlClash/releases"><img alt="Get it on GitHub" src="snapshots/get-it-on-github.svg" width="200px"/></a>

### Homebrew

```bash
brew tap chen08209/tap
brew install --cask flclash
```

## Build

1. 更新 submodules
   ```bash
   git submodule update --init --recursive
   ```

2. 安装 `Flutter` 以及 `Golang` 环境

3. 构建应用

    - android

        1. 安装  `Android SDK` ,  `Android NDK`

        2. 设置 `ANDROID_NDK` 环境变量

        3. 运行构建脚本

           ```bash
           dart setup.dart android
           ```

    - windows

        1. 你需要一个windows客户端

        2. 安装 `GCC`，`Inno Setup`

        3. 运行构建脚本

           ```bash
           dart setup.dart windows
           ```

    - linux

        1. 你需要一个linux客户端

        2. 依赖会由 setup 脚本自动安装，也可以手动安装：
           ```bash
           sudo apt-get install -y libayatana-appindicator3-dev
           ```

        3. 运行构建脚本

           ```bash
           dart setup.dart linux
           ```

    - macOS

        1. 你需要一个macOS客户端

        2. 运行构建脚本

           ```bash
           dart setup.dart macos
           ```

## Star

支持开发者的最简单方式是点击页面顶部的星标（⭐）。

<p style="text-align: center;">
    <a href="https://api.star-history.com/svg?repos=chen08209/FlClash&Date">
        <img alt="start" width=50% src="https://api.star-history.com/svg?repos=chen08209/FlClash&Date"/>
    </a>
</p>

</details>
