import 'package:playx/playx.dart';

class AppConfig extends PlayXAppConfig {
  @override
  String get appTitle => 'playx demo';

  @override
  Future<void> boot() async {
    // put anything here
    // like Get.put<ApiClient>(client);
  }
}
