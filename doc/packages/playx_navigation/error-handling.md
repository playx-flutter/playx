# Error handling

Page setup can be slow or fail: a binding's `onEnter` throws, a request hangs, a controller's
constructor fails, or `onInitApp` fails at boot. Playx Navigation turns these into a visible,
retryable state instead of a spinner that never ends.

## `errorBuilder` and `enterTimeout`

```dart
PlayxRoute(
  path: '/products',
  binding: ProductsBinding(),
  enterTimeout: const Duration(seconds: 10),
  errorBuilder: (context, state, error, stackTrace, retry) => ErrorView(
    message: '$error',
    onRetry: retry,
  ),
  builder: (context, state) => const ProductsPage(),
)
```

| Parameter | Meaning |
|---|---|
| `error` | What was thrown. A `TimeoutException` when `enterTimeout` elapsed. |
| `stackTrace` | Its stack trace. |
| `retry` | Runs the setup again: a fresh `onEnter` and, for route controllers, a fresh controller. |

Set both globally with `PlayxPageConfig(errorBuilder: ..., enterTimeout: ...)`; a route's values
override the global ones.

## What counts as a failure

- `onEnter` throws, or exceeds `enterTimeout`.
- A [route controller](controllers-and-views.md) factory throws, or `PlayxPageLifecycle.onPageEnter` throws.
- `onInitApp` of any binding fails at boot: pages wait for boot, so they fail too.

A failed page is not entered: no `onHidden` / `onReEnter` / `onExit` runs for it, and its
`PlayxPageState` is `pending`. After `retry` it behaves like a normal page.

## Without an `errorBuilder`

The error is reported with `FlutterError.reportError` (so it reaches your crash reporting and shows
in debug logs) and the page keeps its loading state. It is never left as an unhandled async error.

## Errors in other lifecycle callbacks

An exception in `onHidden`, `onReEnter` or `onExit` is reported with `FlutterError.reportError`.
The page's callback queue continues, so a failing `onHidden` does not stop later callbacks, and
`onExit` still disposes the page's scope and controller.

Errors while unregistering or disposing a route controller are reported, and every cleanup step
still runs.

## Boot failures

`PlayxNavigation.boot` rethrows `onInitApp` errors to its caller.
`PlayxNavigationBuilder` reports them with `FlutterError.reportError` instead.
`PlayxNavigation.isInitialized` stays `false`, and `await PlayxNavigation.ensureInitialized`
throws the same error.

---

*Imported from the [playx_navigation 3.0.0 documentation](https://github.com/playx-flutter/playx_navigation/blob/main/docs/error-handling.md). [Package site](https://playx-flutter.github.io/playx_navigation/) · [pub.dev](https://pub.dev/packages/playx_navigation).*
