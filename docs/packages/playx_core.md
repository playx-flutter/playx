# playx_core

[pub.dev](https://pub.dev/packages/playx_core) · [Repository docs](https://github.com/playx-flutter/playx_core/tree/main/doc) · Used by Playx 3.0: **2.0.0** (2.x used 1.0.0)

The foundation of the ecosystem. It provides:

| Area | API |
| --- | --- |
| Preferences | `PlayxPrefs`, `PlayxAsyncPrefs`, `PlayxPrefsWithCache` — typed key-value storage, plus maps, lists and objects as JSON. |
| Secure preferences | `PlayxSecurePrefs` — encrypted storage with several backends. |
| Environment | `PlayxEnv` — `.env` files, per-environment files, `--dart-define`, typed getters. |
| Secure env | `secure_env` command — encrypt API keys into the app. |
| Logging | `PlayxLogger` — named loggers, levels, pluggable targets. |
| Extensions & utilities | `String`, `DateTime`, `Color`, `BuildContext`, padding, borders, `MapUtils`, `WebUtils`. |
| Dependency injection | `GetIt` re-exported. |

Playx boots it for you in the **Core** step (see [Booting Playx](../booting.md)). Pass settings
through `runPlayx`: `prefsSettings`, `securePrefsSettings`, `envSettingsBuilder`, `workManagerSettings`.

## Quick example

```dart
await PlayxPrefs.setString('name', 'Jane');
final name = PlayxPrefs.getString('name');

await PlayxSecurePrefs.setString('access_token', token);

final apiUrl = PlayxEnv.getString('API_URL');     // synchronous in 2.0
final timeout = PlayxEnv.getDuration('TIMEOUT');
```

## What changed in 2.0.0

### Breaking

- **SDK:** Dart `>=3.12.0`, Flutter `>=3.44.0`.
- **`PlayxEnv` getters are synchronous.** `await PlayxEnv.getString(...)` becomes
  `PlayxEnv.getString(...)`.
- **`PlayxEnv.load` takes a `PlayxEnvSettings`.** `PlayxEnv.instance` is removed; use
  `PlayxEnv.all` and `PlayxEnv.values`.
- **Stricter parsing:** an unrecognized bool reads as `null` (so `getBool` returns its fallback);
  `"1.5"` reads as `1` for ints.
- **`PlayxSecurePrefsSettings`** groups `flutter_secure_storage` options into
  `flutterSecureStorageOptions: PlayxFlutterSecureStorageOptions(...)`. `webOptions` is removed.
- **Android:** the default options no longer set `encryptedSharedPreferences` (existing data is
  migrated on first access).
- **Web:** secure prefs use AES-GCM with a non-extractable WebCrypto key in IndexedDB. Data saved
  by 1.x migrates automatically.
- `WebUtils.setAppTitle` takes named arguments on the web too.

### New

- **Secure prefs backends:** `PlayxSecurePrefsSettings.storageType` — `flutterSecureStorage`
  (default), `simpleSecureStorage`, `encryptedPrefs`, `auto` (first healthy backend, then memory),
  `memory`. Also `encryptKeys`, `throwOnError` and `migrateFromFlutterSecureStorage()`.
- **Layered env:** `.env`, then `.env.<environment>`, additional files, secure env, `mergeWith`,
  `PLAYX_DEFINES` and `dartDefines`. `requiredKeys` fails fast with `PlayxEnvException`.
  New getters: `getNum`, `getUri`, `getEnum`, `getDuration`, `getList`, `getMap`, `getObject`
  (each with `maybeGet*`).
- **Secure env:** see [below](#secure-env).
- **JSON helpers** on all prefs: `setMap`/`getMap`, `setList`/`getList`, `setObject`/`getObject`.
- **Extensions:** padding (`16.p`, `widget.withPadding(...)`), borders and radius, `String.toPrettyJson()`,
  `BuildContext.crossAxisCount(...)`, `utcOffset` for local date-time conversion, `onError` for
  `MapUtils.mapAsync`.
- **Logging:** `bootCore(loggerSettings:)` — colors, time, level labels and output target
  (`debugPrint`, `stdout`, `developerLog`). Colors turn off automatically where unsupported.
- **Docs:** guides for every area and a migration guide in the package's `doc/` folder.

### Changed

- Newer `flutter_secure_storage` (^11.2.0), `simple_secure_storage`, `flutter_dotenv` (^6.0.1).
- `clearOnReinstall` no longer requires `PlayxPrefs` to be created.

## Secure env

Keep sensitive values out of plain sight by encrypting them into a generated Dart file:

```sh
dart run playx:secure_env
```

`playx` forwards this command to `playx_core`, so you don't need `playx_core` in your
`pubspec.yaml`. Pass the generated value with `PlayxEnvSettings(secureEnv: playxSecureEnv)`.
See the [core secure env guide](https://github.com/playx-flutter/playx_core/blob/main/doc/secure-env.md)
for CI examples.

## What it means for Playx

Playx 3.0 updated its own code for the synchronous `PlayxEnv` getters (the example app no longer
`await`s them). Your env access needs the same change; see the [migration guide](../migration-3.0.md).
