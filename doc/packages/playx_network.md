# playx_network

[pub.dev](https://pub.dev/packages/playx_network) · [Docs](https://playx-flutter.github.io/playx_network/) · Used by Playx 3.0: **2.0.0** (2.x used 1.0.0)

A Dio wrapper that turns every request into a typed `NetworkResult`, names errors so you can act
on them, and removes the try/catch.

```dart
final client = PlayxNetworkClient(
  dio: Dio(BaseOptions(baseUrl: 'https://api.example.com/')),
  customHeaders: () async => {'authorization': 'Bearer $token'},
);

final result = await client.getList<Cat>('images/search', fromJson: Cat.fromJson);

result.when(
  success: (cats) => show(cats),
  error: (error) => showMessage(error.message),
);
```

`Dio` is re-exported by Playx. You usually create one `PlayxNetworkClient` and register it in your
`PlayXAppConfig.boot()`:

```dart
@override
Future<void> boot() async => Get.put(PlayxNetworkClient(dio: Dio(...)));
```

## What changed in 2.0.0

### Breaking

- **Minimum versions:** Dart `>=3.12.0`, Flutter `>=3.44.0` (via `playx_core ^2.0.0`).
- **New exception types:** `NetworkException` is sealed. Exhaustive `switch` statements must handle
  `ServerUnreachableException`, `CorsException`, `SecureConnectionException` and
  `ReceiveTimeoutException` (or keep a catch-all).
- **Slow responses:** Dio's `receiveTimeout` is now `ReceiveTimeoutException`, not
  `SendTimeoutException`. Catch both if you handled slow responses before.

### New

- **Streaming and SSE:** `getStream`/`postStream` (returning `NetworkStreamResult`), `getSse`/`postSse`
  with `PlayxSseEvent`, and `PlayxStreamFormat` (`bytes`, `text`, `json`/NDJSON, `sse`). Cancelling
  the subscription or token aborts the request.
- **Path parameters:** `pathParameters` substitutes `{placeholder}` segments (`users/{userId}`), URL-encoded.
  `customPathParameters` on the client supplies app-wide values.
- **Custom error objects:** `errorExtraMapper` maps an error response to your own object, read with
  `result.errorExtraAs<E>()`.
- **Empty responses:** `treatEmptyResponseAsSuccess`; `fromJson` is optional on `delete`.
- **Connection failures:** `ServerUnreachableException`, `CorsException` (web), `SecureConnectionException`
  for TLS errors, and an optional `hasInternetConnection` callback (for example backed by
  `connectivity_plus`) to tell offline from unreachable.

### Changes

- A response that can't be parsed is an `InvalidFormatException` (was `UnexpectedErrorException`).
- Dio's `transformTimeout` is an `UnableToProcessException`.
- Consistent handling with Dio's default `validateStatus`.

### Fixes

- Cancelling a request exactly while mapping the response no longer throws `Future already completed`.
- `DefaultApiError` reads Strapi-style messages, joins list messages, supports `{"error": "..."}`,
  and no longer drops the message because of a wrong `statusCode` type.
- Per-request `exceptionMessages`, `shouldShowApiErrors` and `unauthorizedRequestCodes` now apply to all
  request types.
- Fixed a non-exhaustive switch over `DioExceptionType` (Dio 5.10 `transformTimeout`).

### Dependencies

`dio ^5.11.1`; widened ranges for `sentry_dio` (`>=9.16.0 <11.0.0`), `talker`, `talker_dio_logger`
and `dio_web_adapter`. If you move to `sentry_dio` 10, read its notes (Android `minSdk` 26, Swift
Package Manager on Apple platforms, span streaming on by default).

## What changed in 1.0.0 (used by Playx 2.1.x)

`dataKey` / `itemDataKey` for nested JSON, and `cancelTag` for cancelling groups of requests.

## What it means for Playx

Update `switch` statements over `NetworkException` and any code catching `SendTimeoutException`
for slow responses. Everything else is additive.
