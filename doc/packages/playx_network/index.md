
<div class="hero" markdown>

![Playx Network](https://github.com/playx-flutter/playx_network/blob/main/docs/assets/logo.svg)

# Playx Network

<p class="tagline">
A <a href="https://pub.dev/packages/dio">Dio</a> wrapper that turns every request into a typed result, gives errors names you can act on, and removes the try/catch.
</p>

[Get started](getting-started.md){ .md-button .md-button--primary }
[API reference](https://playx-flutter.github.io/playx_network/api/){ .md-button }
[pub.dev](https://pub.dev/packages/playx_network){ .md-button }

</div>

<div class="grid cards" markdown>

- :material-check-decagram:{ .lg .middle } **A result, never an exception**

    ---

    Every request returns a `NetworkResult`: success with your model, or an error with a precise, typed exception. [Handling results](guides/results.md)

- :material-alert-circle-outline:{ .lg .middle } **Errors you can act on**

    ---

    Offline, server down, CORS, bad certificate, timeouts, 404, 422... each has its own type and message. [Error handling](guides/errors.md)

- :material-code-json:{ .lg .middle } **Your models, your errors**

    ---

    Map the response with `fromJson`, and map error bodies to your own error object with `errorExtraMapper`. [Custom error objects](guides/errors.md#custom-error-objects)

- :material-lightning-bolt-outline:{ .lg .middle } **Parsing off the UI thread**

    ---

    Map big responses in an isolate with one setting, and cancel the work when the request is cancelled. [Configuration](configuration.md)

- :material-broadcast:{ .lg .middle } **Streaming and SSE**

    ---

    Consume Server-Sent Events, NDJSON and chunked responses as typed streams with cancellation built in. [Streaming](guides/streaming.md)

- :material-cancel:{ .lg .middle } **Smart cancellation**

    ---

    Tag requests and cancel a whole screen's worth at once, or let a new request replace the old one. [Cancellation](guides/cancellation.md)

- :material-code-braces:{ .lg .middle } **Everyday conveniences**

    ---

    Path parameters, `dataKey` extraction, custom headers and query, per-request settings. [Making requests](guides/requests.md)

- :material-test-tube:{ .lg .middle } **Easy to test**

    ---

    Plug a fake adapter into Dio and test every success and failure path without a network. [Testing](guides/testing.md)

</div>

## A quick look

=== "Make the request"

    ```dart
    final client = PlayxNetworkClient(
      dio: Dio(BaseOptions(baseUrl: 'https://api.thecatapi.com/v1/')),
    );

    final result = await client.getList<Cat>(
      'images/search',
      query: {'limit': 10},
      fromJson: Cat.fromJson,
    );
    ```

=== "Handle the result"

    ```dart
    result.when(
      success: (cats) => showCats(cats),
      error: (error) => showMessage(error.message),
    );
    ```

=== "Or pattern match"

    ```dart
    switch (result) {
      case NetworkSuccess(:final data):
        showCats(data);
      case NetworkError(:final error):
        showMessage(error.message);
    }
    ```

=== "Tell failures apart"

    ```dart
    final message = switch (result.error) {
      NoInternetConnectionException() => 'You are offline',
      ServerUnreachableException() => 'The server is not responding',
      UnauthorizedRequestException() => 'Please sign in again',
      ApiException(:final message) => message,
      _ => 'Something went wrong',
    };
    ```

## Requirements

| | Minimum |
|---|---|
| Dart | 3.12 |
| Flutter | 3.44 |
| Dio | 5.11 |

!!! info "Why such new versions?"
    `playx_network` builds on `playx_core` 2, which requires Dart 3.12 and Flutter 3.44.

## Part of the Playx ecosystem

[Playx](https://pub.dev/packages/playx) brings the Playx packages together, [playx_core](https://pub.dev/packages/playx_core) holds the shared utilities this package builds on, and [playx_theme](https://pub.dev/packages/playx_theme) adds multi-theme support.

---

*Imported from the [playx_network 2.0.0 documentation](https://github.com/playx-flutter/playx_network/blob/main/docs/index.md). [Package site](https://playx-flutter.github.io/playx_network/) · [pub.dev](https://pub.dev/packages/playx_network).*
