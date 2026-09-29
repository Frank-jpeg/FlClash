# Project Context

FlClash is a Flutter client built around the ClashMeta/mihomo core. This checkout is the Android Home customization in
`Frank-jpeg/FlClash`; its upstream is `chen08209/FlClash`. Fork ownership, branch policy, build/signing, and verification
are defined in [the maintenance guide](../docs/HOME-MAINTENANCE.md).

## Version Sources

- `pubspec.yaml` defines the application version and Dart language constraint; the constraint is `>=3.10.0 <4.0.0`.
- `.github/workflows/build-home-apk.yml` pins Flutter 3.47.4 for the Android Home APK.
- `.github/workflows/build.yaml` retains Flutter 3.47.1 for the upstream-style validation/release pipeline.
  Both workflows were exercised for this fork; do not infer the APK SDK from the other workflow.
- `plugins/rust_api/rust/rust-toolchain.toml` pins Rust 1.95.0 and its supported targets.
- Go 1.26.4, JDK 17, and NDK r28c are used by the Home APK workflow.
- `pubspec.lock` is the authority for resolved dependencies. Change the language floor and generator versions
  deliberately, then regenerate and verify generated code; do not copy obsolete dependency ceilings into new changes.

## Forked Dependencies

These dependencies remain under the upstream maintainer's `chen08209` account. They are external dependencies of
`Frank-jpeg/FlClash`; maintaining this application fork does not grant ownership of those dependency repositories.

| Dependency | Pin in `pubspec.yaml` | Purpose |
| --- | --- | --- |
| `window_manager` | `v0.5.1-flclash.3`, `packages/window_manager` | FlClash desktop window integration |
| `launch_at_startup` | `e930ce65c5804343103447e01d39fccabedc8681` | Compatible Windows registry dependency |
| `yaml_writer` | `79c78a44ec9c2f5f5f97da1a65610c6fb2ead8b3` | Quoted YAML map keys |

Before dropping a fork pin, compare its changes with the proposed published dependency and verify its callers.
Keep the license and upstream attribution when updating or redistributing the application.

## Dependency Compatibility

The 2026-09-29 lockfile resolves `analyzer` 13.3.0, `freezed` 4.0.1, `riverpod` / `flutter_riverpod` 3.4.2,
`riverpod_annotation` 4.0.6, and `riverpod_generator` 4.0.8. `dynamic_color` resolves to 2.1.0.
Update these as a compatible dependency set rather than imposing an obsolete analyzer or generator ceiling.

`flutter_test` constrains `test_api`; this lockfile has `test` 1.31.1 and `test_api` 0.7.12. Evaluate upgrades as a
compatible dependency set using the selected Flutter SDK. A `pub outdated` notice alone is not a reason to change pins.
`intl` is intentionally unconstrained in `pubspec.yaml` and is resolved with the Flutter dependency graph.

## Build Dependencies

Every platform needs Flutter, Go, Rust/Cargo, and the host tools needed to compile Rust build scripts.
An existing Flutter/Android SDK installation is useful even when a separate native tool is missing;
check actual executables and versions before choosing local versus cloud builds.

Android additionally needs JDK 17 and Android SDK/NDK. Set `ANDROID_NDK_HOME` to r28c before running Flutter;
Gradle's `ndkVersion` alone does not guarantee the native-asset hook receives that NDK.
On Windows, the Rust MSVC host toolchain also needs the Visual C++ linker and Windows SDK.

Linux desktop:

```bash
sudo apt-get install libayatana-appindicator3-dev
```

Windows desktop packaging additionally uses the existing GCC / Inno Setup workflow. Check the C++ and Rust
host prerequisites separately; installing an Android NDK does not provide the Windows MSVC linker.

macOS packaging:

```bash
npm install -g appdmg
```
