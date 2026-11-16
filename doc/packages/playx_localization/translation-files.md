
# Translation files

## Names

Files live in `config.path` (default `assets/translations`) and are named after the locale:

| Locale | File |
|---|---|
| `en` | `en.json` |
| `en-US` | `en-US.json` |
| `zh-Hant` | `zh-Hant.json` |
| `zh-Hant-TW` | `zh-Hant-TW.json` |

The order is language, script, country (the same as `Locale.toLanguageTag()`).

!!! note
    Before 1.0 a locale with a script **and** a country was named `zh-TW-Hant.json`.
    That name still loads, with a log message asking you to rename the file.

Set `useOnlyLangCode: true` to read only `en.json` for every `en-*` locale.

## Nested keys

Group keys with nested objects and read them with dots:

```json
{
  "home": {
    "title": "Home",
    "subtitle": "Welcome back"
  }
}
```

```dart
'home.title'.tr();
```

A key that contains a dot literally (`"a.b": "..."`) wins over a nested path.

## Linked files

Split big files by pointing a key to another file with `:/`:

```json
{
  "title": "My App",
  "auth": ":/auth.json"
}
```

```plaintext
assets/translations
├── en.json
└── en
    └── auth.json        <- { "login": "Log in" }
```

```dart
'auth.login'.tr();
```

The folder is named after the locale: `en/`, `en-US/`, `zh-Hant-TW/`. Linked files
can link to other files. Linking the same file from several keys is fine; a real
cycle throws an error. Folders named in the old style (`zh-TW/`, which ignored the
script code) still work.

## Fallbacks

When a key is missing in the current locale the package looks in this order:

1. The current locale file.
2. The base language file, for regional locales (`en-US` → `en`).
3. The fallback locale (`fallbackLocale`, else English if supported, else the first locale).
4. The key itself is returned.

Turn the fallbacks off with `useFallbackTranslations: false`. Set
`useFallbackTranslationsForEmptyResources: true` to also fall back when a value is an
empty string. To see which keys are missing while developing, set `logMissingKeys: true`.

## More than one source

`extraAssetLoaders` load additional files for the same locale. Their maps are merged
deeply on top of the main loader, so a later loader overrides single keys:

```dart
PlayxLocaleConfig(
  assetLoader: RootBundleAssetLoader.fromRootBundle(),
  extraAssetLoaders: [MyOverridesLoader()],
  ...
);
```

Translations shipped by other packages are a separate mechanism, see
[Translations from packages](package-translations.md).

## Other formats and remote files

Write your own loader to read CSV, YAML, a database or the network. Only `load` is
required:

```dart
class HttpAssetLoader extends AssetLoader {
  const HttpAssetLoader();

  @override
  Future<Map<String, dynamic>?> load(String path, Locale locale) async {
    final url = Uri.parse('$path/${locale.languageCode}.json');
    final response = await http.get(url);
    return json.decode(response.body) as Map<String, dynamic>;
  }
}

PlayxLocaleConfig(
  path: 'https://example.com/translations',
  assetLoader: const HttpAssetLoader(),
  ...
);
```

If `load` throws, that locale could not be loaded: the current locale is kept and the
update returns `false`.

`RootBundleAssetLoader.fromIOFile()` reads from the file system instead of the asset
bundle, which is useful in Dart command line programs.

---

*Imported from the [playx_localization 1.0.0 documentation](https://github.com/playx-flutter/playx_localization/blob/main/doc/translation-files.md). [Package site](https://playx-flutter.github.io/playx_localization/) · [pub.dev](https://pub.dev/packages/playx_localization).*
