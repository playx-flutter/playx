# Preferences

`playx_core` wraps the [`shared_preferences`](https://pub.dev/packages/shared_preferences) plugin in three static helpers with the same typed API. They store plain (unencrypted) values; for secrets use [secure preferences](secure-prefs.md).

## Which one should I use?

| | `PlayxPrefs` | `PlayxAsyncPrefs` | `PlayxPrefsWithCache` |
| --- | --- | --- | --- |
| Backed by | `SharedPreferences` | `SharedPreferencesAsync` | `SharedPreferencesWithCache` |
| Reads | synchronous | `Future` | synchronous (from a cache) |
| Writes | `Future<void>` | `Future<void>` | `Future<void>` |
| Always reads the latest platform value | no (in-memory snapshot) | **yes** | no, until `reloadCache()` |
| Created at boot | by default | by default | opt-in (`createPlayxPrefsWithCache`) |

- **`PlayxPrefs`** is the simplest choice: read values synchronously in `build` methods or `initState`.
- **`PlayxAsyncPrefs`** always asks the platform, so it is the right choice when other isolates, processes or native code may change the same preferences.
- **`PlayxPrefsWithCache`** reads synchronously from a cache that can be limited to an allow list, and refreshed with `reloadCache()`.

> The three stores are independent: a value saved with one is not guaranteed to be visible to the others. Pick one per kind of data.

## Setting up

`bootCore` creates them according to `PlayxPrefsSettings`:

```dart
await PlayxCore.bootCore(
  prefsSettings: const PlayxPrefsSettings(
    createPlayxPrefs: true,            // default
    createPlayxAsyncPrefs: true,       // default
    createPlayxPrefsWithCache: true,   // default: false
    prefsWithCacheOptions: SharedPreferencesWithCacheOptions(
      allowList: {'theme', 'locale'},  // optional: only cache these keys
    ),
  ),
);
```

Or create one yourself: `await PlayxPrefs.create();`.

Using a store that hasn't been created is safe for reads (they return `null` or the fallback) and throws an `Exception` for the `sharedPrefs` getter.

## Reading and writing

All three classes offer the same methods. `PlayxPrefs` and `PlayxPrefsWithCache` return values directly; `PlayxAsyncPrefs` returns `Future`s.

| Type | Read (`null` if missing) | Read with fallback (default) | Write |
| --- | --- | --- | --- |
| `String` | `maybeGetString(key)` | `getString(key, fallback: '')` | `setString(key, value)` |
| `int` | `maybeGetInt(key)` | `getInt(key, fallback: -1)` | `setInt(key, value)` |
| `double` | `maybeGetDouble(key)` | `getDouble(key, fallback: -1)` | `setDouble(key, value)` |
| `bool` | `maybeGetBool(key)` | `getBool(key, fallback: false)` | `setBool(key, value)` |

```dart
// PlayxPrefs: synchronous reads.
await PlayxPrefs.setString('name', 'John Doe');
await PlayxPrefs.setInt('age', 25);

final name = PlayxPrefs.getString('name');                 // 'John Doe'
final age = PlayxPrefs.getInt('age');                      // 25
final height = PlayxPrefs.maybeGetDouble('height');        // null
final darkMode = PlayxPrefs.getBool('dark', fallback: true);

// PlayxAsyncPrefs: awaited reads.
await PlayxAsyncPrefs.setString('token', 'abc');
final token = await PlayxAsyncPrefs.getString('token');
```

Reads never throw: a missing key, a value of another type, or a store that isn't initialized all give `null` (`maybeGet*`) or the fallback (`get*`).

### Other operations

```dart
PlayxPrefs.find('name');            // the raw value (Object?), or null
await PlayxPrefs.remove('name');    // delete one key
await PlayxPrefs.clear();           // delete everything in this store
await PlayxPrefs.dispose();         // forget the instance (mostly for tests)

await PlayxPrefsWithCache.reloadCache();   // refresh the cache from the platform
```

On `PlayxAsyncPrefs`, `find` returns a `Future<Object?>`.

## Maps, lists and objects

Every preference class (including [`PlayxSecurePrefs`](secure-prefs.md)) can store structured data. Values are saved as JSON strings.

| | Read (`null` if unusable) | Read with fallback | Write |
| --- | --- | --- | --- |
| Map | `maybeGetMap(key)` | `getMap(key, fallback: {})` | `setMap(key, map)` |
| List | `maybeGetList<T>(key, fromJson:)` | `getList<T>(key, fallback: [], fromJson:)` | `setList<T>(key, list, toJson:)` |
| Object | `maybeGetObject<T>(key, fromJson:)` | `getObject<T>(key, fromJson:, fallback:)` | `setObject<T>(key, value, toJson:)` |

```dart
// Maps
await PlayxPrefs.setMap('settings', {'theme': 'dark', 'fontSize': 14});
final settings = PlayxPrefs.getMap('settings');            // Map<String, dynamic>

// Lists of JSON values need no converters...
await PlayxPrefs.setList('ids', [1, 2, 3]);
final ids = PlayxPrefs.getList<int>('ids');                // [1, 2, 3]

// ...lists of your own types do.
await PlayxAsyncPrefs.setList('users', users, toJson: (u) => u.toJson());
final saved = await PlayxAsyncPrefs.getList(
  'users',
  fromJson: User.fromJson,
);

// Single objects
await PlayxSecurePrefs.setObject('user', user, toJson: (u) => u.toJson());
final user = await PlayxSecurePrefs.maybeGetObject(
  'user',
  fromJson: User.fromJson,
);
```

`fromJson` receives the decoded JSON (`dynamic`), so the [safe JSON helpers](utilities.md#safe-json-access) work well there:

```dart
class User {
  final String name;
  final int age;
  const User(this.name, this.age);

  factory User.fromJson(dynamic json) =>
      User(asString(json, 'name'), asIntOr(json, 'age'));

  Map<String, dynamic> toJson() => {'name': name, 'age': age};
}
```

**What happens with bad data**

- `maybeGet*` returns `null` and `get*` returns its fallback when the key is missing, the stored string isn't valid JSON, has another shape (for example a list where a map is expected), an item can't be converted, or `fromJson` throws.
- `setMap` and `setList` without `toJson` accept JSON values and objects with a `toJson()` method. Anything else (for example a `DateTime`) throws a `JsonUnsupportedObjectError`, so convert it first.

## Tips

- Prefer a few well-named keys; consider a constants class (`abstract class PrefKeys { static const theme = 'theme'; }`).
- Store small settings, not large documents or binary data.
- Writes return a `Future`; `await` them when the next read depends on the write (for `PlayxPrefsWithCache` and `PlayxPrefs` the in-memory value updates immediately).
- To observe changes in a UI, keep the value in your state management and write through to preferences.

See also: [Testing](testing.md) for `setMockInitialValues`, [Secure preferences](secure-prefs.md) for encrypted storage.

---

*Imported from the [playx_core 2.0.0 documentation](https://github.com/playx-flutter/playx_core/blob/main/doc/preferences.md). [Package site](https://playx-flutter.github.io/playx_core/) · [pub.dev](https://pub.dev/packages/playx_core).*
