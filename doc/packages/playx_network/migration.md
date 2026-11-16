# Migrating to playx_network 2.0

Playx 3.0 uses `playx_network` 2.0.0 (Playx 2.x used 1.0.0). 2.0 raises the minimum SDK and adds
new exception types. Most apps only need the changes in the checklist.

## Checklist

1. [Upgrade Dart and Flutter](#1-upgrade-dart-and-flutter)
2. [Update exhaustive `switch` statements](#2-update-exhaustive-switch-statements)
3. [Catch `ReceiveTimeoutException` for slow responses](#3-catch-receivetimeoutexception-for-slow-responses)
4. [Check parsing errors](#4-check-parsing-errors)
5. [Dependencies](#5-dependencies)

Run `flutter analyze` afterwards: the first two changes are caught at compile time.

## 1. Upgrade Dart and Flutter

`playx_network` 2.0 depends on `playx_core ^2.0.0`, which requires **Dart `>=3.12.0`** and
**Flutter `>=3.44.0`**. These are now the minimum versions of `playx_network` too (and of Playx 3.0).

## 2. Update exhaustive `switch` statements

`NetworkException` is a sealed class and has four new subclasses:

- `ServerUnreachableException` — connection refused, reset, closed or timed out, no route to host.
- `CorsException` — a request blocked by CORS (web).
- `SecureConnectionException` — rejected certificate or failed TLS handshake.
- `ReceiveTimeoutException` — the server took too long to respond.

An exhaustive `switch` over `NetworkException` no longer compiles until it handles them:

```dart
final text = switch (error) {
  NoInternetConnectionException() => 'You are offline',
  ServerUnreachableException() => 'The server is not responding',   // new
  CorsException() => 'The request was blocked by the browser',      // new
  SecureConnectionException() => 'The connection is not secure',    // new
  ReceiveTimeoutException() => 'The server took too long to answer', // new
  UnauthorizedRequestException() => 'Please sign in again',
  ApiException(:final message) => message,
  _ => 'Something went wrong',
};
```

Or keep a catch-all `_` case. A failure that can't be identified is still
`NoInternetConnectionException`, so existing offline handling keeps working. To tell *offline* from
*server unreachable* reliably, pass the optional `hasInternetConnection` callback to
`PlayxNetworkClient` (for example backed by `connectivity_plus`).

## 3. Catch `ReceiveTimeoutException` for slow responses

Dio's `receiveTimeout` used to be reported as `SendTimeoutException`. It is now a
`ReceiveTimeoutException`. If you handled slow responses, catch both:

```dart
if (error is SendTimeoutException || error is ReceiveTimeoutException) {
  showMessage('The request timed out');
}
```

## 4. Check parsing errors

- A response body that can't be parsed (for example invalid JSON) is now an
  **`InvalidFormatException`**. It used to be an `UnexpectedErrorException`.
- Dio's `transformTimeout` (parsing took too long) is an **`UnableToProcessException`**.

If you matched `UnexpectedErrorException` to show a generic parsing message, add
`InvalidFormatException`.

## 5. Dependencies

- `dio` is `^5.11.1`.
- Ranges were widened so your app can choose versions: `sentry_dio >=9.16.0 <11.0.0`,
  `talker` and `talker_dio_logger` `>=5.1.16 <6.0.0`, `dio_web_adapter >=2.1.2 <3.0.0`.
  `sentry_dio` is only re-exported. If you move to `sentry_dio` 10, read its notes: Android `minSdk`
  26, Swift Package Manager on Apple platforms, span streaming on by default.
- `package:web` is now a direct dependency.

## Behavior that changed without code changes

- A status listed in `successRequestCodes` that Dio rejects (for example `304`) is a success for
  every request type, and error responses of stream requests keep the API message and `extra` data.
- Per-request `exceptionMessages`, `shouldShowApiErrors` and `unauthorizedRequestCodes` now apply to
  error status codes of **every** request type. Before, only the client-level settings were used.
- `DefaultApiError` reads more formats (Strapi `message: [{messages: [...]}]`, list messages,
  `{"error": "..."}`) and no longer drops the message because of a wrongly typed `statusCode`.
- `204 No Content` still needs `successRequestCodes: [200, 201, 204]`; the default is unchanged.

## New in 2.0

Streaming and SSE (`getStream`, `getSse`), path parameters (`users/{userId}`), custom error objects
(`errorExtraMapper`), `treatEmptyResponseAsSuccess`, an optional `fromJson` on `delete`, and
`ServerUnreachableException` / `CorsException` / `SecureConnectionException`. See
[the Playx guide](../playx_network.md#what-changed-in-200) and the [guides](index.md).
