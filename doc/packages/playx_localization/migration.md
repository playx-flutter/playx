
# Migrating to 1.0

Version 1.0 raises the minimum SDKs and cleans up a few behaviors. Saved locales and file
names are migrated automatically. This page lists what changes and what, if anything, you
need to do.

## Requirements

- Dart `>=3.12.0` and Flutter `>=3.44.0`.
- `playx_core` `^2.0.0`. If your app also uses other Playx packages, update them to
  versions that use `playx_core` 2 too.

## Nothing to do

| Change | What happens |
|---|---|
| The saved locale is stored by **id** instead of its position in `supportedLocales`. | The old position is read once and rewritten as an id. The old key is still written, so a downgrade works. |
| Locales with a script and a country are named `zh-Hant-TW`, not `zh-TW-Hant`. | The old file name and the old linked-file folder (`zh-TW/`) still load, with a log message. Rename them when convenient. |
| `DateTime.toFormattedDate` / `toFormattedTime` use the full locale (`de-AT`), not only the language. | Dates in regional locales may use regional month names. |
| Failed locale updates keep the current locale and translations. | `updateTo` and the others return `false` instead of leaving the app without translations. |
| `tr(context: ...)` without a `Localization` in the context falls back to the global instance. | It no longer throws. |

## Check

### Plurals follow the language's rules

`plural()` now chooses `one`, `two`, `few`, `many` or `other` with the plural rules of the
language, and `ignorePluralRules` defaults to `false`. An exact `zero`, `one` or `two`
form still wins for 0, 1 and 2, and a missing form falls back to `other`, so entries that
only use `zero` / `one` / `two` / `other` keep working.

What can differ: entries that already contain `few` or `many`, which used to be ignored,
are now used, and languages like French treat `0` as `one`. To keep the old behavior set:

```dart
PlayxLocaleConfig(ignorePluralRules: true, ...)
```

### Keep ids unique and stable

`XLocale.id` is the saved value now. Two locales must not share an id, and an id should
not change between releases (reordering the list is fine).

### `resetLocale`

It now forgets the saved locale and switches to the fresh-install locale **without
saving it**. Before, the result was saved as an explicit choice.

### Custom `LinkedFileResolver`

`resolveLinkedFiles` has a new optional `scriptCode` parameter. If you subclass
`LinkedFileResolver`, add it to your override.

### `loadTranslations`

`PlayxLocaleController.loadTranslations` returns `Future<bool>` now (`false` when the
locale could not be loaded). `getLastSavedIndexFromPrefs` is deprecated.

### `PlayxCore.bootCore()`

It is not needed before `PlayxLocalization.boot`. If you still call it on macOS, make
sure the app has the keychain entitlement, because `playx_core` 2 uses secure storage
there.

## Bug fixes you may notice

These behaviors were bugs and are fixed:

- `useFallbackTranslations: false` is respected.
- A key that points to a group (`'home'` when `home` is an object) no longer crashes.
- `namedArgs` with names like `{a.b}` are replaced.
- `@:key` links are resolved in the requested locale.
- `context.isCurrentLocaleRtl` reports the language direction correctly.
- One missing locale file no longer breaks `preloadSupportedLocales`.
- `Text(...).tr()` keeps the original `Text.locale`.
- Decimal counts such as `1.4` are no longer treated as singular.

See the [changelog](https://github.com/playx-flutter/playx_localization/blob/main/CHANGELOG.md)
for the complete list.

---

*Imported from the [playx_localization 1.0.0 documentation](https://github.com/playx-flutter/playx_localization/blob/main/doc/migration.md). [Package site](https://playx-flutter.github.io/playx_localization/) · [pub.dev](https://pub.dev/packages/playx_localization).*
