# Booting Playx

Playx starts your app in a fixed order. You can use `Playx.runPlayx` (boots, then runs
your app) or call `Playx.boot` yourself.

## `Playx.runPlayx`

```dart
await Playx.runPlayx(
  appRunner: () => runApp(const MyApp()),
  appConfigBuilder: () => AppConfig(),
  themeConfigBuilder: createThemeConfig,
  localeConfigBuilder: createLocaleConfig,
);
```

| Parameter | Required | Description |
| --- | --- | --- |
| `appRunner` | yes | Runs the app after Playx boots. May be `async`. |
| `appConfigBuilder` | yes | Returns your `PlayXAppConfig`. |
| `themeConfigBuilder` | yes | Returns the `PlayxThemeConfig`. |
| `localeConfigBuilder` | yes | Returns the `PlayxLocaleConfig`. |
| `envSettingsBuilder` | no | Returns `PlayxEnvSettings` to load `.env` files. |
| `securePrefsSettings` | no | Settings for `PlayxSecurePrefs`. |
| `prefsSettings` | no | Settings for `PlayxPrefs`, `PlayxAsyncPrefs` and `PlayxPrefsWithCache`. |
| `workManagerSettings` | no | Settings for the worker manager. |
| `webSettings` | no | `PlayxWebSettings` (path URL strategy). |
| `sentryOptions` | no | Enables Sentry; see [Sentry and web](#sentry-and-web). |
| `initializeBinding` | no | Whether to call `WidgetsFlutterBinding.ensureInitialized()` (default `true`). |

## Boot order

`Playx.boot` runs these steps in order. Each step is logged.

1. **Core** — `PlayxCore.bootCore`: preferences, secure preferences, env, worker manager.
2. **Localization** — `PlayxLocalization.boot`.
3. **Theme** — `PlayxTheme.boot`.
4. **AppConfig** — your `PlayXAppConfig.boot()`.
5. **Web navigation** — `PlayxNavigation.setupWeb`.
6. **Async boot** — your `PlayXAppConfig.asyncBoot()` starts in the background.

## Boot errors

If a step fails, boot throws a `PlayxBootException` that tells you which step failed and
keeps the original error and stack trace:

```dart
try {
  await Playx.boot(/* ... */);
} on PlayxBootException catch (e) {
  print('Boot failed at "${e.step}": ${e.error}');
}
```

`step` is one of `Core`, `Localization`, `Theme`, `AppConfig` or `Web navigation`.

## Boot is idempotent

Calling `Playx.boot` more than once returns the same boot instead of running it again,
including while the first call is still running. If a boot fails, it is cleared so you can
call `boot` again to retry.

## Async boot

`PlayXAppConfig.asyncBoot()` runs in the background so it never delays the first frame.
Track it with:

| API | Meaning |
| --- | --- |
| `Playx.isAsyncBootCompleted()` | `true` only if it finished **successfully**. |
| `Playx.hasAsyncBootFailed()` | `true` if it threw. |
| `Playx.isAsyncBootFinished()` | `true` once it is done, whether it succeeded or failed. |
| `Playx.asyncBootError` / `Playx.asyncBootStackTrace` | The failure details, or `null`. |
| `Playx.asyncBootFuture()` | Waits for it; rethrows the error if it failed. |
| `Playx.waitForAsyncBoot()` | Waits for it; returns `true`/`false` and never throws. |

A failure is logged and, when Sentry is enabled, reported with `Sentry.captureException`.
It never becomes an unhandled error just because nobody awaited it.

```dart
if (await Playx.waitForAsyncBoot()) {
  // ready
} else {
  showError(Playx.asyncBootError);
}
```

## Accessing the app config

After boot, `Playx.appConfig` returns the booted `PlayXAppConfig`. It throws before boot.
`Playx.dispose()` (meant for tests) disposes it and resets the state.

## Sentry and web

Pass `sentryOptions` to `runPlayx` to enable Sentry:

```dart
Playx.runPlayx(
  sentryOptions: (options) => options.dsn = 'https://...@sentry.io/123',
  // ...
);
```

When `sentryOptions` is set, Playx calls `SentryFlutter.init` and boots **inside Sentry's
`appRunner`**. Sentry runs the app in a guarded zone, and on Flutter web the binding and
`runApp` must be in the **same zone**. For that reason Playx never touches
`WidgetsFlutterBinding` before `SentryFlutter.init`: it is initialized inside the runner
instead (and, without Sentry, right before booting).

If your code already initializes the binding in the right zone, pass
`initializeBinding: false` to skip it.

## `Playx.boot` directly

If you want full control, call `Playx.boot` with the same parameters (it has no
`appRunner` and no `sentryOptions`) and then call `runApp` yourself:

```dart
Future<void> main() async {
  await Playx.boot(
    appConfigBuilder: () => AppConfig(),
    themeConfigBuilder: createThemeConfig,
    localeConfigBuilder: createLocaleConfig,
  );
  runApp(const MyApp());
}
```
