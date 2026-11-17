# Web

Web apps differ from mobile in ways that affect navigation: pages can be opened directly by URL,
the user can refresh at any time, and the browser has its own back and forward buttons. Playx
Navigation has features for each.

## Setup

Call this before `runApp` for path URLs (no `#`) and so that `push` is reflected in the browser URL:

```dart
void main() {
  PlayxNavigation.setupWeb();            // usePathUrlStrategy: true, optionURLReflectsImperativeAPIs: true
  runApp(const MyApp());
}
```

It does nothing outside the web.

## `extra` does not survive a refresh

`state.extra` is not part of the URL. After a refresh, a typed or shared URL, or a deep link, it is
`null`. Treat it as an optional shortcut and load by id when it is missing.

```dart
class JobDetailsController with PlayxPageLifecycle {
  JobDetailsController({required this.id, Job? job}) : job = Rxn(job);
  final int id;
  final Rxn<Job> job;

  @override
  Future<void> onPageEnter(GoRouterState state) async {
    job.value ??= await repository.getJob(id);
  }
}

controller: (context, state) => JobDetailsController(
  id: state.intPathParam('id')!,
  job: state.extraAs<Job>(),     // typed, never throws, null when missing
),
```

`state.extraAs<T>()`, `state.intPathParam(name)` and `state.intQueryParam(name)` never throw. To keep
`extra` across browser back and forward, give `GoRouter` an `extraCodec`.

Validate ids before the page is built with a binding's [`redirect`](guards-and-redirects.md) so a
bad URL never builds a half-empty page.

## Back to the parent

After a refresh or deep link there may be nothing to pop, so Flutter's automatic `AppBar` back
button is missing. `PlayxNavigation.back()` pops when it can and otherwise goes to the page's
**parent**: from a job's details to the jobs list, even when the details page was opened directly.

The parent is found in this order:

1. The route's `parentLocation`, if it returns a value.
2. The nearest shorter path that matches a route: `/jobs/5/edit` -> `/jobs/5` -> `/jobs`.

The automatic parent never falls back to `/`, so tab roots such as `/jobs` have no parent unless you
set one.

```dart
// Nested or path-shaped routes need nothing extra:
PlayxRoute(path: '/jobs', builder: ..., routes: [
  PlayxRoute(path: ':id', builder: ...),          // /jobs/5 -> back -> /jobs
]),

// When the path doesn't contain the parent, say where to go:
PlayxRoute(
  path: '/job/:id',
  parentLocation: (state) => '/jobs',
  builder: ...,
),
PlayxRoute(
  path: '/edit-job/:id',
  parentLocation: (state) => '/jobs/${state.pathParameters['id']}',
  builder: ...,
),
```

### `PlayxBackButton`

```dart
AppBar(
  leading: PlayxNavigation.canGoBack ? const PlayxBackButton() : null,
  title: const Text('Job details'),
)
```

`PlayxBackButton` calls `back()`. It renders nothing when `canGoBack` is `false`, and accepts
`onPressed` (called first, e.g. to save a draft) and `color`.

| API | Purpose |
|---|---|
| `PlayxNavigation.back()` | Pop, or go to the parent. Returns `false` if neither is possible. |
| `PlayxNavigation.canGoBack` | Whether `back()` can do something. |
| `PlayxNavigation.parentLocation` | The location `back()` goes to when there is nothing to pop. |
| `PlayxNavigation.popOrGo(location)` | Pop, or go to a specific fallback. |
| `PlayxNavigation.popUntil(location, orGo: true)` | Pop back to a page, or go there if it isn't in the stack. |

## `popUntil`

Return to a page deeper in history, for example back to the jobs list after a create flow:

```dart
PlayxNavigation.popUntil('/jobs');                  // false if '/jobs' isn't in the stack
PlayxNavigation.popUntil('/jobs', orGo: true);      // goes to '/jobs' if it isn't
PlayxNavigation.popUntilNamed('jobs', orGo: true);
```

Pages above the target receive `onHidden` / `onExit` and the target receives `onReEnter`. Details in the
[navigation API](navigation-api.md#going-back).

## Browser back and forward

The browser's buttons behave like `pop` and `push`: the page that was left gets `onExit`, the page
revealed gets `onReEnter`, and going forward creates a new page with `onEnter`.

## Refresh

A refresh restarts the app: `onInitApp` runs again, and the pages for the URL behave like a deep
link. Only the visible page enters; pages behind it are *pending* until they are shown. Controllers
and `extra` from before the refresh are gone, so rebuild state from the URL.

## Browser tab titles

`PlayxNavigationBuilder(pageTitle: PlayxPageTitle(...))` keeps the tab title in sync with the current
page, using the labels you declared for breadcrumbs. See
[Breadcrumbs and page titles](breadcrumbs.md#browser-tab-titles).

## Breadcrumbs

Breadcrumbs are derived from the route tree, so they are correct after a refresh or a deep link.
See [Breadcrumbs and page titles](breadcrumbs.md).

---

*Imported from the [playx_navigation 3.0.0 documentation](https://github.com/playx-flutter/playx_navigation/blob/main/docs/web.md). [Package site](https://playx-flutter.github.io/playx_navigation/) · [pub.dev](https://pub.dev/packages/playx_navigation).*
