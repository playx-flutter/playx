# Scopes

Every page with a binding or controller gets a `PlayxScope`: one per **page visit**, from `onEnter`
to `onExit`. It solves the classic problem of stacked pages (`details/1` over `details/2`, or `edit`
over `create` sharing a `JobFormController`) overwriting or deleting each other's controllers.

It works with any state management (GetX, Bloc, Provider, ChangeNotifier, plain classes).

## Getting the scope

```dart
final scope = PlayxScope.of(context);       // throws a StateError if there is none
final maybe = PlayxScope.maybeOf(context);  // null outside a page with a binding or controller
```

`context` can be the context passed to a binding callback, or any context inside the page's widget
tree. In binding callbacks the same scope is returned in `onEnter`, `onHidden`, `onReEnter` and
`onExit`. The scope is disposed right after `onExit` completes.

## API

| Member | Purpose |
|---|---|
| `id` | A unique, never reused id for this page visit. Use it as a GetX `tag`, a family key, ... |
| `put<T>(value, {dispose})` | Store an object in the page. `dispose(value)` runs when the scope ends. |
| `get<T>()` / `maybeGet<T>()` / `has<T>()` | Read it. Exact type first, then the first stored value that `is T`. |
| `onDispose(callback)` | Run cleanup after `onExit` completes (reverse registration order). |
| `state` | This page's `GoRouterState`. |
| `binding` | The binding the scope belongs to. |
| `pageState`, `isActive`, `isDisposed` | This page's lifecycle state. |

`binding.currentState` is shared by every page using the binding; `scope.pageState` belongs to one page.

Storing again under the same type replaces the value for lookups; the earlier value's `dispose`
still runs when the scope ends. Calling `put` or `onDispose` after the scope is disposed throws a
`StateError`. Errors thrown by disposers are reported and the remaining disposers still run.

## Patterns

### Lifecycle methods with the scope id as a tag (GetX)

```dart
class JobDetailsBinding extends PlayxBinding {
  @override
  Future<void> onEnter(BuildContext context, GoRouterState state) async {
    Get.put(
      JobDetailsController(id: state.intPathParam('id')!, job: state.extraAs<Job>()),
      tag: PlayxScope.of(context).id,
    );
  }

  @override
  Future<void> onHidden(BuildContext context) async =>
      Get.find<JobDetailsController>(tag: PlayxScope.of(context).id).pauseUpdates();

  @override
  Future<void> onReEnter(BuildContext context, GoRouterState? state, bool popped) async =>
      Get.find<JobDetailsController>(tag: PlayxScope.of(context).id).resumeUpdates();

  @override
  Future<void> onExit(BuildContext context) async =>
      Get.delete<JobDetailsController>(tag: PlayxScope.of(context).id);
}

// In the page:
final controller = Get.find<JobDetailsController>(tag: PlayxScope.of(context).id);
```

### Cleanup registered in `onEnter`

`onExit` is optional, so cleanup can be attached where the controller is created:

```dart
@override
Future<void> onEnter(BuildContext context, GoRouterState state) async {
  final scope = PlayxScope.of(context);
  Get.put(JobDetailsController(), tag: scope.id);
  scope.onDispose(() => Get.delete<JobDetailsController>(tag: scope.id));
}
```

### Keep the controller in the scope (no global registry)

```dart
@override
Future<void> onEnter(BuildContext context, GoRouterState state) async {
  PlayxScope.of(context).put(
    JobDetailsController(id: state.intPathParam('id')!),
    dispose: (controller) => controller.onClose(),
  );
}

// In the page, in onHidden / onReEnter / onExit, or in widgets:
final controller = PlayxScope.of(context).get<JobDetailsController>();
// or: context.controller<JobDetailsController>()
```

See [Route controllers and views](controllers-and-views.md) for the declarative version of this.

## Shared (unscoped) resources

`binding.activeScopes` lists the pages currently using the binding. A page leaves the list **before**
its `onExit` runs, so this only cleans up when no other page needs the resource:

```dart
@override
Future<void> onExit(BuildContext context) async {
  if (activeScopes.isEmpty) Get.delete<JobsController>();
}
```

## Dialogs and bottom sheets

Dialogs and sheets are shown above the page's widget tree. Pass the scope down with
`PlayxScopeProvider`:

```dart
final scope = PlayxScope.of(context);
showModalBottomSheet(
  context: context,
  builder: (_) => PlayxScopeProvider(scope: scope, child: const JobFilterSheet()),
);
```

---

*Imported from the [playx_navigation 3.0.0 documentation](https://github.com/playx-flutter/playx_navigation/blob/main/docs/scopes.md). [Package site](https://playx-flutter.github.io/playx_navigation/) · [pub.dev](https://pub.dev/packages/playx_navigation).*
