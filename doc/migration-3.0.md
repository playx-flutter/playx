# Migrating from Playx 2.x to 3.0

Playx 3.0 updates every ecosystem package to a new major version and removes the deprecated
boot API. Most apps need only the changes below.

## 1. SDK versions

| | 2.x | 3.0 |
| --- | --- | --- |
| Dart | `>=3.10.0` | `>=3.12.0` |
| Flutter | `>=3.38.0` | `>=3.44.0` |

Upgrade Flutter first (`flutter upgrade`), then update the dependency:

```yaml
dependencies:
  playx: ^3.0.0
```

## 2. `boot` and `runPlayx` parameters

The deprecated parameters are removed. The builders and `appRunner` are now **required**.

| Removed | Use instead |
| --- | --- |
| `app` | `appRunner: () => runApp(const MyApp())` |
| `appConfig` | `appConfigBuilder: () => AppConfig()` |
| `localeConfig` | `localeConfigBuilder: () => createLocaleConfig()` |
| `themeConfig` | `themeConfigBuilder: () => createThemeConfig()` |
| `envSettings` | `envSettingsBuilder: () => const PlayxEnvSettings(...)` (optional) |

Before:

```dart
Playx.runPlayx(
  app: const MyApp(),
  appConfig: AppConfig(),
  themeConfig: createThemeConfig(),
  localeConfig: createLocaleConfig(),
);
```

After:

```dart
Playx.runPlayx(
  appRunner: () => runApp(const MyApp()),
  appConfigBuilder: () => AppConfig(),
  themeConfigBuilder: createThemeConfig,
  localeConfigBuilder: createLocaleConfig,
);
```

## 3. Sentry exports

`sentry_flutter` is now exported with an explicit list of public APIs. If you use a type that
is no longer available from `package:playx/playx.dart`, import it directly:

```dart
import 'package:sentry_flutter/sentry_flutter.dart';
```

Sentry 10 itself has migration notes (for example Android `minSdk` 26 and span streaming on by
default for `sentry_dio`). Read the
[Sentry Flutter changelog](https://pub.dev/packages/sentry_flutter/changelog).

## 4. Ecosystem package changes

These affect code that uses the packages directly. Details are in each package page.

| Package | You must change |
| --- | --- |
| [`playx_core` 2.0](packages/playx_core.md) | `await PlayxEnv.getString(...)` becomes `PlayxEnv.getString(...)` (getters are synchronous). `PlayxEnv.load` takes a `PlayxEnvSettings`. `PlayxEnv.instance` is removed. Secure prefs options are grouped into `flutterSecureStorageOptions`. |
| [`playx_network` 2.0](packages/playx_network.md) | `NetworkException` has new subclasses; exhaustive `switch` statements need them. Slow responses are `ReceiveTimeoutException`, not `SendTimeoutException`. |
| [`playx_navigation` 3.0](packages/playx_navigation.md) | Page lifecycle is per page instance; `onHidden`/`onReEnter` fire for the initial route; `offAndTo` returns `Future<T?>`. |
| [`playx_localization` 1.0](packages/playx_localization.md) | Locale is saved by id (migrated automatically). Plurals follow language rules by default. Script-code file naming is BCP-47. |
| [`playx_widget` 0.6](packages/playx_widget.md) | Weighted Lucide icons moved to separate libraries. `FavoriteButton.onFavoriteChanged` is a `ValueChanged<bool>`. |
| [`playx_theme` 2.1](packages/playx_theme.md) | No breaking changes. |

## 5. New in 3.0

- `PlayxBootException` names the boot step that failed.
- `Playx.boot` is idempotent and retryable.
- Async boot failures are reported; use `Playx.hasAsyncBootFailed()`, `Playx.asyncBootError`
  and `Playx.waitForAsyncBoot()`.
- `initializeBinding` option for `boot` and `runPlayx`.
- `PlayxWebSettings` is exported, so `webSettings` is usable.
- `Playx.appConfig` returns the booted config (it threw in 2.x).
- `dart run playx:secure_env` command.

See the [changelog](../CHANGELOG.md) for the complete list.
