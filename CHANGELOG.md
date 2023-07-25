## 0.2.3 
- Integrate `Playx_localization` package into this package.
- `Playx.boot` and `Playx.runPlayx` functions now require `XLocaleConfig` to define app localization. Check the example for more information.
- `Playx.boot` and `Playx.runPlayx` functions now boots also `Playx_localization` package so you don't need to worry about it.
- `PlayxMaterialApp` doesn't take any parameters that is about localization as localization is now done with `Playx_localization` package.



## 0.2.1 -0.2.2
- updated packages


## 0.2.0
- Add new `PlayxMaterialApp` which is a widget that wraps [GetMaterialApp] with [PlayXThemeBuilder] to update the app with current theme  and [ScreenUtilInit] that initializes [ScreenUtil]
with the ability to set app orientation and more.
- Add new playx package `playx_network` which is a wrapper around Dio that can perform API requests with better error handling and easily get the result of any API request.
- updated packages


## 0.1.5
- add `SecurePrefsSettings` to Playx.runPlayx function to be able to customize secure storage settings.


## 0.1.4
- updated packages

## 0.1.2 - 0.1.3
- updated packages


## 0.1.1
- updated packages


## 0.1.0
- Add support for Dart 3.0.0 and Flutter 3.10
- Add new `XColorScheme` in `playx_theme` which is a new way to configure custom colors for each themes.
- update packages
- Update `Playx.runPlayx` function to support Sentry.
- Add new packages like `Lottie`, `Sentry`, `Async` and `Fimber`
- Add `IsEqual` which validates text form fields.
- Update example project.

## 0.0.9
- hide `RContextMediaQuery` from `flutter_readable` package to avoid conflicts with `Getx` package.
- update exports.

## 0.0.8
- add `playx_widget` package which contains custom utility widgets to make development faster.

## 0.0.6 - 0.0.7
- add `AppConfing.boot()` to initialize default configuration
- update packages

## 0.0.5
- remove `sentry`
## 0.0.4

- add `Playx.boot()`
- update `playx_theme`
- typos

## 0.0.3

- update `playx_core` to 0.0.2
- export `playx_core`
- fix typos

## 0.0.2

- fix : Error: Undefined name 'kDebugMode'.

## 0.0.1

- initial release.
