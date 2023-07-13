
# Playx  
 [![pub package](https://img.shields.io/pub/v/playx.svg?color=1284C5)](https://pub.dev/packages/playx)

 Playx eco system helps with redundant features as it provides many utilities for themes, widgets and more.


## Features  
 - `Prefs`  :  Key value pair storage powered by `SharedPreferences`.
 - `PlayX.runPlayX`  : Wraps`runApp` to inject , init ..etc what ever is necessary for using this package.
- ``PlayXAppConfig`` : Install and setup any dependencies that are required by the app.               
- ``AppTheme``  : Easily create and mange app theme with the ability to easily change app theme.  
-  `playx_widget` :Contains custom utility widgets to make development faster like `OptimizedScrollView`
    , `ImageViewer`, `AppVersion` and more.
- ``exports``  : packages like `Get` , `queen_validators`, `readable` ,`playx_theme`, `package_info_plus`
   , `flutter_svg` and `cached_network_image`, `lottie` , `async` and `sentry`
  to make it easy to update packages from one place.
  If you have many projects that depend on these packages you will need to update only `playx` package.
  
  
## Installation  
  
In `pubspec.yaml` add these lines to `dependencies`  
  
```yaml  
playx: ^0.1.2
```  
  
## Usage  
  
1.  create an app config class that extends ``PlayxAppConfig`` :
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
2. Create theme config to customize your app theme.
defaults to: 
```dart
class XDefaultThemeConfig extends XThemeConfig {
  @override
  List<XTheme> get themes => [
        XTheme(
          id: 'dark',
          nameBuilder: () => 'Dark',
          theme: ThemeData.dark(),
          colorScheme:LightColorScheme(),
        ),
        XTheme(
          id: 'light',
          nameBuilder: () => 'Light',
          theme: ThemeData.light(),
          colorScheme:DarkColorScheme(),
        ),
      ];
}
```

For more information about how to customize app theme check out [`playx_theme`](https://github.com/playx-flutter/playx_theme)

3. in `main` method call `PlayX.runPlayX` instead of `runApp` 
It will setup any dependencies in app config, initialize app theme and run the app. 
```dart
void main() async {

  Playx.runPlayx(
    appConfig: AppConfig(),
    themeConfig: ThemeConfig(),
    //If sentry is needed in the project.
    sentryOptions: (options) {
      options.dsn = AppConfig.sentryKey;
    },
    app:PlayXThemeBuilder(
      builder: (xTheme) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          theme: xTheme.theme,
          title: 'playx',
        );
      },
    ), 
  );
}
```
## See Also:
 [playx_core](https://pub.dev/packages/playx_core) : core package of playx.
 
[Playx_theme](https://pub.dev/packages/playx_theme) :multi theme features for flutter apps from playx eco system

[Playx_widget](https://pub.dev/packages/playx_widget) : Contains custom utility widgets to make development faster.
