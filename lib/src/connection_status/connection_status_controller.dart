import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:playx/playx.dart';

/// The type of connection check to perform.
enum ConnectionCheckType {
  /// Checks both device network connectivity and verifies actual internet access by pinging URLs.
  /// This is the most comprehensive check.
  both,

  /// Only verifies internet access by periodically pinging URLs, without listening to device network changes.
  /// Note: On Web, this requires URLs that support CORS.
  internet,

  /// Only checks if the device is connected to a local network (WiFi, mobile, etc.),
  /// without verifying actual internet access.
  /// Recommended for Web to avoid CORS issues and unnecessary pings.
  device,
}

/// An enumeration that represents the connection status.
enum ConnectionStatus {
  /// The device is connected.
  connected,

  /// The device is not connected.
  disconnected,

  /// The device lost connection but then restored it.
  connectionRestored,
}

/// A controller that monitors the connection status by checking the
/// device's connectivity. It can also verify internet access through multiple endpoints.
///
/// This class automatically updates the connection status and allows you to react
/// to changes in connectivity. It also manages the connection check interval
/// and handles lifecycle changes to pause or resume connectivity checks as needed.
class ConnectionStatusController extends ValueNotifier<ConnectionStatus>
    with WidgetsBindingObserver {
  InternetConnection? _internetConnection;
  StreamSubscription? _sub;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;

  final Connectivity connectivity = Connectivity();

  final Duration backOnlineDelay;

  /// The type of connection check to perform.
  final ConnectionCheckType checkType;

  bool _isCheckingEnabled;

  /// Whether connection monitoring is currently active.
  bool get isCheckingEnabled => _isCheckingEnabled;

  /// Creates a [ConnectionStatusController] instance with the ability to customize
  /// the connection check interval, the connection check type, and options.
  ///
  /// - [checkType]: Specifies the type of connection check to perform.
  ///   Defaults to `ConnectionCheckType.device` on Web and `ConnectionCheckType.both` otherwise.
  /// - [enableChecking]: Starts monitoring immediately upon creation if true.
  /// - [checkInterval]: The time interval between each connectivity check. Defaults to 5 seconds.
  /// - [customCheckOptions]: A list of [InternetCheckOption] providing custom URLs/timeouts.
  ConnectionStatusController({
    ConnectionCheckType? checkType,
    bool enableChecking = true,
    Duration checkInterval = const Duration(seconds: 5),
    List<InternetCheckOption>? customCheckOptions,
    this.backOnlineDelay = const Duration(seconds: 2),
  }) : checkType =
           checkType ??
           (kIsWeb ? ConnectionCheckType.device : ConnectionCheckType.both),
       _isCheckingEnabled = enableChecking,
       super(ConnectionStatus.connected) {
    if (this.checkType == ConnectionCheckType.both ||
        this.checkType == ConnectionCheckType.internet) {
      _internetConnection = _createInternetConnection(
        checkInterval: checkInterval,
        customCheckOptions: customCheckOptions,
      );
    }
    WidgetsBinding.instance.addObserver(this);

    if (_isCheckingEnabled) {
      listenToConnectionStatus();
    }
  }

  /// Indicates whether the device is currently connected.
  bool get isConnected => value != ConnectionStatus.disconnected;

  /// (Deprecated) Use [isConnected] instead.
  bool get isConnectedToInternet => isConnected;

  /// Enables or disables the connection checking mechanism dynamically.
  void setCheckingEnabled(bool enabled) {
    if (_isCheckingEnabled == enabled) return;
    _isCheckingEnabled = enabled;
    if (enabled) {
      listenToConnectionStatus();
    } else {
      stopListeningToConnectionStatus();
    }
  }

  /// Helper method to create an [InternetConnection] instance with the provided
  /// check interval and custom check options.
  static InternetConnection _createInternetConnection({
    Duration checkInterval = const Duration(seconds: 5),
    List<InternetCheckOption>? customCheckOptions,
  }) => InternetConnection.createInstance(
    checkInterval: checkInterval,
    customCheckOptions:
        customCheckOptions ??
        [
          InternetCheckOption(
            uri: Uri.parse('https://clients3.google.com/generate_204'),
            timeout: 5.seconds,
          ),
          InternetCheckOption(
            uri: Uri.parse('https://1.1.1.1/generate_204'),
            timeout: 5.seconds,
          ),
          InternetCheckOption(
            uri: Uri.parse('http://www.msftncsi.com/ncsi.txt'),
            timeout: 5.seconds,
          ),
          InternetCheckOption(
            uri: Uri.parse('http://captive.apple.com/hotspot-detect.html'),
            timeout: 5.seconds,
          ),
        ],
    useDefaultOptions: false,
  );

  /// Monitors app lifecycle changes to manage the connection status check.
  /// Resumes listening when the app is in the foreground and stops when the app
  /// is paused or closed.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_isCheckingEnabled) return;
    switch (state) {
      case AppLifecycleState.resumed:
        listenToConnectionStatus(fromLifecycleCallback: true);
        break;
      case AppLifecycleState.paused:
        stopListeningToConnectionStatus();
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        break;
      case AppLifecycleState.hidden:
        break;
    }
  }

  /// Manually checks the current connection status and updates
  /// the [ConnectionStatus] value accordingly.
  Future<void> checkInternetConnection() async {
    if (checkType == ConnectionCheckType.device) {
      final result = await connectivity.checkConnectivity();
      final isDeviceConnected =
          result.isNotEmpty &&
          !result.every((r) => r == ConnectivityResult.none);
      _handleInternetConnection(isInternetConnected: isDeviceConnected);
    } else {
      final bool hasInternetAccess =
          await _internetConnection?.hasInternetAccess ?? false;
      _handleInternetConnection(isInternetConnected: hasInternetAccess);
    }
  }

  /// Starts listening to connection status changes and updates
  /// the [ConnectionStatus] value in real-time. Also checks the connection
  /// status immediately upon starting.
  void listenToConnectionStatus({bool fromLifecycleCallback = false}) {
    stopListeningToConnectionStatus();
    if (!fromLifecycleCallback) {
      checkInternetConnection();
    }

    if ((checkType == ConnectionCheckType.both ||
            checkType == ConnectionCheckType.internet) &&
        _internetConnection != null) {
      _sub = _internetConnection!.onStatusChange.listen((event) {
        _handleInternetConnection(
          isInternetConnected: event == InternetStatus.connected,
        );
      });
    }

    if (checkType == ConnectionCheckType.both ||
        checkType == ConnectionCheckType.device) {
      _connectivitySub = connectivity.onConnectivityChanged.listen((result) {
        final isDeviceConnected =
            result.isNotEmpty &&
            !result.every((r) => r == ConnectivityResult.none);

        if (!isDeviceConnected) {
          value = ConnectionStatus.disconnected;
        } else {
          if (checkType == ConnectionCheckType.device) {
            _handleInternetConnection(isInternetConnected: true);
          } else {
            checkInternetConnection();
          }
        }
      });
    }
  }

  /// Handles changes in the connection status and updates the [ConnectionStatus]
  /// value accordingly. If the connection is restored, it briefly shows `connectionRestored`
  /// before switching back to `connected`.
  Future<void> _handleInternetConnection({
    required bool isInternetConnected,
  }) async {
    if (isInternetConnected) {
      if (value == ConnectionStatus.disconnected) {
        value = ConnectionStatus.connectionRestored;
        await Future.delayed(backOnlineDelay);
      }
      // Ensure we haven't gone offline during the delay.
      if (value != ConnectionStatus.disconnected) {
        value = ConnectionStatus.connected;
      }
    } else {
      value = ConnectionStatus.disconnected;
    }
  }

  /// Stops listening to internet connection status changes and cancels
  /// the ongoing subscription to prevent memory leaks.
  void stopListeningToConnectionStatus() {
    _sub?.cancel();
    _sub = null;
    _connectivitySub?.cancel();
    _connectivitySub = null;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    stopListeningToConnectionStatus();
    super.dispose();
  }
}
