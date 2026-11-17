# PlayX Core documentation

Detailed guides for every part of `playx_core`. For a quick overview, see the [package README](https://github.com/playx-flutter/playx_core#readme); for the API reference of every class and method, see the [API documentation](https://pub.dev/documentation/playx_core/latest/).

## Start here

| Guide | What it covers |
| --- | --- |
| [Getting started](getting-started.md) | Requirements, installation, `PlayxCore.bootCore`, GetIt, disposing, project layout. |
| [Migrating to 2.0](migration-2.0.md) | Every breaking change from 1.x, with before/after code. |

## Storage

| Guide | What it covers |
| --- | --- |
| [Preferences](preferences.md) | `PlayxPrefs`, `PlayxAsyncPrefs`, `PlayxPrefsWithCache`: which to pick, typed getters, maps, lists and objects. |
| [Secure preferences](secure-prefs.md) | `PlayxSecurePrefs`: backends, `auto` fallback, hiding key names, web, migration, failure handling. |

## Configuration

| Guide | What it covers |
| --- | --- |
| [Environment configuration](env.md) | `PlayxEnv`: `.env` files, environments and flavors, `--dart-define`, typed getters, required keys. |
| [Secure env](secure-env.md) | Encrypting sensitive values with the `secure_env` command, CI/CD setup, threat model. |

## Utilities

| Guide | What it covers |
| --- | --- |
| [Extensions](extensions.md) | `String`, `Iterable`, `DateTime`, `Duration`, `Color`, `bool`, `Locale`, `BuildContext`, padding and border helpers. |
| [Utilities](utilities.md) | Safe type conversion, JSON access, `MapUtils`, system UI helpers, platform checks, `WebUtils`. |
| [Logging](logging.md) | `PlayxLogger` and its settings. |

## Quality

| Guide | What it covers |
| --- | --- |
| [Testing](testing.md) | Mocking storage, env and platform channels in your own tests. |
| [CI/CD samples](https://github.com/playx-flutter/playx_core/tree/main/doc/ci) | Ready-made Codemagic, GitHub Actions and Vercel configurations. |

## Example app

The [example app](https://github.com/playx-flutter/playx_core/tree/main/example) is a runnable project using `PlayxPrefs` and `PlayxEnv` with environments, build-time defines and secure env.

## Conventions used in these guides

- **`maybeGet*` and `get*`.** Every typed getter in the package comes in two forms: `maybeGetX(key)` returns `null` when there is no usable value, and `getX(key, fallback: ...)` returns a default instead.
- **Unscaled numbers.** Layout helpers such as `16.p` use the raw number. Apps using a scaling package (for example `flutter_screenutil`) scale the number first: `16.r.p`.
- **Examples assume** `import 'package:playx_core/playx_core.dart';`, which exports everything documented here.

---

*Imported from the [playx_core 2.0.0 documentation](https://github.com/playx-flutter/playx_core/blob/main/doc/README.md). [Package site](https://playx-flutter.github.io/playx_core/) · [pub.dev](https://pub.dev/packages/playx_core).*
