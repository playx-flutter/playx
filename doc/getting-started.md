# Getting started

## Requirements

- Dart `>=3.12.0 <4.0.0`
- Flutter `>=3.44.0`

## Install

```yaml
dependencies:
  playx: ^3.0.0
```

```dart
import 'package:playx/playx.dart';
```

One import gives you Playx and all of its ecosystem packages. See [Exports](exports.md).

## 1. App config

A `PlayXAppConfig` registers your app's dependencies. `boot` runs before the app starts.
`asyncBoot` runs in the background without blocking startup. `dispose` cleans up.

```dart
class AppConfig extends PlayXAppConfig {
  @override
  Future<void> boot() async {
    // Register dependencies the first screen needs.
    Get.put<ApiClient>(ApiClient());
  }

  @override
  Future<void> asyncBoot() async {
    // Warm up things that can finish later (caches, analytics, ...).
  }
}
```

## 2. Theme config

```dart
PlayxThemeConfig createThemeConfig() => PlayxThemeConfig(
  themes: [
    XTheme(id: 'light', name: 'Light', themeData: ThemeData.light()),
    XTheme(id: 'dark', name: 'Dark', themeData: ThemeData.dark()),
  ],
);
```

See [playx_theme](packages/playx_theme.md).

## 3. Locale config

```dart
PlayxLocaleConfig createLocaleConfig() {
  const english = XLocale(id: 'en', name: 'English', languageCode: 'en');
  return PlayxLocaleConfig(
    path: 'assets/translations',
    supportedLocales: const [
      english,
      XLocale(id: 'ar', name: 'العربية', languageCode: 'ar'),
    ],
    fallbackLocale: english,
  );
}
```

Declare the translations folder in `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/translations/
```

See [playx_localization](packages/playx_localization.md).

## 4. Run the app

```dart
void main() {
  Playx.runPlayx(
    appRunner: () => runApp(const MyApp()),
    appConfigBuilder: () => AppConfig(),
    themeConfigBuilder: createThemeConfig,
    localeConfigBuilder: createLocaleConfig,
    // Optional: load .env files into PlayxEnv.
    envSettingsBuilder: () => const PlayxEnvSettings(
      fileName: 'assets/env/keys.env',
    ),
    // Optional: report crashes to Sentry.
    // sentryOptions: (options) => options.dsn = 'https://...',
  );
}
```

`appRunner`, `appConfigBuilder`, `themeConfigBuilder` and `localeConfigBuilder` are required.
`envSettingsBuilder` is optional. Read more in [Booting Playx](booting.md).

## 5. Build the app

Use one of the [Playx app widgets](app-widgets.md). They connect theme, localization,
navigation, screen sizing and Sentry for you:

```dart
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return PlayxMaterialApp(
      appSettings: const PlayxAppSettings(title: 'My app'),
      navigationSettings: PlayxNavigationSettings.goRouter(goRouter: router),
    );
  }
}
```

## Next steps

- [Booting Playx](booting.md) — what happens on startup and how failures are reported.
- [App widgets](app-widgets.md) — all settings classes.
- [Ecosystem packages](packages/README.md) — what each package gives you.
