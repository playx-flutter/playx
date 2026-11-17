# Troubleshooting

## "PlayxNavigation is not initialized"

You used `PlayxNavigation` before it was booted. Wrap your app in
`PlayxNavigationBuilder(router: router, ...)`, or call `await PlayxNavigation.boot(router: router)`
before using it. See [Installation and setup](getting-started.md).

## A page shows its loading widget forever

`onEnter` never finishes or the page is waiting for boot.

- Set `enterTimeout` and an `errorBuilder` to see what happens
  ([Error handling](error-handling.md)). Without an `errorBuilder`, errors are reported with
  `FlutterError.reportError`: check your logs.
- Pages wait for every `onInitApp`. If one never completes, or boot was never called, no page enters.
  `await PlayxNavigation.ensureInitialized` completes when boot finished.
- Make sure every code path of `onEnter` completes (no un-awaited completer).

## "No X found for this page" (`StateError`)

`PlayxView<X>` or `context.controller<X>()` did not find a controller of that type. Either:

- declare it: `PlayxRoute<X>(controller: ...)`,
- store it from the binding: `PlayxScope.of(context).put<X>(...)`,
- or configure `PlayxPageConfig.findController` if it lives in a registry
  ([GetX and other registries](state-management-interop.md)).

Also check the widget is below the page. Dialogs and bottom sheets need
[`PlayxScopeProvider`](scopes.md#dialogs-and-bottom-sheets). In a `shellBuilder` or `initBuilder`
the controller may not exist yet: use `context.maybeController<X>()`.

## `onExit` runs after `onReEnter`

This is intended: when a page is popped, the revealed page re-enters immediately and the popped page
exits when its animation ends ([lifecycle guarantees](bindings.md#guarantees)). If two pages share
one resource, key it by `PlayxScope.id` or guard cleanup with `activeScopes.isEmpty`.

## A controller was deleted while a page still used it

Two live pages share a global registration (for example `Get.put` without a tag, for two stacked
`details` pages). Tag registrations with `PlayxScope.of(context).id`, keep the controller in the
scope, or use a [route controller](controllers-and-views.md).

## `state.extra` is `null` on web

It is not part of the URL, so it is lost on refresh, typed or shared URLs and deep links. Load by id
when it is missing and use `state.extraAs<T>()` to read it safely ([Web](web.md)).

## There is no back button on a page opened by URL

Flutter's automatic `AppBar` back button only appears when there is something to pop. Use
`PlayxBackButton` and a route `parentLocation` where needed ([Web](web.md#back-to-the-parent)).

## The browser tab title resets

`MaterialApp` sets its own `title` whenever it rebuilds. Return `PlayxNavigation.pageTitle` from
`onGenerateTitle` ([Browser tab titles](breadcrumbs.md#browser-tab-titles)).

## `await PlayxNavigation.offAndTo(...)` never finishes

The returned future completes when the **new** page is popped, like `to`. Don't `await` it to wait for the
navigation itself ([Navigation API](navigation-api.md#going-forward)).

## Lifecycle callbacks don't fire for dialogs or `Navigator.push`

Only router navigation (pages in go_router's stack) affects the lifecycle. Dialogs, bottom sheets and
routes pushed with `Navigator.push` don't hide the page underneath.

## Changing a query parameter doesn't re-run `onEnter`

Only the path identifies a page. Changing the query string keeps the same page. Read parameters in
the widget from `GoRouterState`, or navigate to a different path.

## Hot reload doesn't re-run `onInitApp`

`onInitApp` runs at boot. Use a hot restart after changing it.

## Dependency conflict with `go_router`

3.0 depends on `go_router: ^17.5.0`. go_router 18 raises the minimum SDK to Flutter 3.44 and moves to
`material_ui` / `cupertino_ui`; support for it will come in a later release.

## Still stuck?

Open an issue with a minimal router that reproduces it:
[github.com/playx-flutter/playx_navigation/issues](https://github.com/playx-flutter/playx_navigation/issues).

---

*Imported from the [playx_navigation 3.0.0 documentation](https://github.com/playx-flutter/playx_navigation/blob/main/docs/troubleshooting.md). [Package site](https://playx-flutter.github.io/playx_navigation/) · [pub.dev](https://pub.dev/packages/playx_navigation).*
