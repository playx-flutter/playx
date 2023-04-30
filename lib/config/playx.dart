abstract class PlayXAppConfig {
  String get appTitle;

  ///you can put here any dependencies that need to be installed with playx boot
  Future<void> boot();
}
