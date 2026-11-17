
# Translating text

## Ways to translate

```dart
Text('title'.tr(context: context))        // String extension
Text(context.tr('title'))                 // BuildContext extension
Text('title').tr(context: context)        // Text extension: returns a translated Text
final title = tr('title');                // static function
```

All of them accept the same arguments. `context` is optional: pass it (or use
`context.tr`) so the widget rebuilds when the locale changes. Anywhere else, for example
in a view model, call `'key'.tr()` without it.

To force the whole app to rebuild when the locale changes instead, pass
`forceAppUpdate: true` to the update method. See
[Switching locales](switching-locales.md).

`'key'.trExists()` tells whether a key exists in the current locale.

## Arguments

| Name | Type | Description |
|---|---|---|
| `args` | `List<String>` | Replaces `{}` from left to right. |
| `namedArgs` | `Map<String, String>` | Replaces `{name}` by its name. |
| `gender` | `String` | Picks the gender form of the key. |
| `locale` | `Locale` | Translate in this locale instead of the current one. |
| `translate` | `bool` | `false` returns the text as it is. |

```json
{
  "msg": "{} is written in {}",
  "msg_named": "Playx Localization is written in {lang}",
  "msg_mixed": "{} is written in {lang}",
  "gender": {
    "male": "Hi sir {}",
    "female": "Hi madam {}",
    "other": "Hi {}"
  }
}
```

```dart
'msg'.tr(args: ['Playx', 'Dart']);
'msg_named'.tr(namedArgs: {'lang': 'Dart'});
'msg_mixed'.tr(args: ['Playx'], namedArgs: {'lang': 'Dart'});
'gender'.tr(gender: isFemale ? 'female' : 'male', args: ['Sam']);
```

## Links to other keys

Reuse a translation by prefixing a key with `@:`:

```json
{
  "example": {
    "hello": "Hello",
    "world": "World!",
    "helloWorld": "@:example.hello @:example.world"
  }
}
```

```dart
'example.helloWorld'.tr(); // Hello World!
```

Use `@:(key)` when the key is followed by characters that could be part of a key
(`@:(example.hello)!`). Arguments work inside linked text too.

### Modifiers

`@.modifier:key` changes the case of the linked text:

| Modifier | Result |
|---|---|
| `upper` | `HELLO` |
| `lower` | `hello` |
| `capitalize` | `Hello` |

```json
{
  "fullName": "Full Name",
  "emptyNameError": "Please fill in your @.lower:fullName"
}
```

```dart
'emptyNameError'.tr(); // Please fill in your full name
```

Links are resolved in the same locale as the text that contains them, also when you
pass `locale`.

## Not translating a key

Use `translate: false` for text that may or may not be a translation key, such as text
that comes from a server. The text is returned as it is and `args` / `namedArgs` are
still applied.

```dart
'title'.tr(translate: false);                                  // 'title'
'Hi {name}'.tr(translate: false, namedArgs: {'name': 'Sam'});  // 'Hi Sam'
```

## A different locale for one key

Pass `locale` to translate one piece of UI in another language, for example English
inside an Arabic app:

```dart
Text('title'.tr(locale: const Locale('en')));
Text(context.tr('title', locale: const Locale('en')));
'item'.plural(3, locale: const Locale('en'));
```

Lookups are synchronous, so the locale has to be loaded already. The current and the
fallback locale always are. For any other, either load all supported locales at boot
with `preloadSupportedLocales: true`, or load only the ones you need:

```dart
await PlayxLocalization.preloadLocales([const Locale('en'), const Locale('fr')]);
```

Preloaded locales stay loaded when the app locale changes. A locale that is not loaded
returns the key, and a warning is logged if `logMissingKeys` is on.

## Missing keys

A missing key returns the key itself, so the UI never shows an empty string by
accident. Set `logMissingKeys: true` in the config to log them while developing, and use
[`validate`](command-line-tools.md) in CI to catch them before release.

---

*Imported from the [playx_localization 1.0.0 documentation](https://github.com/playx-flutter/playx_localization/blob/main/doc/translating-text.md). [Package site](https://playx-flutter.github.io/playx_localization/) · [pub.dev](https://pub.dev/packages/playx_localization).*
