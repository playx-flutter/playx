# playx_navigation

[pub.dev](https://pub.dev/packages/playx_navigation) · [Docs](https://playx-flutter.github.io/playx_navigation/) · Used by Playx 3.0: **3.0.0** (2.x used 2.1.0)

Navigation built on `go_router`. It keeps everything `go_router` gives you and adds a reliable
**page lifecycle**, **page-scoped state**, **web-friendly navigation**, and **navigation without
a `BuildContext`**. `go_router` is re-exported.

```dart
final router = GoRouter(
  routes: [
    PlayxRoute<JobsController>(
      path: '/jobs',
      controller: (context, state) => JobsController(),
      builder: (context, state) => const JobsView(),
    ),
  ],
);

PlayxMaterialApp(
  navigationSettings: PlayxNavigationSettings.goRouter(goRouter: router),
);

PlayxNavigation.to('/jobs/1'); // no BuildContext
```

Pass `PlayxNavigationSettings.goRouter(goRouter: ..., config: PlayxPageConfig(...))` to the
[app widgets](../app-widgets.md); they wrap the app in `PlayxNavigationBuilder` for you. Playx also
calls `PlayxNavigation.setupWeb` during boot using your `PlayxWebSettings`.

## What changed in 3.0.0

The binding lifecycle is now tracked **per page instance**, which fixes a set of navigation bugs
and changes a few observable behaviors. (The unpublished 2.2.0 is included.)

### Breaking / behavior changes

- **Lifecycle per page instance.** `onHidden` / `onReEnter` also fire for the initial route.
  `replace` and changed path parameters end the old page's lifecycle (`onExit` completes) before the
  new page's `onEnter`, and `onEnter` receives the new parameters. Stacked pages each have their own
  lifecycle. `onExit` waits for a still-running `onEnter`. `onEnter` waits for every `onInitApp`.
  A failed `onEnter` is reported (or shown by `errorBuilder`) instead of being unhandled.
- **`offAndTo` / `offAndToNamed` return `Future<T?>`** (were `Future<void>`).
- **`PlayxNavigation.isInitialized` is `false` after a failed boot.**
- `PlayxRoute` and `PlayxShellBranch` are generic (`PlayxRoute<T extends Object>`); existing code is
  unaffected.
- `PlayxBinding.onExit` is optional.
- `currentState`, `currentRoute`, `currentRouteName` return `null` instead of throwing while
  go_router shows its error page.

### New

- **Page scopes (`PlayxScope`)** — a container per page visit with automatic disposal and a unique
  `id` (useful for GetX tags).
- **Route controllers** — `PlayxRoute<T>(controller: ..., disposeController: ...)` creates one controller
  per page visit; mix in `PlayxPageLifecycle` for `onPageEnter`/`onPageExit`. `PlayxView<T>` is a
  `GetView`-like base widget.
- **Guards and redirects** — `PlayxGuard`, `PlayxRoute.guards`, `PlayxBinding.redirect`.
- **Error handling** — `errorBuilder` (with `retry`) and `enterTimeout`.
- **Breadcrumbs** — `PlayxBreadcrumbs` widget, `PlayxBreadcrumbsBuilder`, runtime labels.
- **Browser tab titles** — `PlayxNavigationBuilder(pageTitle: PlayxPageTitle(appName: ...))`.
- **Web/back navigation** — `PlayxNavigation.back()`, `popUntil`, `popOrGo`, `PlayxBackButton`,
  `parentLocation`.
- **`GoRouterState` helpers** — `extraAs<T>()`, `intPathParam(name)`, `intQueryParam(name)`.
- Updated `go_router` to ^17.5.0; new docs site, ~190 tests (99% coverage).

### Fixes

- `router.replace` reused the old page's state, so the new binding never ran `onEnter`.
- Changed path parameters didn't re-run `onEnter`.
- `onExit` was skipped when a page was left during `onEnter`.
- `ensureInitialized` awaited before `boot` never completed; a failed boot is no longer also reported
  as an unhandled async error.
- `PlayxNavigationBuilder` now boots a different router given to the same builder.

## What changed in 2.1.0 (used by Playx 2.1.x)

`initBuilder` — an init-aware builder `(context, state, isInitialized)` on `PlayxRoute` and
`PlayxShellBranch`.

## What it means for Playx

- Playx 2.1.x already used `PlayxPageConfig`; it keeps working through
  `PlayxNavigationSettings.goRouter(config: ...)`.
- Review code that depended on `onEnter`/`onExit` timing or on `onReEnter` to refresh parameters —
  see the [package migration guide](https://playx-flutter.github.io/playx_navigation/migration/).
