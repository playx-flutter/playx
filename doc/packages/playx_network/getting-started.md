# Getting started

This page takes you from nothing to a working request in a few minutes.

## Install

```bash
flutter pub add playx_network
```

or add it to `pubspec.yaml`:

```yaml
dependencies:
  playx_network: ^2.0.0
```

Then import it. The package re-exports `dio`, so you don't need a separate import for `Dio`, `Options` or `CancelToken`:

```dart
import 'package:playx_network/playx_network.dart';
```

!!! note "Requirements"
    Dart 3.12 or newer and Flutter 3.44 or newer.

## Create the client

Create **one** `PlayxNetworkClient` for your app (or one per backend) and reuse it.

```dart
final client = PlayxNetworkClient(
  dio: Dio(
    BaseOptions(
      baseUrl: 'https://api.thecatapi.com/v1/',
      connectTimeout: const Duration(seconds: 20),
      sendTimeout: const Duration(seconds: 20),
    ),
  ),
  // Attached to every request, for example an auth token.
  customHeaders: () async => {'authorization': 'Bearer $token'},
);
```

!!! tip "No `Dio` of your own?"
    `PlayxNetworkClient.createDefaultDioClient(baseUrl: ...)` builds a `Dio` with sensible defaults. It accepts every status code and lets the library decide what is an error.

## Describe your data

A model only needs a way to build itself from decoded JSON:

```dart
class Cat {
  Cat({this.id, this.url});

  factory Cat.fromJson(dynamic json) =>
      Cat(id: json['id'] as String?, url: json['url'] as String?);

  final String? id;
  final String? url;
}
```

## Make a request

`getList` returns a list of models. Use `get` for a single model.

```dart
final result = await client.getList<Cat>(
  'images/search',
  query: {'limit': 10},
  fromJson: Cat.fromJson,
);
```

## Handle the result

There is nothing to catch. The result is either a success or an error:

```dart
result.when(
  success: (cats) {
    print('Got ${cats.length} cats');
  },
  error: (error) {
    print('Failed: ${error.message}');
  },
);
```

Or use the getters:

```dart
if (result.isSuccess) {
  final cats = result.data!;
} else {
  final error = result.error!;
}
```

That's it. Everything that can go wrong (no connection, a timeout, a 404, a server that returns invalid JSON, a mapper that throws) comes back as `result.error` with a typed [exception](guides/errors.md).

## What's next

<div class="grid cards" markdown>

- [**Making requests**](guides/requests.md): all HTTP methods, path parameters, `dataKey`, downloads.
- [**Handling results**](guides/results.md): `when`, `map` and pattern matching.
- [**Error handling**](guides/errors.md): the exception types and custom error objects.
- [**Configuration**](configuration.md): every client option and setting.

</div>

---

*Imported from the [playx_network 2.0.0 documentation](https://github.com/playx-flutter/playx_network/blob/main/docs/getting-started.md). [Package site](https://playx-flutter.github.io/playx_network/) · [pub.dev](https://pub.dev/packages/playx_network).*
