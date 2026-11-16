# Playx

[![pub package](https://img.shields.io/pub/v/playx.svg?color=1284C5)](https://pub.dev/packages/playx)
[![test](https://github.com/playx-flutter/playx/actions/workflows/test.yml/badge.svg?branch=main)](https://github.com/playx-flutter/playx/actions/workflows/test.yml)
[![License: MIT](https://img.shields.io/badge/license-MIT-purple.svg)](LICENSE)

Playx is an ecosystem for Flutter apps. One package boots preferences, environment, theme,
localization, navigation, networking and widgets together, and gives you ready-made app widgets that wire
them up.

> **Playx 3.0** requires Dart `>=3.12.0` and Flutter `>=3.44.0`.
> Upgrading from 2.x? See the [migration guide](doc/migration-3.0.md).

## Features

- **`Playx.runPlayx`** — boots everything in order, then runs your app. Works with Sentry and on web.
- **Clear boot errors** — a failing step throws a `PlayxBootException` naming the step. Boot is idempotent
  and retryable, and async boot failures are logged and reported.
- **App widgets** — `PlayxMaterialApp`, `PlayxPlatformApp` and GetX variants that connect theme,
  localization, navigation, screen sizing and Sentry.
- **Connection status** — `ConnectionStatusController` for online/offline UI.
- **One import** — re-exports the whole [Playx ecosystem](doc/packages/README.md) and common packages.

## Install

```yaml
dependencies:
  playx: ^3.0.0
```

```dart
import 'package:playx/playx.dart';
```

## Quick start

```dart
void main() {
  Playx.runPlayx(
    appRunner: () => runApp(const MyApp()),
    appConfigBuilder: () => AppConfig(),
    themeConfigBuilder: createThemeConfig,
    localeConfigBuilder: createLocaleConfig,
    envSettingsBuilder: () => const PlayxEnvSettings(fileName: 'assets/env/keys.env'),
    // sentryOptions: (options) => options.dsn = 'https://...',
  );
}

class AppConfig extends PlayXAppConfig {
  @override
  Future<void> boot() async {
    Get.put<ApiClient>(ApiClient());
  }

  @override
  Future<void> asyncBoot() async {}
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => const PlayxMaterialApp(
    appSettings: PlayxAppSettings(title: 'My app'),
    navigationSettings: PlayxNavigationSettings(home: HomePage()),
  );
}
```

Full walkthrough: [Getting started](doc/getting-started.md).

## Documentation

| | |
| --- | --- |
| [Getting started](doc/getting-started.md) | Install and create your first Playx app. |
| [Booting Playx](doc/booting.md) | Boot order, errors, async boot, Sentry and web. |
| [App widgets](doc/app-widgets.md) | App widgets and all settings classes. |
| [Connection status](doc/connection-status.md) | `ConnectionStatusController`. |
| [Exports](doc/exports.md) | What `package:playx/playx.dart` re-exports. |
| [Testing](doc/testing.md) | Testing apps that use Playx. |
| [Migration to 3.0](doc/migration-3.0.md) | Breaking changes and fixes. |
| [Ecosystem](doc/packages/README.md) | Every Playx package and what changed in its latest version. |

## The Playx ecosystem

| Package | Version | What it does |
| --- | --- | --- |
| [`playx_core`](https://pub.dev/packages/playx_core) ([guide](doc/packages/playx_core.md)) | 2.0.0 | Preferences, secure storage, env, logging, extensions. |
| [`playx_theme`](https://pub.dev/packages/playx_theme) ([guide](doc/packages/playx_theme.md)) | 2.1.0 | Multi-theme management and animated switching. |
| [`playx_localization`](https://pub.dev/packages/playx_localization) ([guide](doc/packages/playx_localization.md)) | 1.0.0 | Locales, translations without `BuildContext`, plurals. |
| [`playx_navigation`](https://pub.dev/packages/playx_navigation) ([guide](doc/packages/playx_navigation.md)) | 3.0.0 | `go_router` with page lifecycle, scopes and guards. |
| [`playx_network`](https://pub.dev/packages/playx_network) ([guide](doc/packages/playx_network.md)) | 2.0.0 | Dio wrapper returning typed results. |
| [`playx_widget`](https://pub.dev/packages/playx_widget) ([guide](doc/packages/playx_widget.md)) | 0.6.0 | Utility widgets and app info. |

Also see [`playx_version_update`](https://pub.dev/packages/playx_version_update) for update dialogs
on Android and iOS.

## Example

A runnable app is in [`example/`](example/).

```sh
cd example && flutter run
```

## Contributing

```sh
flutter pub get
dart format lib test
flutter analyze lib test example
flutter test --coverage      # CI requires 90% coverage
```

See the [changelog](CHANGELOG.md) for release notes.

## License

MIT — see [LICENSE](LICENSE).
