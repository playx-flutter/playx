# Migrating to playx_widget 0.6

Playx 3.0 uses `playx_widget` 0.6.0 (Playx 2.x used 0.5.0). 0.6 raises the Flutter version and
updates several dependencies with breaking changes.

## Checklist

1. [Upgrade Flutter](#1-upgrade-flutter)
2. [Weighted Lucide icons](#2-weighted-lucide-icons)
3. [`FavoriteButton.onFavoriteChanged`](#3-favoritebuttononfavoritechanged)
4. [Platform requirements](#4-platform-requirements)
5. [Behavior changes](#5-behavior-changes)

## 1. Upgrade Flutter

`playx_widget` 0.6 requires **Flutter `>=3.44.0`** (Dart `>=3.8.0 <4.0.0`). Playx 3.0 itself needs
Dart 3.12 because of the other ecosystem packages.

`cached_network_image` is now `^4.0.6` (with `cached_network_image_platform_interface ^5.0.3`) and
depends on `material_ui`. If you use `cached_network_image` directly, update your own constraint to
match.

## 2. Weighted Lucide icons

`lucide_icons_flutter` is now `^4.0.2`. Weighted icons moved to separate libraries. Regular icons are
unchanged.

```dart
// Before
Icon(LucideIcons.activity300)

// After
import 'package:lucide_icons_flutter/lucide_icons_300.dart';

Icon(LucideIcons300.activity)
```

## 3. `FavoriteButton.onFavoriteChanged`

`onFavoriteChanged` is now a `ValueChanged<bool>`. The button also updates when `isInFavorite`
changes from its parent.

```dart
FavoriteButton(
  isInFavorite: item.isFavorite,
  onFavoriteChanged: (isFavorite) => save(isFavorite),
)
```

## 4. Platform requirements

`package_info_plus` is `^10.2.2`, which needs **iOS 13 / macOS 10.15** and Dart 3.11+. Raise the
deployment target in `ios/Podfile` and `macos/Podfile` if they are lower.

## 5. Behavior changes

- `AppVersion` now reads from a shared `AppInfoNotifier`, so `PackageInfo` is loaded once instead of
  on every rebuild. Call `await AppInfoNotifier.instance.load()` early (for example in `main`) so the
  info is ready when `AppVersion` is first built.
- `showConfirmDialog` closes on confirm and returns `true`; `onConfirmed` and `lottie` are optional.
- `DateTimePicker`: Cupertino pickers return the picked value, clamp `initialDate` and respect
  `initialTime`. Cancelling the time step of `pickDateTime` returns `null`.
- `ReadMoreText` trims at word boundaries, never splits emoji, and appends a configurable
  `ellipsis`.
- `ImageViewer.file` loads picked paths as URLs on web. Use `ImageViewer.filePath(String)` for a
  path that works on every platform. Network images fall back to an HTML element on web
  (`webHtmlElementStrategy`).
- `wolt_modal_sheet` stays at `^0.11.0`. Version 0.12 migrates to `material_ui` and changes
  `WoltModalSheetThemeData`, so don't upgrade it yet.

## From 0.4 to 0.5 (if you skipped it)

- `cupertino_icons` is **no longer exported** from `playx_widget.dart`. Add `cupertino_icons` to your
  own `pubspec.yaml` if you use `CupertinoIcons`.
- `flutter_platform_widgets` is `^10.0.1`, `font_awesome_flutter` is `^11.0.0`, and
  `lucide_icons_flutter` was added.
- Flutter `>=3.38.0`.

## What did not change

The widget APIs not mentioned above are unchanged. See
[the Playx guide](../playx_widget.md#what-changed-in-060) for the full list of fixes and additions.
