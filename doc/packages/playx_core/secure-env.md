# Secure env

Secure env keeps sensitive configuration values (API keys, client secrets, DSNs) **out of plain sight** in your shipped app. You write them in a normal gitignored file, a command encrypts them into a generated Dart file, and `PlayxEnv` decrypts them in memory at startup.

- [What it protects (and what it doesn't)](#what-it-protects-and-what-it-doesnt)
- [Quick start](#quick-start)
- [How it works](#how-it-works)
- [Writing the secrets files](#writing-the-secrets-files)
- [The `secure_env` command](#the-secure_env-command)
- [Keys](#keys)
- [CI/CD](#cicd)
- [Encrypted define](#encrypted-define-playx_secure_defines)
- [At runtime](#at-runtime)
- [Troubleshooting](#troubleshooting)

## What it protects (and what it doesn't)

Plain `.env` assets and `--dart-define` values end up in your app as readable text. Anyone can unzip an APK or IPA, run `strings` on the binary, open browser devtools on a web build, or point an automated scanner at it, and read them.

Secure env removes that: **names and values are encrypted together and stored as numbers**, never as strings, so none of those techniques find anything.

| Threat | Protected? |
| --- | --- |
| Unzipping the app, `strings`, asset inspection | **Yes** |
| Automated scanners that look for API keys in published apps | **Yes** |
| Secrets committed to git by accident | **Yes**: only the encrypted file and the (gitignored) key exist |
| Someone reverse engineering your app with a debugger or decompiler | **No**: the app has to decrypt the values itself, so the key ships with it |

> **The honest limit:** anything an app can decrypt on its own, a determined attacker who has the app can decrypt too. Secure env raises the bar from "anyone with unzip" to "a motivated reverse engineer". For keys that would cause real damage if leaked, don't put them in the app at all: keep them on your server (or a serverless function) and let the app call that instead.

## Quick start

**1. Put secrets in a gitignored file.**

```
# .env.secrets
STRIPE_KEY=pk_test_123
MAPS_API_KEY=AIza...
```

**2. Generate the encrypted Dart file.**

```sh
dart run playx:secure_env
```

> Apps using the `playx` package run `dart run playx:secure_env`; apps depending on `playx_core` only run `dart run playx_core:secure_env`. Both take the same options. The examples in this guide use `playx:secure_env`.

This writes `lib/generated/playx_secure_env.g.dart` and creates a key in `.playx_secure_env.key`.

**3. Ignore the secrets and the key.**

```
# .gitignore
.env.secrets*
.playx_secure_env.key
lib/generated/playx_secure_env.g.dart
secure_defines.json
```

**4. Pass the generated value to `PlayxEnv`.**

```dart
import 'generated/playx_secure_env.g.dart';

await PlayxCore.bootCore(
  envSettings: const PlayxEnvSettings(
    secureEnv: playxSecureEnv,
    requiredKeys: ['STRIPE_KEY'],
  ),
);

PlayxEnv.getString('STRIPE_KEY');   // 'pk_test_123'
PlayxEnv.isSecure('STRIPE_KEY');    // true
```

Secure values use the same getters as every other value (`getString`, `getInt`, `getUri`…), see [Environment configuration](env.md#reading-values).

## How it works

```
.env.secrets  ──►  secure_env command  ──►  playx_secure_env.g.dart  ──►  PlayxEnv.load()
 (gitignored)       AES-256-GCM            encrypted blob + split key     decrypts in memory
```

- **One encrypted blob.** The whole map (names and values) is serialized, then encrypted with **AES-256-GCM** under a fresh random nonce. GCM also authenticates the data, so tampering is detected.
- **Stored as numbers.** The generated file holds the blob as integer lists, so nothing appears as a string in the compiled app.
- **Split key.** The key is stored as two byte lists that are XOR-ed back together at runtime, so it never appears as one contiguous value. (This is obfuscation, see [the limit above](#what-it-protects-and-what-it-doesnt).)
- **Layering.** Secure values are applied after the `.env` files and before `mergeWith`, `PLAYX_DEFINES` and `dartDefines`, so those can still override a secret, for example for local testing. See [How values are layered](env.md#how-values-are-layered).
- **Hidden from dumps.** Secure values are excluded from `PlayxEnv.all`, so logging your configuration doesn't leak them. The getters still return them.

## Writing the secrets files

Secrets files use the same syntax as [`.env` files](env.md#file-syntax): comments, quotes, `export`, and `$VAR` references.

| File | Purpose |
| --- | --- |
| `.env.secrets` | Secrets for every environment. |
| `.env.secrets.<env>` | Secrets for one environment, overriding the base file. Read when `--env <env>` is passed. |

```
# .env.secrets                  # .env.secrets.prod
STRIPE_KEY=pk_test_123          STRIPE_KEY=pk_live_987
MAPS_API_KEY=AIza-dev
```

```sh
dart run playx:secure_env --env prod
```

generates a file for `prod` containing `STRIPE_KEY=pk_live_987` and `MAPS_API_KEY=AIza-dev`. A build only contains the secrets of the environment it was generated for, so a production build never ships development secrets.

Regenerate the file whenever you change a secrets file or switch environment.

## The `secure_env` command

```
dart run playx:secure_env [command] [options]
```

### Commands

| Command | Does |
| --- | --- |
| `generate` (default) | Writes the encrypted Dart file used with `PlayxEnvSettings(secureEnv: playxSecureEnv)`. |
| `define` | Prints (or writes with `--out`) the encrypted value of the `PLAYX_SECURE_DEFINES` define. See [below](#encrypted-define-playx_secure_defines). |
| `generate-key` | Prints a new random key, for example to store as a CI secret. |
| `--help` | Shows all options. |

### Where values come from

Sources are applied in this order; later ones override earlier ones.

| Option | Meaning |
| --- | --- |
| `--input <file>` | The secrets file. Default `.env.secrets`. A missing explicit input is an error. |
| `--env <name>` | Also read `<input>.<name>`. Defaults to the `PLAYX_ENV` environment variable. |
| `--no-file` | Don't read secrets files (CI with variables only). |
| `--from-env A,B` | Read these environment variables. An unset one is an error. |
| `--from-env-prefix P` | Read every environment variable starting with `P`, without the prefix (`PLAYX_SECRET_API_KEY` becomes `API_KEY`). |
| `--define KEY=VALUE` | Add a value. Repeatable. |
| `--allow-empty` | Don't fail when there are no values at all. |

### Key options

| Option | Meaning |
| --- | --- |
| `--key <base64>` | Use this key. |
| `PLAYX_ENV_KEY` | Environment variable holding the key. |
| `--key-file <file>` | Where the key is kept. Default `.playx_secure_env.key`. Created if missing. |
| `--rotate-key` | Create a new key and overwrite the key file. |

The first available of these is used, in this order: `--key`, `PLAYX_ENV_KEY`, the key file; otherwise a new key is generated and saved to the key file.

### Output options

| Option | Meaning |
| --- | --- |
| `--output <file>` | The generated Dart file. Default `lib/generated/playx_secure_env.g.dart`. |
| `--key-from-define` | Don't embed the key; the build passes it with `--dart-define=PLAYX_ENV_KEY=<key>`. See [Keys](#keys). |
| `--import <uri>` | The import used by the generated file. Default `package:playx/playx.dart` when the project depends on `playx`, otherwise `package:playx_core/playx_core.dart`. |
| `--out <file.json>` | `define` only: write a `--dart-define-from-file` JSON file (existing keys in the file are kept). |
| `--verbose` | Print the *names* of the values and the sources used. Never prints values. |

### Behavior worth knowing

- Output never contains secret values. The command prints counts, and key names only with `--verbose`.
- It warns when a secrets file, the key file, or a generated file that embeds the key is **not** in `.gitignore` (when run inside a git repository).
- Exit codes: `0` success, `1` failure (missing input, unset variable, invalid key…), `64` usage error. CI builds therefore fail when something is wrong.
- The generated file starts with `// dart format off`, so formatting your project doesn't expand it into thousands of lines.

## Keys

| Mode | How | Pros | Cons |
| --- | --- | --- | --- |
| **Embedded** (default) | The key is generated once, saved in `.playx_secure_env.key`, and embedded (split) in the generated file. | Nothing to configure at build time. Not visible as a string in the binary. | The generated file contains the key: keep it out of git. |
| **From a define** | `--key-from-define`; build with `--dart-define=PLAYX_ENV_KEY=<key>`. | The generated file holds only ciphertext and can be committed. | `--dart-define` values are compiled into the app as readable strings, so this keeps the key out of **git**, not out of the **app**. |

When both are present, the embedded key is used first.

- **Rotate** with `--rotate-key` and regenerate. Every previously generated file stops working with the new key, so regenerate them all together.
- **Create a key** for CI with `dart run playx:secure_env generate-key`.
- **Reuse a key** across machines by setting `PLAYX_ENV_KEY` (or `--key`) when generating.

## CI/CD

CI machines have no gitignored `.env.secrets`; secrets live in the platform's settings and reach the build as **environment variables**. Run one command before `flutter build`:

```sh
PLAYX_ENV=prod \
PLAYX_SECRET_STRIPE_KEY=... PLAYX_SECRET_MAPS_API_KEY=... \
dart run playx:secure_env --from-env-prefix PLAYX_SECRET_

flutter build appbundle --release
```

- `PLAYX_ENV` selects the environment (and matches the runtime `PLAYX_ENV` define if you use it).
- Every `PLAYX_SECRET_<NAME>` variable becomes `<NAME>`, so **adding a secret is a dashboard change only**, with no edit to the build script.
- The key is created inside the job and embedded in the generated file, which is used by that same build. Nothing else to manage.
- Prefer `--from-env STRIPE_KEY,MAPS_API_KEY` or `--define KEY=VALUE` if you want explicit names.

Ready-made configurations, copy and adapt:

| Platform | File |
| --- | --- |
| Codemagic | [`doc/ci/codemagic.yaml`](https://github.com/playx-flutter/playx_core/blob/main/doc/ci/codemagic.yaml) |
| GitHub Actions | [`doc/ci/github-actions.yml`](https://github.com/playx-flutter/playx_core/blob/main/doc/ci/github-actions.yml) |
| Vercel (Flutter web) | [`doc/ci/vercel.json`](https://github.com/playx-flutter/playx_core/blob/main/doc/ci/vercel.json) and [`doc/ci/vercel-build.sh`](https://github.com/playx-flutter/playx_core/blob/main/doc/ci/vercel-build.sh) |

Any other CI follows the same pattern: expose secrets as `PLAYX_SECRET_*` variables, run the command, then build.

**Web hosts.** A web build is a public JavaScript bundle. Secure env keeps values out of plain sight, but for keys that must stay secret, call a serverless function (for example Vercel `api/`) that holds the key and talks to the third-party service for your app.

## Encrypted define (`PLAYX_SECURE_DEFINES`)

An alternative to the generated file's data: pass the encrypted values as a build define, so they can change without regenerating Dart code.

```sh
dart run playx:secure_env define --from-env-prefix PLAYX_SECRET_ --out secure_defines.json
flutter build apk --dart-define-from-file=secure_defines.json
```

`secure_defines.json` contains only ciphertext:

```json
{ "PLAYX_SECURE_DEFINES": "v1:..." }
```

- The app decrypts it with the same key, which comes from the generated file (generate it in the same job, with the same key) or from `PLAYX_ENV_KEY`.
- Defines override the generated values, so you can ship a base file and adjust per build.
- Disable reading it with `PlayxEnvSettings(useSecureDefines: false)`.
- The define is ciphertext, so finding it in the binary is useless without the key.

Most apps don't need this; the CI flow above is simpler.

## At runtime

| Situation | Behavior |
| --- | --- |
| Normal | Values are decrypted in memory and served by the usual getters. They are excluded from `PlayxEnv.all`. |
| No key available, wrong key, or tampered data | `PlayxEnv.load` throws a `PlayxEnvException` (a build misconfiguration that should fail at startup or in CI). The message never includes values. |
| Generated for another environment | A warning is logged, for example "generated for `prod` but the environment is `dev`". Values are still loaded. |
| A required key is missing after decrypting | `PlayxEnvException` with `missingKeys`. |

## Troubleshooting

| Message | Cause and fix |
| --- | --- |
| `No secret values found` | The secrets file doesn't exist or is empty, and no `--from-env`, `--from-env-prefix` or `--define` supplied values. Create the file, or pass `--allow-empty`. |
| `Input file … not found` | `--input` points at a missing file. |
| `Environment variable X is not set` | A name given to `--from-env` isn't exported in the shell. |
| `Warning: no environment variables start with …` | `--from-env-prefix` matched nothing: check the prefix and that the CI variables are exposed to the step. |
| `Warning: … is not in .gitignore` | Add the file to `.gitignore` before committing. |
| `Secure env values could not be decrypted` | The key in the app doesn't match the data, or the data was altered. Regenerate the file, and make sure `--rotate-key` wasn't run for only some artifacts. |
| `…there is no key` | The generated file was created with `--key-from-define` and the build didn't pass `--dart-define=PLAYX_ENV_KEY=<key>`. |
| `Secure env was generated for "prod" but the environment is "dev"` | You built with a file generated for another environment. Regenerate with the right `--env`. |
| The command isn't found | Use `dart run playx_core:secure_env` when your app depends on `playx_core` only, and `dart run playx:secure_env` when it depends on `playx`. |

See also: [Environment configuration](env.md), the [example app](https://github.com/playx-flutter/playx_core/tree/main/example), and [Testing](testing.md).

---

*Imported from the [playx_core 2.0.0 documentation](https://github.com/playx-flutter/playx_core/blob/main/doc/secure-env.md). [Package site](https://playx-flutter.github.io/playx_core/) · [pub.dev](https://pub.dev/packages/playx_core).*
