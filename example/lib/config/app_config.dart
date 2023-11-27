import 'package:flutter/foundation.dart';
import 'package:playx/playx.dart';

class AppConfig extends PlayXAppConfig {
  @override
  String get appTitle => 'playx demo';

  static const String sentryKey = 'https://example@sentry.io/add-your-dsn-here';

  @override
  Future<void> boot() async {
    if(kDebugMode){
      Fimber.plantTree(DebugTree());
    }

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

    Get.put(ConnectionStatusController());
  }

  @override
  Future<void> asyncBoot() async {

  }
}
