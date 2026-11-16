# Routes and transitions

## `PlayxRoute`

`PlayxRoute<T>` extends go_router's `GoRoute`. Everything `GoRoute` supports still works
(`path`, `name`, `parentNavigatorKey`, `redirect`, `onExit`, nested `routes`); it adds lifecycle,
state and web features.

```dart
PlayxRoute<JobDetailsController>(
  path: ':id',
  name: 'jobDetails',

  // Content: provide exactly one of builder / initBuilder.
  builder: (context, state) => const JobDetailsView(),

  // Lifecycle and state (all optional):
  binding: JobDetailsBinding(),
  controller: (context, state) => JobDetailsController(state.intPathParam('id')!),
  disposeController: (controller) => controller.onClose(),

  // Navigation behavior:
  transition: PlayxPageTransition.fade,
  pageConfiguration: const PlayxPageConfiguration(fullscreenDialog: true),
  guards: [const AuthGuard()],
  parentLocation: (state) => '/jobs',
  breadcrumb: (context, state) => 'Job #${state.pathParameters['id']}',

  // Loading behavior (see Page configuration):
  loadingWidget: const Center(child: CircularProgressIndicator()),
  shellBuilder: (context, state, isInitialized, child) => Scaffold(body: child),
  waitForBinding: false,
  initTransitionDuration: const Duration(milliseconds: 200),

  // Failures:
  errorBuilder: (context, state, error, stackTrace, retry) => ErrorView(onRetry: retry),
  enterTimeout: const Duration(seconds: 10),
)
```

| Parameter | Purpose | Docs |
|---|---|---|
| `builder` / `initBuilder` | Page content. `initBuilder` also receives `isInitialized`. | [Page configuration](page-configuration.md) |
| `binding` | Lifecycle callbacks, `redirect`, `breadcrumb`. | [Bindings](bindings.md) |
| `controller`, `disposeController` | One controller per page visit. | [Route controllers](controllers-and-views.md) |
| `transition`, `pageConfiguration` | How the page animates and behaves as a route. | below |
| `guards` | Redirect before the route is entered. | [Guards](guards-and-redirects.md) |
| `parentLocation` | Where `back()` goes when nothing can be popped. | [Web](web.md) |
| `breadcrumb` | The route's breadcrumb label. | [Breadcrumbs](breadcrumbs.md) |
| `loadingWidget`, `shellBuilder`, `waitForBinding`, `initTransitionDuration` | Loading states. | [Page configuration](page-configuration.md) |
| `errorBuilder`, `enterTimeout` | Slow or failing page setup. | [Error handling](error-handling.md) |

Exactly one of `builder` or `initBuilder` is required (asserted in debug mode).

## Shell routes

`PlayxShellBranch<T>` is a `StatefulShellBranch` with one `PlayxRoute` inside. It takes the same
parameters as `PlayxRoute`, so a tab and its child pages are easy to declare:

```dart
StatefulShellRoute.indexedStack(
  builder: (context, state, navigationShell) => AppScaffold(shell: navigationShell),
  branches: [
    PlayxShellBranch(
      path: '/jobs',
      name: 'jobs',
      breadcrumb: (context, state) => 'Jobs',
      builder: (context, state) => const JobsView(),
      binding: JobsBinding(),
      routes: [
        PlayxRoute(
          path: ':id',
          builder: (context, state) => const JobDetailsView(),
          binding: JobDetailsBinding(),
        ),
      ],
    ),
    PlayxShellBranch(
      path: '/settings',
      builder: (context, state) => const SettingsView(),
    ),
  ],
)
```

For a branch with several top-level routes use `PlayxShellBranch.routes(routes: [...])`. Branch
constructor options such as `navigatorKey`, `initialLocation`, `observers` and `preload` are
available too.

Switch tabs with `PlayxNavigation.goToBranch(index: 1, navigationShell: shell)`. Pages in other
branches stay alive and receive `onHidden` / `onReEnter`, never `onExit`
([details](bindings.md#shell-routes)).

Plain `ShellRoute` works as well: its pages are removed on navigation, so they exit normally.

## Transitions

`transition` takes a `PlayxPageTransition`:

| Value | Effect |
|---|---|
| `cupertino` (default) | iOS-style slide. |
| `material` | Material page transition. |
| `native` | Cupertino on iOS and macOS, Material elsewhere. |
| `fade` | Cross-fade. |
| `none` | No animation. |
| `custom` | Your `transitionsBuilder` from `PlayxPageConfiguration.customTransition`. |

```dart
PlayxRoute(
  path: '/details',
  transition: PlayxPageTransition.custom,
  pageConfiguration: PlayxPageConfiguration.customTransition(
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        SlideTransition(
          position: Tween(begin: const Offset(0, 1), end: Offset.zero).animate(animation),
          child: child,
        ),
    transitionDuration: const Duration(milliseconds: 250),
    reverseTransitionDuration: const Duration(milliseconds: 200),
    opaque: true,
  ),
  builder: (context, state) => const DetailsPage(),
)
```

### `PlayxPageConfiguration`

| Field | Meaning |
|---|---|
| `key`, `name`, `arguments`, `restorationId` | Passed to the underlying `Page`. `key` defaults to the page key from go_router. |
| `maintainState` | Keep the page built while it is covered (default `true`). If `false`, its widgets are disposed while covered, which ends its lifecycle (`onHidden`, `onExit`) and starts a new one (`onEnter`) when it is revealed again. |
| `fullscreenDialog` | Present as a fullscreen dialog. |
| `canPop`, `onPopInvoked` | Control and observe popping (`PopScope`-style). |
| `transitionsBuilder`, `transitionDuration`, `reverseTransitionDuration` | Only for `custom` (and durations also for `fade`). |
| `opaque`, `barrierDismissible`, `barrierColor`, `barrierLabel` | Route opacity and barrier for `custom` and `fade`. |

!!! note
    `none` ignores durations and barrier options. `fade` uses the configuration's durations.

---

*Imported from the [playx_navigation 3.0.0 documentation](https://github.com/playx-flutter/playx_navigation/blob/main/docs/routes.md). [Package site](https://playx-flutter.github.io/playx_navigation/) · [pub.dev](https://pub.dev/packages/playx_navigation).*
