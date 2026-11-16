import 'dart:ui' show AppLifecycleState;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:playx/playx.dart';

const _methodChannel = MethodChannel('dev.fluttercommunity.plus/connectivity');
const _eventChannel = EventChannel(
  'dev.fluttercommunity.plus/connectivity_status',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  late List<String> connectivity;

  setUp(() {
    connectivity = ['wifi'];
    messenger.setMockMethodCallHandler(_methodChannel, (call) async {
      if (call.method == 'check') return connectivity;
      return null;
    });
    messenger.setMockStreamHandler(
      _eventChannel,
      MockStreamHandler.inline(onListen: (arguments, events) {}),
    );
  });

  tearDown(() {
    messenger.setMockMethodCallHandler(_methodChannel, null);
    messenger.setMockStreamHandler(_eventChannel, null);
  });

  ConnectionStatusController createController({
    bool enableChecking = true,
    Duration backOnlineDelay = Duration.zero,
  }) {
    return ConnectionStatusController(
      checkType: ConnectionCheckType.device,
      enableChecking: enableChecking,
      backOnlineDelay: backOnlineDelay,
    );
  }

  group('ConnectionStatusController (device check)', () {
    test('starts as connected', () {
      final controller = createController(enableChecking: false);
      addTearDown(controller.dispose);

      expect(controller.value, ConnectionStatus.connected);
      expect(controller.isConnected, isTrue);
      expect(controller.isConnectedToInternet, isTrue);
      expect(controller.isCheckingEnabled, isFalse);
      expect(controller.checkType, ConnectionCheckType.device);
    });

    test('stays connected when the device has a connection', () async {
      final controller = createController(enableChecking: false);
      addTearDown(controller.dispose);

      await controller.checkInternetConnection();

      expect(controller.value, ConnectionStatus.connected);
    });

    test('becomes disconnected when there is no connection', () async {
      connectivity = ['none'];
      final controller = createController(enableChecking: false);
      addTearDown(controller.dispose);

      await controller.checkInternetConnection();

      expect(controller.value, ConnectionStatus.disconnected);
      expect(controller.isConnected, isFalse);
    });

    test(
      'reports connectionRestored then connected after reconnecting',
      () async {
        connectivity = ['none'];
        final controller = createController(
          enableChecking: false,
          backOnlineDelay: const Duration(milliseconds: 20),
        );
        addTearDown(controller.dispose);
        await controller.checkInternetConnection();

        final statuses = <ConnectionStatus>[];
        controller.addListener(() => statuses.add(controller.value));
        connectivity = ['wifi'];
        await controller.checkInternetConnection();
        await Future<void>.delayed(const Duration(milliseconds: 60));

        expect(statuses, [
          ConnectionStatus.connectionRestored,
          ConnectionStatus.connected,
        ]);
      },
    );

    test('checks immediately when checking is enabled', () async {
      connectivity = ['none'];
      final controller = createController();
      addTearDown(controller.dispose);

      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(controller.value, ConnectionStatus.disconnected);
    });

    test('setCheckingEnabled starts and stops monitoring', () async {
      connectivity = ['none'];
      final controller = createController(enableChecking: false);
      addTearDown(controller.dispose);

      controller.setCheckingEnabled(true);
      expect(controller.isCheckingEnabled, isTrue);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(controller.value, ConnectionStatus.disconnected);

      controller.setCheckingEnabled(true);
      controller.setCheckingEnabled(false);
      expect(controller.isCheckingEnabled, isFalse);
    });

    test('pauses and resumes with the app lifecycle', () async {
      final controller = createController();
      addTearDown(controller.dispose);

      controller.didChangeAppLifecycleState(AppLifecycleState.paused);
      controller.didChangeAppLifecycleState(AppLifecycleState.inactive);
      controller.didChangeAppLifecycleState(AppLifecycleState.hidden);
      controller.didChangeAppLifecycleState(AppLifecycleState.detached);
      controller.didChangeAppLifecycleState(AppLifecycleState.resumed);

      expect(controller.isCheckingEnabled, isTrue);
    });

    test('ignores lifecycle changes when checking is disabled', () {
      final controller = createController(enableChecking: false);
      addTearDown(controller.dispose);

      controller.didChangeAppLifecycleState(AppLifecycleState.resumed);

      expect(controller.isCheckingEnabled, isFalse);
    });
  });

  group('ConnectionStatusController (internet check)', () {
    test('creates an internet connection for the internet check type', () {
      final controller = ConnectionStatusController(
        checkType: ConnectionCheckType.internet,
        enableChecking: false,
      );
      addTearDown(controller.dispose);

      expect(controller.checkType, ConnectionCheckType.internet);
    });

    test('is disconnected when no internet check URL is reachable', () async {
      final controller = ConnectionStatusController(
        checkType: ConnectionCheckType.internet,
        enableChecking: false,
        customCheckOptions: [
          InternetCheckOption(
            uri: Uri.parse('http://127.0.0.1:1/'),
            timeout: const Duration(milliseconds: 200),
          ),
        ],
      );
      addTearDown(controller.dispose);

      await controller.checkInternetConnection();

      expect(controller.value, ConnectionStatus.disconnected);
    });
  });
}
