# Guards and redirects

Redirects run **before** a page is built, so a guarded page never flashes and its `onEnter` /
`onExit` never run when navigation is redirected. Playx Navigation offers three levels, evaluated in
this order for the destination route:

1. `guards` on the route (`PlayxGuard`), in order.
2. The route's binding `redirect`.
3. The route's own `redirect` (go_router's).

The first one that returns a location wins; `null` means "continue".

## `PlayxGuard`

```dart
class AuthGuard extends PlayxGuard {
  const AuthGuard();

  @override
  FutureOr<String?> redirect(BuildContext context, GoRouterState state) {
    return AuthService.isLoggedIn ? null : '/login?from=${state.matchedLocation}';
  }
}

PlayxRoute(
  path: '/account',
  guards: const [AuthGuard()],
  builder: (context, state) => const AccountPage(),
)
```

- Guards may be async (`Future<String?>`). The chain stays synchronous as long as every guard
  answers synchronously, so navigation is not delayed by a frame.
- Guards on a route also protect its child routes.
- Create one inline with `PlayxGuard.from((context, state) => ...)`.

```dart
guards: [
  PlayxGuard.from((context, state) => user.isAdmin ? null : '/forbidden'),
  const AuthGuard(),
],
```

## Binding `redirect`

Validate parameters before building the page:

```dart
class JobDetailsBinding extends PlayxBinding {
  @override
  FutureOr<String?> redirect(BuildContext context, GoRouterState state) =>
      state.intPathParam('id') == null ? '/jobs' : null;
}
```

It runs only when the binding's own route is the destination, not for its child routes (use a
guard for that). Prefer it over navigating away from `onEnter`: the page is never built with
missing data and `onEnter` / `onExit` don't run.

## Route `redirect`

go_router's own `redirect` still works, and runs last. It composes with guards and bindings.

## Global redirects

Use go_router's top-level `GoRouter(redirect: ...)` for app-wide rules. It runs before route-level
redirects.

## Parameter helpers

`GoRouterState` gets safe accessors so redirects and builders never throw on bad input:

| Helper | Returns |
|---|---|
| `state.extraAs<T>()` | `extra` if it is a `T`, otherwise `null`. |
| `state.intPathParam('id')` | the path parameter as `int?`. |
| `state.intQueryParam('page')` | the query parameter as `int?`. |

!!! warning "`extra` is not part of the URL"
    After a web refresh, a typed or shared URL, or a deep link, `state.extra` is `null`. Treat
    it as an optional shortcut and load data by id. See [Web](web.md).

---

*Imported from the [playx_navigation 3.0.0 documentation](https://github.com/playx-flutter/playx_navigation/blob/main/docs/guards-and-redirects.md). [Package site](https://playx-flutter.github.io/playx_navigation/) · [pub.dev](https://pub.dev/packages/playx_navigation).*
