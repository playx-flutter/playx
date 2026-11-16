# Page configuration

While a binding's `onEnter` runs, the page can show a loading state. These options decide what the
user sees. Settings can be given per route or once for all routes with `PlayxPageConfig`.

## Resolution order

For every option: **route value, then global `PlayxPageConfig`, then the built-in default.**

```dart
PlayxNavigationBuilder(
  router: router,
  config: PlayxPageConfig(
    loadingWidget: const Center(child: CircularProgressIndicator()),
    waitForBinding: true,
    initTransitionDuration: const Duration(milliseconds: 200),
    shellBuilder: (context, state, isInitialized, child) => Scaffold(body: child),
  ),
  builder: (context) => MaterialApp.router(routerConfig: router),
)
```

| Option | Route | Global | Default |
|---|---|---|---|
| Loading widget | `loadingWidget` | `PlayxPageConfig.loadingWidget` | `SizedBox.shrink()` |
| Block until `onEnter` completes | `waitForBinding` | `PlayxPageConfig.waitForBinding` | `true` |
| Shell around the content | `shellBuilder` | `PlayxPageConfig.shellBuilder` | none |
| Cross-fade loading to content | `initTransitionDuration` | `PlayxPageConfig.initTransitionDuration` | none |
| Error UI | `errorBuilder` | `PlayxPageConfig.errorBuilder` | none (see [Error handling](error-handling.md)) |
| `onEnter` timeout | `enterTimeout` | `PlayxPageConfig.enterTimeout` | none |

These options apply to routes that have a binding or a controller. A route without either has
nothing to wait for and builds immediately.

## Blocking (default)

The page shows `loadingWidget` until `onEnter` finishes, then the content. This guarantees the
content never builds before its data and controllers exist.

## Non-blocking: `waitForBinding: false`

The content builds immediately and `onEnter` runs in the background. Use it when the page can
render before data arrives (skeletons, placeholders).

```dart
PlayxRoute(
  path: '/profile',
  binding: ProfileBinding(),
  waitForBinding: false,
  builder: (context, state) => const ProfilePage(),
)
```

!!! note
    A page with a [route controller](controllers-and-views.md) always waits until the controller
    exists, even with `waitForBinding: false`, so a view never builds without its controller.

## Shell builder

A `shellBuilder` renders the page's chrome (AppBar, Drawer, Scaffold) **immediately**, including
during the page transition. Only the body waits for `onEnter`, so there are no blank frames.

```dart
PlayxRoute(
  path: '/channels',
  binding: ChannelsBinding(),
  builder: (context, state) => const ChannelsList(),          // the body
  shellBuilder: (context, state, isInitialized, child) => Scaffold(
    appBar: AppBar(title: const Text('Channels')),
    drawer: isInitialized ? const AppDrawer() : null,
    body: child, // loading widget until initialized, then the body
  ),
)
```

`child` is the loading widget until `onEnter` completes, then the result of `builder`.
`shellBuilder` only applies with `builder`, not `initBuilder`.

## Init-aware builder

`initBuilder` gives you full control: it receives `isInitialized` and decides what to show. The
loading widget, shell builder and cross-fade are not applied.

```dart
PlayxRoute(
  path: '/profile',
  binding: ProfileBinding(),
  initBuilder: (context, state, isInitialized) =>
      isInitialized ? const ProfilePage() : const ProfileSkeleton(),
)
```

Without a binding, `isInitialized` is always `true`. Provide `builder` **or** `initBuilder`, not both.

## Cross-fade animation

With `initTransitionDuration`, an `AnimatedSwitcher` cross-fades from the loading state to the
content. `Duration.zero` or `null` disables it. It applies to `builder` (with or without a shell).

```dart
PlayxPageConfig(initTransitionDuration: Duration(milliseconds: 250))
```

## Changing the global config

Provide a new `PlayxPageConfig` to `PlayxNavigationBuilder` and pages that depend on it update
(for example to change the loading widget when the theme changes).

---

*Imported from the [playx_navigation 3.0.0 documentation](https://github.com/playx-flutter/playx_navigation/blob/main/docs/page-configuration.md). [Package site](https://playx-flutter.github.io/playx_navigation/) · [pub.dev](https://pub.dev/packages/playx_navigation).*
