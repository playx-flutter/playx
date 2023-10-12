## 1.0.0-beta.1
> Note: This release has breaking changes.
> Bumping version from(0.3.0-beta) to version(1.0.0-beta).

- Update packages.
- Update Playx `boot` and `runPlayx` methods to take PlayxEnvSettings parameter which is used to configure flutter_dotenv and load the .env file.
- Update example app to show example of loading keys from  .env file using `PlayxEnv`.
- Add `flutter_animate` package to the list of exported packages.

### BREAKING Changes
- Updated`PlayxMaterialApp` to take screenSettings, themeSettings, navigationSettings, appSettings in it's constructor to make it easy to configure the app.

## playx_core

### BREAKING Changes
- `Prefs` was renamed to `PlayxPrefs`.
- `SecurePrefs` was renamed to `PlayxSecurePrefs`.
- `SecurePrefsSettings` was renamed to `PlayxSecurePrefsSettings`.
-  `getString`, `getInt`, `getDouble` and `getBool` methods in `PlayxPrefs` now return non nullable value of it's type with the ability to provide it with a fallback that is returned if the key not found .
-  `getString`, `getInt`, `getDouble` and `getBool` methods in `PlayxSecurePrefsSettings` now return non nullable value of it's type with the ability to provide it with a fallback that is returned if the key not found .

### New features
- Update packages.
- Added `PlayxEnv` : Wrapper for configure any the application with global variables using a `.env` file`.
- Update `PlayxCore` `bootCore` method to take `PlayxEnvSettings` parameter which is used to configure `flutter_dotenv` and load the `.env` file.
- Added new `maybeGetString`, `maybeGetInt`, `maybeGetDouble` and `maybeGetBool` methods in `PlayxPrefs` which return the value of it's type or null if the key not found or any error happened .
- `maybeGetString`, `maybeGetInt`, `maybeGetDouble` and `maybeGetBool` methods in `PlayxSecurePrefsSettings` which return the value of it's type or null if the key not found or any error happened .

## playx_widget

### New Widgets

- DashedLine :Creates a dashed line widget.
- FadeIndexedStack : Creates an indexed Stack widget that paints a single child with fade animation.
- FavoriteButton :Creates a button that shows favorite state.


### Bug fixes and Enhancements

#### OptimizedCard

- Update OptimizedCard default shadowColor to not be transparent on Ios.
- Add the onPressed callback for the card to listen to any tapping events.
- Add borderRadius which can be used to set the border radius of the default card's rounded
  rectangular shape.

#### OptimizedTextField

- Add hintStyle to the text field to customize the hint text style.
- Enhancement to the text field in Ios when using `.adaptive` constructor.


## 0.3.0-beta.3
> Note: This release has breaking changes.
- Update packages.
- `PlayxAppConfig` now requires `asyncBoot` to be overridden.
- We can check whether `PlayxAppConfig` `asyncBoot` function is completed by calling `Playx.isAsyncBootCompleted` . 
- We can wait for  `PlayxAppConfig` `asyncBoot` function to complete by calling `Playx.asyncBootFuture`.


## 0.3.0-beta.2
- Update packages.
- Added platformSettings to `PlayxPlatformApp` that controls current platform settings.


## 0.3.0-beta.1

> Note: This release has breaking changes.
### New features

- Update packages.
- Added `PlayxPlatformApp` : A widget that wraps [GetMaterialApp] or [ GetCupertinoApp] based on the platform with support to `screen_util`, `playx_theme` and `playx_localization`.
- Added `asyncBoot` method that can be implemented by [PlayXAppConfig] to boot long running tasks asynchronously when launching the application.

## playx_widget
- include `flutter_platform_widgets` into the package to include platform specific widgets.
- fix errorMaxLines on `OptimizedTextField` not working correctly.

## playx_theme
- PlayxTheme now has `isDeviceInDarkMode` to indicate whether the user device is in dark mode or not.
  - XThemeConfig now has `defaultThemeIndex` to specify the default theme index that will be used first time as default theme.
  - new `ImageTheme` widget which is a widget that is themed by image content by providing image provider to be used with Material3 themes.
  - new utilities to be used like `getBlendedColorScheme` which blends two color schemes together and returns a new color scheme to be used with Material3 themes.
   - Included [`flex_seed_scheme`](https://pub.dev/packages/flex_seed_scheme) package which is more flexible and powerful version of Flutter's ColorScheme.fromSeed and uses multiple seed colors, custom chroma and tone mapping to enahce creating a color scheme for Material3.

### BREAKING Changes
  - `XColorScheme` was renamed to `XColors`.
  - a Removed abstract colors like primary, secondary, background,surface, error ,onPrimary, Color get onSecondary, onBackground, onSurface, onError from `XColors`.
  - `XTheme` colors property now have default value which is `DefaultColors`.



## 0.2.6
- Update packages.
- Update `PlayxMaterialApp` to include latest `ScreenUtil` parameters.

## 0.2.5
- Update packages.

## 0.2.4
- Update packages.
- Integrate `Playx_theme` updates into the app.


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
