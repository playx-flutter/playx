
# Playx

[![pub package](https://img.shields.io/pub/v/playx.svg?color=1284C5)](https://pub.dev/packages/playx)

Welcome to Playx, where simplicity meets functionality! Playx is an ecosystem designed to streamline your Flutter app development process by offering a plethora of utilities for themes, widgets, networking, and more.

## Features
- **PlayxPrefs**: Efficient key-value pair storage powered by SharedPreferences.
- **PlayX.runPlayX**: Simplifies app initialization by wrapping runApp and providing injection capabilities.
- **AppConfig**: Enables hassle-free installation and setup of app dependencies.
- **AppTheme**: Facilitates the creation and management of app themes with seamless theme switching.
- **PlayxLocalization**: Effortlessly manage app localization with a straightforward implementation and an array of utilities.
- **playx_widget**: Offers a collection of custom utility widgets like OptimizedScrollView, ImageViewer, and AppVersion to expedite development.
- **playx_network**: Enhances Dio with improved error handling and simplified API request handling.
- **exports**: Conveniently manage package updates for dependencies like Get, async, and more from a single location. Only one import is needed to access all the packages.

## Installation
To integrate Playx into your project, add the following line to your `pubspec.yaml` file:

```yaml  
playx: ^1.2.0  
```  

## Usage
### 🔥 Create App Configuration:
Initialize dependencies before calling `runApp` using AppConfig.

```dart  
class AppConfig extends PlayXAppConfig {  
  @override  
  Future<void> boot() async {  
    final ApiClient client = ApiClient(dio);  
    Get.put<ApiClient>(client);  
  }  
}  
```  

### 🔥 Create Theme Configuration:
Customize your app's theme settings including themes, colors, and fonts.

```dart  
PlayxThemeConfig createThemeConfig() {  
  return PlayxThemeConfig(  
    themes: [  
      // Define your themes here  
    ],  
  );  
}  
```  
Check out [`playx_theme`](https://pub.dev/packages/playx_theme) for detailed theme customization.

### 🔥 Create Locale Configuration:
Configure app locales with settings like supported locales and path to translations.

```dart  
PlayxLocaleConfig createLocaleConfig() {  
  return PlayxLocaleConfig(  
    // Customize your locale settings here  
  );  
}  
```  
Explore [`playx_localization`](https://pub.dev/packages/playx_localization) for efficient app localization management.

### 🔥 Run App with `PlayX.runPlayX`:
Initialize dependencies, themes, and locales effortlessly with `PlayX.runPlayX`.

```dart  
void main() async {  
  Playx.runPlayx(  
    appConfig: config,  
    themeConfig: createThemeConfig(),  
    envSettings: const PlayxEnvSettings(  
      fileName: 'assets/env/keys.env',  
    ),  
    localeConfig: createLocaleConfig(),  
    app: const MyApp(),  
    sentryOptions: (options) {  
      options.dsn = AppConfig.sentryKey;  
    },  
  );  
}  
```  

### 🔥Network Requests with `playx_network`:

playx_network is a Wrapper around Dio that can perform api request with better error handling and easily get the result of any api request.
We can use  `PlayxNetworkClient`  to perform GET, POST, PUT,, and DELETE HTTP methods for retrieving from and sending data to a server.

To use it we need to :

-   Setup  `PlayxNetworkClient`  an configure it based on your needs. You should create only one instance of this network client to be used for the app depending on your use case.

    ```dart
    final PlayxNetworkClient _client = PlayxNetworkClient(
       //you can customize your dio options like base URL, connection time out.
       dio: Dio(
         BaseOptions(
           baseUrl: _baseUrl,
           connectTimeout: const Duration(seconds: 20),
           senTimeout: const Duration(seconds: 20),
         ),
       ),
       customHeaders: () async => {
         'authorization': 'Bearer token'
       },  
       errorMapper: (json) {
         if (json.containsKey('message')) {
           return json['message'] as String? ;
         }
         return null;
       },
     );
    
    ```

-   Now we can use the client to perform any GET, POST, PUT, and DELETE HTTP method.

    For example we will perfrom a  `GET`  request that gets list of cats using this api :  `https://api.thecatapi.com/v1/images/search?limit=10`

    -   First create a model for the data returned from the api. It should contain a from json function that takes dynamic json and converts it to the model.

        ```dart
        class Cat {
           String? id;
           String? url;
           num? width;
           num? height;
        
          Cat({
            this.id, 
            this.url, 
            this.width, 
            this.height,});
        
            Cat.fromJson(dynamic json) {
                  id = json['id'];
                  url = json['url'];
                 width = json['width'];
                height = json['height'];
              }
        ```

    -   Perform the GET request :

        ```dart
            //gets list f cats by getting cats endpoint.
            final result = await _client.getList(catsEndpoint,
            // pass your own queries.
            query: {
              'limit': '10',
            },
            // Pass the from json function that was created in the cat model.
            fromJson: Cat.fromJson);
        
        ```

    -   Handle The request result :

        ```dart
          result.when(success: (cats) {
          //Handles success here as it returns list of cats.
          }, error: (error) {
            //handle error here and display the error message.
            print("Error is : ${error.message}");
         });
        
        ```

        Just like that you can perform any GET, POST, PUT, and DELETE HTTP method and return it's result whether success or failure with better error handling.


## See Also:
- [`playx_core`](https://pub.dev/packages/playx_core): Core package of Playx.
- [`playx_theme`](https://pub.dev/packages/playx_theme): Multi-theme features for Flutter apps.
- [`playx_widget`](https://pub.dev/packages/playx_widget): Custom utility widgets for faster development.
- [`playx_localization`](https://pub.dev/packages/playx_localization): Efficient app localization management.
- [`playx_version_update`](https://pub.dev/packages/playx_version_update): Simplified update dialogs for Android and iOS.
- [`playx_network`](https://pub.dev/packages/playx_network): Enhanced Dio wrapper for API requests.
