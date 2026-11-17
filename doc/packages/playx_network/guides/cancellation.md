# Cancellation

A cancelled request returns a `RequestCanceledException`, like any other error, so cancelling never needs a try/catch either.

## With a cancel token

Pass a Dio `CancelToken`:

```dart
final token = CancelToken();
final future = client.get<User>('me', fromJson: User.fromJson, cancelToken: token);

token.cancel('left the screen');

final result = await future;
print(result.error is RequestCanceledException); // true
```

## With a tag

For anything bigger than one request, give requests a `cancelTag` and cancel the tag:

```dart
client.get<Feed>('feed', fromJson: Feed.fromJson, cancelTag: 'home');
client.getList<Story>('stories', fromJson: Story.fromJson, cancelTag: 'home');

// When the screen is disposed:
client.cancelRequestsByTag('home', reason: 'screen disposed');
```

`client.cancelAllRequests()` cancels every tagged request, for example on sign-out.

### One request per tag

By default a new request with a tag **cancels the previous one with the same tag**, which is exactly what search-as-you-type needs:

```dart
Future<void> onQueryChanged(String query) async {
  final result = await client.getList<Product>(
    'search',
    query: {'q': query},
    fromJson: Product.fromJson,
    cancelTag: 'search', // cancels the previous search
  );
  if (result.error is RequestCanceledException) return; // superseded, ignore it
  // ...
}
```

Pass `cancelOld: false` to let requests with the same tag run side by side. They share one token, so cancelling the tag still cancels them all.

## While the response is being parsed

Cancelling is honoured **while the response is mapped to your model**, not only while it is in flight. If the token is cancelled before `fromJson` finishes, the result is a `RequestCanceledException` and the parsed value is dropped, even if the mapping was running in an isolate.

## Streams

Tokens and tags work for [streams](streaming.md) too: cancelling ends the stream with a `RequestCanceledException` and aborts the HTTP request.

---

*Imported from the [playx_network 2.0.0 documentation](https://github.com/playx-flutter/playx_network/blob/main/docs/guides/cancellation.md). [Package site](https://playx-flutter.github.io/playx_network/) · [pub.dev](https://pub.dev/packages/playx_network).*
