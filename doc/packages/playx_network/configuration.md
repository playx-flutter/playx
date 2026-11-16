# Configuration

## The client

```dart
final client = PlayxNetworkClient(
  dio: Dio(BaseOptions(baseUrl: 'https://api.example.com/')),
  customHeaders: () async => {'authorization': 'Bearer $token'},
  customQuery: () => {'lang': 'en'},
  customPathParameters: () => {'version': 'v2'},
  onUnauthorizedRequestReceived: (response) => signOut(),
  errorMapper: (json) => json['message'] as String?,
  errorExtraMapper: ApiError.fromJson,
  hasInternetConnection: checkConnectivity,
  settings: const PlayxNetworkClientSettings(),
);
```

| Parameter | Type | |
|-----------|------|---|
| `dio` | `Dio` | **Required.** The Dio instance that sends the requests. Configure the base URL and the timeouts here. |
| `customHeaders` | `FutureOr<Map<String, dynamic>> Function()?` | Headers added to every request. [More](guides/requests.md#headers-and-query-parameters) |
| `customQuery` | `FutureOr<Map<String, dynamic>> Function()?` | Query parameters added to every request. |
| `customPathParameters` | `FutureOr<Map<String, dynamic>> Function()?` | Values for `{placeholders}` in every path. [More](guides/requests.md#app-wide-path-parameters) |
| `onUnauthorizedRequestReceived` | `void Function(Response?)?` | Called for the unauthorized status codes. [More](guides/errors.md#unauthorized-requests) |
| `errorMapper` | `String? Function(dynamic)?` | Turns an error body into the server's message. Defaults to a parser for the common shapes. [More](guides/errors.md#where-the-servers-message-comes-from) |
| `errorExtraMapper` | `Object? Function(dynamic)?` | Turns an error body into your own error object. [More](guides/errors.md#custom-error-objects) |
| `hasInternetConnection` | `FutureOr<bool> Function()?` | Tells "offline" from "server unreachable". [More](guides/connection-failures.md#telling-offline-from-unreachable-reliably) |
| `settings` | `PlayxNetworkClientSettings` | See below. |

!!! tip "One client"
    Create one client for each backend and reuse it. It keeps the Dio instance, the interceptors and the cancellation tags.

## Settings { #settings }

`PlayxNetworkClientSettings` groups the options. Every request accepts a `settings:` argument that replaces the client's settings **for that request**.

```dart
const PlayxNetworkClientSettings(
  shouldShowApiErrors: true,
  successRequestCodes: [200, 201],
  unauthorizedRequestCodes: [401, 403],
  treatEmptyResponseAsSuccess: false,
  useIsolateForMappingJson: true,
  useWorkMangerForMappingJsonInIsolate: true,
  exceptionMessages: DefaultEnglishExceptionMessage(),
  logSettings: PlayxNetworkLoggerSettings(),
);
```

| Setting | Default | |
|---------|---------|---|
| `shouldShowApiErrors` | `true` | Whether `error.message` is the **server's** message (`true`) or always the generic one (`false`). |
| `successRequestCodes` | `[200, 201]` | Status codes that are a success. A `400` is always an error. Add `204` if your API uses it. [More](guides/errors.md#what-counts-as-a-success) |
| `unauthorizedRequestCodes` | `[401, 403]` | Codes that produce `UnauthorizedRequestException` and call `onUnauthorizedRequestReceived`. |
| `treatEmptyResponseAsSuccess` | `false` | Return `[]` instead of `EmptyResponseException` for empty list responses. [More](guides/errors.md#lists-an-empty-list-is-a-valid-answer) |
| `useIsolateForMappingJson` | `true` | Run `fromJson` in an isolate. [More](guides/results.md#automatic-json-mapping-in-an-isolate) |
| `useWorkMangerForMappingJsonInIsolate` | `true` | Use `work_manager` for that isolate instead of `compute`. |
| `exceptionMessages` | English | The generic error texts. [More](guides/errors.md#customizing-the-generic-messages) |
| `logSettings` | `PlayxNetworkLoggerSettings()` | What is logged. [More](guides/logging.md) |

`settings.copyWith(...)` returns a changed copy, which is handy for per-request overrides:

```dart
final quiet = client.settings.copyWith(shouldShowApiErrors: false);
await client.get<User>('me', fromJson: User.fromJson, settings: quiet);
```

## Default Dio

`PlayxNetworkClient.createDefaultDioClient(baseUrl: ...)` returns a `Dio` that accepts every status code (so the library decides what is an error), follows redirects and has a 30 second connect timeout.

```dart
final client = PlayxNetworkClient(
  dio: PlayxNetworkClient.createDefaultDioClient(baseUrl: 'https://api.example.com/'),
);
```

---

*Imported from the [playx_network 2.0.0 documentation](https://github.com/playx-flutter/playx_network/blob/main/docs/configuration.md). [Package site](https://playx-flutter.github.io/playx_network/) · [pub.dev](https://pub.dev/packages/playx_network).*
