# Logging

Requests, responses and errors are logged through [`talker_dio_logger`](https://pub.dev/packages/talker_dio_logger). Logging is **on in debug builds and off in release builds** by default.

## Settings

Configure it with `PlayxNetworkLoggerSettings`, inside the client settings:

```dart
final client = PlayxNetworkClient(
  dio: dio,
  settings: const PlayxNetworkClientSettings(
    logSettings: PlayxNetworkLoggerSettings(
      printResponseData: true,
      printRequestHeaders: false,
      hiddenHeaders: {'authorization', 'cookie'},
    ),
  ),
);
```

| Option | Default | Logs |
|--------|---------|------|
| `enabled` | `kDebugMode` | Turns the whole logger on or off. |
| `printRequestData` | `true` | The request body. |
| `printRequestHeaders` | `true` | The request headers. |
| `printRequestExtra` | `false` | `RequestOptions.extra`. |
| `printResponseData` | `true` | The response body. |
| `printResponseHeaders` | `false` | The response headers. |
| `printResponseMessage` | `true` | The status message. |
| `printResponseRedirects` | `false` | The redirects. |
| `printResponseTime` | `false` | How long the request took. |
| `printErrorData` | `true` | The body of an error response. |
| `printErrorHeaders` | `true` | The headers of an error response. |
| `printErrorMessage` | `true` | The error message. |
| `enableColors` | `false` | ANSI colors in the output. |
| `hiddenHeaders` | `{}` | Header names (case insensitive) whose values are replaced with `*****`. |
| `requestFilter`, `responseFilter`, `errorFilter` | `null` | Functions that decide whether a request, response or error is logged. |
| `talker` | `null` | Your own `Talker` instance. |

!!! tip "Hide secrets"
    Add `authorization`, `cookie` and any API-key header to `hiddenHeaders` so they never reach the logs.

## Filtering

Log only what you care about:

```dart
PlayxNetworkLoggerSettings(
  requestFilter: (options) => !options.path.contains('health'),
  errorFilter: (error) => error.response?.statusCode != 404,
);
```

## Your own Talker

By default the output goes through `dart:developer`'s `log`, which avoids the `flutter:` prefix that `print` adds. To integrate with an existing [Talker](https://pub.dev/packages/talker) (for example `talker_flutter` and its in-app log screen), pass it:

```dart
final talker = TalkerFlutter.init();

PlayxNetworkLoggerSettings(talker: talker);
```

## Per request

Logging can be changed for a single request through its settings. Use it to silence a noisy endpoint, or to log one request in a release build:

```dart
await client.get<Token>(
  'auth/refresh',
  fromJson: Token.fromJson,
  settings: const PlayxNetworkClientSettings(
    logSettings: PlayxNetworkLoggerSettings(enabled: false),
  ),
);
```

The package's own diagnostics (for example "the error mapper threw") follow the same `enabled` flag.

---

*Imported from the [playx_network 2.0.0 documentation](https://github.com/playx-flutter/playx_network/blob/main/docs/guides/logging.md). [Package site](https://playx-flutter.github.io/playx_network/) · [pub.dev](https://pub.dev/packages/playx_network).*
