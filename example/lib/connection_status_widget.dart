import 'package:flutter/material.dart';
import 'package:playx/playx.dart';

class ConnectionStatusWidget extends StatefulWidget {
  final bool enableCheckingInternet;
  final bool retryOnConnectionRestored;
  final VoidCallback? onRetryClicked;

  const ConnectionStatusWidget({super.key,
    this.enableCheckingInternet = true,
    this.onRetryClicked,
    this.retryOnConnectionRestored = true,
  });

  @override
  State<ConnectionStatusWidget> createState() => _ConnectionStatusWidgetState();
}

class _ConnectionStatusWidgetState extends State<ConnectionStatusWidget> {
  ConnectionStatusController get controller =>
      Get.find<ConnectionStatusController>();

  String msg = '';

  @override
  void initState() {
    super.initState();
    if (widget.enableCheckingInternet) {
      listenToConnectionStatus();
      controller.addListener(listenToConnectionStatus);
    } else {
      stopListeningToConnectionStatus();
    }
  }

  void listenToConnectionStatus() {
    final status = controller.value;
    if (mounted) {
      switch (status) {
        case ConnectionStatus.connected:
          setState(() {
            msg = 'Connected to Internet';
          });
        case ConnectionStatus.disconnected:
          setState(() {
            msg = 'Disconnected From Internet';
          });
        case ConnectionStatus.connectionRestored:
          setState(() {
            msg = 'Connection RESTORED INTERNET';
          });
          if (widget.retryOnConnectionRestored) {
            widget.onRetryClicked?.call();
          }
      }
    }
  }

  void stopListeningToConnectionStatus() {
    controller.removeListener(listenToConnectionStatus);
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      msg,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
      ),
      textAlign: TextAlign.center,
    );
  }

  @override
  void dispose() {
    stopListeningToConnectionStatus();
    super.dispose();
  }
}
