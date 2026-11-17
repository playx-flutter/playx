
# Translations from packages

A package that has its own UI text can ship its translations and register them. The app
does not have to copy or know about those keys.

## In the other package

Add the files and declare the folder in that package's `pubspec.yaml`:

```plaintext
my_package
└── assets
    └── translations
        ├── en.json
        └── ar.json
```

```yaml
flutter:
  assets:
    - assets/translations/
```

Register them, for example in the package's own initialization method:

```dart
await PlayxLocalization.registerTranslations(
  PlayxTranslationSource.package(
    package: 'my_package',     // reads packages/my_package/assets/translations
    namespace: 'my_package',   // optional: keys become my_package.title
  ),
);
```

```dart
'my_package.title'.tr();
```

You can call it before or after `PlayxLocalization.boot`. After boot the current locale
is reloaded immediately and the UI rebuilds.

## Rules

- **The app wins.** Keys defined by the app (`assetLoader`, `extraAssetLoaders`) always
  override the same keys from a package. Between two packages, the one registered last
  wins.
- **Use a namespace** to avoid collisions. Dots create nested levels:
  `namespace: 'libs.my_package'` gives `libs.my_package.title`.
- **A package does not need every locale.** A missing locale is skipped, and a regional
  locale falls back to its language file (`en-US` → `en`).
- Registering the same id again replaces the previous source. The id is the package name
  for `.package`, or the `id` you pass to the main constructor.

## Options

```dart
PlayxTranslationSource(
  id: 'my_package',
  path: 'assets/i18n',                  // base path
  loader: const MyCustomAssetLoader(),  // default: reads from the asset bundle
  namespace: 'my_package',
)

PlayxTranslationSource.package(
  package: 'my_package',
  path: 'assets/i18n',                  // inside the package, default assets/translations
)
```

## Removing

```dart
await PlayxLocalization.unregisterTranslations('my_package');
```

It returns `false` if nothing was registered with that id.

---

*Imported from the [playx_localization 1.0.0 documentation](https://github.com/playx-flutter/playx_localization/blob/main/doc/package-translations.md). [Package site](https://playx-flutter.github.io/playx_localization/) · [pub.dev](https://pub.dev/packages/playx_localization).*
