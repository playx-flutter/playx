/// PlayXAppConfig: This abstract class is designed to manage the configuration
/// of your application, including setting up and tearing down any necessary
/// dependencies. It provides a structured way to initialize and dispose of resources
/// when your app starts or stops.
abstract class PlayXAppConfig {
  /// Use this method to initialize any dependencies or resources required
  /// by your application before it starts running. This method is called
  /// during the app's boot process.
  ///
  /// Example usage:
  /// ```dart
  /// @override
  /// Future<void> boot() async {
  ///   // Initialize services, plugins, or any required resources here
  /// }
  /// ```
  Future<void> boot();

  /// This method is intended for initializing long-running tasks that should
  /// be executed asynchronously during the app's boot process. Use it to set
  /// up dependencies that can run in the background without blocking the main
  /// application thread.
  ///
  /// Example usage:
  /// ```dart
  /// @override
  /// Future<void> asyncBoot() async {
  ///   // Start background services, fetch data, etc.
  /// }
  /// ```
  Future<void> asyncBoot();

  /// Use this method to dispose of any dependencies or resources when
  /// your application is being terminated or no longer needs them. It
  /// ensures that resources are properly released to prevent memory leaks.
  ///
  /// Example usage:
  /// ```dart
  /// @override
  /// Future<void> dispose() async {
  ///   // Clean up services, close streams, etc.
  /// }
  /// ```
  Future<void> dispose() async {}
}
