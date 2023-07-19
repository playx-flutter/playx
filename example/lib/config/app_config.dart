import 'package:playx/playx.dart';

class AppConfig extends PlayXAppConfig {
  @override
  String get appTitle => 'playx demo';

  static const String sentryKey = 'https://example@sentry.io/add-your-dsn-here';

  @override
  Future<void> boot() async {
    // put anything here
    // like Get.put<ApiClient>(client);
    //nice logging client
    Fimber.plantTree(DebugTree());

    final apiClient =  PlayxNetworkClient(
      dio: Dio(
        BaseOptions(
          baseUrl: 'https://api.open-meteo.com/v1/',
          connectTimeout: const Duration(seconds: 20),
          sendTimeout: const Duration(seconds: 20),
        ),
      ),
    );
    Get.put<PlayxNetworkClient>(apiClient);

  }
}
