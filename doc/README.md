# Playx documentation

Playx is an umbrella package for Flutter apps. It boots the whole Playx ecosystem
(preferences, environment, theme, localization, navigation, networking and widgets)
with one call and gives you ready-made app widgets that wire everything together.

> **Current version: 3.0.0** — requires Dart `>=3.12.0` and Flutter `>=3.44.0`.
> Coming from 2.x? Read the [migration guide](migration-3.0.md).

## Guides

| Guide | What it covers |
| --- | --- |
| [Getting started](getting-started.md) | Install, create the configs, and run your first Playx app. |
| [Booting Playx](booting.md) | `runPlayx` and `Playx.boot`, boot errors, async boot, Sentry and web. |
| [App widgets](app-widgets.md) | `PlayxMaterialApp`, `PlayxPlatformApp`, the GetX variants and their settings. |
| [Connection status](connection-status.md) | `ConnectionStatusController` for online/offline UI. |
| [Exports](exports.md) | Everything `package:playx/playx.dart` re-exports. |
| [Testing](testing.md) | Testing apps that use Playx, and how this package is tested. |
| [Migration to 3.0](migration-3.0.md) | Breaking changes from 2.x and how to fix them. |

## The Playx ecosystem

Playx re-exports these packages, so one import is enough. Each has its own page with
what it does, a quick example, and **what changed in the version Playx 3.0 uses**.

| Package | Version | Purpose | Page |
| --- | --- | --- | --- |
| [`playx_core`](https://pub.dev/packages/playx_core) | 2.0.0 | Preferences, secure storage, env, logging, extensions. | [playx_core](packages/playx_core.md) |
| [`playx_theme`](https://pub.dev/packages/playx_theme) | 2.1.0 | Multi-theme management with animated switching. | [playx_theme](packages/playx_theme.md) |
| [`playx_localization`](https://pub.dev/packages/playx_localization) | 1.0.0 | Locales, translation without `BuildContext`, plurals. | [playx_localization](packages/playx_localization.md) |
| [`playx_navigation`](https://pub.dev/packages/playx_navigation) | 3.0.0 | `go_router` with page lifecycle, scopes and guards. | [playx_navigation](packages/playx_navigation.md) |
| [`playx_network`](https://pub.dev/packages/playx_network) | 2.0.0 | Dio wrapper returning typed results. | [playx_network](packages/playx_network.md) |
| [`playx_widget`](https://pub.dev/packages/playx_widget) | 0.6.0 | Utility widgets and `AppVersion`. | [playx_widget](packages/playx_widget.md) |

See the [ecosystem overview](packages/README.md) for how the pieces fit together and a
summary of what changed in each package.
