# Playx
Helps with redundant features , less code , more productivity , better organizing.

## Features

| name                      | short description                                                                      |  
| ------------------------- |----------------------------------------------------------------------------------------|  
| `Prefs` facade            | Key value pair storage powered by `SharedPreferences`                                  |  
| `PlayX.runPlayX` function | wraps`runApp` to inject , init ..etc what ever is necessary for   using this package   |  
| PlayXAppConfig            | install and setup any dependencies that are required by the app.                       |  
| AppTheme                  | easily create and mange app theme with the ability to easily change app theme.         |  
| exports                   | packages like `get` , `queen_validators`, `readable` ,`playx_theme`                    |  


### installation

in `pubspec.yaml` add these lines to `dependencies`

```yaml  
playx: ^0.0.6  
```  

### usage

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
        ),
        XTheme(
          id: 'light',
          nameBuilder: () => 'Light',
          theme: ThemeData.light(),
        ),
      ];
}
```

3. in `main` method call `PlayX.runPlayX` instead of `runApp`
   It will setup any dependencies in app config, initialize app theme and run the app.
```dart
void main() async {

  Playx.runPlayx(
    appConfig: AppConfig(),
    themeConfig: ThemeConfig(),
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
### See Also:
[playx_core](https://pub.dev/packages/playx_core) : core pakage of playx.
[Playx_theme](https://pub.dev/packages/playx_theme) :multi theme features for flutter apps from playx eco system