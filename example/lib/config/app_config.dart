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
    final duration = 300.seconds;
    Fimber.d(
        'It takes ${duration.toSeconds()} to buy ${3000000.toFormattedCurrencyNumber()} SAR worth of items.');
  }
}
