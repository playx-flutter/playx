# Making requests

## The methods

Every method returns a `Future<NetworkResult<...>>` and never throws.

| Method | Sends | Returns |
|--------|-------|---------|
| `get<T>` | `GET` | `NetworkResult<T>` |
| `getList<T>` | `GET` | `NetworkResult<List<T>>` |
| `post<T>` / `postList<T>` | `POST` | `NetworkResult<T>` / `NetworkResult<List<T>>` |
| `put<T>` / `putList<T>` | `PUT` | `NetworkResult<T>` / `NetworkResult<List<T>>` |
| `patch<T>` / `patchList<T>` | `PATCH` | `NetworkResult<T>` / `NetworkResult<List<T>>` |
| `delete<T>` / `deleteList<T>` | `DELETE` | `NetworkResult<T>` / `NetworkResult<List<T>>` |
| `download` | `GET` | `NetworkResult<Response>` (see [Downloads](#downloads)) |
| `getStream<T>` / `postStream<T>` | `GET` / `POST` | `NetworkStreamResult<T>` (see [Streaming](streaming.md)) |
| `getSse` / `postSse` | `GET` / `POST` | `NetworkStreamResult<PlayxSseEvent>` |

The methods share the same parameters:

```dart
final result = await client.post<User>(
  'users',                                   // path, relative to the Dio baseUrl
  body: {'name': 'Ada'},                     // request body (post, put, patch, delete)
  contentType: Headers.jsonContentType,
  query: {'notify': true},                   // query parameters
  headers: {'x-request-id': id},             // extra headers
  fromJson: User.fromJson,                   // JSON -> your model
);
```

## Mapping the response

`fromJson` receives the decoded JSON (`dynamic`: usually a `Map` or a `List`) and returns your model. It can be `async`. If it throws, the result is an `UnableToProcessException`.

For `getList`, `postList` and the other list methods, `fromJson` is called **once per item**:

```dart
final result = await client.getList<Cat>('images/search', fromJson: Cat.fromJson);
```

### Reading nested data with `dataKey`

When the useful data is wrapped in an envelope, point `dataKey` at it. Dot notation reaches nested maps, and numeric segments index into lists:

```json
{ "status": "ok", "payload": { "user": { "id": 1, "name": "Ada" } } }
```

```dart
final result = await client.get<User>(
  'me',
  dataKey: 'payload.user',
  fromJson: User.fromJson,
);
```

`dataKey: 'data.users.0'` reads the first user of `data.users`. A key that contains a literal dot wins over the path reading, and a key that doesn't exist gives `null`.

### Unwrapping each list item with `itemDataKey`

For APIs that wrap every item (Strapi's `attributes`, for example), `itemDataKey` unwraps each element before `fromJson`:

```json
{ "data": [ { "id": 1, "attributes": { "title": "Hello" } } ] }
```

```dart
final result = await client.getList<Post>(
  'posts',
  dataKey: 'data',
  itemDataKey: 'attributes',
  fromJson: Post.fromJson,
);
```

Items without the key are passed through unchanged.

## Path parameters

Write placeholders in the path and pass the values:

```dart
final result = await client.get<Post>(
  'users/{userId}/posts/{postId}',
  pathParameters: {'userId': 42, 'postId': 7},
  fromJson: Post.fromJson,
);
// GET users/42/posts/7
```

- Values are URL-encoded with `Uri.encodeComponent`, so `hello world` becomes `hello%20world` and `a/b` becomes `a%2Fb`.
- A placeholder without a matching key is left untouched.
- The substitution is a single pass, so a value that contains `{other}` is not substituted again.
- A `null` value for a placeholder that appears in the path is a programming error. The request is not sent and the result is an `UnexpectedErrorException` (the cause is logged).
- Path parameters work with every method, including `download` and the [streaming](streaming.md) methods.

### App-wide path parameters

`customPathParameters` fills placeholders for **every** request. It is handy for an API version or a tenant:

```dart
final client = PlayxNetworkClient(
  dio: Dio(BaseOptions(baseUrl: 'https://api.example.com/')),
  customPathParameters: () => {'version': 'v2'},
);

await client.get<User>('{version}/users/{id}', pathParameters: {'id': 1}, fromJson: User.fromJson);
// GET v2/users/1
```

Values passed to a request win over the app-wide ones. Pass `attachCustomPathParameters: false` to skip them for one request. The callback is only called when the path contains a `{`.

## Headers and query parameters

Set headers and query parameters that apply to every request on the client. Both callbacks can be `async`:

```dart
final client = PlayxNetworkClient(
  dio: dio,
  customHeaders: () async => {'authorization': 'Bearer ${await tokens.read()}'},
  customQuery: () => {'lang': 'en'},
);
```

Per-request `headers` and `query` are merged on top, and win when the same key appears in both. Skip the client-level values for one request with `attachCustomHeaders: false` and `attachCustomQuery: false`.

!!! warning "Passing your own `options`"
    If you pass a Dio `Options` object, it is used **as is** and replaces `headers` and the client's custom headers. The custom query is still attached. Prefer `headers:` unless you need other `Options` fields such as `responseType` or `extra`.

## Downloads

`download` saves the response to `savePath` and returns the Dio `Response` on success:

```dart
final result = await client.download(
  'files/{id}',
  pathParameters: {'id': 12},
  savePath: '${dir.path}/report.pdf',
  onReceiveProgress: (received, total) => print('$received / $total'),
);
```

`deleteOnError` (default `true`) removes a partial file when the download fails.

## Per-request overrides

Most client-level behavior can be overridden for a single request:

| Parameter | Effect |
|-----------|--------|
| `settings` | Replaces the client's [`PlayxNetworkClientSettings`](../configuration.md#settings) for this request (log settings, messages, success codes, isolate mapping, ...). |
| `errorMapper` | A different [message mapper](errors.md#the-error-message). |
| `errorExtraMapper` | A different [error object mapper](errors.md#custom-error-objects). |
| `shouldHandleUnauthorizedRequest` | `false` to skip the `onUnauthorizedRequestReceived` callback. |
| `cancelToken` / `cancelTag` / `cancelOld` | See [Cancellation](cancellation.md). |

```dart
final result = await client.get<Report>(
  'reports/1',
  fromJson: Report.fromJson,
  settings: const PlayxNetworkClientSettings(
    useIsolateForMappingJson: false,   // small payload, parse inline
    shouldShowApiErrors: false,        // never show the server's message
  ),
);
```

---

*Imported from the [playx_network 2.0.0 documentation](https://github.com/playx-flutter/playx_network/blob/main/docs/guides/requests.md). [Package site](https://playx-flutter.github.io/playx_network/) · [pub.dev](https://pub.dev/packages/playx_network).*
