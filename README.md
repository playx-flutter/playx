
# Playx
[![pub package](https://img.shields.io/pub/v/playx.svg?color=1284C5)](https://pub.dev/packages/playx)

Playx eco system helps with redundant features as it provides many utilities for themes, widgets and more.


## Features
- `Prefs` :  Key value pair storage powered by `SharedPreferences`.
- `PlayX.runPlayX` : Wraps`runApp` to inject , init ..etc what ever is necessary for using this package.
- ``PlayXAppConfig`` : Install and setup any dependencies that are required by the app.
- ``AppTheme`` : Easily create and mange app theme with the ability to easily change app theme.
- `PlayxLocalization` : Easily manage and update app localization with a simple implementation and a lot of utilities.
- `playx_widget` :Contains custom utility widgets to make development faster like `OptimizedScrollView`  
  , `ImageViewer`, `AppVersion` and more.
- `playx_network` : Wrapper around Dio that can perform API requests with better error handling and easily get the result of any API request.
- ``exports`` : packages like `Get` , `queen_validators`, `readable` ,`playx_theme`, `package_info_plus`  
  , `flutter_svg` and `cached_network_image`, `lottie` , `async` and `sentry`  
  to make it easy to update packages from one place.  
  If you have many projects that depend on these packages you will need to update only `playx` package.


## Installation
In `pubspec.yaml` add these lines to `dependencies`
 ```yaml
  playx: ^1.0.0-beta.1
```    
## Usage
###  🔥  Create App configuration:
You can use it to initialize any needed dependencies before calling `runApp`.
```dart  
class AppConfig extends PlayXAppConfig {    
  @override    
  String get appTitle => "Sourcya App";    
    
  // setup and boot your dependencies here    
  @override    
  Future<void> boot() async {    
  final ApiClient client = ApiClient(dio);    
  Get.put<ApiClient>(client);    
  }    
}  
```  
###  🔥 Create Theme configuration.
Create a class that extends  `XThemeConfig`  then overrides it's themes method and provides it with all themes that your app needs to be able to customize your app theme.
Defaults to:
```dart  
class XDefaultThemeConfig extends XThemeConfig {  
  @override  
  List<XTheme> get themes => [  
        XTheme(  
          id: 'dark',  
          name: 'Dark',  
          theme:  (locale) => ThemeData.dark(),  
          colorScheme:DarkColorScheme(),  
        ),  
        XTheme(  
          id: 'light',  
          nameBuilder: () => 'Light',  
            theme: (locale) => ThemeData(
                  brightness: Brightness.light,
                  fontFamily: locale.isArabic ? 'Segoe UI' : 'Roboto',
                ),
          colorScheme:LightColorScheme(),  
        ),  
      ];  
}  
```  

For more information about how to customize app theme check out [`playx_theme`](https://pub.dev/packages/playx_theme) .


###  🔥  Create Locale configuration.
Create your own locale configuration with settings like supported locales, start locale, path to translations and more.

```dart
class AppLocaleConfig extends XLocaleConfig{

  AppLocaleConfig() : super(path: 'assets/translations',);

  @override
  List<XLocale> get supportedLocales => [
    //Make sure your passing language code and country code same as in your translation folder as described above.
    const XLocale(id: 'en', name: 'English', languageCode: 'en', countryCode: 'US'),
    const XLocale(id: 'ar', name: 'العربية', languageCode: 'ar'),
  ];

  @override
  XLocale? get startLocale => supportedLocales[0];

  @override
  XLocale? get fallbackLocale => supportedLocales[0];

}
```
To learn more about how to customize app locales check out [`playx_localization`](https://pub.dev/packages/playx_localization) .

###  🔥Run App with  `PlayX.runPlayX`
In `main` method you can call `PlayX.runPlayX` instead of `runApp`
It will setup any dependencies in app config, initialize app theme and run the app.  
use `PlayxMaterialApp` to configure orientation, theme , screen util and get material app settings.
```dart  
void main() async {  
  
  Playx.runPlayx(  
    appConfig: AppConfig(),  
    themeConfig: ThemeConfig(),  
    app: const MyApp(),
    //If sentry is needed in the project.  
    sentryOptions: (options) {
      options.dsn = AppConfig.sentryKey;
    },
    localeConfig: AppLocaleConfig(),
  );  
}  
```  

Now we have our app ready and setup with required dependecies, themes and locales with many utities and helpful packages to be used in the app.
## See Also:
[`playx_core`](https://pub.dev/packages/playx_core) : core package of playx.

[`Playx_theme`](https://pub.dev/packages/playx_theme) :multi theme features for flutter apps from playx eco system

[`Playx_widget`](https://pub.dev/packages/playx_widget) : Contains custom utility widgets to make development faster.
[`playx_localization`](https://pub.dev/packages/playx_localization) :Easily manage and update app localization with a simple implementation and a lot of utilities.

[`playx_version_update`](https://pub.dev/packages/playx_version_update)  : Easily show material update dialog in Android or Cupertino dialog in IOS with support for Google play in app updates.

[`playx_network`](https://pub.dev/packages/playx_network)  : Wrapper around Dio that can perform api request with better error handling and easily get the result of any api request.
