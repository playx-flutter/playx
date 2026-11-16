
# Command line tools

Two commands ship with the package. They run with plain `dart run`, no emulator needed,
and exit with a non-zero code when they find a problem, so they fit CI.

## Generate keys

Generates a class with a constant for every key in your base translation file, so you
get autocomplete and no typos.

```bash
dart run playx_localization:generate
```

| Option | Default | Description |
|---|---|---|
| `--source` | `assets/translations/en.json` | The base translation file. |
| `--output` | `lib/generated/app_trans.dart` | The Dart file to write. |
| `--class` | `AppTrans` | The generated class name. |
| `--check` | | Do not write, exit with `1` if the output is out of date. |

```dart
abstract class AppTrans {
  AppTrans._();

  /// My App
  static const appName = 'app_name';

  /// Home
  static const homeTitle = 'home.title';
}
```

```dart
AppTrans.appName.tr();
AppTrans.homeTitle.tr();
AppTrans.items.plural(3);   // a plural group is one key
```

- Nested keys become one constant, `home.title` is `homeTitle`, and its value is the real
  key so the lookup works.
- Linked files (`":/auth.json"`) are resolved.
- Each constant has the base text as a doc comment.
- Names that would clash with another constant get a number, and a warning is printed.

## Validate translations

Compares every locale with a base locale.

```bash
dart run playx_localization:validate
dart run playx_localization:validate --base en --src lib --strict
```

| Option | Default | Description |
|---|---|---|
| `--dir` | `assets/translations` | The translations folder. |
| `--base` | `en` | The reference locale. |
| `--src` | | Also report base keys never used in the Dart code in this folder. |
| `--strict` | | Treat warnings as errors. |

**Errors** (exit code `1`):

- a key missing in a locale,
- `{}` / `{name}` placeholders that differ from the base locale,
- a plural group without `other`,
- invalid JSON or a broken `:/linked.json` file.

**Warnings:**

- keys that exist in a locale but not in the base locale,
- empty values,
- keys unused in the code (with `--src`; a key counts as used when its string appears, or
  its generated constant is referenced),
- plural groups missing a form their language uses, for example Arabic `few` and `many`.

## In CI

```yaml
- run: dart run playx_localization:generate --check
- run: dart run playx_localization:validate --strict
```

You can also install them once with `dart pub global activate playx_localization` and
call `generate` and `validate` directly.

---

*Imported from the [playx_localization 1.0.0 documentation](https://github.com/playx-flutter/playx_localization/blob/main/doc/command-line-tools.md). [Package site](https://playx-flutter.github.io/playx_localization/) · [pub.dev](https://pub.dev/packages/playx_localization).*
