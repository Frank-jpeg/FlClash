<div>

[**English**](README.md)

</div>

## 安卓首页版下载

### [⬇ 下载安卓手机 APK](https://github.com/Frank-jpeg/FlClash/releases/latest/download/FlClash-home-arm64-v8a.apk)

**ARM64 · APK** — 点击直接下载，下载后安装，无需解压或登录 GitHub。

[x86_64 模拟器 APK](https://github.com/Frank-jpeg/FlClash/releases/latest/download/FlClash-home-x86_64.apk) ·
[更新记录](https://github.com/Frank-jpeg/FlClash/releases/latest) ·
[使用说明](https://github.com/Frank-jpeg/FlClash/blob/feature/android-home-tailscale/docs/HOME-ANDROID.md)

发布的 APK 沿用首页版固定签名，可覆盖之前的固定签名首页版。
线上构建成功后自动签名发布，此链接始终指向最新发布版。

## FlClash

此分支是基于上游 v0.8.98 的 **FlClash 安卓首页版**，加入首页分应用开关、Google Play
组件显示修复和 Tailscale 内网设置。代码保存在公开仓库
[Frank-jpeg/FlClash](https://github.com/Frank-jpeg/FlClash) 的
[`feature/android-home-tailscale`](https://github.com/Frank-jpeg/FlClash/tree/feature/android-home-tailscale) 分支。
参阅[使用说明](docs/HOME-ANDROID.md)和[构建、更新与验证记录](docs/HOME-MAINTENANCE.md)。
下方上游徽章与 F-Droid/GitHub 按钮属于原版 FlClash。

[![Downloads](https://img.shields.io/github/downloads/chen08209/FlClash/total?style=flat-square&logo=github)](https://github.com/chen08209/FlClash/releases/)[![Last Version](https://img.shields.io/github/release/chen08209/FlClash/all.svg?style=flat-square)](https://github.com/chen08209/FlClash/releases/)[![License](https://img.shields.io/github/license/chen08209/FlClash?style=flat-square)](LICENSE)

[![Channel](https://img.shields.io/badge/Telegram-Channel-blue?style=flat-square&logo=telegram)](https://t.me/FlClash)

基于ClashMeta的多平台代理客户端，简单易用，开源无广告。

on Desktop:
<p style="text-align: center;">
    <img alt="desktop" src="snapshots/desktop.gif">
</p>

on Mobile:
<p style="text-align: center;">
    <img alt="mobile" src="snapshots/mobile.gif">
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

首页版支持下列操作（上游原版使用 `com.follow.clash.action.*`）：

   ```bash
    com.follow.clash.home.action.START
    
    com.follow.clash.home.action.STOP
    
    com.follow.clash.home.action.TOGGLE
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

2. 安装 `Flutter`、`Golang`、`Rust` 及宿主机 C/C++ 链接工具。
   使用对应工作流固定的版本；安卓首页版工作流使用 Flutter 3.47.4。

3. 构建应用

    - android

        1. 安装  `Android SDK` ,  `Android NDK`

        2. 将 `ANDROID_NDK_HOME` 指向 NDK r28c（`28.2.13676358`），使用 JDK 17。

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
