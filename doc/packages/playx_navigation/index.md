# Playx Navigation

**Playx Navigation** is a navigation package for Flutter built on top of
[`go_router`](https://pub.dev/packages/go_router). It keeps everything go_router
gives you and adds what larger apps keep rebuilding by hand:

- a **lifecycle for every page** (`onEnter`, `onHidden`, `onReEnter`, `onExit`) that behaves
  correctly with shell routes, stacked pages, deep links, replace and the browser's back button;
- **page-scoped state**: controllers that are created per page, can't overwrite each other, and
  are disposed when the page goes away, with optional GetX interop;
- **web-friendly navigation**: back to the parent when there is nothing to pop, `popUntil`,
  breadcrumbs, and browser tab titles;
- **navigation without a `BuildContext`**, route guards, error handling for slow or failing page
  setup, and loading states without blank frames.

```dart
PlayxRoute<JobDetailsController>(
  path: ':id',
  breadcrumb: (context, state) => 'Job #${state.pathParameters['id']}',
  controller: (context, state) => JobDetailsController(state.intPathParam('id')!),
  disposeController: (controller) => controller.onClose(),
  builder: (context, state) => const JobDetailsView(),
)

class JobDetailsView extends PlayxView<JobDetailsController> {
  const JobDetailsView({super.key});

  @override
  Widget buildView(BuildContext context, JobDetailsController controller) {
    return Scaffold(body: Text(controller.title));
  }
}
```

## Where to go next

| I want to... | Read |
|---|---|
| Add the package to an app | [Installation and setup](getting-started.md) |
| Decide between bindings, scopes and route controllers | [Choosing an approach](choosing-an-approach.md) |
| Define routes, transitions and shell branches | [Routes and transitions](routes.md) |
| Understand exactly when `onEnter` / `onExit` run | [Bindings and lifecycle](bindings.md) |
| Show loading states, shells and animations | [Page configuration](page-configuration.md) |
| Protect routes, validate parameters | [Guards and redirects](guards-and-redirects.md) |
| Handle slow or failing page setup | [Error handling](error-handling.md) |
| Keep a controller per page (GetX, Bloc, ...) | [Scopes](scopes.md), [Route controllers and views](controllers-and-views.md) |
| Navigate from anywhere in the app | [PlayxNavigation API](navigation-api.md) |
| Support web refresh, deep links, tab titles | [Web](web.md), [Breadcrumbs and page titles](breadcrumbs.md) |
| Test my bindings and controllers | [Testing your app](testing.md) |
| Upgrade from 2.x | [Migrating to 3.0](migration.md) |

## Requirements

- Flutter `>=3.27.0`, Dart `>=3.6.0`
- `go_router` `^17.5.0` (re-exported by this package, so one import is enough)

## Links

- [pub.dev](https://pub.dev/packages/playx_navigation)
- [GitHub](https://github.com/playx-flutter/playx_navigation)
- [API reference](https://playx-flutter.github.io/playx_navigation/api/)
- [`llms.txt`](https://github.com/playx-flutter/playx_navigation/blob/main/docs/llms.txt) and [`llms-full.txt`](https://playx-flutter.github.io/playx_navigation/llms-full.txt) for AI assistants

---

*Imported from the [playx_navigation 3.0.0 documentation](https://github.com/playx-flutter/playx_navigation/blob/main/docs/index.md). [Package site](https://playx-flutter.github.io/playx_navigation/) · [pub.dev](https://pub.dev/packages/playx_navigation).*
