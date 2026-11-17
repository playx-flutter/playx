
# Testing

You can boot Playx Localization in tests with no assets and no real storage by using an
in-memory loader and `PlayxMemoryLocaleStorage`.

```dart
class MemoryAssetLoader extends AssetLoader {
  const MemoryAssetLoader(this.data);

  /// Translations by language tag, for example `{'en': {...}, 'ar': {...}}`.
  final Map<String, Map<String, dynamic>> data;

  @override
  Future<Map<String, dynamic>?> load(String path, Locale locale) async {
    final translations = data[locale.toLanguageTag()];
    if (translations == null) throw StateError('No translations for $locale');
    return translations;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('welcome is translated', () async {
    const en = XLocale(id: 'en', name: 'English', languageCode: 'en');

    await PlayxLocalization.boot(
      config: PlayxLocaleConfig(
        supportedLocales: const [en],
        assetLoader: const MemoryAssetLoader({
          'en': {'welcome': 'Welcome, {name}!'},
        }),
        storage: PlayxMemoryLocaleStorage(),
        logLocaleChanges: false,
      ),
    );

    expect('welcome'.tr(namedArgs: {'name': 'Sam'}), 'Welcome, Sam!');
  });
}
```

## Tips

- Each `boot` replaces the previous state, so tests can boot again with other locales.
- A fresh `PlayxMemoryLocaleStorage()` per test avoids a saved locale leaking between
  tests. To test restoring, share one storage between two boots.
- In widget tests wrap the widget in `PlayxLocalizationBuilder` and `await tester.pumpAndSettle()`
  so the delegates finish loading.
- To switch locales while a widget test runs, start the update and pump:
  `final result = PlayxLocalization.updateTo(ar); await tester.pumpAndSettle();`.
- Translation sources registered with `registerTranslations` stay registered between
  tests. Call `unregisterTranslations` in `tearDown`.

---

*Imported from the [playx_localization 1.0.0 documentation](https://github.com/playx-flutter/playx_localization/blob/main/doc/testing.md). [Package site](https://playx-flutter.github.io/playx_localization/) · [pub.dev](https://pub.dev/packages/playx_localization).*
