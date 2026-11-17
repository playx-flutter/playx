# Testing

How to test your own code that uses `playx_core`, and how to run this package's tests.

- [A typical test setup](#a-typical-test-setup)
- [Preferences](#preferences)
- [Secure preferences](#secure-preferences)
- [Environment configuration](#environment-configuration)
- [Platform behavior](#platform-behavior)
- [Logging](#logging)
- [Web tests](#web-tests)
- [Testing the `secure_env` command](#testing-the-secure_env-command)
- [Running this package's tests](#running-this-packages-tests)

## A typical test setup

Boot the core with in-memory storage and no isolates, and dispose it after each test:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:playx_core/playx_core.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    PlayxPrefs.setMockInitialValues({});
    SharedPreferencesAsyncPlatform.instance = InMemorySharedPreferencesAsync.empty();

    await PlayxCore.bootCore(
      securePrefsSettings: const PlayxSecurePrefsSettings(
        storageType: PlayxSecureStorageType.memory,
        clearOnReinstall: false,
      ),
      workerManagerSettings: const WorkManagerSettings(initWorkerManager: false),
    );
  });

  tearDown(PlayxCore.dispose);

  test('stores the counter', () async {
    await PlayxPrefs.setInt('counter', 3);
    expect(PlayxPrefs.getInt('counter'), 3);
  });
}
```

Add `shared_preferences_platform_interface` as a `dev_dependency` to use the in-memory async store.

## Preferences

| Store | How to prepare it in tests |
| --- | --- |
| `PlayxPrefs` | `PlayxPrefs.setMockInitialValues({...})`, then `await PlayxPrefs.create()` |
| `PlayxAsyncPrefs`, `PlayxPrefsWithCache` | `SharedPreferencesAsyncPlatform.instance = InMemorySharedPreferencesAsync.empty()` (or `.withData({...})`), then `create()` |

```dart
PlayxPrefs.setMockInitialValues({'name': 'Jane'});
await PlayxPrefs.create();
expect(PlayxPrefs.getString('name'), 'Jane');
```

Reset between tests with `PlayxPrefs.clear()` / `dispose()`, or `PlayxCore.dispose()`.

## Secure preferences

Use the `memory` backend: no plugins, no platform channels.

```dart
await PlayxSecurePrefs.create(
  securePrefsSettings: const PlayxSecurePrefsSettings(
    storageType: PlayxSecureStorageType.memory,
    clearOnReinstall: false,
  ),
);
```

`clearOnReinstall: false` avoids touching `SharedPreferences` during setup. Call `await PlayxSecurePrefs.dispose()` afterwards.

To test **your fallback handling** (what happens when secure storage fails), fake the plugins' platform interfaces. This package's own tests do it, see [`test/prefs/secure_prefs_test.dart`](https://github.com/playx-flutter/playx_core/blob/main/test/prefs/secure_prefs_test.dart):

```dart
// Fakes for simple_secure_storage and flutter_secure_storage:
SimpleSecureStoragePlatform.instance = FakeSimpleSecureStorage()..failInitialize = true;
FlutterSecureStoragePlatform.instance = FakeFlutterSecureStorage();

await PlayxSecurePrefs.create(
  securePrefsSettings: const PlayxSecurePrefsSettings(storageType: PlayxSecureStorageType.auto),
);
expect(PlayxSecurePrefs.storageType, PlayxSecureStorageType.flutterSecureStorage);
```

## Environment configuration

Three ways, from simplest to most realistic:

**1. Set the values directly.**

```dart
PlayxEnv.setMockValues({'API_URL': 'http://localhost', 'RETRIES': '3'});
// ...
await PlayxEnv.dispose();
```

**2. Load `.env` text.**

```dart
PlayxEnv.loadFromString(
  'API_URL=http://localhost\nRETRIES=3',
  mergeWith: {'RETRIES': '5'},
  usePlayxDefines: false,   // ignore --dart-define values of the test run
);
```

**3. Load the real asset files.** `PlayxEnv.load` reads Flutter assets. In unit tests, serve them from memory:

```dart
void mockAssets(Map<String, String> files) {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMessageHandler('flutter/assets', (message) async {
    final key = utf8.decode(message!.buffer.asUint8List());
    final content = files[Uri.decodeFull(key)];
    if (content == null) return null;                          // missing file
    return ByteData.sublistView(Uint8List.fromList(utf8.encode(content)));
  });
}

setUp(() => mockAssets({
      '.env': 'API_URL=https://api.example.com',
      '.env.prod': 'API_URL=https://api.prod.example.com',
    }));

test('prod overrides the base', () async {
  await PlayxEnv.load(const PlayxEnvSettings(environment: 'prod'));
  expect(PlayxEnv.getString('API_URL'), 'https://api.prod.example.com');
});
```

Or load the files your app actually ships, as the [example app's tests](https://github.com/playx-flutter/playx_core/blob/main/example/test/env_test.dart) do (widget tests can read real assets).

**Build flags.** Tests can run with defines and flavors to cover those code paths:

```sh
flutter test --dart-define=PLAYX_ENV=prod
flutter test --dart-define=PLAYX_DEFINES="DEBUG=true"
flutter test --flavor staging
```

Because `usePlayxDefines` is on by default, a `PLAYX_DEFINES` value passed to the test run also applies to tests that don't expect it. Pass `usePlayxDefines: false` in such tests.

**Secure env.** Build `PlayxSecureEnvData` in the test with the same codec the command uses, or point a test at the generated file of your app:

```dart
import 'generated/playx_secure_env.g.dart';

await PlayxEnv.load(const PlayxEnvSettings(secureEnv: playxSecureEnv));
expect(PlayxEnv.isSecure('STRIPE_KEY'), isTrue);
```

## Platform behavior

**Platform checks** (`PlayxPlatform`) follow Flutter's override:

```dart
debugDefaultTargetPlatformOverride = TargetPlatform.android;
addTearDown(() => debugDefaultTargetPlatformOverride = null);

expect(PlayxPlatform.isAndroid, isTrue);
```

**System UI, orientation and clipboard** go through the `SystemChannels.platform` channel. Mock it to assert what is sent:

```dart
final calls = <MethodCall>[];
TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
    .setMockMethodCallHandler(SystemChannels.platform, (call) async {
  calls.add(call);
  return null;
});

setOrientation(isPortrait: false);

expect(calls.single.method, 'SystemChrome.setPreferredOrientations');
expect(calls.single.arguments, ['DeviceOrientation.landscapeLeft']);
```

`WebUtils` is a no-op outside the browser, so it needs no setup in VM tests.

## Logging

Capture output by giving the logger an `output`:

```dart
final lines = <String>[];
final logger = TalkerPlayxLogger(
  settings: PlayxLoggerSettings(enabled: true, printToConsole: true, useColors: false, output: lines.add),
  name: 'TEST',
);
logger.info('hello');
expect(lines.join(), contains('hello'));
```

`PlayxLogger.setDefaultLogger(...)` with a recording `PlayxBaseLogger` lets you assert on what the package logs. See [Logging](logging.md#your-own-logger).

## Web tests

Code that behaves differently on the web (`WebUtils`, the WebCrypto key store, secure prefs on web) is tested in a browser:

```dart
@TestOn('browser')
library;
```

```sh
flutter test --platform chrome test/utils/web_utils_web_test.dart
```

## Testing the `secure_env` command

The command is a function you can call from tests, with temporary directories and captured output:

```dart
import 'package:playx_core/secure_env_cli.dart';

final out = StringBuffer();
final code = await runSecureEnvCli(
  ['--env', 'prod'],
  environment: {'PLAYX_ENV': 'prod'},   // instead of the process environment
  workingDirectory: tempDir.path,
  stdoutSink: out,
  stderrSink: StringBuffer(),
  executableName: 'playx_core:secure_env',
);
expect(code, 0);
```

See [`test/env/secure_env_cli_test.dart`](https://github.com/playx-flutter/playx_core/blob/main/test/env/secure_env_cli_test.dart) for many examples, including decrypting the generated file.

## Running this package's tests

```sh
flutter test                                              # VM tests
flutter test --coverage                                   # writes coverage/lcov.info
flutter test --platform chrome test/prefs/secure_prefs_web_test.dart \
  test/env/secure_env_web_test.dart test/utils/web_utils_web_test.dart   # browser tests
```

Some tests only run when the matching build flag is passed, and are skipped otherwise:

```sh
flutter test test/env --dart-define=PLAYX_ENV=prod
flutter test test/env --flavor staging
flutter test test/env '--dart-define=PLAYX_DEFINES=PD_DEBUG=true;PD_NAME=define'
```

The `secure_env` define tests need `PLAYX_ENV_KEY` and `PLAYX_SECURE_DEFINES`; see the comments in [`test/env/secure_env_test.dart`](https://github.com/playx-flutter/playx_core/blob/main/test/env/secure_env_test.dart) for how to create them with the command.

---

*Imported from the [playx_core 2.0.0 documentation](https://github.com/playx-flutter/playx_core/blob/main/doc/testing.md). [Package site](https://playx-flutter.github.io/playx_core/) · [pub.dev](https://pub.dev/packages/playx_core).*
