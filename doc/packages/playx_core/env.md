# Environment configuration

`PlayxEnv` gives your app typed configuration values (API URLs, feature flags, timeouts) from:

1. `.env` files bundled as assets, including one per environment or flavor;
2. build-time values passed with `--dart-define`;
3. [encrypted secure env](secure-env.md) for sensitive values.

All sources are merged into one set of values that you read **synchronously** with typed getters.

> **Security:** `.env` files ship as plain text inside your app and `--dart-define` values are compiled into it. Anyone who has the app can read them. Use them for configuration, and [secure env](secure-env.md) for sensitive values.

- [Quick start](#quick-start)
- [Settings reference](#settings-reference)
- [How values are layered](#how-values-are-layered)
- [Environments and flavors](#environments-and-flavors)
- [File syntax](#file-syntax)
- [Build-time values](#build-time-values)
- [Reading values](#reading-values)
- [Required keys and errors](#required-keys-and-errors)
- [Inspecting what was loaded](#inspecting-what-was-loaded)
- [Loading without `bootCore`](#loading-without-bootcore)
- [Recipes](#recipes)

## Quick start

**1. Create the files** next to your `pubspec.yaml`:

```
# .env
API_URL=https://api.example.com
ENABLE_LOGS=true
TIMEOUT=30s
```

**2. Declare them as assets.** List every file you want to load, including environment files:

```yaml
# pubspec.yaml
flutter:
  assets:
    - .env
    - .env.dev
    - .env.prod
```

**3. Load them at startup** by passing `envSettings` to `bootCore`:

```dart
await PlayxCore.bootCore(
  envSettings: const PlayxEnvSettings(
    requiredKeys: ['API_URL'],   // fail at startup if missing
  ),
);
```

**4. Read values:**

```dart
final apiUrl = PlayxEnv.getUri('API_URL', fallback: Uri.parse('https://api.example.com'));
final logs = PlayxEnv.getBool('ENABLE_LOGS');
final timeout = PlayxEnv.getDuration('TIMEOUT', fallback: const Duration(seconds: 30));
```

## Settings reference

`PlayxEnvSettings` is a `const` class. Every option is optional.

| Option | Default | Meaning |
| --- | --- | --- |
| `fileName` | `'.env'` | The base file. |
| `environment` | `null` | Environment name (`dev`, `prod`…). Loads `'$fileName.$environment'` after the base file. When `null`, resolved from `--dart-define=PLAYX_ENV`, then the Flutter flavor. |
| `useFlavor` | `true` | Use the Flutter flavor as the environment when none is set. |
| `additionalFiles` | `[]` | More files loaded after the environment file, e.g. `['.env.local']`. |
| `mergeWith` | `{}` | Values that override the files. |
| `usePlayxDefines` | `true` | Read `--dart-define=PLAYX_DEFINES`. |
| `dartDefines` | `{}` | Individual build-time values that override everything else. |
| `secureEnv` | `null` | Encrypted values from [secure env](secure-env.md). |
| `useSecureDefines` | `true` | Read `--dart-define=PLAYX_SECURE_DEFINES`. |
| `requiredKeys` | `[]` | Keys that must have a non-empty value once loaded. |
| `isOptional` | `true` | When `false`, a missing file throws instead of being skipped. |
| `parser` | `Parser()` | The `flutter_dotenv` parser, if you need custom parsing. |

## How values are layered

Sources are applied in this order. **Later sources override earlier ones**, key by key: a source only replaces the keys it defines, everything else is kept.

| # | Source | Example |
| --- | --- | --- |
| 1 | `fileName` | `.env` |
| 2 | `'$fileName.$environment'` | `.env.prod` |
| 3 | `additionalFiles`, in order | `.env.local` |
| 4 | [Secure env](secure-env.md): `secureEnv`, then `PLAYX_SECURE_DEFINES` | generated file |
| 5 | `mergeWith` | `{'API_URL': '...'}` |
| 6 | `PLAYX_DEFINES` | `--dart-define=PLAYX_DEFINES="DEBUG=true"` |
| 7 | `dartDefines` | `--dart-define=DEBUG=true` |

```
# .env                            # .env.prod
BASE_URL=https://api.example.com  BASE_URL=https://api.prod.example.com
TIMEOUT=30s
```

With `--dart-define=PLAYX_ENV=prod`, `BASE_URL` comes from `.env.prod` and `TIMEOUT` still comes from `.env`. A `--dart-define=PLAYX_DEFINES="BASE_URL=https://staging.example.com"` on top would replace `BASE_URL` only.

**Missing files.** A missing file is logged and skipped, so a missing `.env.prod` simply leaves the values from `.env` in place. With `isOptional: false`, `load` throws a `PlayxEnvException` listing the missing files. The setting applies to all files at once.

## Environments and flavors

The environment name selects `.env.<name>`. It is resolved in this order:

1. `PlayxEnvSettings.environment`, if set;
2. `--dart-define=PLAYX_ENV=<name>`;
3. the Flutter flavor (`flutter run --flavor <name>`), unless `useFlavor: false`.

```sh
flutter run --dart-define=PLAYX_ENV=dev
flutter run --flavor prod                  # flavors need native flavor setup
flutter build apk --flavor staging
```

`PlayxEnv.environment` reports the resolved name and `PlayxEnv.loadedFiles` the files that were actually found. If no name is resolved, only the base file (and `additionalFiles`) is loaded.

Set `environment` in code when the name comes from somewhere else:

```dart
PlayxEnvSettings(environment: kReleaseMode ? 'prod' : 'dev')
```

## File syntax

Files use the usual `.env` format:

```
# Comments start with a hash
APP_NAME=Playx Core
GREETING="Hello, world"        # quotes keep spaces
export TOKEN_URL=https://auth.example.com
API_URL=https://$HOST/api      # references an earlier value
PRICE=\$5                      # escape a literal dollar sign
```

- Variables can reference earlier values with `$NAME`, including values from earlier **files**.
- **A reference is resolved when its line is read.** If `.env` defines `API_URL=https://$HOST/api` and `.env.prod` only changes `HOST`, `API_URL` keeps the old host. Redefine `API_URL` in `.env.prod` as well.
- Empty files are fine; unreadable lines are ignored.

## Build-time values

Dart can only read a define whose name is written as a **constant in code**. Reading one by a name known only at runtime works in debug builds, but returns `""` in release builds and throws on web, so playx never does that. There are two ways to pass build-time values.

### `PLAYX_DEFINES`: any number of values, nothing to declare

```sh
flutter run --dart-define=PLAYX_DEFINES="DEBUG=true;API_URL=https://dev.example.com"
```

```dart
PlayxEnv.getBool('DEBUG');   // true, with no setup in code
```

- Entries use `.env` syntax, separated by `;` or new lines.
- For values containing `;` or awkward characters, pass base64: `--dart-define=PLAYX_DEFINES=base64:$(base64 < .env.ci)`.
- It works with `--dart-define-from-file`, which avoids shell quoting:

  ```json
  { "PLAYX_DEFINES": "DEBUG=true;API_URL=https://dev.example.com" }
  ```

- Values can reference values from the files (`API_URL=https://$HOST`).
- An explicit empty entry (`KEY=`) overrides with an empty string, which is the only way to blank a value from the command line.
- Disable with `usePlayxDefines: false`.

### `dartDefines`: individual, declared defines

```sh
flutter run --dart-define=DEBUG=true
```

```dart
const PlayxEnvSettings(
  dartDefines: {'DEBUG': String.fromEnvironment('DEBUG')},
);
```

Unset defines come through as `''` and are ignored, so `.env` values stay in place. `dartDefines` wins over `PLAYX_DEFINES`.

> If you only need a flag **in code**, `const debug = bool.fromEnvironment('DEBUG');` is a compile-time constant: code behind `if (debug)` is removed from release builds, which runtime configuration can't do.

## Reading values

All getters are synchronous. Each type has `maybeGetX` (returns `null` when there's no usable value) and `getX` (returns a fallback).

| Type | Accepted values | Read | Fallback default |
| --- | --- | --- | --- |
| `String` | anything | `maybeGetString`, `getString` | `''` |
| `int` | `3`, `"3.9"` (truncated) | `maybeGetInt`, `getInt` | `-1` |
| `double` | `2.5`, `3` | `maybeGetDouble`, `getDouble` | `-1` |
| `num` | `7`, `2.5` | `maybeGetNum`, `getNum` | `-1` |
| `bool` | `true`, `false`, `1`, `0` (case-insensitive) | `maybeGetBool`, `getBool` | `false` |
| `Uri` | `https://example.com/a` | `maybeGetUri`, `getUri` | required `fallback` |
| enum | the value's name, case-insensitive | `maybeGetEnum(key, Mode.values)`, `getEnum` | required `fallback` |
| `Duration` | `250ms`, `30s`, `5m`, `1.5h`, `1d` (no unit = milliseconds) | `maybeGetDuration`, `getDuration` | required `fallback` |
| `List<T>` | `a, b, c` or `[1, 2, 3]` | `maybeGetList<T>`, `getList<T>` | `[]` |
| JSON object | `{"enabled": true}` | `maybeGetMap`, `getMap` | `{}` |
| your type | JSON | `maybeGetObject(key, fromJson:)`, `getObject` | required `fallback` |

A value that can't be converted (for example `maybe` as a bool) is treated like a missing one.

```dart
final retries = PlayxEnv.getInt('RETRIES', fallback: 3);
final mode = PlayxEnv.getEnum('THEME_MODE', ThemeMode.values, fallback: ThemeMode.system);
final locales = PlayxEnv.getList<String>('SUPPORTED_LOCALES');       // 'en, ar' -> ['en', 'ar']
final ports = PlayxEnv.getList<int>('PORTS');                        // '80,443' or '[80, 443]'
final flags = PlayxEnv.getObject(
  'FEATURES',
  fromJson: FeatureFlags.fromJson,                                   // '{"newCheckout": true}'
  fallback: const FeatureFlags(),
);
```

Lists accept a custom `separator` (default `,`), skip empty items, and convert `String`, `int`, `double`, `num`, `bool` and `Uri` items automatically. Pass `fromJson` for other types. If any item can't be converted the whole list reads as `null` (or the fallback).

### `PlayxEnv.values` and `EnvValues`

`PlayxEnv`'s getters are shortcuts for the same getters on `PlayxEnv.values`, an immutable `EnvValues`. You can also wrap any `Map<String, String>`, such as remote config:

```dart
final remote = EnvValues({'NEW_CHECKOUT': 'true', 'LIMIT': '10'});
remote.getBool('NEW_CHECKOUT');   // true
remote.getInt('LIMIT');           // 10
```

## Required keys and errors

```dart
const PlayxEnvSettings(requiredKeys: ['API_URL', 'STRIPE_KEY']);
```

`load` throws a `PlayxEnvException` when:

- a required key is missing or empty: `missingKeys` lists **all** of them;
- a file is missing and `isOptional` is `false`: `missingFiles` lists them;
- [secure env](secure-env.md) values can't be decrypted.

```dart
try {
  await PlayxEnv.load(settings);
} on PlayxEnvException catch (e) {
  print(e.message);        // 'Missing required env keys: API_URL'
  print(e.missingKeys);    // ['API_URL']
}
```

`bootCore` rethrows it, so a misconfigured build fails at startup. Values that did load remain available through `PlayxEnv` even when required keys are missing.

## Inspecting what was loaded

| Member | Meaning |
| --- | --- |
| `PlayxEnv.isLoaded` | Whether values have been loaded. |
| `PlayxEnv.environment` | The resolved environment name, if any. |
| `PlayxEnv.loadedFiles` | The files that were found, in order. |
| `PlayxEnv.all` | Every value **except** secure ones: safe to log. |
| `PlayxEnv.containsKey(key)` | Whether a key has a value (secure keys included). |
| `PlayxEnv.isSecure(key)` | Whether a key holds a [secure value](secure-env.md). |
| `PlayxEnv.values` | The loaded `EnvValues`. |

Reading before `load` returns no values and logs one warning, which usually means `envSettings` was not passed to `bootCore`.

## Loading without `bootCore`

```dart
await PlayxEnv.load(const PlayxEnvSettings(requiredKeys: ['API_URL']));
```

`loadFromString` loads `.env`-formatted text instead of assets, for configuration fetched at runtime or for tests:

```dart
PlayxEnv.loadFromString(
  'API_URL=https://api.example.com\nRETRIES=3',
  mergeWith: {'RETRIES': '5'},
  requiredKeys: ['API_URL'],
);
```

`PlayxEnv.dispose()` clears everything. See [Testing](testing.md) for `setMockValues`.

## Recipes

**Per-environment API URL**

```
# .env            # .env.dev                       # .env.prod
API_URL=https://api.example.com
                  API_URL=https://dev.example.com  API_URL=https://api.prod.example.com
```

```sh
flutter run --dart-define=PLAYX_ENV=dev
```

**A local override that isn't committed**

```dart
const PlayxEnvSettings(additionalFiles: ['.env.local'])
```

Add `.env.local` to `.gitignore` and to your assets while developing. If it isn't there, it is skipped.

**Feature flags from the command line**

```sh
flutter run --dart-define=PLAYX_DEFINES="NEW_CHECKOUT=true;MAX_UPLOADS=5"
```

```dart
if (PlayxEnv.getBool('NEW_CHECKOUT')) { /* ... */ }
```

**Switching the theme from config**

```dart
MaterialApp(
  themeMode: PlayxEnv.getEnum('THEME_MODE', ThemeMode.values, fallback: ThemeMode.system),
);
```

See the [example app](https://github.com/playx-flutter/playx_core/tree/main/example) for a complete project, and [Secure env](secure-env.md) for sensitive values.

---

*Imported from the [playx_core 2.0.0 documentation](https://github.com/playx-flutter/playx_core/blob/main/doc/env.md). [Package site](https://playx-flutter.github.io/playx_core/) · [pub.dev](https://pub.dev/packages/playx_core).*
