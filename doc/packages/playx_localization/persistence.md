
# Persistence

The selected locale is saved when `saveLocale` is `true` (the default) and restored on
the next `boot`.

```dart
PlayxLocaleConfig(
  supportedLocales: locales,
  saveLocale: false, // don't persist
)
```

## What is saved

- The **id** of the selected `XLocale`. Reordering, adding or removing locales in an app
  update does not restore the wrong language.
- A marker when the app follows the device locale (`updateToDeviceLocale`).

On boot the app starts with, in this order:

1. The saved locale.
2. `startLocale` (unless the app follows the device).
3. The device locale, if supported.
4. The fallback locale.

If the saved locale was removed in an update, the saved choice is dropped and steps 2 to
4 apply.

!!! warning
    Keep `XLocale.id` values unique and stable between app versions.

Writes are applied in the order the switches were requested, so when locales are
changed quickly the last requested one is the one that is saved.

## Custom storage

By default the value is stored with `SharedPreferencesAsync`. Implement
`PlayxLocaleStorage` to keep it anywhere (secure storage, Hive, a backend, ...):

```dart
class MyLocaleStorage implements PlayxLocaleStorage {
  const MyLocaleStorage();

  @override
  Future<int?> getInt(String key) async => ...;

  @override
  Future<void> setInt(String key, int value) async => ...;

  @override
  Future<String?> getString(String key) async => ...;

  @override
  Future<void> setString(String key, String value) async => ...;

  @override
  Future<void> remove(String key) async => ...;
}

PlayxLocaleConfig(
  supportedLocales: locales,
  storage: const MyLocaleStorage(),
)
```

`PlayxMemoryLocaleStorage` keeps everything in memory, which is handy in tests.

## Clearing

```dart
await PlayxLocalization.deleteSavedLocale(); // forget the saved choice
await PlayxLocalization.resetLocale();       // forget it and go back to the default locale
```

## Migrating from older versions

Nothing to do. Versions before 1.0 saved the **position** of the locale in
`supportedLocales`. On the first start of 1.0 that position is read once and rewritten as
an id, and the app continues with the same language. The old key is still written, so a
downgrade keeps working. The "follow the device" choice of 0.4 is migrated as well.

If your app used `SharedPreferences` (not the async API) before 0.2, set
`migratePrefsToAsync: true` once to move that value over.

---

*Imported from the [playx_localization 1.0.0 documentation](https://github.com/playx-flutter/playx_localization/blob/main/doc/persistence.md). [Package site](https://playx-flutter.github.io/playx_localization/) · [pub.dev](https://pub.dev/packages/playx_localization).*
