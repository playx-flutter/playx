# playx_widget

[pub.dev](https://pub.dev/packages/playx_widget) · [API docs](https://playx-flutter.github.io/playx_widget/) · Used by Playx 3.0: **0.6.0** (2.x used 0.5.0)

Utility widgets that make everyday Flutter development faster. It also re-exports
`cached_network_image`, `flutter_screenutil`, `flutter_svg`, `flutter_platform_widgets`,
`lottie`, `lucide_icons_flutter`, `package_info_plus`, `wolt_modal_sheet` and more, so Playx
apps get them from a single import.

| Widget | Purpose |
| --- | --- |
| `AppVersion` / `AppInfoNotifier` | Show or listen to app name, version, build number. |
| `ImageViewer`, `IconViewer` | Assets, network, cached or SVG images from one API. |
| `OptimizedTextField`, `AnimSearchBar` | Validated text field and animated search bar. |
| `OptimizedCard`, `OptimizedListTile` | Cards and list tiles with better shadows. |
| `ReadMoreText`, `StrokeText`, `Marquee` | Text helpers. |
| `showConfirmDialog`, `DateTimePicker` | Adaptive dialogs and pickers. |

The Playx [app widgets](../app-widgets.md) already wrap your app in `ScreenUtilInit`, so sizing
extensions such as `16.w` and `14.sp` work out of the box.

```dart
await AppInfoNotifier.instance.load();
const AppVersion(prefix: 'v', showVersionCode: true);

ReadMoreText(longText, trimCharsCount: 120);
FavoriteButton(isInFavorite: item.isFavorite, onFavoriteChanged: save);
```

## What changed in 0.6.0

### Breaking

- **Flutter** `>=3.44.0`.
- **`cached_network_image` ^4.0.6** (and `cached_network_image_platform_interface ^5.0.3`).
- **`lucide_icons_flutter` ^4.0.2** — weighted icons moved to separate libraries
  (`LucideIcons.activity300` is now `LucideIcons300.activity`, imported from
  `package:lucide_icons_flutter/lucide_icons_300.dart`). Regular icons are unchanged.
- `package_info_plus` ^10.2.2 (iOS 13 / macOS 10.15, Dart 3.11+).
- `FavoriteButton.onFavoriteChanged` is now `ValueChanged<bool>`.

### New

- `AppInfoNotifier` — a shared `ValueNotifier<AppInfo?>` with app name, package name, version, build
  number, signature and installer store, loaded once. `AppVersion` uses it, so `PackageInfo` is read
  once instead of on every rebuild.
- `AppVersion` gains `color`, `showStroke`, `strokeColor`.
- `ReadMoreText` trims at word boundaries, never splits emoji, and has a configurable `ellipsis`.
- `DateTimePicker`: `pickDateRange`, `endOfToday`, `label`, `use24hFormat`; Cupertino pickers return the
  picked value.
- Web: `ImageViewer.filePath(String)`, an HTML-element fallback for network images, SVG `errorBuilder`.
- `showConfirmDialog` closes on confirm and returns `true`; `onConfirmed` and `lottie` are optional.

### Fixes

`ImageViewer.network` never showing the image, `ImageViewer.icon` rendering nothing, `AppVersion`
ignoring `textAlign`, `FavoriteButton` not updating from its parent, dashed lines and
`AnimatedVisibility`, `AutoAnimatedList` diffing, `OptimizedTextField` timers, `AnimSearchBar` disposal,
`OptimizedCard` ripple and `Marquee` idle spinning. Widget tests were added.

> `wolt_modal_sheet` stays at `^0.11.0`: version 0.12 migrates to `material_ui`.

## What changed in 0.5.0 (used by Playx 2.1.x)

Added `lucide_icons_flutter`, updated `flutter_platform_widgets` (^10.0.1) and `font_awesome_flutter`
(^11.0.0), and removed the `cupertino_icons` export.

## What it means for Playx

Check any code that uses weighted Lucide icons or `FavoriteButton.onFavoriteChanged`. The Playx
app widgets are unaffected.
