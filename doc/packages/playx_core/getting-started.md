# Getting started

## Requirements

| | Minimum |
| --- | --- |
| Dart | 3.12 |
| Flutter | 3.44 |

Supported platforms: Android, iOS, macOS, Windows, Linux and web.

## Installation

```yaml
dependencies:
  playx_core: ^2.0.0
```

Using the full PlayX ecosystem? Depend on [`playx`](https://pub.dev/packages/playx) instead, which includes `playx_core`.

```dart
import 'package:playx_core/playx_core.dart';
```

One import gives you everything: preferences, secure storage, environment configuration, extensions, utilities, logging, and re-exports of `GetIt`, `Equatable`, `SharedPreferences` and `worker_manager`.

## Booting the core

Call `PlayxCore.bootCore` once, before `runApp`. It creates the pieces you ask for and initializes logging and dependency injection.

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await PlayxCore.bootCore();

  runApp(const MyApp());
}
```

With no arguments it creates `PlayxPrefs`, `PlayxAsyncPrefs`, `PlayxSecurePrefs` (using `flutter_secure_storage`) and the worker manager. Everything is configured through settings objects:

```dart
await PlayxCore.bootCore(
  // Which preference stores to create.
  prefsSettings: const PlayxPrefsSettings(
    createPlayxPrefsWithCache: true,
  ),
  // Secure storage backend and behavior.
  securePrefsSettings: const PlayxSecurePrefsSettings(
    storageType: PlayxSecureStorageType.auto,
  ),
  // Environment configuration. Omit to skip loading any env.
  envSettings: const PlayxEnvSettings(
    requiredKeys: ['API_URL'],
  ),
  // Isolate pool used by the *InIsolate helpers.
  workerManagerSettings: const WorkManagerSettings(isolatesCount: 2),
  // How the package's own logs look: no colors, with the time, no box.
  loggerSettings: PlayxLoggerSettings(
    useColors: false,
    printDateTime: true,
    formatter: const DefaultColoredLoggerFormatter(),
  ),
);
```

### What `bootCore` sets up

`bootCore` runs these steps in order. Each is skipped when its setting turns it off.

| Step | Setting | Default |
| --- | --- | --- |
| Create `PlayxPrefs` | `prefsSettings.createPlayxPrefs` | `true` |
| Create `PlayxAsyncPrefs` | `prefsSettings.createPlayxAsyncPrefs` | `true` |
| Create `PlayxPrefsWithCache` | `prefsSettings.createPlayxPrefsWithCache` (with `prefsWithCacheOptions`) | `false` |
| Create `PlayxSecurePrefs` | `securePrefsSettings.createSecurePrefs` | `true` |
| Load `PlayxEnv` | `envSettings` is not `null` | not loaded |
| Start the worker manager | `workerManagerSettings.initWorkerManager` (with `isolatesCount`, `dynamicSpawning`) | `true` |

The logger named `PLAYX CORE` is always initialized first (configure it with `loggerSettings`), and `GetIt` becomes available at the end.

`bootCore` throws if loading the env fails (for example a missing `requiredKeys` entry, or `isOptional: false` with a missing file), so a misconfigured build fails at startup rather than deep inside the app.

> Create only what you use. Skipping a store you don't need avoids reading it at startup, and calling a store that wasn't created throws an `Exception` saying so.

## Dependency injection

`playx_core` re-exports [`GetIt`](https://pub.dev/packages/get_it). After `bootCore`, use the global `getIt`:

```dart
getIt.registerSingleton<AuthService>(AuthService());
getIt.registerLazySingleton<Api>(() => Api(PlayxEnv.getUri('API_URL', fallback: Uri())));

final auth = getIt<AuthService>();
```

`getIt` (and `PlayxCore.getIt`) throws an `Exception` if `bootCore` hasn't run. `PlayxCore.dispose()` resets it.

## Logging

`bootCore` creates the logger `PLAYX CORE`, used by the package itself (for example when a secure storage fallback happens). You can use it too, or create your own. Pass `loggerSettings` to turn colors off, add the time, hide the boot messages or change where logs go: see [Logging](logging.md#configuring-the-playx-core-logger).

```dart
PlayxCore.logger.i('App started');
```

## Disposing

`PlayxCore.dispose()` releases everything `bootCore` created: `GetIt`, the preference stores, `PlayxSecurePrefs`, `PlayxEnv` and the worker manager. It is mainly useful in tests:

```dart
tearDown(PlayxCore.dispose);
```

See [Testing](testing.md) for complete test setups.

## What next

- Store data: [Preferences](preferences.md) and [Secure preferences](secure-prefs.md).
- Configure the app per environment: [Environment configuration](env.md), and [Secure env](secure-env.md) for sensitive values.
- Upgrading from 1.x? Read [Migrating to 2.0](migration-2.0.md).

---

*Imported from the [playx_core 2.0.0 documentation](https://github.com/playx-flutter/playx_core/blob/main/doc/getting-started.md). [Package site](https://playx-flutter.github.io/playx_core/) · [pub.dev](https://pub.dev/packages/playx_core).*
