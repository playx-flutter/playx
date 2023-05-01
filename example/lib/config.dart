import 'package:playx/config/playx_app_config.dart';

class AppConfig extends PlayXAppConfig {
  @override
  String get appTitle => 'playx demo';

  @override
  Future<void> boot() async {
    // put anything here
    // like Get.put<ApiClient>(client);
  }
}
