
# Playx Localization

Manage the locales of your Flutter app, load and translate text without a
`BuildContext`, handle plurals the way each language needs them, and remember the
user's choice.

- **Locale management**: any number of locales, switch by index, id, language code or `XLocale`.
- **Translate anywhere**: `'title'.tr()` works in widgets, view models and plain Dart classes.
- **Real plurals**: Arabic `مركبة` / `مركبتان` / `٣ مركبات` / `١١ مركبة` from a single entry, plus Russian, Polish and more.
- **Persistence**: the selected locale is saved by id and restored, in the storage you choose. Following the device language is a saved choice too.
- **Fallbacks**: fallback locale, base-language files (`en-US` → `en`) and optional per-key fallbacks.
- **Flexible sources**: JSON files, linked files, several loaders merged together, your own loader, and translations shipped by other packages.
- **Per-call locale**: show one string in English while the app is in Arabic.
- **Command line tools**: generate typed key constants and validate every locale in CI.

[Get started](getting-started.md){ .md-button .md-button--primary }
[API reference](https://playx-flutter.github.io/playx_localization/api/){ .md-button }

## Requirements

| | Minimum |
|---|---|
| Dart | 3.12 |
| Flutter | 3.44 |

## Install

```yaml
dependencies:
  playx_localization: ^1.0.0
```

## Guides

| Guide | What it covers |
|---|---|
| [Getting started](getting-started.md) | Install, boot and the first translated screen. |
| [Translation files](translation-files.md) | File names, nesting, linked files, fallbacks, custom loaders. |
| [Translating text](translating-text.md) | `tr`, arguments, gender, links, a different locale for one key. |
| [Plurals](plurals.md) | Plural forms per language, nouns with numbers, Arabic digits. |
| [Switching locales](switching-locales.md) | Updating the locale, following the device, resetting. |
| [Persistence](persistence.md) | What is saved, custom storage, migration. |
| [Translations from packages](package-translations.md) | Let other packages register their own translations. |
| [Command line tools](command-line-tools.md) | Generate keys and validate translations. |
| [Configuration](configuration.md) | Every `PlayxLocaleConfig` option. |
| [Extensions](extensions.md) | String, number, date and locale helpers. |
| [Testing](testing.md) | Testing code that uses translations. |
| [Migration](migration.md) | Moving from 0.x to 1.0. |

---

*Imported from the [playx_localization 1.0.0 documentation](https://github.com/playx-flutter/playx_localization/blob/main/doc/index.md). [Package site](https://playx-flutter.github.io/playx_localization/) · [pub.dev](https://pub.dev/packages/playx_localization).*
