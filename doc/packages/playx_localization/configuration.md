
# Configuration

`PlayxLocaleConfig` is passed to `PlayxLocalization.boot`.

```dart
await PlayxLocalization.boot(
  config: PlayxLocaleConfig(
    supportedLocales: locales,
    startLocale: locales.first,
    fallbackLocale: locales.first,
  ),
);
```

## Locales

| Option | Default | Description |
|---|---|---|
| `supportedLocales` | required | The `XLocale`s the app supports. Must not be empty. |
| `startLocale` | `null` | The locale to start with when nothing is saved. `null` uses the device locale. |
| `fallbackLocale` | `null` | Used for missing keys. `null` picks English if supported, else the first locale. |

## Files and loading

| Option | Default | Description |
|---|---|---|
| `path` | `'assets/translations'` | The folder (or base URL for a custom loader). |
| `assetLoader` | `RootBundleAssetLoader` | Loads one locale. Replace it to read other formats. |
| `extraAssetLoaders` | `null` | Additional loaders merged on top of `assetLoader`. |
| `useOnlyLangCode` | `false` | Read `en.json` for every `en-*` locale. |
| `preloadSupportedLocales` | `false` | Load every supported locale at boot, so `tr(locale: ...)` works for all of them. |

## Fallbacks and plurals

| Option | Default | Description |
|---|---|---|
| `useFallbackTranslations` | `true` | Look in the fallback locale when a key is missing. |
| `useFallbackTranslationsForEmptyResources` | `false` | Also fall back when a value is an empty string. |
| `ignorePluralRules` | `false` | Skip the language's plural rules, only use `zero`, `one`, `two`, `other`. |
| `localizePluralDigits` | `false` | Show the count of `plural()` in the digits of the locale (`٣`). |

## Persistence

| Option | Default | Description |
|---|---|---|
| `saveLocale` | `true` | Save the selected locale and restore it on the next start. |
| `storage` | `PlayxPrefsLocaleStorage()` | Where it is saved. See [Persistence](persistence.md). |
| `migratePrefsToAsync` | `false` | Move a value saved by `SharedPreferences` (before 0.2) to the async storage. |

## Logging

| Option | Default | Description |
|---|---|---|
| `logMissingKeys` | `false` | Log a warning when a key is not found. |
| `logLocaleChanges` | `true` | Log locale changes and failed updates. |

## Delegates

| Option | Default | Description |
|---|---|---|
| `extraDelegates` | `null` | Delegates added after the package delegate, for example from other packages. |
| `customLocalizationDelegateBuilder` | `null` | Build the whole delegate list yourself from the `PlayxLocalizationDelegate`. |

```dart
PlayxLocaleConfig(
  supportedLocales: locales,
  customLocalizationDelegateBuilder: (delegate) => [
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ],
)
```

The default list is the package delegate, `extraDelegates`, then the Material, Widgets
and Cupertino delegates.

## XLocale

| Field | Description |
|---|---|
| `id` | Unique and stable. It is what is saved. |
| `name` | A display name, for example in a language picker. |
| `languageCode` | `en`, `ar`, ... |
| `countryCode` | Optional, `US`, `EG`, ... |
| `scriptCode` | Optional, `Hant`, `Hans`, ... |
| `fontFamily` | Optional font for this locale, read with `context.fontFamily`. |

---

*Imported from the [playx_localization 1.0.0 documentation](https://github.com/playx-flutter/playx_localization/blob/main/doc/configuration.md). [Package site](https://playx-flutter.github.io/playx_localization/) · [pub.dev](https://pub.dev/packages/playx_localization).*
