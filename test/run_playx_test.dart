import 'package:flutter_test/flutter_test.dart';
import 'package:playx/playx.dart';

import 'helpers/boot_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(mockBootPlatform);
  tearDown(() async {
    await Playx.dispose();
  });

  test('runPlayx boots Playx and then runs the app', () async {
    final calls = <String>[];

    await Playx.runPlayx(
      appRunner: () => calls.add('appRunner'),
      appConfigBuilder: () => FakeAppConfig(calls),
      localeConfigBuilder: fakeLocaleConfig,
      themeConfigBuilder: fakeThemeConfig,
      envSettingsBuilder: () =>
          const PlayxEnvSettings(fileName: 'assets/env/test.env'),
      securePrefsSettings: testSecurePrefsSettings,
      workManagerSettings: testWorkManagerSettings,
      webSettings: const PlayxWebSettings(usePathUrlStrategy: false),
    );
    await Playx.asyncBootFuture();

    expect(calls, containsAllInOrder(['boot', 'appRunner']));
    expect(calls, contains('asyncBoot'));
    expect(PlayxEnv.getString('API_KEY'), 'secret');
  });

  test('runPlayx supports an async appRunner', () async {
    final calls = <String>[];

    await Playx.runPlayx(
      appRunner: () async {
        await Future<void>.delayed(const Duration(milliseconds: 10));
        calls.add('appRunner');
      },
      appConfigBuilder: () => FakeAppConfig(calls),
      localeConfigBuilder: fakeLocaleConfig,
      themeConfigBuilder: fakeThemeConfig,
      securePrefsSettings: testSecurePrefsSettings,
      workManagerSettings: testWorkManagerSettings,
    );

    expect(calls, contains('appRunner'));
  });

  test('runPlayx does not run the app when boot fails', () async {
    final calls = <String>[];

    await expectLater(
      Playx.runPlayx(
        appRunner: () => calls.add('appRunner'),
        appConfigBuilder: () =>
            FakeAppConfig(calls, bootError: StateError('boom')),
        localeConfigBuilder: fakeLocaleConfig,
        themeConfigBuilder: fakeThemeConfig,
        securePrefsSettings: testSecurePrefsSettings,
        workManagerSettings: testWorkManagerSettings,
      ),
      throwsA(isA<PlayxBootException>()),
    );

    expect(calls, isNot(contains('appRunner')));
  });

  test('runPlayx boots inside Sentry when sentryOptions is set', () async {
    final calls = <String>[];

    await Playx.runPlayx(
      appRunner: () => calls.add('appRunner'),
      appConfigBuilder: () => FakeAppConfig(calls),
      localeConfigBuilder: fakeLocaleConfig,
      themeConfigBuilder: fakeThemeConfig,
      securePrefsSettings: testSecurePrefsSettings,
      workManagerSettings: testWorkManagerSettings,
      sentryOptions: (options) {
        options.dsn = '';
        options.autoInitializeNativeSdk = false;
      },
    );

    expect(calls, containsAllInOrder(['boot', 'appRunner']));
    await Sentry.close();
  });
}
