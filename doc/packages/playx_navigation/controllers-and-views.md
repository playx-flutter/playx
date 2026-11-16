# Route controllers and views

The simplest way to give a page state: declare the controller type on the route. The package
creates one controller **per page visit**, runs its lifecycle hooks, and disposes it. Views read it
like GetX's `GetView<T>`. No binding class is needed (but a binding can be added too).

## Declaring a controller

```dart
PlayxRoute<JobDetailsController>(
  path: ':id',
  controller: (context, state) => JobDetailsController(
    jobId: state.intPathParam('id')!,
    job: state.extraAs<Job>(),   // null on web refresh / deep link
  ),
  disposeController: (controller) => controller.onClose(),   // optional
  builder: (context, state) => const JobDetailsView(),
)
```

`PlayxShellBranch<T>` accepts the same `controller` / `disposeController` parameters.

- The factory runs when the page is entered, after every `onInitApp` finished. The controller is
  stored in the page's [scope](scopes.md) under `T` and exists before the first build.
- `disposeController` runs when the page exits (after `onPageExit`).
- Two stacked pages of the same route each get their own controller.

## Controller lifecycle hooks

Mix in `PlayxPageLifecycle` to react to the page's lifecycle from the controller itself. The `onPage*`
names do not clash with `GetxController`'s `onInit` / `onReady` / `onClose`.

```dart
class JobsController extends GetxController with PlayxPageLifecycle {
  @override
  Future<void> onPageEnter(GoRouterState state) async => loadFirstPage();

  @override
  void onPageHidden() => tourController.dismissTour();

  @override
  void onPageReEnter(GoRouterState? state, bool wasPoppedAndReentered) {
    if (pagingController.itemList?.isNotEmpty ?? false) {
      tourController.startTour(checkRoute: false);
    }
  }

  @override
  void onPageExit() => saveScrollPosition();
}
```

All hooks may be sync or async. While `onPageEnter` runs, the page shows its loading state
([Page configuration](page-configuration.md)), so the view only builds once the data is loaded
(unless the route uses `waitForBinding: false`).

### Order

For a route with both a binding and a controller:

```
enter:    create controller -> registerController -> binding.onEnter -> onPageEnter -> content builds
hidden:   binding.onHidden  -> onPageHidden
reEnter:  binding.onReEnter -> onPageReEnter
exit:     binding.onExit    -> onPageExit -> unregisterController -> disposeController
```

- The controller is created **before** `binding.onEnter`, so the binding can call
  `PlayxScope.of(context).get<T>()`.
- Callbacks never overlap, and exit waits for a running enter.
- Replace or a path-parameter change disposes the old controller before the new one is created.
- A page behind a deep link gets its controller when it is first shown. Until then it shows its
  loading widget, even with `waitForBinding: false`.
- If the factory or `onPageEnter` throws, the route's [`errorBuilder`](error-handling.md) is shown.
  `retry` creates a fresh controller.

## `PlayxView<T>`

`PlayxView<T>` gets the page's controller and passes it to `buildView`:

```dart
class JobsView extends PlayxView<JobsController> {
  const JobsView({super.key});

  @override
  Widget buildView(BuildContext context, JobsController controller) {
    return Scaffold(
      body: const BuildJobsList(),                 // a child view in another file
      floatingActionButton: FloatingActionButton(onPressed: controller.refresh),
    );
  }
}
```

Child widgets in separate files work the same way. Any widget below the page resolves **the same
page's** controller:

```dart
class BuildJobsList extends PlayxView<JobsController> {
  const BuildJobsList({super.key});

  @override
  Widget buildView(BuildContext context, JobsController controller) =>
      ListView(children: [for (final job in controller.jobs) BuildJobItem(job: job)]);
}

class BuildJobItem extends PlayxView<JobsController> {
  const BuildJobItem({super.key, required this.job});
  final Job job;

  @override
  Widget buildView(BuildContext context, JobsController controller) => ListTile(
        title: Text(job.title),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () => controller.delete(job),   // closures are safe
        ),
      );
}
```

Plain widgets can use the context extension:

```dart
final controller = context.controller<JobsController>();   // throws a clear StateError if missing
final maybe = context.maybeController<JobsController>();   // null if missing
```

- `const` constructors and callbacks are safe: the controller is resolved from the context on every
  build and passed in. A widget instance never stores it.
- A view can ask for a **base type**: `PlayxView<JobFormController>` works on both
  `PlayxRoute<CreateJobController>` and `PlayxRoute<EditJobController>`.
- In a `shellBuilder` or `initBuilder` the controller may not exist yet; use `maybeController<T>()`.
- Dialogs and bottom sheets need [`PlayxScopeProvider`](scopes.md#dialogs-and-bottom-sheets).

### Lookup order

1. The page's scope: a route controller, or a value a binding stored with
   `PlayxScope.of(context).put`, including values of a subtype.
2. `PlayxPageConfig.findController`: lets `PlayxView` find controllers a binding registered in an
   external registry. See [GetX and other registries](state-management-interop.md).

So `PlayxView` also works with plain bindings:

```dart
class JobsBinding extends PlayxBinding {
  @override
  Future<void> onEnter(BuildContext context, GoRouterState state) async {
    PlayxScope.of(context).put(JobsController(), dispose: (c) => c.onClose());
  }
}
```

## Migrating from `GetView<T>`

| Before (GetX) | After |
|---|---|
| `class X extends GetView<T>` | `class X extends PlayxView<T>` |
| `Widget build(BuildContext context)` | `Widget buildView(BuildContext context, T controller)` |
| body uses `controller` | unchanged |
| `Get.find<T>()` in a widget | `context.controller<T>()` |
| binding `Get.put` / `Get.delete` | `PlayxRoute<T>(controller:, disposeController:)`, or keep the binding |
| binding `onHidden` / `onReEnter` using `Get.find` | `PlayxPageLifecycle` hooks on the controller, or keep them in the binding |

---

*Imported from the [playx_navigation 3.0.0 documentation](https://github.com/playx-flutter/playx_navigation/blob/main/docs/controllers-and-views.md). [Package site](https://playx-flutter.github.io/playx_navigation/) · [pub.dev](https://pub.dev/packages/playx_navigation).*
