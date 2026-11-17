# Utilities

- [Safe conversion](#safe-conversion)
- [Safe JSON access](#safe-json-access)
- [MapUtils and mapAsync](#maputils-and-mapasync)
- [System UI helpers](#system-ui-helpers)
- [Clipboard](#clipboard)
- [Platform checks](#platform-checks)
- [WebUtils](#webutils)
- [Colors](#colors)
- [Scroll behavior](#scroll-behavior)

## Safe conversion

Functions that turn an unknown value (`dynamic`, for example from JSON or a map) into a typed one **without throwing** unless you ask them to. Every type has three forms:

| Form | Returns |
| --- | --- |
| `toXOrNull(value)` | the converted value, or `null` |
| `toXOr(value, fallback: …)` | the converted value, or the fallback |
| `toX(value)` | the converted value, or throws a `FormatException` |

| Type | Functions | Converts |
| --- | --- | --- |
| `int` | `toIntOrNull`, `toIntOr` (`0`), `toInt` | `int`, `double` (truncated), `bool` (`1`/`0`), numeric `String` (`"3.9"` → `3`) |
| `num` | `toNumOrNull`, `toNumOr`, `toNum` | `num`, `bool`, numeric `String` |
| `double` | `toDoubleOrNull`, `toDoubleOr` (`0.0`), `toDouble` | `double`, `int`, `bool`, numeric `String` |
| `bool` | `toBoolOrNull`, `toBoolOr`, `toBool` | `bool`, `1`/`0`, `'true'`/`'false'`/`'1'`/`'0'` (case-insensitive). Anything else is `null`. |
| `String` | `toStringOrNull`, `toStringOr`, `toString` | `String`, `bool`, `num` |
| `DateTime` | `toDateTimeOrNull`, `toDateTimeOr`, `toDateTime` | `DateTime`, ISO-8601 `String`, epoch milliseconds (`int`) |
| local `DateTime` | `toLocalDateTimeOrNull`, `toLocalDateTimeOr`, `toLocalDateTime` | same, converted to local time; see `utcOffset` below |
| `Map<K, V>` | `toMapOrNull`, `toMapOr`, `toMap` | a `Map<K, V>` (or an empty map) |
| `List<T>` | `toListOrNull`, `toListOr`, `toList` | a `List<T>`; with `fromJson`, each item is converted |
| enum | `toEnumOrNull(value, Mode.values)`, `toEnumOr`, `toEnum` | the enum value whose name matches, case-insensitive |
| `Uri` | `toUriOrNull`, `toUriOr`, `toUri` | `Uri` or a parseable `String` |
| any `T` | `toTOrNull(value, fromJson:)`, `toTOr`, `toT` | runs your `fromJson`; errors become `null` |

```dart
toIntOrNull('42');                          // 42
toIntOrNull('abc');                         // null
toIntOr('abc', fallback: -1);               // -1
toBoolOrNull('TRUE');                       // true
toBoolOrNull('maybe');                      // null
toEnumOrNull('dark', Mode.values);          // Mode.dark
toListOrNull<int>(['1', '2'], fromJson: (e) => int.parse(e as String));  // [1, 2]
toUri('https://example.com');
toInt('abc');                               // throws FormatException
```

### Dates in a fixed time zone

Servers often send local times without a zone, such as `2024-05-01 10:00:00` in Saudi time. Pass the zone's offset to read them correctly:

```dart
const saudi = Duration(hours: 3);
toLocalDateTime('2024-05-01 10:00:00', utcOffset: saudi);   // 07:00 UTC, shown in local time
```

Values that already carry a zone (`Z`, `+03:00`) and epoch integers are absolute and unaffected by `utcOffset`. Without it, a value without a zone is read as local time.

## Safe JSON access

The same conversions, reading a **key** from decoded JSON. Functions are named `asX`, with the same three forms (`asXOrNull`, `asXOr`, `asX`):

```dart
final json = jsonDecode(body);

final name = asString(json, 'name');                       // throws if missing
final age = asIntOr(json, 'age', fallback: 0);
final city = asStringOrNull(json, 'address.city');         // nested key
final firstTag = asStringOrNull(json, 'tags.0');           // list index
final created = asDateTimeOrNull(json, 'createdAt');
final mode = asEnumOr(json, 'mode', Mode.values, fallback: Mode.light);
final tags = asListString(json, 'tags');
final scores = asListInt(json, 'scores');                  // [1, '2', 3.0] -> [1, 2, 3]
final settings = asMapOrNull<String, dynamic>(json, 'settings');
final owner = asTOrNull<User>(json, 'owner', fromJson: User.fromJson);
```

- **Nested keys** use dot notation and list indexes (`'data.users.0.name'`). A key that literally contains a dot is matched first, so `{'a.b': 1}` still works.
- Available types: `int`, `double`, `num`, `bool`, `String`, `DateTime` (and local), enums, `Uri`, `Map`, `List`, `List<int>`, `List<String>`, and any `T` through `asT*`.
- A missing key, a `null` json, or a value that can't be converted all give `null` / the fallback (or a `FormatException` for the throwing form).
- `asLocalDateTime*` accept `utcOffset`, like the `to*` versions.

This pairs well with `fromJson` factories:

```dart
factory User.fromJson(dynamic json) => User(
      name: asString(json, 'name'),
      age: asIntOr(json, 'age'),
      email: asStringOrNull(json, 'contact.email'),
    );
```

## MapUtils and mapAsync

Run a mapping function asynchronously, optionally in an isolate, with built-in error handling.

```dart
// Asynchronously, in the current isolate
final dto = await MapUtils.mapAsync<String, User>(
  data: body,
  mapper: (body) => User.fromJson(jsonDecode(body)),
);

// In an isolate: keeps the UI thread free for heavy parsing
final users = await MapUtils.mapAsyncInIsolate<String, List<User>>(
  data: body,
  mapper: parseUsers,                 // top-level or static function
);

// The same, as an extension on any value
final user = await body.mapAsync(mapper: parseUser);
final list = await body.mapAsyncInIsolate(mapper: parseUsers);
```

| Parameter | Meaning |
| --- | --- |
| `data`, `mapper` | The input and the function (`FutureOr<S> Function(T)`). |
| `printError` | Log errors with the `PLAYX CORE` logger. Defaults to `kDebugMode`. |
| `onError` | `S Function(T data, Object error, StackTrace stack)`. When given, errors are caught and its return value is returned instead of rethrowing. |
| `useWorkManager` | (`mapAsyncInIsolate`) Run on the `worker_manager` pool started by `bootCore` (default `true`), or with Flutter's `compute` when `false`. |

```dart
final user = await body.mapAsync(
  mapper: parseUser,
  onError: (data, error, stack) => User.guest(),   // never throws
);
```

**Isolate rules.** The mapper and the data are sent to another isolate, so the mapper must be a **top-level or static function** (not a closure capturing objects), and the data and result must be sendable. For lists, see [`asyncMapInIsolate`](extensions.md#asynchronous-mapping).

## System UI helpers

Top-level functions for the status bar, navigation bar, orientation, keyboard and full screen:

| Function | Does |
| --- | --- |
| `setStatusBarColor({color, isDark})` | Status bar color (default transparent). `isDark: true` gives dark icons, for light backgrounds. |
| `setNavigationBarColor({color, isDark})` | Bottom navigation bar color (default black) and icon brightness. |
| `setOrientation({isPortrait, allowRotation})` | Locks the orientation. Portrait only by default; `allowRotation` adds upside-down (portrait) or both directions (landscape). |
| `hideKeyboard()` | Hides the on-screen keyboard. |
| `showKeyboard()` | Asks the system to show it for the focused field. |
| `enterFullScreen()` / `exitFullScreen()` | Immersive mode that hides the system bars, and restores them. |

```dart
setStatusBarColor(color: Colors.white, isDark: true);
setOrientation(isPortrait: false, allowRotation: true);   // landscape, both directions
hideKeyboard();
```

## Clipboard

```dart
await copyToClipboard('hello');
final text = await getClipboardText();      // 'hello', or null when empty
await clearClipboard();
```

## Platform checks

`PlayxPlatform` wraps `defaultTargetPlatform` and `kIsWeb`, so it works on every platform and can be overridden in tests with `debugDefaultTargetPlatformOverride`.

| Getter | `true` for |
| --- | --- |
| `isWeb`, `isWasm` | web / WebAssembly |
| `isAndroid`, `isIOS`, `isMacOS`, `isWindows`, `isLinux`, `isFuchsia` | that platform (never on web) |
| `isMobile` | Android or iOS |
| `isDesktop` | Windows, Linux or macOS |
| `isCupertino` | iOS or macOS |
| `isMaterial` | Android, Fuchsia, Windows or Linux, or web |

```dart
if (PlayxPlatform.isMobile) { /* ... */ }
```

## WebUtils

Helpers for browser behavior. On the web they use the DOM; on every other platform the same calls compile and are **safe no-ops**, so you don't need `kIsWeb` guards.

| Function | On web | Elsewhere |
| --- | --- | --- |
| `updateUrl(Uri)` | Replaces the URL in the address bar without navigating | no-op |
| `updateQueryParameters(Map<String, String>)` | Replaces the query parameters of the current URL | no-op |
| `setBodyBackgroundColor(String colorHex)` | Sets the `<body>` background | no-op |
| `setAppTitle({required title, primaryColor, webOnly = true})` | Sets the tab title and the app-switcher description | with `webOnly: false`, sets the app-switcher description only |
| `isFullScreen()` | Whether the page is full screen | `false` |
| `enterFullScreen()`, `exitFullScreen()`, `toggleFullScreen()` | Browser full screen | no-op |
| `reloadPage()` | Reloads | no-op |
| `openInNewTab(String url)` | Opens a new tab | no-op |

```dart
WebUtils.setAppTitle(title: 'Playx Core');
WebUtils.updateQueryParameters({'tab': 'settings'});
WebUtils.openInNewTab('https://example.com');
```

Works with both dart2js and WebAssembly builds.

## Colors

```dart
ColorUtils.fromHex(hex: '#336699');                 // opaque
ColorUtils.fromHex(hex: '336699', alpha: 128);      // 50% alpha
ColorUtils.fromRGB(red: 51, green: 102, blue: 153, alpha: 200);
```

For hex strings with the alpha included (`#80336699`) and other helpers, see the [`Color` extensions](extensions.md#color).

## Scroll behavior

`DefaultAppScrollBehavior` lets scrollables be dragged with touch, mouse **and** trackpad, which is handy for web and desktop apps:

```dart
MaterialApp(
  scrollBehavior: DefaultAppScrollBehavior(),
  home: const HomePage(),
);
```

---

*Imported from the [playx_core 2.0.0 documentation](https://github.com/playx-flutter/playx_core/blob/main/doc/utilities.md). [Package site](https://playx-flutter.github.io/playx_core/) · [pub.dev](https://pub.dev/packages/playx_core).*
