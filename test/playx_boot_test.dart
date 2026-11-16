import 'package:flutter_test/flutter_test.dart';
import 'package:playx/playx.dart';

import 'helpers/boot_helpers.dart';

Future<void> bootPlayx(
  List<String> calls, {
  Object? bootError,
  Object? asyncBootError,
  Future<void>? asyncBootGate,
  bool initializeBinding = true,
}) {
  return Playx.boot(
    appConfigBuilder: () => FakeAppConfig(
      calls,
      bootError: bootError,
      asyncBootError: asyncBootError,
      asyncBootGate: asyncBootGate,
    ),
    localeConfigBuilder: fakeLocaleConfig,
    themeConfigBuilder: fakeThemeConfig,
    securePrefsSettings: testSecurePrefsSettings,
    prefsSettings: testPrefsSettings,
    workManagerSettings: testWorkManagerSettings,
    initializeBinding: initializeBinding,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(mockBootPlatform);
  tearDown(() async {
    await Playx.dispose();
  });

  group('Playx.boot', () {
    test('boots the app config and exposes it', () async {
      final calls = <String>[];
      await bootPlayx(calls);

      expect(calls, contains('boot'));
      expect(Playx.appConfig, isA<FakeAppConfig>());
    });

    test('throws when the app config is read before booting', () {
      expect(() => Playx.appConfig, throwsException);
    });

    test('runs the async boot after boot', () async {
      final calls = <String>[];
      await bootPlayx(calls);
      await Playx.asyncBootFuture();

      expect(calls, ['boot', 'asyncBoot']);
      expect(Playx.isAsyncBootCompleted(), isTrue);
      expect(Playx.isAsyncBootFinished(), isTrue);
      expect(Playx.hasAsyncBootFailed(), isFalse);
      expect(Playx.asyncBootError, isNull);
      expect(await Playx.waitForAsyncBoot(), isTrue);
    });

    test('works when the binding is initialized by the caller', () async {
      final calls = <String>[];
      await bootPlayx(calls, initializeBinding: false);
      expect(calls, contains('boot'));
    });

    test('calling boot twice boots only once', () async {
      final calls = <String>[];
      final first = bootPlayx(calls);
      final second = bootPlayx(calls);
      await Future.wait([first, second]);
      await Playx.asyncBootFuture();

      expect(calls.where((c) => c == 'boot'), hasLength(1));
      expect(calls.where((c) => c == 'asyncBoot'), hasLength(1));
    });

    test('is not finished while the async boot is still running', () async {
      final gate = Future<void>.delayed(const Duration(milliseconds: 50));
      await bootPlayx(<String>[], asyncBootGate: gate);

      expect(Playx.isAsyncBootFinished(), isFalse);
      await Playx.asyncBootFuture();
      expect(Playx.isAsyncBootFinished(), isTrue);
    });
  });

  group('Playx.boot failures', () {
    test('wraps a failing step in a PlayxBootException', () async {
      final error = StateError('config failed');

      await expectLater(
        bootPlayx(<String>[], bootError: error),
        throwsA(
          isA<PlayxBootException>()
              .having((e) => e.step, 'step', 'AppConfig')
              .having((e) => e.error, 'error', error),
        ),
      );
    });

    test('can retry boot after it failed', () async {
      final calls = <String>[];
      await expectLater(
        bootPlayx(calls, bootError: StateError('first')),
        throwsA(isA<PlayxBootException>()),
      );

      await bootPlayx(calls);
      expect(calls.where((c) => c == 'boot'), hasLength(2));
    });

    test('reports an async boot failure without throwing from boot', () async {
      final error = StateError('async failed');
      await bootPlayx(<String>[], asyncBootError: error);

      expect(await Playx.waitForAsyncBoot(), isFalse);
      expect(Playx.hasAsyncBootFailed(), isTrue);
      expect(Playx.isAsyncBootFinished(), isTrue);
      expect(Playx.isAsyncBootCompleted(), isFalse);
      expect(Playx.asyncBootError, error);
      expect(Playx.asyncBootStackTrace, isNotNull);
      await expectLater(Playx.asyncBootFuture(), throwsA(error));
    });
  });

  group('Playx.dispose', () {
    test('disposes the app config and resets the async boot state', () async {
      final calls = <String>[];
      await bootPlayx(calls);
      await Playx.asyncBootFuture();
      await Playx.dispose();

      expect(calls, contains('dispose'));
      expect(Playx.isAsyncBootCompleted(), isFalse);
      expect(Playx.hasAsyncBootFailed(), isFalse);
    });
  });
}
