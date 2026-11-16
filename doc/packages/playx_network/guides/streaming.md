# Streaming and SSE

Some endpoints answer with a response that keeps going: Server-Sent Events, newline-delimited JSON, a chunked download of text. The streaming methods give you those as a typed `Stream`, with the same error handling and cancellation as every other request.

| Method | Sends | Result |
|--------|-------|--------|
| `getStream<T>` | `GET` | `NetworkStreamResult<T>` |
| `postStream<T>` | `POST` | `NetworkStreamResult<T>` |
| `getSse` | `GET` | `NetworkStreamResult<PlayxSseEvent>` |
| `postSse` | `POST` | `NetworkStreamResult<PlayxSseEvent>` |

## Server-Sent Events

```dart
final result = await client.getSse('events');

result.when(
  success: (events) {
    events.listen(
      (event) => print('${event.event}: ${event.data}'),
      onError: (error) => print('Stream error: $error'),
      onDone: () => print('Stream closed'),
    );
  },
  error: (error) => print('Could not connect: ${error.message}'),
);
```

A `PlayxSseEvent` has:

| Field | |
|-------|---|
| `event` | The event type, `message` when the server doesn't send one. |
| `data` | The payload. Several `data:` lines are joined with `\n`. |
| `id` | The last event id sent by the server. It persists across events until the server changes it. |
| `retry` | The reconnection delay in milliseconds hinted by the server, if any. |

Helpers: `event.dataToJson()` parses `data` as JSON, `event.dataToJsonOrNull()` returns `null` instead of throwing, and `event.isEmpty` filters heartbeats.

The parser follows the SSE specification: `\n`, `\r\n` and `\r` line endings, a leading byte order mark, comments, and events split across network chunks all work. A partial last line is dropped, and a block with only an `id` or `retry` field is not emitted as an event.

!!! info "No automatic reconnect"
    When the stream ends or fails, nothing reconnects for you. To resume, call `getSse` again and send the last `id` in a `Last-Event-ID` header.

`getSse` and `postSse` send `Accept: text/event-stream` and `Cache-Control: no-cache` unless you set those headers yourself.

## Other formats

`getStream` and `postStream` take a `format` that decides how the bytes are decoded, and `T` must match it:

| Format | `T` | What you get |
|--------|-----|--------------|
| `PlayxStreamFormat.bytes` | `List<int>` | The raw chunks, untouched. |
| `PlayxStreamFormat.text` | `String` | UTF-8 text per network chunk. |
| `PlayxStreamFormat.json` | `Object` | One decoded JSON value per line (NDJSON). |
| `PlayxStreamFormat.sse` | `PlayxSseEvent` | Server-Sent Events. |

```dart
final result = await client.postStream<Object>(
  'ai/complete',
  body: {'prompt': 'Hello'},
  format: PlayxStreamFormat.json,
);

result.data?.listen((json) => print(json));
```

Decoding is done on the whole byte stream, so a multibyte character (Arabic, emoji, CJK) that is split across two network chunks is reassembled correctly.

!!! warning "NDJSON needs newlines"
    `PlayxStreamFormat.json` expects one JSON document per line, each terminated by a newline. A final document without a trailing newline is still emitted when the stream closes. A line that is not valid JSON produces an `UnableToProcessException` **error event**, and the stream carries on with the next line.

If `T` doesn't match the format (for example `getStream<int>` with `text`), each element produces an `UnableToProcessException` error event.

## The result

`NetworkStreamResult<T>` is a sealed class like `NetworkResult`, with `NetworkStreamSuccess` (holding the `Stream`) and `NetworkStreamError`. It offers `when`, `map`, `mapAsync`, `mapStream` and `mapStreamAsync`, plus `isSuccess`, `isError`, `data` and `error`.

The result is an **error** when the request fails before any data arrives: no connection, a `401`, a `500`, a certificate problem. The body of such an error is read (up to 64 KB), so the server's message and your [error object](errors.md#custom-error-objects) are available just like for normal requests.

```dart
final firstThree = result.mapStream<String>(
  mapper: (stream) => stream.map((e) => e.data).take(3),
);
```

### Collecting a stream

`toList()` collects the whole stream into a `NetworkResult<List<T>>`:

```dart
final listResult = await result.toList();
```

A stream error becomes `NetworkResult.error` instead of being thrown. Note that it waits for the stream to **complete**, so it never returns for an endless stream such as a long-lived SSE connection.

## Lifecycle

- The stream is **single-subscription**: listen once.
- The response is read when you listen, and it follows your subscription: **pause** and **resume** are honoured, and **cancelling** the subscription (or `break`ing out of an `await for`) aborts the HTTP request and releases the connection.
- Cancelling the request's `cancelToken` or `cancelTag` ends the stream with a `RequestCanceledException` error and then completes it.
- A failure while the stream is open, such as a dropped connection, is emitted as a `NetworkException` error event, and then the stream **completes**. Whether the failure is "offline" or "server unreachable" follows the [same rules](connection-failures.md) as other requests.

```dart
final token = CancelToken();
final result = await client.getSse('events', cancelToken: token);

final subscription = result.data!.listen(print);

// Later:
token.cancel();          // or: await subscription.cancel();
```

## Timeouts and headers

The idle receive timeout is **disabled** for streams, so a quiet SSE connection isn't cut off. If you want one, set `options: Options(receiveTimeout: ...)`. Headers from `options.headers`, the client's custom headers and the `headers` argument are all merged. Streams also support [path parameters](requests.md#path-parameters).

---

*Imported from the [playx_network 2.0.0 documentation](https://github.com/playx-flutter/playx_network/blob/main/docs/guides/streaming.md). [Package site](https://playx-flutter.github.io/playx_network/) · [pub.dev](https://pub.dev/packages/playx_network).*
