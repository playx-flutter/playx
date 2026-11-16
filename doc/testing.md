# Testing

## Testing apps that use Playx

Booting Playx touches platform plugins, so mock them first and turn off what you don't need:

```dart
setUp(() {
  SharedPreferences.setMockInitialValues({});
  SharedPreferencesAsyncPlatform.instance = InMemorySharedPreferencesAsync.empty();
});

tearDown(() => Playx.dispose());

test('boots', () async {
  await Playx.boot(
    appConfigBuilder: () => MyAppConfig(),
    themeConfigBuilder: createThemeConfig,
    localeConfigBuilder: createLocaleConfig,
    securePrefsSettings: const PlayxSecurePrefsSettings(createSecurePrefs: false),
    workManagerSettings: const WorkManagerSettings(initWorkerManager: false),
  );
});
```

`SharedPreferencesAsyncPlatform` comes from `shared_preferences_platform_interface`
(`in_memory_shared_preferences_async.dart`). Translations are loaded from the asset bundle,
so tests need to answer `flutter/assets` requests for your translation files (see
`test/helpers/boot_helpers.dart` in this repository for a working example).

`Playx.dispose()` is `@visibleForTesting`. It disposes the app config and resets boot state
so the next test can boot again.

Use plain `test` (not `testWidgets`) for code that waits on real timers, because
`testWidgets` runs in fake async.

## Testing `ConnectionStatusController`

Mock the `connectivity_plus` channels:

```dart
const channel = MethodChannel('dev.fluttercommunity.plus/connectivity');
messenger.setMockMethodCallHandler(channel, (call) async => ['wifi']);
```

## How Playx itself is tested

```sh
flutter pub get
flutter test --coverage
```

Tests live in [`test/`](../test):

| File | Covers |
| --- | --- |
| `playx_boot_test.dart` | Boot, idempotency, `PlayxBootException`, async boot flags, dispose. |
| `run_playx_test.dart` | `runPlayx` with and without Sentry, env loading, boot failure. |
| `widgets_test.dart` | All four app widgets, Navigator / Router / GoRouter / GetX, Cupertino. |
| `connection_status_controller_test.dart` | Statuses, check types, lifecycle, dispose. |
| `models_test.dart`, `validators_test.dart` | Settings classes and validators. |

CI enforces **90%** line coverage (see [`.github/workflows/test.yml`](../.github/workflows/test.yml)).
