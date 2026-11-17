# Testing

`PlayxNetworkClient` wraps a `Dio`, so the easiest way to test code that uses it is to give the `Dio` a **fake adapter**. Nothing touches the network, and the real client code still runs: mapping, error handling and all.

## A fake adapter

```dart
class FakeAdapter implements HttpClientAdapter {
  FakeAdapter(this.status, this.body);

  final int status;
  final String body; // the raw response body

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      body,
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }
}

/// A client whose server answers every request with [status] and [body].
PlayxNetworkClient clientReturning(int status, Object body) {
  return PlayxNetworkClient(
    dio: Dio(BaseOptions(baseUrl: 'https://example.com/'))
      ..httpClientAdapter = FakeAdapter(
        status,
        body is String ? body : jsonEncode(body),
      ),
    settings: const PlayxNetworkClientSettings(
      // Small payloads in tests: parse inline instead of in an isolate.
      useIsolateForMappingJson: false,
      logSettings: PlayxNetworkLoggerSettings(enabled: false),
    ),
  );
}
```

## Testing the success path

```dart
test('loads the user', () async {
  final client = clientReturning(200, {'id': 1, 'name': 'Ada'});

  final result = await client.get<User>('me', fromJson: User.fromJson);

  expect(result.isSuccess, isTrue);
  expect(result.data!.name, 'Ada');
});
```

## Testing failures

Every failure is a value, so asserting on it is straightforward:

```dart
test('shows the server message for a 404', () async {
  final client = clientReturning(404, {'message': 'No such user'});

  final result = await client.get<User>('users/9', fromJson: User.fromJson);

  expect(result.error, isA<NotFoundException>());
  expect(result.error!.message, 'No such user');
});

test('reports an invalid response', () async {
  final client = clientReturning(200, '{not json'); // a String is sent as is

  final result = await client.get<User>('me', fromJson: User.fromJson);

  expect(result.error, isA<InvalidFormatException>());
});
```

## Simulating connection problems

Throw from the adapter, or reject in an interceptor, to simulate a connection failure:

```dart
class OfflineAdapter implements HttpClientAdapter {
  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    throw DioException.connectionError(
      requestOptions: options,
      reason: 'offline',
      error: const SocketException('Network is unreachable'),
    );
  }
}
```

The `SocketException` above is classified like a real one, so `ECONNREFUSED`-style messages give `ServerUnreachableException` and `Network is unreachable` gives `NoInternetConnectionException`. To force the answer, pass `hasInternetConnection: () => false` (or `true`) to the client.

## Good to know

- **Dio defaults:** a plain `Dio` throws for non-2xx statuses. The client handles that, so you don't need `validateStatus: (_) => true` in tests.
- **Exception messages are global.** Each `PlayxNetworkClient` registers its `exceptionMessages` in a shared registry, which `NetworkResult.mapDataAsyncInIsolate` and `NetworkStreamResult.toList` read as a fallback. A client created later replaces an earlier registration, so tests that create several clients with different messages should not rely on that fallback.
- **Cancellation** is easy to test: cancel the `CancelToken` and expect a `RequestCanceledException`.

---

*Imported from the [playx_network 2.0.0 documentation](https://github.com/playx-flutter/playx_network/blob/main/docs/guides/testing.md). [Package site](https://playx-flutter.github.io/playx_network/) · [pub.dev](https://pub.dev/packages/playx_network).*
