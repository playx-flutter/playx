# Extensions

Everything here is available from `import 'package:playx_core/playx_core.dart';`.

- [String](#string)
- [Iterable](#iterable)
- [DateTime](#datetime)
- [Duration](#duration)
- [Color](#color)
- [bool](#bool)
- [Locale](#locale)
- [Future](#future)
- [BuildContext](#buildcontext)
- [Padding](#padding)
- [Borders and radius](#borders-and-radius)

## String

### Formatting and case

| Member | Does | Example |
| --- | --- | --- |
| `capitalizeFirstChar` | Uppercases the first character. | `'hello'` → `'Hello'` |
| `capitalizeFirstCharForEachWord` | Uppercases the first character of every space-separated word. | `'hello big world'` → `'Hello Big World'` |
| `capitalizedInitialChar` | The first visible character, uppercased. Unicode-safe (emoji and combined characters stay whole); empty for blank strings. Ideal for avatar initials. | `'  élodie'` → `'É'` |
| `format(List args)` | `sprintf`-style formatting. | `'Hi %s, you are %d'.format(['Jane', 30])` |
| `limit(maxLength, {suffix})` | Truncates and appends a suffix (default `...`). | `'Hello World'.limit(5)` → `'Hello...'` |
| `toSlug()` | URL-friendly slug. | `'Hello, World! 2024'` → `'hello-world-2024'` |
| `toPrettyJson({indent})` | Indents a JSON string; returns it unchanged if it isn't valid JSON. | `'{"a":1}'` → `'{\n  "a": 1\n}'` |

### Inspecting and searching

| Member | Does |
| --- | --- |
| `reversed` | The characters in reverse order. |
| `isPalindrome` | Whether the string equals its reverse. |
| `linesCount` | Number of lines. |
| `firstOrNull`, `lastOrNull`, `lastOrEmpty` | First / last character, or `null` / `''` when empty. |
| `containsIgnoreCase(other)`, `equalsIgnoreCase(other)` | Case-insensitive comparison. |
| `anyChar(predicate)` | Whether any single character satisfies the predicate. |
| `isNumeric` | Whether it parses as a number. |
| `isValidEmail`, `isValidUrl` | Basic format checks (not a guarantee that the address or URL exists). |

### Converting and editing

| Member | Does | Example |
| --- | --- | --- |
| `toBoolean()` | `true` for `'true'` or `'1'` (case-insensitive), otherwise `false`. | `'TRUE'.toBoolean()` → `true` |
| `toIntOrNull()`, `toDoubleOrNull()` | Parse, or `null`. | `'42'.toIntOrNull()` → `42` |
| `removeWhitespace()` | Removes all whitespace. | `' a b '` → `'ab'` |
| `removeHtmlTags()` | Strips basic HTML tags. | `'<b>Hi</b>'` → `'Hi'` |
| `replaceAfter(delimiter, replacement, [defaultValue])` | Replaces everything after the first `delimiter` (the delimiter stays). | `'key=old'.replaceAfter('=', 'new')` → `'key=new'` |
| `replaceBefore(delimiter, replacement, [defaultValue])` | Replaces everything before the first `delimiter`. | `'old=value'.replaceBefore('=', 'new')` → `'new=value'` |

For safer conversions of unknown values see [`toIntOrNull`/`toInt`… in Utilities](utilities.md#safe-conversion).

### Nullable strings

```dart
String? name;
name.isNullOrEmpty;              // true
name.isNotNullOrEmpty;           // false
name.ifNullOrEmpty('Anonymous'); // 'Anonymous'
```

## Iterable

Methods are on every `Iterable<T>` (lists, sets…). Note `firstOrNull()` and `lastOrNull()` are **methods**.

### Counting and picking

| Member | Does |
| --- | --- |
| `countWhere([predicate])` | Number of elements matching (all elements without a predicate). |
| `countNotNull()` | Number of non-null elements. |
| `random` | A random element, or `null` when empty. |
| `firstOrNull()`, `lastOrNull()` | First / last element, or `null`. |
| `firstOr(value)`, `lastOr(value)` | First / last element, or `value`. |
| `isIndexValid(index)` | Whether `index` is in range. |
| `atOrNull(index)`, `atOr(index, value)` | Element at `index`, or `null` / `value`. |
| `firstWhereOrNull(test)`, `firstWhereOr(test, value)` | First match, or `null` / `value`. |
| `lastWhereOrNull(test)`, `lastWhereOr(test, value)` | Last match, or `null` / `value`. |

### Transforming

| Member | Does | Example |
| --- | --- | --- |
| `withoutDuplicate()` | List without duplicates. | `[1, 1, 2]` → `[1, 2]` |
| `mapWithIndex((i, e) => …)` | Map with the index. | `['a', 'b']` → `['0a', '1b']` |
| `chunked(size)` | Splits into lists of `size` (throws `ArgumentError` for `size <= 0`). | `[1, 2, 3].chunked(2)` → `[[1, 2], [3]]` |
| `groupBy(keySelector)` | `Map<K, List<T>>`. | `[1, 2, 3].groupBy((e) => e.isEven)` |
| `sortedBy(key)`, `sortedByDescending(key)` | A sorted copy (the source is untouched). | `words.sortedBy((w) => w.length)` |

### Asynchronous mapping

```dart
final doubled = await [1, 2, 3].asyncMap(mapper: (e) async => e * 2);
final parsed = await files.asyncMapInIsolate(mapper: parseFile);   // runs each item in an isolate
```

`asyncMapInIsolate` takes `useWorkManager` (use the `worker_manager` pool started by `bootCore`, default `true`), `printError` and `printEachItemError`. The mapper must be a top-level or static function (it is sent to another isolate). See also [`MapUtils`](utilities.md#maputils-and-mapasync).

### Nested iterables

```dart
final nested = [[1, 2], [3], <int>[]];
nested.flatten();                                      // [1, 2, 3]
nested.flatMap(mapper: (e) => e * 10);                 // 10, 20, 30
await nested.flatMapAsync(mapper: (e) async => e + 1); // [2, 3, 4]
```

`asyncFlatMap` is deprecated; use `flatMapAsync`.

### Numbers

```dart
[1, 2, 3, 4].sum;       // 10
[1, 2, 3, 4].average;   // 2.5
<int>[].sum;            // 0 (empty collections give 0)
```

## DateTime

| Member | Does |
| --- | --- |
| `isAm` | Whether the hour is before 12. |
| `nextDay`, `previousDay` | ±1 day. |
| `sameDayNextWeek`, `sameDayPreviousWeek` | ±7 days. |
| `nextMonth`, `previousMonth` | **±30 days**, not a calendar month. |
| `isToday`, `isTomorrow`, `isYesterday` | Relative to now. |
| `isSameDay(date)`, `isSameMonth(date)`, `isSameYear(date)` | Compare calendar parts. |
| `isSameWeek(date: …, firstDay: …)` | Same week, for a configurable first weekday. |
| `isInThisWeek({firstDay})`, `isInThisMonth`, `isInThisYear` | Relative to now. |
| `isInTheFuture`, `isInThePast` | Compared with now. |
| `dayOfTheWeekIndex({firstDay})` | 0-6, counted from `firstDay` (default Monday). |
| `dayOfTheWeek()` → `Weekday`, `monthOfTheYear()` → `Month` | Enums with a `fromDate` constructor. |
| `isLeapYear` | Leap-year check. |
| `withoutTime()` | Midnight of the same day. |
| `copyWith({year, month, day, hour, minute, second, millisecond})` | Replace parts. |
| `startOfDay`, `endOfDay` | `00:00:00.000` / `23:59:59.999`. |
| `startOfMonth`, `endOfMonth` | First moment / last millisecond of the month. |
| `startOfWeek({firstDay})`, `endOfWeek({firstDay})` | Boundaries of the week; Monday-first by default. |

```dart
final date = DateTime(2024, 5, 15);          // a Wednesday
date.startOfWeek();                           // 2024-05-13
date.startOfWeek(firstDay: Weekday.sunday);   // 2024-05-12
date.endOfMonth;                              // 2024-05-31 23:59:59.999
date.dayOfTheWeek();                          // Weekday.wednesday
```

## Duration

Total and remaining parts, as strings with an optional leading zero (default `true`):

| Member | Example for `27h 5m 9s` |
| --- | --- |
| `toDays()`, `toHours()`, `toMinutes()`, `toSeconds()`, `toMilliSeconds()` | `toHours()` → `'27'` (total hours) |
| `toRemainingHours()`, `toRemainingMinutes()`, `toRemainingSeconds()` | `'03'`, `'05'`, `'09'` |
| `toFormattedDuration(...)` | see below |
| `delay([callback])` | Waits for the duration, then runs `callback` (if given) and returns its result |

```dart
const d = Duration(hours: 27, minutes: 5, seconds: 9);

d.toRemainingMinutes();                            // '05'
d.toRemainingMinutes(leadingZero: false);          // '5'

d.toFormattedDuration(
  days: 'd', hours: 'h', minutes: 'm', seconds: 's', spacer: ', ',
);                                                  // '01 d, 03 h, 05 m, 09 s'

await const Duration(seconds: 2).delay(() => 'done');   // 'done' after 2 seconds
```

Parts you don't pass (`days:`, `hours:`…) are left out. `leaveSpaceBetweenTimeAndText: false` removes the space (`'3h5m'`). `twoDigits(int)` is also exported.

## Color

```dart
const color = Color(0xFF336699);

color.toHex();                               // '#336699'
color.toHex(leadingHashSign: false);         // '336699'
color.toHex(includeAlpha: true);             // '#ff336699'

PlayxColorExtensions.fromHex('#336699');     // Color(0xFF336699)
PlayxColorExtensions.fromHex('80336699');    // with alpha

color.copyWith(alpha: 0.5, red: 1);          // channels are 0.0-1.0
color.lighten(0.2);                          // lightness +0.2, clamped
color.darken();                              // lightness -0.1 by default
color.isDark;                                // luminance < 0.5: pick a text color
```

`ColorUtils.fromHex(hex:, alpha:)` and `ColorUtils.fromRGB(...)` are also available, see [Utilities](utilities.md#colors).

## bool

```dart
true.toInt();        // 1
false.toInt();       // 0
true.toggle();       // false

bool? value;
value.isTrue;        // true only for an explicit true
value.isFalse;       // true only for an explicit false
```

## Locale

| Member | Does |
| --- | --- |
| `isRTL` | Right-to-left languages: Arabic, Farsi, Hebrew, Pashto, Urdu. |
| `direction` | The matching `TextDirection`. |
| `isArabic`, `isEnglish` | Language checks. |

## Future

```dart
final length = await fetchName().map((name) => name.length);
```

`map` transforms the result of a future (`FutureOr` transform allowed).

## BuildContext

### Theme

| Member | Same as |
| --- | --- |
| `theme`, `textTheme`, `brightness` | `Theme.of(context)`, `.textTheme`, `.brightness` |
| `isDark`, `isLight` | whether the brightness is dark / light |

### Colors

Shortcuts for `Theme.of(context)` colors: `primaryColor`, `primaryColorDark`, `primaryColorLight`, `backgroundColor`, `scaffoldBackgroundColor`, `bottomAppBarColor`, `cardColor`, `dividerColor`, `disabledColor`, `focusColor`, `hoverColor`, `highlightColor`, `splashColor`, `unselectedWidgetColor`, `secondaryHeaderColor`, `hintColor`, `errorColor`, `colorScheme`, `secondary`, `buttonPrimaryColor`.

And every Material 3 `ColorScheme` role: `primary`, `onPrimary`, `primaryContainer`, `onPrimaryContainer`, `secondary` (+ `on…`, `…Container`), `tertiary` (+ `on…`, `…Container`), `surface`, `onSurface`, `error`, `onError`, `errorContainer`, `onErrorContainer`, `outline`, `outlineVariant`, `shadow`, `scrim`, `inverseSurface`, `onInverseSurface`, `inversePrimary`.

```dart
Container(color: context.primaryContainer, child: Text('Hi', style: TextStyle(color: context.onPrimaryContainer)));
```

### Media query

| Member | Does |
| --- | --- |
| `mediaQuery` | `MediaQuery.of(context)` |
| `width`, `height`, `aspectRatio` | Screen size values |
| `mediaQueryPadding` | System padding (notches, bars) |
| `orientation`, `isPortrait`, `isLandscape` | Orientation |
| `alwaysUse24HourFormat` | The platform setting |
| `crossAxisCount({mediumBreakpoint, wideBreakpoint, compact, medium, wide})` | Grid columns for the width: `1` below 840, `2` from 840, `3` from 1400 |

```dart
GridView.count(crossAxisCount: context.crossAxisCount(), children: items);
context.crossAxisCount(mediumBreakpoint: 600, medium: 3, wide: 5);
```

> **`context.size` is not the screen size.** `BuildContext` already has a member named `size` (the size of the widget's render object), and a real member wins over an extension getter. Use `context.width`, `context.height` and `context.aspectRatio` for the screen.

### Navigation

| Member | Same as |
| --- | --- |
| `navigator`, `rootNavigator` | `Navigator.of(context)` / `…, rootNavigator: true` |
| `canPop` | `Navigator.of(context).canPop()` |
| `pop()` | `Navigator.of(context).pop()` |
| `focusScope` | `FocusScope.of(context)` |
| `form` | `Form.maybeOf(context)`: `null` when there is no `Form` above |

### Localization

`directionality`, `isRtl`, `isLtr`, `locale`.

## Padding

Helpers to create `EdgeInsets` from numbers, and to wrap widgets in `Padding`. Values are unscaled (see [conventions](index.md#conventions-used-in-these-guides)).

### On numbers

| Member | Creates |
| --- | --- |
| `p`, `pAll` | `EdgeInsets.all(n)` |
| `px`, `pLR` | `EdgeInsets.symmetric(horizontal: n)` |
| `py`, `pTB` | `EdgeInsets.symmetric(vertical: n)` |
| `pt`, `pb`, `pl`, `pr` | One side: top, bottom, left, right |
| `ps`, `pe` | `EdgeInsetsDirectional` start / end (follows RTL) |
| `pZero` | `EdgeInsets.zero` |

```dart
Container(padding: 16.p);
Container(padding: 8.px + 4.py);          // insets add up
Container(padding: 12.ps);                // start side: left in LTR, right in RTL
```

Insets of the same kind combine with `+`. To mix absolute and directional insets, use `add`, which returns an `EdgeInsetsGeometry` resolved against the text direction:

```dart
Container(padding: 12.ps.add(4.pt));      // start 12 + top 4
```

### On widgets

| Member | Does |
| --- | --- |
| `withPadding(EdgeInsetsGeometry)` | Wrap with any padding, e.g. `16.px`. |
| `pAll(value)` | Equal padding on all sides. |
| `pSymmetric({horizontal, vertical})` | Symmetric padding. |
| `pOnly({left, top, right, bottom})` | Per-side padding. |
| `pDirectional({start, top, end, bottom})` | RTL-aware padding. |
| `pZero()` | `EdgeInsets.zero`: a placeholder padding. |

```dart
Text('Hello').pAll(16);
Text('Hello').pSymmetric(horizontal: 12, vertical: 6);
Text('Hello').pDirectional(start: 8);
Text('Hello').withPadding(24.px);
```

All of them return a `Padding`.

## Borders and radius

### On numbers

| Member | Creates |
| --- | --- |
| `radius` | `Radius.circular(n)` |
| `ellipticalRadius(y)` | `Radius.elliptical(n, y)` |
| `borderRadius` | `BorderRadius.circular(n)` |
| `borderRadiusTop`, `borderRadiusBottom`, `borderRadiusLeft`, `borderRadiusRight` | Rounded on one side |
| `borderRadiusStart`, `borderRadiusEnd` | `BorderRadiusDirectional` start / end (RTL-aware) |
| `roundedShape` | `RoundedRectangleBorder`, e.g. for `Card.shape` |
| `border([color])` | `Border.all(width: n)` |
| `borderSide([color])` | `BorderSide(width: n)` |

```dart
DecoratedBox(
  decoration: BoxDecoration(
    borderRadius: 12.borderRadius,
    border: 1.border(Colors.grey),
  ),
);
Card(shape: 8.roundedShape);
ClipRRect(borderRadius: 16.borderRadiusTop, child: image);
```

### On colors

```dart
Colors.grey.border(width: 2);   // Border.all
Colors.grey.borderSide();       // BorderSide, width 1
```

### On widgets

| Member | Does |
| --- | --- |
| `clipRounded(radius)` | `ClipRRect` with a circular radius. |
| `clipBorderRadius(borderRadius)` | `ClipRRect` with any radius, e.g. `16.borderRadiusTop`. |
| `bordered({color, width, radius})` | Draws a border (rounded when `radius > 0`). |

```dart
Image.network(url).clipRounded(12);
Text('Tag').pSymmetric(horizontal: 8, vertical: 4).bordered(color: Colors.grey, radius: 8);
```

---

*Imported from the [playx_core 2.0.0 documentation](https://github.com/playx-flutter/playx_core/blob/main/doc/extensions.md). [Package site](https://playx-flutter.github.io/playx_core/) · [pub.dev](https://pub.dev/packages/playx_core).*
