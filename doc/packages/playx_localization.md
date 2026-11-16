# playx_localization

[pub.dev](https://pub.dev/packages/playx_localization) · [Docs](https://playx-flutter.github.io/playx_localization/) · Used by Playx 3.0: **1.0.0** (2.x used 0.4.0)

Manage locales, **translate without a `BuildContext`**, handle plurals the way each language
needs them, and remember the user's choice.

```dart
Text('welcome'.tr(context: context, namedArgs: {'name': 'Sam'}));
Text(context.plural('item', 3));          // 3 items
await PlayxLocalization.updateById('ar'); // saved and restored on next start
```

Playx boots it in the **Localization** step from your `PlayxLocaleConfig`, and the
[app widgets](../app-widgets.md) set the locale, delegates and supported locales for you.

## What changed in 1.0.0 (first stable release)

### Breaking / needs attention

- **SDK:** Dart `>=3.12.0`, Flutter `>=3.44.0`.
- **Script codes follow BCP-47:** `zh-Hant-TW` instead of `zh-TW-Hant`. Old file names still load
  (with a log message to rename them); old linked-file folders are found too.
- **Custom `LinkedFileResolver`** subclasses: `resolveLinkedFiles` has a new optional `scriptCode`.
- **Locale saved by id:** the selected locale is stored by `XLocale.id`, not its index, so reordering
  locales in an update no longer restores the wrong language. Existing installs migrate automatically.
- **`resetLocale` forgets the saved choice** and applies the fresh-install locale without saving it.
- **Plurals follow language rules by default:** `one`/`two`/`few`/`many`/`other` (for example Arabic
  `مركبة` / `مركبتان` / `٣ مركبات` / `١١ مركبة` from one entry). Existing entries keep working;
  set `ignorePluralRules: true` for the old behavior.

### New

- **Translations from other packages:** `PlayxLocalization.registerTranslations` with
  `PlayxTranslationSource`.
- **Command line tools:**
  - `dart run playx_localization:generate` — typed key constants from a base file (`--check` for CI).
  - `dart run playx_localization:validate` — missing/extra keys, placeholder mismatches, plural
    gaps, unused keys, invalid JSON (non-zero exit on errors, or warnings with `--strict`).
- `localizePluralDigits` — show `٣` instead of `3` in Arabic.
- `preloadLocales` — load only the locales you need for `tr(locale: ...)`.
- `translate: false` on `tr`/`plural` to return text as-is.
- Pluggable storage: `PlayxLocaleConfig.storage` (`PlayxPrefsLocaleStorage`, `PlayxMemoryLocaleStorage`).
- Easier custom asset loaders (`fileLoader`/`linkedFileResolver` optional); `PlayxLocalizationDelegate`
  exported; `PlayxLocalization.resetLocale`.
- `tr` with a `BuildContext` falls back to the global instance instead of throwing.

### Fixes

- `config.useFallbackTranslations` is respected.
- A failed locale switch keeps the current locale and returns `false`.
- One broken locale file no longer breaks `preloadSupportedLocales`.
- Group keys and keys through text values behave like missing keys instead of crashing.
- `namedArgs` with regex characters (`{a.b}`) are replaced; `@:key` links resolve in the requested locale.
- `isCurrentLocaleRtl` / `isCurrentLocaleLtr` were always LTR; now correct.
- `Text(...).tr()` keeps the original `Text.locale`; decimal plural counts aren't rounded;
  `DateTime.toFormattedDate` uses the full locale tag; `currentLocaleToString` is `static`.

## What changed in 0.4.0 (used by Playx 2.1.x)

`useFallbackTranslationsForEmptyResources`, `ignorePluralRules`, `extraAssetLoaders`, `errorWidget`,
`scriptCode` on `XLocale`, deep translation merging, device-locale persistence, and
`preloadSupportedLocales`.

## What it means for Playx

- No code changes in Playx apps beyond the new SDK floor.
- The saved locale migrates automatically on first launch after upgrading.
- If you rely on singular/plural entries for languages with more forms, check the new plural
  rules or set `ignorePluralRules: true`.
