# Bindings and lifecycle

A `PlayxBinding` attaches logic to a route. Every page that shows a route with a binding runs the
binding's callbacks at well-defined moments.

```dart
class JobsBinding extends PlayxBinding {
  @override Future<void> onInitApp() async {}                                          // once, at boot
  @override FutureOr<String?> redirect(BuildContext c, GoRouterState s) => null;       // before the page is built
  @override Future<void> onEnter(BuildContext c, GoRouterState s) async {}             // required
  @override Future<void> onHidden(BuildContext c) async {}
  @override Future<void> onReEnter(BuildContext c, GoRouterState? s, bool popped) async {}
  @override Future<void> onExit(BuildContext c) async {}
  @override String? breadcrumb(BuildContext c, GoRouterState s) => null;               // see Breadcrumbs
}
```

Only `onEnter` is required. `context` is the page's own context. `PlayxScope.of(context)` returns the
page's [scope](scopes.md) in every callback, including `onExit`.

## The callbacks

| Callback | When | Typical use |
|---|---|---|
| `onInitApp()` | Once per binding, during boot, before any page enters. | Register repositories, datasources, services. |
| `redirect(context, state)` | Before the route is built, when it is the destination (not for child routes). Return a location to redirect or `null`. | Validate parameters (`/jobs/abc`). |
| `onEnter(context, state)` | The page is shown for the first time. | Load data, create controllers. |
| `onHidden(context)` | Another page covers this one (push, tab switch) but it stays in the stack. | Pause timers, dismiss tours. |
| `onReEnter(context, state, wasPoppedAndReentered)` | The page becomes visible again after being hidden. | Refresh, resume. |
| `onExit(context)` | The page is removed from the tree. | Dispose resources. |

`wasPoppedAndReentered` is `true` when the pages above it were removed (pop, `popUntil`,
`go` to a parent, resetting a branch), and `false` when it comes back through a branch switch.

### Order

```
onInitApp  ->  onEnter  ->  onHidden <-> onReEnter  ->  onHidden -> onExit
```

`onExit` is always preceded by `onHidden` unless the page was never entered or is replaced in
place (see below).

## Guarantees

These hold for every navigation, so bindings can rely on them.

- **One lifecycle per page, not per route.** `details/1` pushed over `details/2` are two pages;
  the first receives `onHidden` and later `onReEnter`. The same applies when a single binding
  instance is shared by several routes.
- **Callbacks never overlap.** For one page they run strictly in order. Leaving a page while
  `onEnter` is still running queues `onHidden` / `onExit` until it finishes, so cleanup always
  runs after setup.
- **Leaving before entering.** On one navigation, every `onHidden` starts before any `onEnter` /
  `onReEnter`.
- **`onExit` follows the exit animation.** When a page is popped, the revealed page gets
  `onReEnter` immediately; the popped page gets `onHidden` immediately and `onExit` once it is
  removed from the tree.
- **`onEnter` waits for `onInitApp`.** No page enters before every binding's `onInitApp` finished.
  If boot fails the page is not entered (it shows the [error handling](error-handling.md)).
- **Replace and parameter changes start a new lifecycle.** `PlayxNavigation.offAndTo(...)`, or
  going from `/item/1` to `/item/2`, ends the old page's lifecycle (`onExit` completes) before the
  new page's `onEnter` starts, and `onEnter` receives the new parameters. Query-only changes do not
  restart it.
- **Deep links and preloaded branches are pending.** A page mounted behind the visible page (the
  parent of a deep-linked child, or a `preload: true` shell branch) has
  `PlayxPageState.pending`. It receives `onEnter` (not `onReEnter`) when it is first shown.
- **A failed `onEnter` is not entered.** If it throws or times out, no `onHidden` / `onReEnter` /
  `onExit` runs for that page. Nothing is left half-initialized.
- **Only router navigation counts.** Dialogs, bottom sheets and routes pushed with
  `Navigator.push` (outside go_router) do not hide the page underneath.

## Shell routes

```
Branch A (Home) <-> Branch B (Products)

1. Enter Home          home.onEnter
2. Switch to Products  home.onHidden, products.onEnter
3. Switch back         products.onHidden, home.onReEnter(popped: false)
```

```
Parent -> child (push and pop)

1. Enter list          list.onEnter
2. Push details        list.onHidden, details.onEnter
3. Pop details         details.onHidden, list.onReEnter(popped: true), details.onExit
4. Navigate away       list.onHidden, list.onExit
```

### Scenario table

Shell with `products -> details` and `favorites -> details` branches, plus a top-level
`/details/:id` route:

| Navigation | Events |
|---|---|
| Products, push details | `products.onHidden`, `details.onEnter` |
| Pop details | `details.onHidden`, `products.onReEnter(popped: true)`, `details.onExit` |
| Favorites details, switch to the products tab | `favDetails.onHidden`, `products.onReEnter(popped: false)` |
| Switch back to favorites | `products.onHidden`, `favDetails.onReEnter(popped: false)` |
| Push top-level `/details/1` from anywhere, then pop | `origin.onHidden`, `details.onEnter`, then `details.onHidden`, `origin.onReEnter(popped: true)`, `details.onExit` |
| `go('/products/details/7')` from favorites details | `favDetails.onHidden`, `details.onEnter` (favorites details stays alive in its branch) |
| Deep link to `/products/details/1`, then pop | `details.onEnter`, then `products.onEnter` (not re-enter) |
| `goBranch(i, initialLocation: true)` with details open | `details.onHidden`, `products.onReEnter(popped: true)`, `details.onExit` |
| `go('/login')` (outside the shell) | `onExit` once for every page that was entered, in every branch |

## Page state

`binding.currentState` (a `PlayxPageState?`) reflects the page's phase: `pending`, `enter`,
`reEnter`, `hidden`, `exit`. It is shared by every page using the binding, so for several live
pages prefer `PlayxScope.of(context).pageState`.

## Sharing a binding between live pages

One binding instance can back several pages that are alive at the same time (the same route
stacked, or one instance used for several routes). Each page still gets its own `onEnter` /
`onExit`, so one page's `onExit` can run while another page of that binding is active, and for
different routes the new page's `onEnter` can run before the old page's `onExit`. Keep per-page state
in the page's [scope](scopes.md), or check `binding.activeScopes`:

```dart
@override
Future<void> onExit(BuildContext context) async {
  // activeScopes no longer contains this page here.
  if (activeScopes.isEmpty) Get.delete<JobsController>();
}
```

## Binding registry

```dart
final binding = PlayxNavigation.findBinding<JobsBinding>();         // throws if not found
final maybe = PlayxNavigation.findBindingOrNull<JobsBinding>();
final all = PlayxNavigation.bindings;                               // unmodifiable
```

Bindings are collected from the route tree during boot, including nested and shell routes.

## Binding redirect

`redirect` validates before the page is built, which is better than navigating away from
`onEnter` (the page would still be built with missing data):

```dart
@override
FutureOr<String?> redirect(BuildContext context, GoRouterState state) =>
    state.intPathParam('id') == null ? '/jobs' : null;
```

It runs after the route's `guards` and before the route's own `redirect`, and only when the
binding's own route is the destination. See [Guards and redirects](guards-and-redirects.md).

---

*Imported from the [playx_navigation 3.0.0 documentation](https://github.com/playx-flutter/playx_navigation/blob/main/docs/bindings.md). [Package site](https://playx-flutter.github.io/playx_navigation/) · [pub.dev](https://pub.dev/packages/playx_navigation).*
