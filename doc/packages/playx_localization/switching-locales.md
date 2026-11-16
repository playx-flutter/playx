
# Switching locales

All the update methods are on `PlayxLocalization` and return a `Future<bool>`: `true`
when the locale changed, `false` when it is not supported or its translations could not
be loaded. In both cases the current locale stays as it was.

```dart
await PlayxLocalization.updateTo(xLocale);
await PlayxLocalization.updateById('ar');
await PlayxLocalization.updateByIndex(1);
await PlayxLocalization.updateByLanguageCode(languageCode: 'zh', scriptCode: 'Hant');
await PlayxLocalization.updateToDeviceLocale();
await PlayxLocalization.nextLocale(); // cycles, handy for a toggle button
```

Every method takes `forceAppUpdate: true` to rebuild the whole app after the change. Use
it when parts of your UI call `tr()` without a `BuildContext`.

## Language picker example

```dart
ListView(
  children: [
    for (final locale in PlayxLocalization.supportedXLocales)
      RadioListTile<XLocale>(
        value: locale,
        groupValue: PlayxLocalization.currentXLocale,
        title: Text(locale.name),
        onChanged: (value) => PlayxLocalization.updateTo(value!),
      ),
  ],
)
```

Wrap it in `PlayxLocalizationBuilder` (or use `context.currentXLocale`) so the selection
rebuilds.

## Following the device language

`updateToDeviceLocale()` switches to the device locale and **saves that choice**, so the
app keeps following the device on the next starts, even when the user changes the system
language later. Selecting any other locale ends that. `PlayxLocalization.isDeviceLocaleSelected`
tells which one is active, so a picker can show a "System default" row.

A regional device locale matches a supported locale by language: an `ar-EG` device gets
`ar` if you only support `ar`. If the device language is not supported the method returns
`false`.

## Resetting

```dart
await PlayxLocalization.resetLocale();       // forget the saved locale
await PlayxLocalization.deleteSavedLocale(); // forget it without switching
```

`resetLocale` switches to what a fresh install would start with (`startLocale`, else the
device locale, else the fallback locale) and does not save it.

## Reading the current state

| Member | Description |
|---|---|
| `currentXLocale`, `currentLocale`, `currentIndex` | The active locale. |
| `supportedXLocales`, `supportedLocales` | What the config declared. |
| `fallbackLocale` | The fallback locale, `null` if fallback translations are off. |
| `deviceLocale` | The locale of the device. |
| `isDeviceLocaleSelected` | `true` while following the device. |
| `isCurrentLocaleArabic()`, `isCurrentLocaleEnglish()`, `isCurrentLocaleRtl()` | Quick checks. |
| `currentLocaleToString({separator})` | `ar`, `zh_Hant_TW`, ... |
| `localizationDelegates` | For `MaterialApp.localizationsDelegates`. |

Inside widgets, `BuildContext` has the same information and rebuilds with the locale:
`context.currentXLocale`, `context.currentLocale`, `context.localeTag`,
`context.fontFamily`, `context.isCurrentLocaleRtl`, and more. See
[Extensions](extensions.md).

## Fonts per locale

Give an `XLocale` a `fontFamily` and read it from the context:

```dart
const XLocale(id: 'ar', name: 'العربية', languageCode: 'ar', fontFamily: 'Cairo')

ThemeData(fontFamily: context.fontFamily)
```

---

*Imported from the [playx_localization 1.0.0 documentation](https://github.com/playx-flutter/playx_localization/blob/main/doc/switching-locales.md). [Package site](https://playx-flutter.github.io/playx_localization/) · [pub.dev](https://pub.dev/packages/playx_localization).*
