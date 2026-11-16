# Secure preferences

`PlayxSecurePrefs` stores small secrets (tokens, keys, credentials) encrypted at rest. It has the same typed API as the [other preference stores](preferences.md), but every operation is asynchronous, and you choose **where** the data lives.

- [Quick start](#quick-start)
- [Choosing a backend](#choosing-a-backend)
- [Settings reference](#settings-reference)
- [The `auto` backend](#the-auto-backend)
- [Encrypted preferences](#encrypted-preferences)
- [Hiding key names](#hiding-key-names-encryptkeys)
- [Web](#web)
- [Switching an existing app](#switching-an-existing-app-from-flutter_secure_storage)
- [Errors and failures](#errors-and-failures)
- [Security notes](#security-notes)

## Quick start

`PlayxCore.bootCore` creates it with the default settings:

```dart
await PlayxCore.bootCore();

await PlayxSecurePrefs.setString('access_token', 'abc123');
final token = await PlayxSecurePrefs.getString('access_token');
final missing = await PlayxSecurePrefs.maybeGetString('nope');   // null

await PlayxSecurePrefs.remove('access_token');
await PlayxSecurePrefs.clear();
```

Typed values and structured data work like the other stores:

```dart
await PlayxSecurePrefs.setInt('attempts', 3);
await PlayxSecurePrefs.setBool('biometrics', true);
await PlayxSecurePrefs.setDouble('balance', 12.5);
await PlayxSecurePrefs.setMap('session', {'id': 7, 'role': 'admin'});
await PlayxSecurePrefs.setObject('user', user, toJson: (u) => u.toJson());
```

| Type | Read (`null` if missing) | Read with fallback | Write |
| --- | --- | --- | --- |
| `String` | `maybeGetString` | `getString` (`''`) | `setString` |
| `int` | `maybeGetInt` | `getInt` (`-1`) | `setInt` |
| `double` | `maybeGetDouble` | `getDouble` (`-1`) | `setDouble` |
| `bool` | `maybeGetBool` | `getBool` (`false`) | `setBool` |
| Map / List / Object | `maybeGetMap`, `maybeGetList`, `maybeGetObject` | `getMap`, `getList`, `getObject` | `setMap`, `setList`, `setObject` |

Numbers and bools are stored as strings and parsed back; a value that can't be parsed reads as `null` (so `getBool` returns its fallback). See [Preferences](preferences.md#maps-lists-and-objects) for maps, lists and objects.

Other members:

| Member | Purpose |
| --- | --- |
| `PlayxSecurePrefs.storageType` | The backend actually in use, e.g. after an `auto` fallback. |
| `PlayxSecurePrefs.isInitialized` | Whether `create` has been called. |
| `PlayxSecurePrefs.securePrefs` | The underlying `FlutterSecureStorage` instance (always created). |
| `PlayxSecurePrefs.create(securePrefsSettings:)` | Create it yourself instead of through `bootCore`. |
| `PlayxSecurePrefs.dispose()` | Release it (mostly for tests). |
| `PlayxSecurePrefs.migrateFromFlutterSecureStorage()` | Move data from `flutter_secure_storage`. See [below](#switching-an-existing-app-from-flutter_secure_storage). |

## Choosing a backend

Select it with `PlayxSecurePrefsSettings.storageType`. The API stays the same whichever you pick.

| `PlayxSecureStorageType` | Stores values in | Notes |
| --- | --- | --- |
| `flutterSecureStorage` (default) | [`flutter_secure_storage`](https://pub.dev/packages/flutter_secure_storage): Keystore-backed storage on Android, Keychain on iOS and macOS, DPAPI on Windows, libsecret on Linux | The default of previous versions. No startup health check. |
| `simpleSecureStorage` | [`simple_secure_storage`](https://pub.dev/packages/simple_secure_storage): the same native stores through a different, actively maintained plugin | Initialization errors are thrown (unless `throwOnError: false`). |
| `encryptedPrefs` | `SharedPreferencesAsync`, each value encrypted with AES-256-GCM | The key lives in a secure store, with a fallback. Works anywhere preferences work. |
| `auto` | The first healthy backend of `autoOrder` | **Recommended** when you want the app to keep working on devices where a plugin fails. |
| `memory` | A map in memory | Nothing survives a restart. For tests, or as a last resort. |

```dart
await PlayxCore.bootCore(
  securePrefsSettings: const PlayxSecurePrefsSettings(
    storageType: PlayxSecureStorageType.auto,
  ),
);
```

**Which should I pick?**

- *Existing app, no problems with `flutter_secure_storage`:* keep the default.
- *Seeing plugin errors or crashes on some devices:* use `auto` with `simple_secure_storage` first. Data in the old store can be moved with [`migrateFromFlutterSecureStorage`](#switching-an-existing-app-from-flutter_secure_storage).
- *Web:* nothing to choose; every type except `memory` uses [WebCrypto](#web).
- *Tests:* `memory`.

## Settings reference

### `PlayxSecurePrefsSettings`

| Option | Default | Meaning |
| --- | --- | --- |
| `storageType` | `flutterSecureStorage` | The backend. |
| `autoOrder` | `[simpleSecureStorage, flutterSecureStorage, encryptedPrefs]` | Order `auto` tries backends in. Only these three types are allowed; `memory` is always the last resort. The first entry is the *preferred* backend. |
| `throwOnError` | `true` | When `false`, errors are logged instead of thrown: reads return `null`, writes are ignored, and `memory` is used if the backend can't be created. |
| `encryptKeys` | `false` | Hide key names. See [below](#hiding-key-names-encryptkeys). |
| `flutterSecureStorageOptions` | defaults | Platform options for `flutter_secure_storage`. |
| `simpleSecureStorageOptions` | defaults | Options for `simple_secure_storage`. |
| `encryptedPrefsOptions` | defaults | Options for `encryptedPrefs`. |
| `clearOnReinstall` | `true` | Clear the store on the first start after a reinstall (the iOS and macOS Keychain survives uninstalling). |
| `createSecurePrefs` | `true` | Whether `bootCore` creates it. |

### `PlayxFlutterSecureStorageOptions`

Groups the native `flutter_secure_storage` options: `iosOptions`, `androidOptions`, `linuxOptions`, `windowsOptions`, `macOsOptions`. Defaults use `KeychainAccessibility.first_unlock` on iOS.

```dart
const PlayxSecurePrefsSettings(
  flutterSecureStorageOptions: PlayxFlutterSecureStorageOptions(
    iosOptions: IOSOptions(accessibility: KeychainAccessibility.unlocked),
  ),
);
```

### `PlayxSimpleSecureStorageOptions`

| Option | Default | Meaning |
| --- | --- | --- |
| `appName` | `null` | Your app name, used by the plugin on some platforms. |
| `namespace` | `null` | Your app namespace, e.g. `com.example.app`. |
| `prefix` | `'sss_'` | Prepended to every key to avoid conflicts. |
| `darwinAccessibility` | `afterFirstUnlock` | Keychain accessibility on iOS and macOS. |

### `PlayxEncryptedPrefsOptions`

| Option | Default | Meaning |
| --- | --- | --- |
| `keyPrefix` | `'playx_secure_'` | Prefix of every key stored in preferences. It isolates secure values from your other preferences, so `clear()` only removes keys with this prefix. Must not be empty. |
| `keyStores` | `[simpleSecureStorage, flutterSecureStorage]` | Where the encryption key is kept, in order of preference. Only these two are allowed. |

## The `auto` backend

`auto` picks a backend **at every start**:

1. For each type in `autoOrder`, it creates the backend and runs a **health check**: write a random value, read it back, delete it.
2. The first backend that passes is used. Failures are logged, not thrown.
3. If none passes, it uses `memory`, so the app still starts (nothing is persisted that session).

```dart
// Prefer simple_secure_storage, fall back to encrypted preferences.
const PlayxSecurePrefsSettings(
  storageType: PlayxSecureStorageType.auto,
  autoOrder: [
    PlayxSecureStorageType.simpleSecureStorage,
    PlayxSecureStorageType.encryptedPrefs,
  ],
);
```

### Data follows the preferred backend

If a fallback was used in one session, `auto` keeps a small journal (in preferences) of what happened, so the data can be moved to the preferred backend on a later start where it works again:

- values written during the fallback are moved back;
- values removed during the fallback stay removed;
- a `clear()` during the fallback (for example a logout) is applied to the preferred backend too;
- an older fallback value never overwrites a newer one.

The journal contains key names and backend names, never values. With `encryptKeys: true` it is encrypted as well.

> **Native crashes can't be caught.** Only Dart exceptions trigger a fallback. If a plugin crashes the app natively on some devices, put it last in `autoOrder` or remove it.

## Encrypted preferences

`encryptedPrefs` encrypts each value with **AES-256-GCM** (with a random nonce per value, and authentication, so tampering is detected) and saves it in `SharedPreferencesAsync`. Two keys are involved:

- **The primary key**: random bytes generated on the device, kept in the first healthy store of `keyStores` (on web, a [non-extractable WebCrypto key](#web)). A marker in preferences remembers which store holds it.
- **The fallback key**: random bytes kept in plain preferences, used when the primary key can't be loaded. It only **obfuscates** the data: anyone with the preferences file can decrypt it.

Each stored value records which key encrypted it, so values written with the fallback key stay readable once the primary key is back.

### Protecting the primary key

The key is never discarded while values encrypted with it may still be readable:

| Situation | What happens |
| --- | --- |
| The key store is unavailable this session | The fallback key is used; the stored key is left untouched. |
| The key store works but the key reads back missing or invalid | The fallback key is used; the stored key is **not** replaced. |
| It stays missing for **3 starts in a row** (for example the Android Keystore was reset) | The key is considered lost: values encrypted with it are removed (they can't be decrypted anymore) and a new key is created. |
| The key is missing and there is no data that needs it | A new key is created right away. |
| A key store is removed from `keyStores` later | An existing key is still read from where it was created; `keyStores` only decides where **new** keys go. |

## Hiding key names (`encryptKeys`)

Encrypting values doesn't hide **key names** such as `access_token`: some stores keep them readable in files. Enable `encryptKeys` to store each value under a keyed hash (HMAC-SHA256) of its name instead:

```dart
const PlayxSecurePrefsSettings(
  storageType: PlayxSecureStorageType.auto,
  encryptKeys: true,
);
```

| Storage | Names with `encryptKeys: true` |
| --- | --- |
| `encryptedPrefs` (every platform, so all of web) | Hidden; only `keyPrefix` stays visible |
| `flutterSecureStorage` on Android | Hidden (otherwise plain text in a private preferences file) |
| `simpleSecureStorage` on Android | Already encrypted by the plugin |
| iOS and macOS Keychain | Kept by the OS, out of app files |
| Windows and Linux credential stores | Not hidden |

How it works:

- The hash key is kept in secure storage (the keystore, or a non-extractable WebCrypto key on web), so names can't be guessed from the files alone.
- The real name is stored **inside** the encrypted value, so `readAll`, migrations and recovery keep working.
- It can be turned on or off at any time: stored values are converted on the next start. For `flutter_secure_storage` the conversion happens lazily on first use, so startup does no extra work.
- If the primary key is unavailable for a session, names are hashed with the fallback key; each entry carries a timestamp, so the newest value wins once the primary key is back, and removals made meanwhile are applied.
- Values you write directly to `PlayxSecurePrefs.securePrefs` bypass playx and keep plain names. playx still reads them as a fallback.

## Web

On web every storage type except `memory` uses `encryptedPrefs` with a **non-extractable WebCrypto key** stored in IndexedDB:

- Nothing secret ships with your app: there is no password, salt or key to configure.
- Scripts can use the key while the page runs, but the browser never lets them read or export its bytes. Stored data can't be decrypted on another machine or offline.
- Values saved by 1.x (which used `flutter_secure_storage` on web) are migrated automatically on the first start.

What it doesn't protect against: code running in your page (for example XSS) and full access to the user's browser profile. For auth tokens on web, prefer `HttpOnly` cookies set by your server.

## Switching an existing app from `flutter_secure_storage`

Values saved with the default backend stay in `flutter_secure_storage`. After changing `storageType`, copy them over:

```dart
await PlayxCore.bootCore(
  securePrefsSettings: const PlayxSecurePrefsSettings(
    storageType: PlayxSecureStorageType.auto,
  ),
);

// Safe to call on every start: once the source is empty it does nothing.
final moved = await PlayxSecurePrefs.migrateFromFlutterSecureStorage();
```

| Parameter | Default | Meaning |
| --- | --- | --- |
| `from` | `PlayxSecurePrefs.securePrefs` | The `FlutterSecureStorage` holding the data. Pass your own instance if it was created with custom options. |
| `deleteFromSource` | `true` | Delete migrated values from `flutter_secure_storage` afterwards. |

- Keys that already exist in the new backend are kept, because they are newer.
- It returns the number of values copied, and `0` when the current backend is `flutterSecureStorage` itself.
- It understands entries whose names were hidden by `encryptKeys`, and skips playx's own internal keys.
- It **reads** `flutter_secure_storage`, so it runs into any native crash that plugin has on a device. If that is why you are switching, consider doing the migration once, behind your own guard.

## Errors and failures

By default errors are thrown to your code. Set `throwOnError: false` for the lenient behavior:

```dart
const PlayxSecurePrefsSettings(throwOnError: false);
```

| | `throwOnError: true` (default) | `throwOnError: false` |
| --- | --- | --- |
| Read fails | throws | logs, returns `null` / the fallback |
| Write, remove or clear fails | throws | logs, does nothing |
| Backend can't be created | `create` throws | logs, uses `memory` |
| Value can't be decrypted (`encryptedPrefs`) | returns `null` (always) | returns `null` |

`auto` and `encryptedPrefs` never throw because a storage is unavailable: they end up on `memory`. Failures are written to the `PLAYX CORE` logger (see [Logging](logging.md)).

## Security notes

- **What is protected.** Values at rest on the device. Other apps and casual file access can't read them.
- **What isn't.** A rooted or compromised device, a debugger attached to your running app, and values while they are in memory.
- **The fallback key is obfuscation**, not secrecy. Treat sessions that use it as lower assurance, and prefer a backend that passes its health check.
- **Don't store what you can avoid storing.** Refresh tokens and short-lived credentials are good fits; long-lived secrets shared by all users belong on your server.

See also: [Preferences](preferences.md), [Secure env](secure-env.md) (for secrets that ship *with* the app), [Testing](testing.md).

---

*Imported from the [playx_core 2.0.0 documentation](https://github.com/playx-flutter/playx_core/blob/main/doc/secure-prefs.md). [Package site](https://playx-flutter.github.io/playx_core/) · [pub.dev](https://pub.dev/packages/playx_core).*
