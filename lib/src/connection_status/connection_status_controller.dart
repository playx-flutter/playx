import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:playx/playx.dart';

/// An enumeration that represents the internet connection status.
enum ConnectionStatus {
  /// The device is connected to the internet.
  connected,

  /// The device is not connected to the internet.
  disconnected,

  /// The device lost connection but then restored it.
  connectionRestored;
}

/// A controller that monitors the internet connection status by checking the
/// device's connectivity and verifying internet access through multiple endpoints.
///
/// This class automatically updates the connection status and allows you to react
/// to changes in internet connectivity. It also manages the connection check interval
/// and handles lifecycle changes to pause or resume connectivity checks as needed.
class ConnectionStatusController extends ValueNotifier<ConnectionStatus>
    with WidgetsBindingObserver {
  final InternetConnection _internetConnection;
  StreamSubscription? _sub;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;

  /// Creates a [ConnectionStatusController] instance with the ability to customize
  /// the connection check interval and the URLs used to verify internet access.
  ///
  /// - [checkInterval]: The time interval between each connectivity check.
  ///   Defaults to 5 seconds.
  /// - [customCheckOptions]: A list of [InternetCheckOption] objects that specify
  ///   custom URLs and timeout durations for checking internet access. If not provided,
  ///   default options will be used.
  ConnectionStatusController({
    Duration checkInterval = const Duration(seconds: 5),
    List<InternetCheckOption>? customCheckOptions,
  })  : _internetConnection = _createInternetConnection(
            checkInterval: checkInterval,
            customCheckOptions: customCheckOptions),
        super(ConnectionStatus.connected) {
    WidgetsBinding.instance.addObserver(this);
    listenToConnectionStatus();
  }

  /// Indicates whether the device is currently connected to the internet.
  bool get isConnectedToInternet => value != ConnectionStatus.disconnected;

  /// Helper method to create an [InternetConnection] instance with the provided
  /// check interval and custom check options.
  static InternetConnection _createInternetConnection({
    Duration checkInterval = const Duration(seconds: 5),
    List<InternetCheckOption>? customCheckOptions,
  }) =>
      InternetConnection.createInstance(
        checkInterval: checkInterval,
        customCheckOptions: customCheckOptions ??
            [
              InternetCheckOption(
                  uri: Uri.parse('https://icanhazip.com/'),
                  timeout: 10.seconds),
              InternetCheckOption(
                uri: Uri.parse(
                  'https://jsonplaceholder.typicode.com/posts/1',
                ),
                timeout: 10.seconds,
              ),
              InternetCheckOption(
                  uri: Uri.parse('https://pokeapi.co/api/v2/pokemon/1'),
                  timeout: 10.seconds),
              InternetCheckOption(
                  uri: Uri.parse('https://reqres.in/api/users/1'),
                  timeout: 10.seconds),
              InternetCheckOption(
                  uri: Uri.parse('https://google.com'), timeout: 10.seconds),
            ],
        useDefaultOptions: false,
      );

  /// Monitors app lifecycle changes to manage the connection status check.
  /// Resumes listening when the app is in the foreground and stops when the app
  /// is paused or closed.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        listenToConnectionStatus();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        stopListeningToConnectionStatus();
        break;
      case AppLifecycleState.hidden:
        break;
    }
  }

  /// Manually checks the current internet connection status and updates
  /// the [ConnectionStatus] value accordingly.
  Future<void> checkInternetConnection() async {
    final bool hasInternetAccess = await _internetConnection.hasInternetAccess;

    _handleInternetConnection(
      isInternetConnected: hasInternetAccess,
    );
  }

  /// Starts listening to internet connection status changes and updates
  /// the [ConnectionStatus] value in real-time. Also checks the connection
  /// status immediately upon starting.
  Future<void> listenToConnectionStatus() async {
    stopListeningToConnectionStatus();
    checkInternetConnection();

    _sub = _internetConnection.onStatusChange.listen((event) async {
      _handleInternetConnection(
        isInternetConnected: event == InternetStatus.connected,
      );
    });

    _connectivitySub =
        Connectivity().onConnectivityChanged.listen((result) async {
      if (result.contains(ConnectivityResult.mobile) ||
          result.contains(ConnectivityResult.wifi)) {
        checkInternetConnection();
      } else {
        value = ConnectionStatus.disconnected;
      }
    });
  }

  /// Handles changes in the internet connection status and updates the [ConnectionStatus]
  /// value accordingly. If the connection is restored, it briefly shows `connectionRestored`
  /// before switching back to `connected`.
  Future<void> _handleInternetConnection({
    required bool isInternetConnected,
  }) async {
    if (isInternetConnected) {
      if (value != ConnectionStatus.connected) {
        value = ConnectionStatus.connectionRestored;
      }
      await Future.delayed(2.5.seconds);
      value = ConnectionStatus.connected;
    } else {
      value = ConnectionStatus.disconnected;
    }
  }

  /// Stops listening to internet connection status changes and cancels
  /// the ongoing subscription to prevent memory leaks.
  Future<void> stopListeningToConnectionStatus() async {
    _sub?.cancel();
    _sub = null;
    _connectivitySub?.cancel();
    _connectivitySub = null;
  }
}
