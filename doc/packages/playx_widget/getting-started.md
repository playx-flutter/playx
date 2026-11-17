# Getting started

## Requirements

- Flutter `>=3.44.0`, Dart `>=3.8.0 <4.0.0`

## Install

```yaml
dependencies:
  playx_widget: ^0.6.0
```

```dart
import 'package:playx_widget/playx_widget.dart';
```

## Set up ScreenUtil

Several widgets size text and spacing with `flutter_screenutil` (`12.sp`, etc.). Initialize it once at
the root of your app:

```dart
void main() {
  runApp(
    ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => const MaterialApp(home: HomePage()),
    ),
  );
}
```

Without `ScreenUtilInit`, widgets that default to `.sp` sizes (for example `AppVersion`) throw a
`LateInitializationError` unless you pass an explicit `textStyle` / `fontSize`.

## Upgrading to 0.6.0

- Requires Flutter `>=3.44.0`.
- `cached_network_image` 4.x and its platform interface 5.x depend on `material_ui`.
- `lucide_icons_flutter` 4.x moved weighted icons to separate libraries:
  `LucideIcons.activity300` is now `LucideIcons300.activity`
  (`import 'package:lucide_icons_flutter/lucide_icons_300.dart'`). Regular icons are unchanged.
- `package_info_plus` 10 requires iOS 13 / macOS 10.15.
- `wolt_modal_sheet` stays on `0.11.x`.
- `FavoriteButton.onFavoriteChanged` is now a `ValueChanged<bool>`.
- `ReadMoreText` appends a configurable `ellipsis` (default `'... '`).

---

*Imported from the [playx_widget 0.6.0 documentation](https://github.com/playx-flutter/playx_widget/blob/main/doc/getting-started.md). [Package site](https://playx-flutter.github.io/playx_widget/) · [pub.dev](https://pub.dev/packages/playx_widget).*
