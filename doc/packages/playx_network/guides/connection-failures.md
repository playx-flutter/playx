# Connection failures

A request that never gets an answer is not always "no internet". The server may be down, the certificate may be invalid, or a browser may have blocked the call. Each case has its own exception, so you can show the right message.

| Exception | Meaning |
|-----------|---------|
| `NoInternetConnectionException` | The device has no usable network. |
| `ServerUnreachableException` | The device has a network, but the server could not be reached: connection refused, reset, closed or timed out, or no route to the host. |
| `CorsException` | **Web only.** The browser blocked the request, or it failed without a response, most commonly because the server doesn't allow your site's origin (CORS). |
| `SecureConnectionException` | The TLS/SSL connection failed: the certificate is invalid, expired or untrusted, or the handshake failed. The server was reached, so this is not an offline problem. |
| `RequestTimeoutException` | Establishing the connection timed out. |
| `SendTimeoutException` | Sending the request timed out. |
| `ReceiveTimeoutException` | The server took too long to send the response. |

```dart
result.when(
  success: (data) {},
  error: (error) => switch (error) {
    NoInternetConnectionException() => showOfflineBanner(),
    ServerUnreachableException() => showServerDownMessage(),
    SecureConnectionException() => showCertificateProblem(),
    ReceiveTimeoutException() || SendTimeoutException() || RequestTimeoutException() => showSlowNetwork(),
    CorsException() => showCorsHint(),
    _ => showError(error.message),
  },
);
```

## How the exception is chosen

Without any setup, the library reads the operating system error of the failed connection:

- `Connection refused`, `Connection reset`, `Connection timed out`, `No route to host` become `ServerUnreachableException`.
- `Network is unreachable` or `Network is down` become `NoInternetConnectionException`.
- A failed host lookup (a DNS error) is usually caused by being offline, so it also becomes `NoInternetConnectionException`.
- A failure that can't be identified stays `NoInternetConnectionException`, as in earlier versions.

The detection covers the error codes of Android and Linux, macOS and iOS, and Windows.

## Telling offline from unreachable reliably

The operating system error is a good hint, not a guarantee. Give the client a `hasInternetConnection` callback, for example backed by [connectivity_plus](https://pub.dev/packages/connectivity_plus):

```dart
final client = PlayxNetworkClient(
  dio: dio,
  hasInternetConnection: () async {
    final results = await Connectivity().checkConnectivity();
    return !results.contains(ConnectivityResult.none);
  },
);
```

It is called **only after a connection failure**, never on a normal request, and:

- when it returns `false`, the error is always `NoInternetConnectionException`;
- when it returns `true`, the error is never `NoInternetConnectionException` (it becomes `ServerUnreachableException`, or `CorsException` on the web);
- if it throws, the library falls back to inspecting the error as described above.

TLS failures are not connection failures, so the callback is not called for them.

## On the web

A browser reveals nothing about why a request failed: a CORS problem, an offline browser and a server that is down all look identical. So on the web:

- if `navigator.onLine` (or your `hasInternetConnection` callback) says the browser is offline, the error is `NoInternetConnectionException`;
- otherwise it is `CorsException`.

Treat `CorsException` as "blocked or unreachable, most likely CORS", and check the browser's developer console for the exact reason.

## Custom messages

The messages come from your [`ExceptionMessage`](errors.md#customizing-the-generic-messages): `serverUnreachable`, `corsError`, `secureConnectionError` and `receiveTimeout`. English and Arabic are built in.

---

*Imported from the [playx_network 2.0.0 documentation](https://github.com/playx-flutter/playx_network/blob/main/docs/guides/connection-failures.md). [Package site](https://playx-flutter.github.io/playx_network/) · [pub.dev](https://pub.dev/packages/playx_network).*
