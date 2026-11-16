
# Plurals

`plural()` picks the form of a text from a number, following the plural rules of the
language. Use `{}` where the number goes.

```json
{
  "item": {
    "one": "{} item",
    "other": "{} items"
  }
}
```

```dart
'item'.plural(1);   // 1 item
'item'.plural(5);   // 5 items
Text('item').plural(5);
context.plural('item', 5);
plural('item', 5);  // static function
```

!!! warning
    The `other` form is required.

## Nouns with numbers: Arabic

Arabic changes the noun with the count. Write all the forms in one entry:

```json
{
  "vehicle": {
    "one": "مركبة",
    "two": "مركبتان",
    "few": "{} مركبات",
    "many": "{} مركبة",
    "other": "{} مركبة"
  }
}
```

```dart
'vehicle'.plural(1);    // مركبة
'vehicle'.plural(2);    // مركبتان
'vehicle'.plural(3);    // 3 مركبات
'vehicle'.plural(11);   // 11 مركبة
'vehicle'.plural(100);  // 100 مركبة
```

| Form | Used for (Arabic) |
|---|---|
| `zero` | 0 |
| `one` | 1 |
| `two` | 2 |
| `few` | 3 to 10, 103 to 110, ... |
| `many` | 11 to 99, 111 to 199, ... |
| `other` | 100, 101, 102, ... and decimals |

Russian uses `one` (1, 21, 31), `few` (2 to 4, 22 to 24) and `many` (0, 5 to 20, 25 to
30), Polish and many other languages have their own sets.

### Arabic digits

Pass `localizeDigits` to show `٣` instead of `3`, or turn it on for the whole app:

```dart
'vehicle'.plural(3, localizeDigits: true);   // ٣ مركبات
'vehicle'.plural(11, localizeDigits: true);  // ١١ مركبة

PlayxLocaleConfig(localizePluralDigits: true, ...);

'vehicle'.plural(3);                         // ٣ مركبات
'vehicle'.plural(3, localizeDigits: false);  // 3 مركبات
```

Large numbers are grouped as well: `1250` becomes `١٬٢٥٠`. A custom `format` always
wins over `localizeDigits`.

## How the form is chosen

1. An exact `zero`, `one` or `two` form wins for 0, 1 and 2 in every language.
2. Otherwise the form the language's rule picks (`few`, `many`, ...).
3. If that form is missing, `other` is used.

So a simple `one` / `other` entry works in every language, and you only add the forms a
language needs. Decimals follow the rules too: `1.5` is not singular in English.

Set `ignorePluralRules: true` in the config to skip the language rules and only use
`zero`, `one`, `two` and `other`.

!!! note
    `validate` warns when a plural group misses a form its language uses, for example
    Arabic `few` and `many`. See [Command line tools](command-line-tools.md).

## Arguments

| Name | Type | Description |
|---|---|---|
| `value` | `num` | The number. |
| `args` | `List<String>` | Replaces `{}` from left to right. Defaults to the number. |
| `namedArgs` | `Map<String, String>` | Replaces `{name}`. |
| `name` | `String` | The name under which the number is available, `{name}`. |
| `format` | `NumberFormat` | Formats the number. |
| `localizeDigits` | `bool` | Show the number in the digits of the locale. |
| `locale` | `Locale` | Use the plural rules and text of this locale. |
| `translate` | `bool` | `false` returns the text as it is. |

```json
{
  "money": {
    "one": "You have {} dollar",
    "other": "You have {} dollars"
  },
  "money_args": {
    "one": "{} has {} dollar",
    "other": "{} has {} dollars"
  },
  "money_named": {
    "one": "{name} has {money} dollar",
    "other": "{name} has {money} dollars"
  }
}
```

```dart
'money'.plural(1000000, format: NumberFormat.compact());                // You have 1M dollars
'money_args'.plural(10.5, args: ['John', '10.5']);                      // John has 10.5 dollars
'money_named'.plural(10.5, namedArgs: {'name': 'Jane'}, name: 'money'); // Jane has 10.5 dollars
```

---

*Imported from the [playx_localization 1.0.0 documentation](https://github.com/playx-flutter/playx_localization/blob/main/doc/plurals.md). [Package site](https://playx-flutter.github.io/playx_localization/) · [pub.dev](https://pub.dev/packages/playx_localization).*
