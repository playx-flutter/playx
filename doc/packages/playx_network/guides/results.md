# Handling results

Every request returns a `NetworkResult<T>`, a sealed class with exactly two cases:

- `NetworkSuccess<T>`: holds the `data`.
- `NetworkError<T>`: holds the `error`, a [`NetworkException`](errors.md).

## Reading a result

=== "when"

    ```dart
    result.when(
      success: (user) => print(user.name),
      error: (error) => print(error.message),
    );
    ```

    `when` runs the matching callback and returns the result, so calls can be chained.

=== "Pattern matching"

    ```dart
    switch (result) {
      case NetworkSuccess(:final data):
        print(data.name);
      case NetworkError(:final error):
        print(error.message);
    }
    ```

    The compiler checks that both cases are handled.

=== "Getters"

    ```dart
    if (result.isSuccess) {
      print(result.data!.name);
    } else {
      print(result.error!.message);
    }
    ```

    `data` is `null` for an error and `error` is `null` for a success.

## Transforming a result

`map` turns a result into any value, one function per case:

```dart
final label = result.map(
  success: (success) => 'Hello ${success.data.name}',
  error: (error) => 'Failed: ${error.error.message}',
);
```

`mapAsync` is the same for async work:

```dart
final label = await result.mapAsync(
  success: (success) async => await translate(success.data.name),
  error: (error) async => 'Failed',
);
```

### Mapping to another result

These keep the error and only transform the data:

```dart
// NetworkResult<List<Cat>> -> NetworkResult<List<String>>
final urls = await result.mapDataAsync<List<String>>(
  mapper: (cats) async => NetworkResult.success([for (final c in cats) c.url!]),
);

// Returns null for errors, or the mapped error if you give an errorMapper.
final first = await result.mapDataAsyncOrNull<Cat>(
  mapper: (cats) => cats.first,
  errorMapper: (error) => Cat.empty(),
);
```

### Mapping in an isolate

For heavy transformations, run the mapping off the UI thread:

```dart
final result2 = await result.mapDataAsyncInIsolate<List<String>>(
  mapper: extractUrls,          // must be a top-level or static function
  useWorkManager: false,        // use compute instead of work_manager
);
```

`mapAsyncInIsolate` takes a `success` and an `error` function and returns your own type. If the mapper throws, `mapDataAsyncInIsolate` returns an `UnableToProcessException`.

!!! warning "Isolate rules"
    A function that runs in an isolate must be a top-level or static function, and its input and output must be sendable between isolates. Closures that capture non-sendable objects will fail.

## Reading custom error data

If you configured an [`errorExtraMapper`](errors.md#custom-error-objects), read its object without casting:

```dart
final apiError = result.errorExtraAs<ApiError>(); // null for successes
```

## Automatic JSON mapping in an isolate

Separately from the helpers above, the client itself can map each response in an isolate. It is controlled by two settings and is on by default:

| Setting | Default | |
|---------|---------|---|
| `useIsolateForMappingJson` | `true` | Run `fromJson` in an isolate. |
| `useWorkMangerForMappingJsonInIsolate` | `true` | Use `work_manager` for the isolate instead of Flutter's `compute`. |

Because the mapper runs in an isolate, `fromJson` must be a top-level or static function (`Cat.fromJson` as a static or factory is fine, an inline closure that captures state is not). Turn the isolate off for small payloads or when your mapper needs captured state:

```dart
const PlayxNetworkClientSettings(useIsolateForMappingJson: false);
```

---

*Imported from the [playx_network 2.0.0 documentation](https://github.com/playx-flutter/playx_network/blob/main/docs/guides/results.md). [Package site](https://playx-flutter.github.io/playx_network/) · [pub.dev](https://pub.dev/packages/playx_network).*
