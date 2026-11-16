# Migrating from 1.x to 2.0

2.0 raises the minimum SDK and changes a few APIs, mostly in `PlayxEnv` and `PlayxSecurePrefs`. Most apps need only a handful of edits. Work through the checklist in order, then run `flutter analyze`: nearly every change below is caught at compile time.

- [Checklist](#checklist)
- [1. Upgrade Dart and Flutter](#1-upgrade-dart-and-flutter)
- [2. PlayxEnv](#2-playxenv)
- [3. Secure preferences settings](#3-secure-preferences-settings)
- [4. Secure preferences on web](#4-secure-preferences-on-web)
- [5. Smaller behavior changes](#5-smaller-behavior-changes)
- [6. Dependencies](#6-dependencies)
- [What did not change](#what-did-not-change)
- [New in 2.0](#new-in-20)

## Checklist

| | Change | Affects you if… |
| --- | --- | --- |
| ☐ | Dart ≥ 3.12 and Flutter ≥ 3.44 | always |
| ☐ | `PlayxEnv` getters are synchronous | you call `PlayxEnv.get*` / `maybeGet*` |
| ☐ | `PlayxEnv.load` takes a `PlayxEnvSettings` | you call `PlayxEnv.load(...)` yourself |
| ☐ | `PlayxEnv.instance` is removed | you read `PlayxEnv.instance` or `dotenv` |
| ☐ | Bool parsing is stricter | you read bools from env or secure prefs |
| ☐ | `PlayxSecurePrefsSettings` options are grouped | you customize secure storage options |
| ☐ | `AndroidOptions(encryptedSharedPreferences: …)` is gone | you set it |
| ☐ | Secure storage on web uses WebCrypto | you target web |
| ☐ | `WebUtils.setAppTitle` takes named arguments | you call it |
| ☐ | `context.form` returns `null` outside a `Form` | you use it |
| ☐ | Dependency versions | your app pins `flutter_secure_storage`, `flutter_dotenv` or `get_it` |

## 1. Upgrade Dart and Flutter

| | 1.x | 2.0 |
| --- | --- | --- |
| Dart | 3.5 | **3.12** |
| Flutter | 3.24 | **3.44** |

```yaml
environment:
  sdk: '>=3.12.0 <4.0.0'
  flutter: '>=3.44.0'
```

The new floor comes from `simple_secure_storage` (see [Secure preferences](secure-prefs.md)). If you can't upgrade yet, stay on 1.x.

## 2. PlayxEnv

`PlayxEnv` was rewritten around synchronous reads and a settings object. Details: [Environment configuration](env.md).

### Getters are synchronous

Values are in memory after `load`, so there is nothing to await.

```dart
// 1.x
final url = await PlayxEnv.getString('API_URL');
final retries = await PlayxEnv.getInt('RETRIES', fallback: 3);

// 2.0
final url = PlayxEnv.getString('API_URL');
final retries = PlayxEnv.getInt('RETRIES', fallback: 3);
```

A leftover `await` still compiles (and `flutter analyze` flags it with `await_only_futures`), but code that treated the result as a `Future` (`.then(...)`, `Future<String>` variables) no longer compiles. Search for `PlayxEnv.` in your project.

### `load` takes a `PlayxEnvSettings`

```dart
// 1.x
await PlayxEnv.load(fileName: '.env.dev', mergeWith: {'A': '1'}, isOptional: false);

// 2.0
await PlayxEnv.load(
  const PlayxEnvSettings(fileName: '.env.dev', mergeWith: {'A': '1'}, isOptional: false),
);
```

`PlayxEnvSettings` keeps its four original options (`fileName`, `parser`, `mergeWith`, `isOptional`), so the `envSettings:` argument of `bootCore` needs no change.

### `PlayxEnv.instance` is removed

`PlayxEnv` no longer fills `flutter_dotenv`'s global `dotenv`.

| 1.x | 2.0 |
| --- | --- |
| `PlayxEnv.instance.env` / `dotenv.env` | `PlayxEnv.all` (secure values excluded) |
| `PlayxEnv.instance.isInitialized` | `PlayxEnv.isLoaded` |
| `PlayxEnv.instance.isEveryDefined([...])` | `requiredKeys` in the settings, or `PlayxEnv.values.missingKeys([...]).isEmpty` |
| `dotenv.get('KEY')` | `PlayxEnv.getString('KEY')` |

### Stricter bool parsing

| Value | 1.x `getBool` | 2.0 `getBool` |
| --- | --- | --- |
| `true`, `TRUE`, `1` | `true` | `true` |
| `false`, `0` | `false` | `false` |
| `yes`, `maybe`, garbage | `false` | the **fallback** (`maybeGetBool` gives `null`) |

If you relied on "anything else is false", pass an explicit `fallback: false` (the default), or normalize your values.

`getInt` and `getDouble` also became more lenient: `"3.9"` reads as `3` for ints and `3` as `3.0` for doubles.

### Missing files and keys

Missing env files are now **logged and skipped** (as before for optional files), and you can add `requiredKeys` to fail at startup with a `PlayxEnvException` listing everything that is missing.

## 3. Secure preferences settings

The native `flutter_secure_storage` options moved into one object, and `webOptions` was removed (see [web](#4-secure-preferences-on-web)).

```dart
// 1.x
const PlayxSecurePrefsSettings(
  iosOptions: IOSOptions(accessibility: KeychainAccessibility.unlocked),
  androidOptions: AndroidOptions(encryptedSharedPreferences: true),
);

// 2.0
const PlayxSecurePrefsSettings(
  flutterSecureStorageOptions: PlayxFlutterSecureStorageOptions(
    iosOptions: IOSOptions(accessibility: KeychainAccessibility.unlocked),
    androidOptions: AndroidOptions(),
  ),
);
```

Moved options: `iosOptions`, `androidOptions`, `linuxOptions`, `windowsOptions`, `macOsOptions`. `clearOnReinstall` and `createSecurePrefs` are unchanged.

### `encryptedSharedPreferences` is gone

`flutter_secure_storage` 11 removed it and migrates existing Android data automatically on first access. Delete the argument (or the whole `AndroidOptions`).

### Staying on the same storage

The default is still `flutter_secure_storage`, so nothing changes about **where** your data lives. To move to the new backends, follow [Switching an existing app](secure-prefs.md#switching-an-existing-app-from-flutter_secure_storage).

## 4. Secure preferences on web

On web, `PlayxSecurePrefs` now encrypts with a **non-extractable WebCrypto key** kept in IndexedDB for every storage type except `memory`, instead of `flutter_secure_storage`'s web implementation (which kept its key in `localStorage`).

- Existing values are **migrated automatically** on the first start.
- Remove `webOptions` and any wrap-key configuration: there is nothing to configure now.
- Values written directly to `PlayxSecurePrefs.securePrefs` on web are no longer where playx reads and writes. Use the `PlayxSecurePrefs` API instead.

Details: [Secure preferences, Web](secure-prefs.md#web).

## 5. Smaller behavior changes

| Area | 1.x | 2.0 | Action |
| --- | --- | --- | --- |
| `WebUtils.setAppTitle` | positional on web (`setAppTitle('x')`), named on other platforms | named everywhere: `setAppTitle(title: 'x')` | Use the named form. The two forms could not compile on both platforms before. |
| `WebUtils` on WebAssembly | silently the no-op version | the real web version | none |
| `context.form` | threw outside a `Form` | returns `null` | none (a fix) |
| `asListInt` / `asListIntOr` | rejected `[1, '2', 3.0]` | convert like `asListIntOrNull`: `[1, 2, 3]` | none (a fix) |
| `PlayxSecurePrefs.maybeGetInt` / `Double` / `Bool` | `int.parse`, `double.parse`, `== 'true'` or `'1'` | `safe_convert` helpers | See [stricter bool parsing](#stricter-bool-parsing) |
| `PlayxAsyncPrefs.maybeGet*` | async errors escaped | errors return `null` as documented | none (a fix) |
| `clearOnReinstall` | required `PlayxPrefs` to be created | reads `SharedPreferences` itself, with the same flag | none |

## 6. Dependencies

| Package | 1.x | 2.0 |
| --- | --- | --- |
| `flutter_secure_storage` | `^10` | `^11.2` |
| `simple_secure_storage` | not used | `^0.4.3` |
| `flutter_dotenv` | `^6.0` | `^6.0.1` |
| `pointycastle` | not used | `>=3.9.1 <5.0.0` |
| `get_it` | `^9.2` | `>=8.0.0 <10.0.0` |
| `shared_preferences` | `^2.5.5` | `>=2.3.0 <3.0.0` |
| `equatable` | `^2.0.8` | `>=2.0.7 <4.0.0` |

If `flutter pub get` reports a version conflict, check that your app doesn't pin `flutter_secure_storage` below 11. New plugins mean new native code: run a full rebuild after upgrading (`flutter clean`, and `pod install` on iOS and macOS).

## What did not change

- `PlayxCore.bootCore`, `getIt`, `PlayxCore.dispose`.
- The `PlayxPrefs`, `PlayxAsyncPrefs` and `PlayxPrefsWithCache` APIs (new methods were added).
- The `PlayxSecurePrefs` API and its default backend.
- The `PlayxLogger` API.
- All `safe_convert` and `safe_json_convert` functions (new optional parameters only).

## New in 2.0

Not required for the upgrade, but worth a look:

- **More secure storage backends and a resilient `auto` mode:** [Secure preferences](secure-prefs.md).
- **Hiding key names** with `encryptKeys`: [Secure preferences](secure-prefs.md#hiding-key-names-encryptkeys).
- **Environments, flavors, `--dart-define` and typed getters:** [Environment configuration](env.md).
- **Encrypted secrets** generated by a command: [Secure env](secure-env.md).
- **Maps, lists and objects** in every preference store: [Preferences](preferences.md#maps-lists-and-objects).
- **Padding, border and radius helpers** and more: [Extensions](extensions.md).
- A full list in the [changelog](https://pub.dev/packages/playx_core/changelog).

---

*Imported from the [playx_core 2.0.0 documentation](https://github.com/playx-flutter/playx_core/blob/main/doc/migration-2.0.md). [Package site](https://playx-flutter.github.io/playx_core/) · [pub.dev](https://pub.dev/packages/playx_core).*
