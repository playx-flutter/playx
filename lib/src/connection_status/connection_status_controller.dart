import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:playx/playx.dart';


/// Connection status enum
enum ConnectionStatus {
  connected,
  disconnected,
  connectionRestored;
}

/// Connection status controller that is used to check internet connection status by checking device connectivity and internet connection.
class ConnectionStatusController extends FullLifeCycleController with FullLifeCycleMixin {
  StreamSubscription? _sub;
  StreamSubscription? _deviceConnectionSub;

  final connectionStatus = Rx<ConnectionStatus>(ConnectionStatus.connected);

  bool get isConnectedToInternet => connectionStatus.value != ConnectionStatus.disconnected;


  @override
  void onInit() {
    super.onInit();
    listenToConnectionStatus();

  }

  Future<void> checkInternetConnection() async {
    final status = await InternetConnectionChecker().connectionStatus;

    _handleInternetConnection(
      isInternetConnected: status == InternetConnectionStatus.connected,
    );
  }

  Future<void> listenToConnectionStatus() async {
    stopListeningToConnectionStatus();
    checkInternetConnection();
    _deviceConnectionSub = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      checkInternetConnection();
    });

    _sub = InternetConnectionChecker().onStatusChange.listen((event) async {
      _handleInternetConnection(
        isInternetConnected: event == InternetConnectionStatus.connected,
      );
    });
  }

  Future<void> _handleInternetConnection({
    required bool isInternetConnected,
  }) async {
    if (isInternetConnected) {
      if (connectionStatus.value != ConnectionStatus.connected) {
        connectionStatus.value = ConnectionStatus.connectionRestored;
      }
      await threeSeconds();
      connectionStatus.value = ConnectionStatus.connected;
    } else {
      connectionStatus.value = ConnectionStatus.disconnected;
    }
  }

  Future<void> stopListeningToConnectionStatus() async {
    _sub?.cancel();
    _sub = null;
    _deviceConnectionSub?.cancel();
    _deviceConnectionSub = null;
  }

  @override
  void onDetached() {
  }

  @override
  void onHidden() {
  }

  @override
  void onInactive() {
  }

  @override
  void onPaused() {
    stopListeningToConnectionStatus();
  }

  @override
  void onResumed() {
    listenToConnectionStatus();
  }
}
