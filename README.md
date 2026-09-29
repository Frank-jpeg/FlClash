<div>

[**简体中文**](README_zh_CN.md)

</div>

## 安卓首页版下载 / Android Home download

### [⬇ 下载安卓手机 APK / Download Android APK](https://github.com/Frank-jpeg/FlClash/releases/latest/download/FlClash-home-arm64-v8a.apk)

**ARM64 · APK** — 直接下载安装，无需解压或登录 GitHub。Download and install directly; no ZIP or GitHub sign-in.

[x86_64 模拟器 APK / Emulator APK](https://github.com/Frank-jpeg/FlClash/releases/latest/download/FlClash-home-x86_64.apk) ·
[更新记录 / Release notes](https://github.com/Frank-jpeg/FlClash/releases/latest) ·
[使用说明 / Usage guide](https://github.com/Frank-jpeg/FlClash/blob/feature/android-home-tailscale/docs/HOME-ANDROID.md)

发布的 APK 沿用首页版固定签名，可覆盖之前的固定签名首页版。Release APKs retain the Home signing key for upgrades.
线上构建成功后自动签名发布，此链接始终指向最新发布版。Successful cloud builds are signed and published automatically.

## FlClash

This branch contains **FlClash Home for Android**, based on upstream v0.8.98: home-screen
per-app VPN controls, Google Play component visibility fixes, and Tailscale private-network settings.
It is maintained in the public [Frank-jpeg/FlClash fork](https://github.com/Frank-jpeg/FlClash), on
[`feature/android-home-tailscale`](https://github.com/Frank-jpeg/FlClash/tree/feature/android-home-tailscale).
See the [usage guide](docs/HOME-ANDROID.md) and [build, update, and verification notes](docs/HOME-MAINTENANCE.md).
The upstream badges and F-Droid/GitHub buttons below refer to the original FlClash.

[![Downloads](https://img.shields.io/github/downloads/chen08209/FlClash/total?style=flat-square&logo=github)](https://github.com/chen08209/FlClash/releases/)[![Last Version](https://img.shields.io/github/release/chen08209/FlClash/all.svg?style=flat-square)](https://github.com/chen08209/FlClash/releases/)[![License](https://img.shields.io/github/license/chen08209/FlClash?style=flat-square)](LICENSE)

[![Channel](https://img.shields.io/badge/Telegram-Channel-blue?style=flat-square&logo=telegram)](https://t.me/FlClash)

A multi-platform proxy client based on ClashMeta, simple and easy to use, open-source and ad-free.

on Desktop:
<p style="text-align: center;">
    <img alt="desktop" src="snapshots/desktop.gif">
</p>

on Mobile:
<p style="text-align: center;">
    <img alt="mobile" src="snapshots/mobile.gif">
</p>

## Features

✈️ Multi-platform: Android, Windows, macOS and Linux

💻 Adaptive multiple screen sizes, Multiple color themes available

💡 Based on Material You Design, [Surfboard](https://github.com/getsurfboard/surfboard)-like UI

☁️ Supports data sync via WebDAV

✨ Support subscription link, Dark mode

## Use

### Linux

⚠️ Make sure to install the following dependencies before using them

   ```bash
    sudo apt-get install libayatana-appindicator3-dev
   ```

### Android

Android Home supports these actions (the upstream app uses `com.follow.clash.action.*`):

   ```bash
    com.follow.clash.home.action.START
    
    com.follow.clash.home.action.STOP
    
    com.follow.clash.home.action.TOGGLE
   ```

## Download

[**Download Android Home APK (ARM64)**](https://github.com/Frank-jpeg/FlClash/releases/latest/download/FlClash-home-arm64-v8a.apk)

### Upstream FlClash

<a href="https://chen08209.github.io/FlClash-fdroid-repo/repo?fingerprint=789D6D32668712EF7672F9E58DEEB15FBD6DCEEC5AE7A4371EA72F2AAE8A12FD"><img alt="Get it on F-Droid" src="snapshots/get-it-on-fdroid.svg" width="200px"/></a> <a href="https://github.com/chen08209/FlClash/releases"><img alt="Get it on GitHub" src="snapshots/get-it-on-github.svg" width="200px"/></a>

### Homebrew

```bash
brew tap chen08209/tap
brew install --cask flclash
```

## Build

1. Update submodules
   ```bash
   git submodule update --init --recursive
   ```

2. Install `Flutter`, `Golang`, and `Rust` (including a host C/C++ linker).
   Use the versions pinned by the workflow you are building; the Android Home workflow uses Flutter 3.47.4.

3. Build Application

    - android

        1. Install `Android SDK`, `Android NDK`

        2. Set `ANDROID_NDK_HOME` to NDK r28c (`28.2.13676358`), and use JDK 17.

        3. Run build script

           ```bash
           dart setup.dart android
           ```

    - windows

        1. Requires a Windows client

        2. Install `GCC`, `Inno Setup`

        3. Run build script

           ```bash
           dart setup.dart windows
           ```

    - linux

        1. Requires a Linux client

        2. Dependencies are auto-installed by setup script, or manually:
           ```bash
           sudo apt-get install -y libayatana-appindicator3-dev
           ```

        3. Run build script

           ```bash
           dart setup.dart linux
           ```

    - macOS

        1. Requires a macOS client

        2. Run build script

           ```bash
           dart setup.dart macos
           ```

## Star

The easiest way to support developers is to click on the star (⭐) at the top of the page.

<p style="text-align: center;">
    <a href="https://api.star-history.com/svg?repos=chen08209/FlClash&Date">
        <img alt="start" width=50% src="https://api.star-history.com/svg?repos=chen08209/FlClash&Date"/>
    </a>
</p>
