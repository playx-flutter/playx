
# Extensions

Helpers for text, numbers, dates and locales. Most of them use the current locale when
you don't pass one.

## BuildContext

They rebuild when the locale changes.

| Member | Description |
|---|---|
| `tr`, `plural` | Translate, see [Translating text](translating-text.md). |
| `currentXLocale`, `currentLocale` | The active locale. |
| `localeTag` | `ar`, `en-US`, `zh-Hant-TW`. |
| `currentLanguageCode` | `ar`, `en`. |
| `fontFamily` | The `fontFamily` of the `XLocale`. |
| `isCurrentLocaleArabic`, `isCurrentLocaleEnglish` | Language checks. |
| `isCurrentLocaleRtl`, `isCurrentLocaleLtr` | Text direction of the locale. |
| `isDeviceLocaleSelected` | `true` while following the device. |

## String

| Member | Example |
|---|---|
| `isRtl`, `isLtr` | `'مرحبا'.isRtl` is `true`. |
| `isEnglish`, `isArabic` | Contains any English / Arabic letter. |
| `containsOnlyEnglish`, `containsOnlyArabic` | Only letters of that language and spaces. |
| `hasNumbers` | Contains a digit. |
| `stripDiacritics` | Removes Arabic tashkeel. |
| `normalizeArabicLetters()` | `أ إ آ` to `ا`, `ى` to `ي`, `ة` to `ه`. |
| `toArabicIndicDigits()` | `'123'` to `'١٢٣'`. |
| `toEnglishDigits()` | `'١٢٣'` to `'123'`. |
| `toLocalizedDigits()` | Arabic digits when the current locale is Arabic, else English. |
| `removeExtraSpaces()` | `'a   b '` to `'a b'`. |
| `toLocale()` | `'zh_Hant_TW'` to a `Locale`. |

## Numbers

```dart
1234.5.toFormattedCurrencyNumber(currencySymbol: r'$');   // $1,234.50
1234.5.toLocalizedCurrencyNumber();                       // follows the current locale
1234.5.toLocalizedNumber();                               // follows the current locale's symbols
1234.5.toFormattedNumber(format: '#,##0.0', locale: 'en'); // 1,234.5
7.toLocalizedArabicOrEnglishNumber();                     // ٧ in Arabic, 7 otherwise
7.toLocalizedArabicNumber();                              // ٧
7.toLocalizedEnglishNumber();                             // 7
3.14159.roundToPrecision(numbersToRoundTo: 2);            // 3.14
0.00000001.isZero();                                      // true
```

`toLocalizedNumber` uses the symbols intl defines for the current locale, which for plain
`ar` are Western digits. To always get Arabic digits in an Arabic app use
`toLocalizedArabicOrEnglishNumber` or `toLocalizedCurrencyNumber`.

## Dates

```dart
DateTime.now().toFormattedDate(format: 'yyyy-MM-dd');   // uses the current locale
DateTime.now().toFormattedTime(format: 'hh:mm a');
DateTime.now().toFormattedDate(locale: 'de');           // explicit locale
```

The full locale is used, so `de-AT` gets Austrian month names. Date formats for a locale
need its date symbols to be initialized. The Material delegates do that for the supported
locales.

## Locale

```dart
const Locale('en').supports(const Locale('en', 'US'));   // true
const Locale('en', 'US').supports(const Locale('en', 'GB')); // false
const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant', countryCode: 'TW')
    .toStringWithSeparator();                              // zh-Hant-TW
```

---

*Imported from the [playx_localization 1.0.0 documentation](https://github.com/playx-flutter/playx_localization/blob/main/doc/extensions.md). [Package site](https://playx-flutter.github.io/playx_localization/) · [pub.dev](https://pub.dev/packages/playx_localization).*
