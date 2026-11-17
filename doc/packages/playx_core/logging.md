# Logging

`PlayxLogger` is a small logging facade: static methods that forward to a **default logger**, plus support for any number of **named loggers**. The built-in implementation uses [`talker_logger`](https://pub.dev/packages/talker_logger), and you can plug in any other backend.

## Quick start

`PlayxCore.bootCore` creates a logger named `PLAYX CORE` and makes it the default, so you can log straight away:

```dart
PlayxLogger.i('App started');
PlayxLogger.d('Cart loaded', tag: 'cart');
PlayxLogger.w('Slow response');
PlayxLogger.e('Request failed', error: error, stackTrace: stackTrace);
```

Not using `bootCore`? Create a logger yourself:

```dart
PlayxLogger.initLogger(name: 'APP');
```

If no default logger exists, the static methods do nothing.

## Levels

| Method | Short | Level |
| --- | --- | --- |
| `PlayxLogger.verbose(msg)` | `v` | verbose |
| `PlayxLogger.debug(msg)` | `d` | debug |
| `PlayxLogger.info(msg)` | `i` | info |
| `PlayxLogger.warning(msg)` | `w` | warning |
| `PlayxLogger.error(msg, {error, stackTrace})` | `e` | error |
| `PlayxLogger.critical(msg)` | `c` | critical |
| `PlayxLogger.log(msg)` | | unspecified |

Every method takes a `message` (anything: it is converted with `toString`, and `null` prints as `null`) and an optional `tag`, which is shown in brackets next to the logger name:

```
[APP] [cart] Cart loaded
```

`error` also accepts an `error` and a `stackTrace`, appended below the message.

## Named loggers

```dart
final network = PlayxLogger.initLogger(name: 'NETWORK', setAsDefault: false);
final storage = PlayxLogger.initLogger(name: 'STORAGE', setAsDefault: false);

network.i('GET /users');                       // log with a specific logger
PlayxLogger.getLogger('STORAGE')?.w('Disk almost full');

PlayxLogger.hasLogger('NETWORK');              // true
PlayxLogger.setDefaultLogger(network);         // make it the target of PlayxLogger.i(...)
```

| Member | Does |
| --- | --- |
| `initLogger({name, settings, setAsDefault = true, useColoredFormatter = false})` | Creates a `TalkerPlayxLogger`, registers it under `name` (`PLAYX LOGGER` when omitted), and returns it. It becomes the default when `setAsDefault` is `true`, or when there is no default yet. |
| `getLogger(name)` | The logger registered under `name`, or `null`. |
| `hasLogger(name)` | Whether it exists. |
| `setDefaultLogger(logger)` | Sets any `PlayxBaseLogger` as the default. |

`PlayxCore.logger` returns the `PLAYX CORE` logger created by `bootCore`.

## Message layout

Every message is written as:

```
[time] [LEVEL] [name] [tag] message
```

Each part is optional: the **time** with `printDateTime`, the **level** with `printLevel`, the **logger name** with `printLoggerName` (on by default), and the **tag** when you pass one.

```dart
PlayxLogger.initLogger(
  name: 'APP',
  settings: PlayxLoggerSettings(
    printDateTime: true,
    printLevel: true,
    useColors: false,
    formatter: const DefaultColoredLoggerFormatter(),   // plain lines, no box
  ),
);

PlayxLogger.w('Slow response', tag: 'net');
// [13:45:30.123] [WARNING] [APP] [net] Slow response
```

| Option | Default | Result |
| --- | --- | --- |
| `printLoggerName` | `true` | `[APP] …` |
| `printDateTime` | `false` | `[13:45:30.123] …` |
| `dateTimeFormat` | `PlayxLogDateTimeFormat.time` | `time`: `13:45:30.123`, `dateTime`: `2024-05-15 13:45:30.123`, `iso8601`: `2024-05-15T13:45:30.123` |
| `dateTimeFormatter` | `null` | Your own function (for example with `intl`); overrides `dateTimeFormat`. |
| `printLevel` | `false` | `[INFO] …`: handy when colors are off, because the level is otherwise only shown by color. |

> **Single lines instead of boxes.** The default formatter (`ExtendedLoggerFormatter`) draws a box around each message. `DefaultColoredLoggerFormatter()` prints plain lines, colored only when `useColors` is on. It is what the `PLAYX CORE` logger uses by default.

## Colors and the `flutter:` prefix

Two things can make console output look noisy, and they have different causes.

**1. Escape codes such as `^[[38;5;4m`.** These are ANSI color codes. Terminals render them as colors; some consoles (Xcode, some IDE panels) show them as text. Turn them off:

```dart
PlayxLoggerSettings(useColors: false)
```

Colors are also switched off automatically when they can't be shown, see [Color detection](#color-detection).

**2. The `flutter: ` prefix.** The platform adds it to everything written with `print` or `debugPrint` (`flutter: ` on iOS and macOS, `I/flutter` on Android). The logger can't remove it, but it can use another channel with `target`:

| `target` | Console shows | Notes |
| --- | --- | --- |
| `PlayxLogTarget.debugPrint` (default) | `flutter: [APP] hello` | Shown by every console. Safe for long messages. |
| `PlayxLogTarget.stdout` | `[APP] hello` | **No prefix** in a terminal running the app. Some consoles only collect `print` output, such as a mobile device's system log, and may not show it. Falls back to `debugPrint` on web. |
| `PlayxLogTarget.developerLog` | `[APP] hello` under the logger's name, no ANSI codes | Appears in DevTools and IDE debug consoles. **Not** shown in the terminal of `flutter run`. |

These behaviors were checked with `flutter run -d macos`. Try your own console and device: where each channel shows up varies by tool. A custom `output` overrides `target`.

```dart
PlayxLoggerSettings(
  useColors: false,
  target: PlayxLogTarget.stdout,
  formatter: const DefaultColoredLoggerFormatter(),
)
```

### Color detection

With `useColors: true` (the default), colors are still dropped when something says the console can't show them:

| Situation | Colors |
| --- | --- |
| Web, or `target: PlayxLogTarget.developerLog` | off |
| `--dart-define=PLAYX_LOG_COLORS=true` or `false` | forced, whatever else is set (not on web or `developerLog`) |
| `useColors: false` | off |
| `NO_COLOR` environment variable set (non-empty), or `TERM=dumb` | off |
| `target: PlayxLogTarget.stdout` in a terminal that doesn't support ANSI | off |
| Anything else | on |

An app can't see which console shows its `print` output, so on a phone or in an IDE panel colors stay on unless one of the signals above applies.

### Android Studio and IntelliJ

The Run panel doesn't interpret ANSI codes: it prints them as text. Based on the Flutter plugin's source (not tested on every version), there are two ways to get a clean panel:

- **Turn colors off** with a build define. In the run configuration, set *Additional run args* to `--dart-define=PLAYX_LOG_COLORS=false`. No code change is needed, and other developers keep their colors.
- **Use `PlayxLogTarget.developerLog`** for real styling. The IDE shows the logger name as a gray `[name]` prefix, and the `error` and `stackTrace` of `logger.error(...)` in red. The log level is also passed, so DevTools can filter by severity. No ANSI codes are written, and the name is not repeated in the text. The cost: these entries are not printed in the terminal of `flutter run`.

```dart
PlayxLoggerSettings(target: PlayxLogTarget.developerLog)
```

## Configuring the `PLAYX CORE` logger

`bootCore` creates the logger that writes the boot messages (`Booting Preferences...`) and the package's own warnings. Configure it with `loggerSettings`:

```dart
await PlayxCore.bootCore(
  loggerSettings: PlayxLoggerSettings(
    useColors: false,
    printDateTime: true,
    formatter: const DefaultColoredLoggerFormatter(),
  ),
);
```

| Goal | Settings |
| --- | --- |
| No escape codes | `useColors: false` |
| Hide the boot messages, keep warnings and errors | `level: LogLevel.warning` |
| Silence the package completely | `enabled: false` |
| Time on every line | `printDateTime: true` |
| Send the package's logs elsewhere | `output: (message) => ...` |

Without `loggerSettings`, the core logger prints single-line colored messages with `debugPrint` in debug builds, as before. The same logger is the default one for `PlayxLogger.i(...)`, so these settings apply to your own messages too, unless you create another logger and make it the default.

## Settings

```dart
PlayxLogger.initLogger(
  name: 'APP',
  settings: PlayxLoggerSettings(
    enabled: true,                 // log in release builds too
    level: LogLevel.info,          // ignore verbose and debug
    useColors: false,
  ),
);
```

`PlayxLoggerSettings`:

| Option | Default | Meaning |
| --- | --- | --- |
| `enabled` | `kDebugMode` | Master switch. When `false`, nothing is logged. |
| `printToConsole` | `kDebugMode` | Whether formatted messages are passed to `output` / `target`. When `false` they are discarded (see the note below). |
| `level` | `LogLevel.verbose` | Messages with a lower priority than this are ignored. |
| `useColors` | `true` | ANSI colors. Dropped automatically where they can't be shown: see [Color detection](#color-detection). |
| `colors` | red/yellow/blue/gray per level | Colors per `LogLevel` (`AnsiPen`). |
| `printLoggerName`, `printDateTime`, `dateTimeFormat`, `dateTimeFormatter`, `printLevel` | see [Message layout](#message-layout) | What each message starts with. |
| `formatter` | `ExtendedLoggerFormatter()` | How messages are laid out: `ExtendedLoggerFormatter` (boxed), `ColoredLoggerFormatter`, `DefaultColoredLoggerFormatter` (plain lines), or your own `LoggerFormatter`. `useColoredFormatter: true` in `initLogger` uses the plain one. |
| `lineSymbol` | `─` | The symbol of the separator line. |
| `maxLineWidth` | `140` | Width of the separator line. |
| `target` | `PlayxLogTarget.debugPrint` | The channel used when there is no `output`. See [Colors and the `flutter:` prefix](#colors-and-the-flutter-prefix). |
| `output` | `null` | Where formatted messages go; overrides `target`. |
| `filter` | `null` | A `LoggerFilter` to drop messages. |

> **`printToConsole` and `output`.** With `printToConsole: true` messages go to `output` (or to the `target` when none is given). With `printToConsole: false` nothing is printed, even if you passed an `output`. To send logs somewhere else (a file, a crash reporter), keep `printToConsole: true` and pass `output`.

`LogLevel`, `AnsiPen`, `LoggerFormatter`, `LoggerFilter`, `LoggerOutput`, `LogDetails`, `ExtendedLoggerFormatter`, `ColoredLoggerFormatter` and `TalkerLoggerSettings` are re-exported by `playx_core`, so you don't need to depend on `talker_logger` yourself.

### Sending logs elsewhere

```dart
PlayxLogger.initLogger(
  name: 'APP',
  settings: PlayxLoggerSettings(
    enabled: true,
    printToConsole: true,
    output: (message) => crashReporter.addBreadcrumb(message),
  ),
);
```

### Release builds

`enabled` and `printToConsole` default to `kDebugMode`, so a default logger is **silent in release builds**. Enable it explicitly (as above) if you want logs in production, ideally with a `level` of `warning` or higher and an `output` that goes to your reporting tool.

## Your own logger

Implement `PlayxBaseLogger` to use another backend (for example `package:logger`, Sentry or Crashlytics) and make it the default:

```dart
class SentryLogger extends PlayxBaseLogger {
  const SentryLogger() : super(name: 'SENTRY');

  @override
  void debug(message, {String? tag}) => Sentry.addBreadcrumb(Breadcrumb(message: '$message'));

  @override
  void info(message, {String? tag}) => Sentry.addBreadcrumb(Breadcrumb(message: '$message'));

  @override
  void warning(message, {String? tag}) => Sentry.captureMessage('$message', level: SentryLevel.warning);

  @override
  void error(message, {Object? error, StackTrace? stackTrace, String? tag}) =>
      Sentry.captureException(error ?? message, stackTrace: stackTrace);

  @override
  void critical(message, {String? tag}) => Sentry.captureMessage('$message', level: SentryLevel.fatal);

  @override
  void verbose(message, {String? tag}) {}

  @override
  void log(message, {String? tag}) {}
}

PlayxLogger.setDefaultLogger(const SentryLogger());
```

You only implement the seven level methods: the short aliases (`d`, `i`, `w`, `e`, `c`, `v`, `l`) are provided by the base class.

## What `playx_core` logs

The package logs through the `PLAYX CORE` logger, for example:

- startup steps (`Booting Preferences...`), configurable with [`bootCore(loggerSettings:)`](#configuring-the-playx-core-logger);
- skipped env files and reads before `PlayxEnv.load`;
- secure storage fallbacks and failures (`auto` choosing another backend, an unreadable key, a lost key);
- errors in `MapUtils` helpers when `printError` is set.

Messages never include secret values. In release builds nothing is printed unless you enabled the logger.

---

*Imported from the [playx_core 2.0.0 documentation](https://github.com/playx-flutter/playx_core/blob/main/doc/logging.md). [Package site](https://playx-flutter.github.io/playx_core/) · [pub.dev](https://pub.dev/packages/playx_core).*
