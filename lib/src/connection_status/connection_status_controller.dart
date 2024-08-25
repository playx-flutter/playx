import 'dart:async';

import 'package:flutter_animate/flutter_animate.dart';
import 'package:playx/playx.dart';

/// Connection status enum
enum ConnectionStatus {
  connected,
  disconnected,
  connectionRestored;
}

/// Connection status controller that is used to check internet connection status by checking device connectivity and internet connection.
class ConnectionStatusController extends FullLifeCycleController
    with FullLifeCycleMixin {
  final InternetConnection _internetConnection;

  ConnectionStatusController(
      {Duration checkInterval = const Duration(seconds: 5),
      List<InternetCheckOption>? customCheckOptions})
      : _internetConnection = InternetConnection.createInstance(
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

  StreamSubscription? _sub;

  final connectionStatus = Rx<ConnectionStatus>(ConnectionStatus.connected);

  bool get isConnectedToInternet =>
      connectionStatus.value != ConnectionStatus.disconnected;

  @override
  void onInit() {
    super.onInit();
    listenToConnectionStatus();
  }

  Future<void> checkInternetConnection() async {
    final bool hasInternetAccess = await _internetConnection.hasInternetAccess;

    _handleInternetConnection(
      isInternetConnected: hasInternetAccess,
    );
  }

  Future<void> listenToConnectionStatus() async {
    stopListeningToConnectionStatus();
    checkInternetConnection();

    _sub = _internetConnection.onStatusChange.listen((event) async {
      _handleInternetConnection(
        isInternetConnected: event == InternetStatus.connected,
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
      await Future.delayed(3.seconds);
      connectionStatus.value = ConnectionStatus.connected;
    } else {
      connectionStatus.value = ConnectionStatus.disconnected;
    }
  }

  Future<void> stopListeningToConnectionStatus() async {
    _sub?.cancel();
    _sub = null;
  }

  @override
  void onDetached() {}

  @override
  void onHidden() {}

  @override
  void onInactive() {}

  @override
  void onPaused() {
    stopListeningToConnectionStatus();
  }

  @override
  void onResumed() {
    listenToConnectionStatus();
  }
}
