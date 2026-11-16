# Error handling

When a request fails, `result.error` holds a `NetworkException`. It is a sealed class, so you can match on it exhaustively, and every case has a message you can show.

## The exception types

=== "API errors"

    The server answered with an error status. These are all `ApiException`s: they carry the `statusCode`, the server's message (`apiErrorMessage`) and your [custom error object](#custom-error-objects) (`extra`).

    | Status | Exception |
    |--------|-----------|
    | `401`, `403` (configurable) | `UnauthorizedRequestException` |
    | `404` | `NotFoundException` |
    | `408` | `RequestTimeoutException` |
    | `409` | `ConflictException` |
    | `422` | `UnableToProcessException` |
    | `500` | `InternalServerErrorException` |
    | `503` | `ServiceUnavailableException` |
    | `400` and any other | `DefaultApiException` |
    | empty body | `EmptyResponseException` |

=== "Connection errors"

    The request did not get an answer. See [Connection failures](connection-failures.md) for how they are told apart.

    | Exception | Meaning |
    |-----------|---------|
    | `NoInternetConnectionException` | The device is offline. |
    | `ServerUnreachableException` | Online, but the server can't be reached. |
    | `CorsException` | Web only: blocked by the browser, usually CORS. |
    | `SecureConnectionException` | TLS failed: invalid certificate or handshake. |
    | `RequestTimeoutException` | Connecting timed out. |
    | `SendTimeoutException` | Sending the request timed out. |
    | `ReceiveTimeoutException` | The server took too long to answer. |

=== "Other"

    | Exception | Meaning |
    |-----------|---------|
    | `RequestCanceledException` | The request was [cancelled](cancellation.md). |
    | `InvalidFormatException` | The response body could not be parsed (for example invalid JSON). |
    | `UnableToProcessException` | Your `fromJson` threw, or the body had the wrong shape (`statusCode` is `-1`). |
    | `UnexpectedErrorException` | Anything else. The cause is logged. |

### Handling by type

```dart
final text = switch (result.error) {
  null => null,
  UnauthorizedRequestException() => 'Please sign in again',
  NotFoundException() => 'We could not find that',
  NoInternetConnectionException() => 'You are offline',
  ServerUnreachableException() => 'The server is not responding',
  ApiException(:final message) => message,
  final error => error.message,
};
```

!!! warning "Keep a catch-all case"
    `NetworkException` is sealed. If you `switch` over it **without** a wildcard or `final error` case, the compiler asks you to handle any exception type added in a new version. Keep a catch-all case.

## The error message

Every exception has a `message` that is safe to show to users:

- For an `ApiException`, `message` is the **server's message** when there is one and [`shouldShowApiErrors`](../configuration.md#settings) is `true` (the default), otherwise the generic text of the exception (`errorMessage`).
- For everything else it is the generic text.

The generic texts are the [`ExceptionMessage`](#customizing-the-generic-messages) of the client (English by default).

### Where the server's message comes from

`errorMapper` turns the error body into the message. The default understands these shapes:

| Body | Message |
|------|---------|
| `{"message": "Not found"}` | `Not found` |
| `{"message": ["name is required", "age must be a number"]}` | the two lines joined with a new line |
| `{"error": "Invalid token"}` | `Invalid token` |
| `{"error": {"name": "AuthError", "message": "Token expired"}}` | `Token expired` |
| `{"message": [{"messages": [{"message": "Identifier invalid"}]}]}` (Strapi) | `Identifier invalid` |

Blank messages are treated as missing, and a field with an unexpected type is ignored instead of breaking the rest.

For any other shape, provide your own mapper on the client or on one request:

```dart
final client = PlayxNetworkClient(
  dio: dio,
  errorMapper: (json) => json is Map ? json['detail'] as String? : null,
);

await client.get<User>('me', fromJson: User.fromJson,
    errorMapper: (json) => json['title'] as String?); // just for this request
```

## Custom error objects

When your API returns a structured error (a code, field errors, ...), map it to your own type with `errorExtraMapper`. The message still comes from `errorMapper`.

```dart
class ApiError {
  ApiError(this.code, this.fields);

  factory ApiError.fromJson(dynamic json) => ApiError(
        json['code'] as String,
        Map<String, String>.from(json['fields'] ?? {}),
      );

  final String code;
  final Map<String, String> fields;
}

final client = PlayxNetworkClient(
  dio: dio,
  errorExtraMapper: ApiError.fromJson,
);
```

Read it from the result, or from the exception, without casting:

```dart
final apiError = result.errorExtraAs<ApiError>();

result.when(
  success: (user) {},
  error: (error) => print(error.extraAs<ApiError>()?.fields),
);
```

- It can be set per request too, and then overrides the client-level mapper.
- `extra` is `null` when no mapper is set, when the mapper returns `null`, or when it throws (the failure is logged and the message from `errorMapper` is still returned).
- Only API errors carry `extra`. Timeouts and connection errors have no response body, so `extraAs` returns `null` for them.

## Unauthorized requests

Status codes in `unauthorizedRequestCodes` (default `[401, 403]`) produce an `UnauthorizedRequestException` and call `onUnauthorizedRequestReceived`. This is the place to refresh a token or sign the user out:

```dart
final client = PlayxNetworkClient(
  dio: dio,
  onUnauthorizedRequestReceived: (response) {
    sessionManager.signOut();
  },
);
```

Pass `shouldHandleUnauthorizedRequest: false` on a request to skip the callback, for example for the sign-in request itself.

## What counts as a success

A response is a success when its status code is in `successRequestCodes`, which defaults to `[200, 201]`. A `400` is always an error.

!!! warning "`204 No Content`"
    `204` is **not** in the default list, so a `204` response is reported as an error. If your API answers successful requests (for example `DELETE`) with `204`, add it:

    ```dart
    const PlayxNetworkClientSettings(successRequestCodes: [200, 201, 204]);
    ```

### Dio's `validateStatus`

You can pass your own `Dio`. A plain `Dio` uses the default `validateStatus`, which throws for anything outside 200-299 before the response reaches the library. That is handled for you:

- Error responses keep the server's message and your error object, and unauthorized codes still call the callback. This also works for stream requests, where the body is read for you.
- A status listed in `successRequestCodes` is treated as a success even if Dio rejected it, for example `successRequestCodes: [200, 201, 304]`.

`PlayxNetworkClient.createDefaultDioClient` accepts every status and lets the library decide.

## Empty responses

An empty response body (`null` or `""`) is an `EmptyResponseException` by default, because there is usually nothing to map. You can opt out in two cases.

### Lists: an empty list is a valid answer

```dart
const PlayxNetworkClientSettings(treatEmptyResponseAsSuccess: true);
```

With it, list requests (`getList`, `postList`, ...) that succeed with an empty body or `[]` (also after `dataKey` / `itemDataKey`) return `NetworkResult.success([])`. Single-object requests are not affected, because there is no "empty" value for an arbitrary model.

### Delete: no body is fine

`DELETE` often answers with an empty `200` or `204`. For `delete`, `fromJson` is optional and an empty body is always a success:

```dart
// No mapper: any successful response is NetworkResult.success(null)
final result = await client.delete<void>('posts/{id}', pathParameters: {'id': 7});

// With a mapper: it receives `null` for an empty body (no dataKey is read)
final result = await client.delete<Post?>(
  'posts/{id}',
  pathParameters: {'id': 7},
  fromJson: (json) => json == null ? null : Post.fromJson(json),
);
```

Use `void` or a nullable type when you omit `fromJson`. A non-nullable type without a mapper, or a mapper that can't handle `null`, returns an `UnableToProcessException`.

## Customizing the generic messages

Extend `ExceptionMessage` and pass it in the settings. English (`DefaultEnglishExceptionMessage`) is the default.

```dart
class MyMessages extends ExceptionMessage {
  const MyMessages();

  @override String get requestCancelled => 'Request cancelled';
  @override String get unauthorizedRequest => 'Please sign in again';
  @override String get badRequest => 'The request is not valid';
  @override String get notFound => 'Not found';
  @override String get notAcceptable => 'Not acceptable';
  @override String get requestTimeout => 'The connection timed out';
  @override String get sendTimeout => 'Sending the request timed out';
  @override String get conflict => 'Conflict';
  @override String get internalServerError => 'Server error';
  @override String get serviceUnavailable => 'Service unavailable';
  @override String get noInternetConnection => 'No internet connection';
  @override String get formatException => 'Invalid response format';
  @override String get unableToProcess => 'Could not process the data';
  @override String get defaultError => 'Something went wrong';
  @override String get unexpectedError => 'Something went wrong';
  @override String get emptyResponse => 'The server sent an empty response';
}

final client = PlayxNetworkClient(
  dio: dio,
  settings: const PlayxNetworkClientSettings(exceptionMessages: MyMessages()),
);
```

Four messages were added later and are **optional** to override: `receiveTimeout` (defaults to `sendTimeout`), and `serverUnreachable`, `corsError` and `secureConnectionError` (default to `defaultError`). That keeps existing message classes compiling.

You can also pass different `exceptionMessages` for one request through its `settings`.

---

*Imported from the [playx_network 2.0.0 documentation](https://github.com/playx-flutter/playx_network/blob/main/docs/guides/errors.md). [Package site](https://playx-flutter.github.io/playx_network/) · [pub.dev](https://pub.dev/packages/playx_network).*
