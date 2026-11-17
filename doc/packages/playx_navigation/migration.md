# Migrating to 3.0

3.0.0 reworks how the binding lifecycle is tracked (per page instead of per route) and adds
page scopes, route controllers, web helpers, breadcrumbs and page titles. Most apps only need to
check the items under [What changes](#what-changes). Everything from 2.x still compiles, apart from the
small signature changes listed below.

```yaml
dependencies:
  playx_navigation: ^3.0.0
```

!!! info "About 2.2.0"
    2.2.0 was developed on the way to 3.0.0 and was never published; its changes are part of 3.0.0.

## What changes

### Lifecycle behavior

The lifecycle now belongs to each page instance. This fixes real bugs (see the
[changelog](https://github.com/playx-flutter/playx_navigation/blob/main/CHANGELOG.md)) and changes
observable behavior in a few places. Check bindings that depend on any of these:

| Before | Now |
|---|---|
| The first navigation away from the initial route did not call `onHidden` / `onReEnter` for it. | It does. |
| `router.replace` (`offAndTo`) reused the old page's state: the new binding never ran `onEnter` and the old one never ran `onExit`. | The old page exits, then the new one enters. |
| Going from `/item/1` to `/item/2` did not re-run `onEnter` with the new parameters. | The old page exits and a new one enters with the new parameters. |
| `onReEnter` was used to refresh a page's parameters (`updateJob(...)`). | A different path parameter is a new page (`onExit`, then `onEnter`), so that workaround is no longer needed. |
| The same route stacked twice, or a binding shared by several routes, mixed up lifecycle state. | Every page has its own lifecycle. |
| Leaving a page while `onEnter` was still running skipped `onExit`. | `onExit` runs after `onEnter` finishes. |
| `onEnter` could start before an async `onInitApp` finished. | `onEnter` waits for boot. |
| `onExit` ran synchronously when the widget was disposed. | It is queued behind running callbacks, so it can run slightly later. |
| On pop, order between the revealed page's `onReEnter` and the popped page's `onExit` was unspecified. | `onReEnter` first (immediately), `onExit` after the exit animation. |
| `wasPoppedAndReentered` compared path prefixes. | It uses the router's page stack. It is also `true` when popping a top-level route back into a tab, or `details/2` back to `details/1`. |
| An exception in `onEnter` was an unhandled async error and left the page loading forever. | It is reported with `FlutterError.reportError` (or shown by `errorBuilder`). |

If you relied on the old behavior of any of these, review the [lifecycle guarantees](bindings.md#guarantees).

### Signature and type changes

| Change | Action |
|---|---|
| `PlayxRoute` and `PlayxShellBranch` are generic (`PlayxRoute<T extends Object>`). | None: `PlayxRoute(...)` infers `Object`. Raw `is PlayxRoute` checks still match. |
| `PlayxBinding.onExit` is optional (no-op by default). | None. Existing overrides still work. |
| `PlayxNavigation.offAndTo` and `offAndToNamed` return `Future<T?>` (they were `Future<void>`). | None for fire-and-forget calls. If you `await` them, note the future completes when the **new page is popped** (with its result), as `to` does. |
| `currentState`, `currentRoute` and `currentRouteName` return `null` instead of throwing while go_router shows its error page. | None. |
| `PlayxNavigation.isInitialized` is `false` after a failed boot (it used to be `true`). | None. |
| `PlayxNavigation.ensureInitialized` can be awaited before `boot` and is released when boot finishes. | None. |
| `PlayxNavigationBuilder` boots again when it is given a different router. | None. |
| `PlayxPageState` is exported. | None. |

### Guards: composition order

Guards run before a binding's `redirect`, which runs before the route's own `redirect`. If you
used go_router's `redirect` only, nothing changes.

## What's new

You do not need to adopt any of it, but you may want to:

- **[Scopes](scopes.md)** (`PlayxScope`): per-page controllers that stacked pages cannot overwrite.
- **[Route controllers and `PlayxView<T>`](controllers-and-views.md)**: no binding needed for the
  common one-controller-per-page case, plus a `GetView<T>` replacement.
- **[GetX interop hooks](state-management-interop.md)**: `registerController`, `unregisterController`,
  `findController`.
- **[Guards](guards-and-redirects.md)** and binding `redirect`.
- **[Error handling](error-handling.md)**: `errorBuilder`, `enterTimeout`.
- **[Web helpers](web.md)**: `back()`, `canGoBack`, `popUntil`, `popOrGo`, `PlayxBackButton`, `extraAs`, `intPathParam`.
- **[Breadcrumbs and page titles](breadcrumbs.md)**.

## Migration checklist

1. Update the dependency and run your tests.
2. Search for `await PlayxNavigation.offAndTo` / `offAndToNamed` and check you want to wait for the
   new page's result.
3. Review bindings that use `onReEnter` to refresh state, `onExit` to delete shared objects, or that
   are shared between routes (see [sharing a binding](bindings.md#sharing-a-binding-between-live-pages)).
4. Move `Get.put` / `Get.delete` pairs to a [tag per page](scopes.md) if you stack pages of one type.
5. Add `errorBuilder` / `enterTimeout` where a failing `onEnter` would leave users on a spinner.
6. On web, replace hand-written back buttons with `PlayxBackButton` and load data by id when
   `state.extra` is `null`.

---

*Imported from the [playx_navigation 3.0.0 documentation](https://github.com/playx-flutter/playx_navigation/blob/main/docs/migration.md). [Package site](https://playx-flutter.github.io/playx_navigation/) · [pub.dev](https://pub.dev/packages/playx_navigation).*
