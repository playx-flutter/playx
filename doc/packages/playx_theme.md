# playx_theme

[pub.dev](https://pub.dev/packages/playx_theme) · Used by Playx 3.0: **2.1.0** (2.x used 2.0.0)

Manage multiple app themes, switch between them with animations, define custom colors per
theme, and save the last theme automatically.

```dart
final config = PlayxThemeConfig(
  themes: [
    XTheme(id: 'light', name: 'Light', themeData: ThemeData.light()),
    XTheme(id: 'dark', name: 'Dark', themeData: ThemeData.dark()),
  ],
);

// Switch
PlayxTheme.updateById('dark');
PlayxTheme.toggleMode();

// Read
final isDark = context.isDarkMode;
final primary = context.colorScheme.primary;
```

Playx boots it in the **Theme** step and the [app widgets](../app-widgets.md) listen to it
through `PlayxThemeBuilder`, so the app rebuilds when the theme changes.

## What changed in 2.1.0

- **New:** `PlayxTheme.nextIndex` / `PlayxTheme.nextTheme` preview the theme `next()` switches to.
- **New:** `PlayxTheme.toggleMode()` and `context.themeMode`.
- **New:** `ThemeExtension` helpers — `XTheme.extension<T>()`, `context.themeExtension<T>()`,
  `context.maybeThemeExtension<T>()`.
- **New:** pluggable persistence with `PlayxThemeStorage` and `PlayxThemeConfig.storage`
  (`PlayxPrefsThemeStorage` default, `PlayxMemoryThemeStorage`).
- **New:** `PlayxThemeAnimation.lerp` interpolates `ThemeData` between themes.
- **Fix:** a saved theme index without a saved mode (from v1) is restored on boot.
- **Fix:** `XThemeController.dispose` is idempotent; the controller logger no longer crashes
  without `PlayxTheme.boot`.
- **Fix:** switching themes quickly can no longer leave a stale index saved; storage operations
  run in call order.
- **Fix:** the theme and theme mode change together, and the mode isn't changed when no theme
  matches (the call still throws).
- `PlayxThemeBuilder` no longer disposes a controller it doesn't own.
- Depends on `playx_core ^2.0.0`; SDK floor is Dart 3.12 / Flutter 3.44. Test coverage ~93%.

**Breaking changes:** none for apps already on 2.0.

## What changed in 2.0.0 (used by Playx 2.1.x)

2.0.0 added system theme mode support (`ThemeMode.system/light/dark`), `PlayxTheme.themeModeNotifier`,
`lightThemeIndex` / `darkThemeIndex`, `initialThemeMode`, and the `updateMode` flag on update methods.

## What it means for Playx

Nothing to change in your Playx setup. Playx 3.0 only moves to the 2.1.0 dependency (and its
new SDK floor).
