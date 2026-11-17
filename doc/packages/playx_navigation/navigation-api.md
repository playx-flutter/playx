# PlayxNavigation API

`PlayxNavigation` is a static facade over the router, so you can navigate from controllers,
services and bindings without a `BuildContext`. Boot it first (`PlayxNavigationBuilder(router: ...)`
or `PlayxNavigation.boot`). Using it before that throws an exception that explains how to set it up.

## Going forward

Names matter here: methods without `Named` take a **location** (`'/jobs/5?tab=open'`), methods with
`Named` take a **route name** plus parameters.

| Method | go_router call | Stack effect |
|---|---|---|
| `to(location, {extra})` | `push` | Adds a page on top. Returns a `Future<T?>` with the page's result. |
| `toNamed(name, {pathParameters, queryParameters, extra})` | `pushNamed` | Same, by name. |
| `offAll(location, {extra})` | `go` | Replaces the whole stack with the location's own stack. |
| `offAllNamed(name, ...)` | `goNamed` | Same, by name. |
| `offAndTo(location, {extra})` | `replace` | Replaces the **top** page only. Pages below stay and are not re-entered. |
| `offAndToNamed(name, ...)` | `replaceNamed` | Same, by name. |

```dart
// Push and wait for a result:
final saved = await PlayxNavigation.toNamed<bool>('editJob',
    pathParameters: {'id': '5'}, extra: job);

// Clear the stack:
PlayxNavigation.offAllNamed('home');

// Replace the current page (e.g. login -> home):
PlayxNavigation.offAndToNamed('home');
```

!!! warning "`offAndTo` returns the *new* page's result"
    Like `to`, the future returned by `offAndTo` / `offAndToNamed` completes when the new page is
    popped (with its result), **not** when the replacement happens. Don't `await` it if you
    only want to wait for the navigation:

    ```dart
    PlayxNavigation.offAndTo('/home');                 // fire and forget
    final ok = await PlayxNavigation.offAndTo<bool>('/edit');  // wait for the result
    ```

`offAll` / `offAllNamed` return a `Future<void>` that completes immediately.

The lifecycle that results from each is described in [Bindings and lifecycle](bindings.md).

## Going back

| Method | Behavior |
|---|---|
| `pop([result])` | Pops the top page. Throws if there is nothing to pop. |
| `maybePop([result])` | Pops if possible; returns whether it did. |
| `canPop()` | Whether something can be popped. |
| `back([result])` | Pops, or goes to the page's parent when there is nothing to pop. Returns `false` if neither is possible. |
| `canGoBack` / `parentLocation` | Whether `back()` can do something, and where it would go. |
| `popOrGo(location, {result, extra})` | Pops, or goes to a specific fallback location. |
| `popOrGoNamed(name, ...)` | Same, by name. |
| `popUntil(location, {orGo})` | Pops until the page showing `location` is on top. |
| `popUntilNamed(name, {pathParameters, orGo})` | Same, by name. |

`popUntil` compares paths only (query and fragment are ignored) and the page closest to the top
wins. It returns `true` when that page is on top. If the location is not in the stack, nothing is
popped and it returns `false`, unless `orGo: true`, which then goes to the location. Pages above the
target receive `onHidden` / `onExit` and the target `onReEnter(popped: true)`.

See [Web](web.md) for `back()`, `parentLocation` and `popUntil` when the stack may be empty.

## Tabs

```dart
PlayxNavigation.goToBranch(index: 1, navigationShell: shell);
```

Restores the branch's last location. Pass `initialLocation: true` to reset it
(by default `true` when tapping the already-selected branch).

## State and listeners

| Member | Description |
|---|---|
| `currentState` | Current `GoRouterState`, or `null` while go_router shows its error page. |
| `currentRoute` / `currentRouteName` | The top `GoRoute` and its name. |
| `namedLocation(name, {pathParameters, queryParameters})` | Builds a location string. |
| `addRouteChangeListener(l)` / `removeRouteChangeListener(l)` | Notified on every route change. |
| `refresh()` | Re-evaluates redirects for the current location. Doesn't rebuild pages or change lifecycle. |
| `restore(matchList)` | Restores a saved `RouteMatchList`. |
| `goRouter` | The underlying `GoRouter`. |
| `playxRouter` | The `PlayxRouter` with helpers like `parentOf`, `stateFor`, `pageStack`, `popToPage`. |
| `rootNavigatorKey`, `navigationContext` | The root navigator's key and its current context (for dialogs, snack bars). |
| `hasRouter` | Whether a router has been set up. |

## Boot and bindings

| Member | Description |
|---|---|
| `boot({required router})` | Finds every binding, runs `onInitApp`, sets `isInitialized`. Calling it again re-boots with the new router. |
| `ensureInitialized` | A `Future` that completes when boot finished. May be awaited before `boot` is called. If boot failed it completes with that error. |
| `isInitialized` | `true` after a successful boot, `false` after a failed one. |
| `bindings`, `findBinding<T>()`, `findBindingOrNull<T>()` | The binding registry. |
| `setupWeb({usePathUrlStrategy, optionURLReflectsImperativeAPIs})` | Path URLs and push-reflecting URLs on web. No-op elsewhere. |

## Breadcrumbs and titles

| Member | Description |
|---|---|
| `breadcrumbs(context, {mode, rootLocation})` | The breadcrumb trail of the current page. |
| `setBreadcrumbLabel(context, label)` | Set (or with `null` clear) the current page's runtime label. |
| `breadcrumbsListenable` | Notifies when the trail may have changed. |
| `pageTitle` | The browser tab title last applied by `PlayxNavigationBuilder.pageTitle`. |

See [Breadcrumbs and page titles](breadcrumbs.md).

## `PlayxRouter`

The instance behind the facade is available as `PlayxNavigation.playxRouter`. It exposes the same
navigation methods plus lower-level helpers that are useful for custom navigation UI:

| Member | Description |
|---|---|
| `parentOf(state)` | The location `back()` would go to from the page described by `state`. |
| `stateFor(location)` | The `GoRouterState` a location would show, without navigating. `null` if no route matches. |
| `isShellBranchRoot(location)` | Whether the location is the first page of its shell branch. |
| `pageStack` | The states of the pages in the stack, bottom to top. |
| `popToPage(pageKey)` | Pops until the page with that key is on top. |
| `stateOrNull` | Like `state`, but `null` instead of throwing when nothing matched. |

---

*Imported from the [playx_navigation 3.0.0 documentation](https://github.com/playx-flutter/playx_navigation/blob/main/docs/navigation-api.md). [Package site](https://playx-flutter.github.io/playx_navigation/) · [pub.dev](https://pub.dev/packages/playx_navigation).*
