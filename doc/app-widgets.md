# App widgets

Playx ships four app widgets. They replace `MaterialApp` / `CupertinoApp` / `GetMaterialApp`
and wire up the ecosystem for you:

- `PlayxThemeBuilder` — current theme from `playx_theme`
- `PlayxLocalizationBuilder` — locale, delegates and supported locales from `playx_localization`
- `ScreenUtilInit` — screen sizing from `playx_widget`
- navigation from `playx_navigation` (or GetX), with the Sentry navigator observer when enabled

| Widget | Based on | Navigation settings |
| --- | --- | --- |
| `PlayxMaterialApp` | `MaterialApp` | `PlayxNavigationSettings` |
| `PlayxPlatformApp` | `PlatformApp` (Material or Cupertino per platform) | `PlayxNavigationSettings` |
| `PlayxGetMaterialApp` | `GetMaterialApp` | `PlayxGetNavigationSettings` |
| `PlayxGetPlatformApp` | `GetPlatformApp` | `PlayxGetNavigationSettings` |

All of them accept `preferredOrientations` (default `[DeviceOrientation.portraitUp]`),
`screenSettings`, `themeSettings`, `navigationSettings` and `appSettings`. The platform
variants also accept `platformSettings`.

> Playx must be booted first (see [Booting Playx](booting.md)). These widgets read the
> theme and locale that boot sets up.

## `PlayxMaterialApp`

```dart
PlayxMaterialApp(
  appSettings: const PlayxAppSettings(title: 'My app'),
  screenSettings: const PlayxScreenSettings(designSize: Size(390, 844)),
  themeSettings: PlayxThemeSettings(
    onThemeChanged: (xTheme) => debugPrint('Theme: ${xTheme.id}'),
  ),
  navigationSettings: const PlayxNavigationSettings(home: HomePage()),
)
```

## Settings classes

### `PlayxNavigationSettings`

Three mutually exclusive modes:

```dart
// 1. Navigator
const PlayxNavigationSettings(
  home: HomePage(),
  routes: {'/settings': (_) => SettingsPage()},
  includeSentryNavigationObserver: true,
)

// 2. Router
PlayxNavigationSettings.router(
  routeInformationProvider: router.routeInformationProvider,
  routeInformationParser: router.routeInformationParser,
  routerDelegate: router.routerDelegate,
)

// 3. GoRouter (recommended with playx_navigation)
PlayxNavigationSettings.goRouter(
  goRouter: router,
  config: const PlayxPageConfig(waitForBinding: false), // optional global defaults
)
```

With `goRouter`, the app is wrapped in `PlayxNavigationBuilder`, so bindings, scopes, guards and
lifecycle callbacks work. See [playx_navigation](packages/playx_navigation.md).

### `PlayxGetNavigationSettings`

The GetX equivalent. It adds `getPages`, `defaultTransition`, `initialBinding`,
`smartManagement`, `routingCallback` and the other `GetMaterialApp` options. It also has a
`.router(...)` constructor.

```dart
PlayxGetMaterialApp(
  navigationSettings: PlayxGetNavigationSettings(
    initialRoute: '/',
    getPages: [GetPage(name: '/', page: () => const HomePage())],
  ),
)
```

> For `PlayxGetPlatformApp`, pass the home widget with its own `home:` parameter.

### `PlayxAppSettings`

`title`, `showPerformanceOverlay`, `checkerboardRasterCacheImages`,
`checkerboardOffscreenLayers`, `showSemanticsDebugger`, `debugShowCheckedModeBanner`,
`debugShowMaterialGrid`, `enableLog`, `shortcuts`, `actions`, `scrollBehavior` and
`localizationsDelegates` (added after Playx's own delegates).

### `PlayxThemeSettings`

`theme`, `darkTheme`, `themeMode`, `cupertinoTheme`, `highContrastTheme`,
`highContrastDarkTheme` and `onThemeChanged`. When `theme` is not set, the current `XTheme`
from `playx_theme` is used.

### `PlayxScreenSettings`

Options for `flutter_screenutil`: `designSize` (default `360x690`), `minTextAdapt`,
`splitScreenMode`, `useInheritedMediaQuery`, `rebuildFactor`, `fontSizeResolver`,
`ensureScreenSize` and `responsiveWidgets`.

### `PlayxPlatformSettings`

For the platform apps: `initialPlatform`, `iosUsesMaterialWidgets`,
`iosUseZeroPaddingForAppbarPlatformIcon`, `platformStyle` and
`wrapCupertinoAppBarMiddleWithMediaQuery`.

### `PlayxWebSettings`

Passed to `runPlayx` / `boot`:

```dart
const PlayxWebSettings(
  usePathUrlStrategy: true,                 // /path instead of /#/path
  optionURLReflectsImperativeAPIs: true,    // URL follows push/replace
)
```
