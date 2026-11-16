
# Getting started

## 1. Add translation files

Create one JSON file per locale in `assets/translations/`. The file name is the
language code, optionally followed by the country code.

```plaintext
assets
└── translations
    ├── en.json
    └── ar.json
```

```json
{
  "app_name": "My App",
  "welcome": "Welcome, {name}!"
}
```

Declare the folder in `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/translations/
```

!!! note
    On iOS, also list the supported languages in `ios/Runner/Info.plist` as described
    in the [Flutter docs](https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization#specifying-supportedlocales).

## 2. Boot Playx Localization

Boot it once before `runApp`.

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const locales = [
    XLocale(id: 'en', name: 'English', languageCode: 'en'),
    XLocale(id: 'ar', name: 'العربية', languageCode: 'ar'),
  ];

  await PlayxLocalization.boot(
    config: PlayxLocaleConfig(
      supportedLocales: locales,
      startLocale: locales.first,
      fallbackLocale: locales.first,
    ),
  );

  runApp(const MyApp());
}
```

!!! warning
    Each `XLocale.id` must be unique and stable. It is what the app saves, so changing
    the **order** of the list later is safe, changing an **id** is not.

## 3. Wrap your app

`PlayxLocalizationBuilder` rebuilds when the locale changes.

```dart
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return PlayxLocalizationBuilder(
      builder: (context, xLocale) => MaterialApp(
        locale: xLocale.locale,
        supportedLocales: PlayxLocalization.supportedLocales,
        localizationDelegates: PlayxLocalization.localizationDelegates,
        theme: ThemeData(fontFamily: xLocale.fontFamily),
        home: const HomePage(),
      ),
    );
  }
}
```

`localizationDelegates` already includes the Material, Widgets and Cupertino
delegates, so the framework's own text (date pickers, back button, ...) and text
direction follow the locale too.

## 4. Translate

```dart
Text('app_name'.tr(context: context));
Text('welcome'.tr(context: context, namedArgs: {'name': 'Sam'}));
Text(context.tr('welcome', namedArgs: {'name': 'Sam'}));
```

Pass the `context` (or use `context.tr`) so the widget rebuilds when the locale
changes. Without it, `'key'.tr()` still works anywhere, for example in a view
model, but it does not subscribe to locale changes.

## 5. Switch the locale

```dart
await PlayxLocalization.updateTo(locales[1]);          // by XLocale
await PlayxLocalization.updateById('ar');              // by id
await PlayxLocalization.updateByLanguageCode(languageCode: 'ar');
await PlayxLocalization.nextLocale();                  // cycle through the list
```

The choice is saved and restored on the next start. See
[Switching locales](switching-locales.md) and
[Persistence](persistence.md).

## Next

- [Translation files](translation-files.md): nesting, linked files, fallbacks.
- [Translating text](translating-text.md): arguments, gender, links.
- [Plurals](plurals.md): nouns that change with the number.

---

*Imported from the [playx_localization 1.0.0 documentation](https://github.com/playx-flutter/playx_localization/blob/main/doc/getting-started.md). [Package site](https://playx-flutter.github.io/playx_localization/) · [pub.dev](https://pub.dev/packages/playx_localization).*
