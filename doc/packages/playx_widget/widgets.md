# Widgets

Full API reference: <https://playx-flutter.github.io/playx_widget/>

## Display

- `AppVersion`: shows the app version (see [App info](app-info.md)).
- `ImageViewer`: images from assets, network, cached network, memory, files or SVG. Use `ImageViewer.filePath(path)` for picked images on every platform (web uses the blob URL).
- `IconViewer`: an icon from `IconData`, SVG, image or text.
- `StrokeText`: text with an outline.
- `ReadMoreText`: expands/collapses text past a character count; trims at word boundaries.
- `Marquee`: scrolls any widget horizontally.
- `CenterLoading`: centered loading indicator (`material`, `cupertino` or `adaptive`).

## Input

- `OptimizedTextField`: text field with auto validation and focus chaining.
- `AnimSearchBar`: search bar that animates between collapsed and expanded.
- `FavoriteButton`: animated favorite toggle; follows the parent's `isInFavorite`.
- `CustomInkWell`: standardized ink well.
- `DateTimePicker`: platform-adaptive `pickDate`, `pickTime`, `pickDateTime` and `pickDateRange` (`DatePickerPlatform`).
- `showConfirmDialog`: adaptive confirmation dialog.

## Layout and containers

- `OptimizedScrollView`: scroll view that fills the viewport between the last widget and the bottom.
- `OptimizedCard`, `OptimizedListTile`: cards and tiles with better shadows.
- `Box`, `SliverSizedBox`, `SpacingExtensions`: spacing helpers (`20.boxH`, `10.boxW`, `20.sliverH`).
- `BlurBox`: animated blur effect over a child.
- `DashedLine`, `VerticalDashedLine`: dashed separators.
- `KeepAliveWrapper`: keeps a child alive in lists/tabs.
- `AdaptiveWidget`: builds different widgets for small/medium/large mobile and tablets.
- `OrientationWidget`: separate builders for portrait and landscape.

## Animation and state

- `AutoAnimatedList`: animates insertions and removals.
- `FadeIndexedStack`: `IndexedStack` with fade transitions.
- `AnimatedVisibility`: fades a child and removes its space when hidden (unlike `AnimatedOpacity`).
- `TimerRefreshWidget`: rebuilds its child periodically.
- `MultiValueListenableBuilder`: rebuilds from several `ValueListenable`s.
- `AppInfoNotifier`: shared app info.


## Images on web

- `ImageViewer.network` falls back to an HTML `<img>` when the server has no CORS headers
  (`webHtmlElementStrategy`, default `fallback`).
- `ImageViewer.cachedNetwork` uses `imageRenderMethodForWeb`; pass `ImageRenderMethodForWeb.HtmlImage` for hosts
  without CORS.
- Picked images: `XFile.path` is a blob URL on web. Use `ImageViewer.filePath(xFile.path)` on every platform
  instead of branching on `kIsWeb`:

```dart
if (bytes != null) Image.memory(bytes!, fit: BoxFit.contain)
else if (file != null) ImageViewer.filePath(file!.path, errorBuilder: (_, _) => const PlaceholderImage())
else if (url != null) ImageViewer.cachedNetwork(url!)
```

## Date and time pickers

```dart
final date = await DateTimePicker.pickDate(context: context, label: 'Birth date');
final time = await DateTimePicker.pickTime(context: context, initialTime: TimeOfDay.now(), use24hFormat: true);
final dateTime = await DateTimePicker.pickDateTime(context: context, lastDate: DateTime(2100));
final range = await DateTimePicker.pickDateRange(
  context: context, firstDate: DateTime(2024), lastDate: DateTimePicker.endOfToday,
  startLabel: 'Start', endLabel: 'End',
);
```

Defaults: `firstDate` 2010, `lastDate` end of today (pass a later `lastDate` for future dates); `initialDate`
is clamped into range. Pass `cancelLabel` / `confirmLabel` for localized buttons.

---

*Imported from the [playx_widget 0.6.0 documentation](https://github.com/playx-flutter/playx_widget/blob/main/doc/widgets.md). [Package site](https://playx-flutter.github.io/playx_widget/) · [pub.dev](https://pub.dev/packages/playx_widget).*
