/// PlayXAppConfig: used to add any configuration for the application.
/// and installing any dependencies needed before running the application
abstract class PlayXAppConfig {
  ///you can put here any dependencies that need to be installed with playx boot
  Future<void> boot();

  ///you can put here any dependencies that need to be installed with playx boot which are long running tasks that will be executed asynchronously.
  Future<void> asyncBoot();

  ///you can put here any dependencies that need to be disposed with playx dispose
  Future<void> dispose() async {}
}
