# Choosing an approach

Playx Navigation offers three ways to attach logic and state to a page. They can be mixed in the
same app, even on the same route.

| | 1. Binding only | 2. Binding + scope | 3. Route controller |
|---|---|---|---|
| You write | a `PlayxBinding` class | a `PlayxBinding` class | one `controller:` factory on the route |
| Controller lives in | wherever you put it (a global registry, a field) | the page's [`PlayxScope`](scopes.md) or a registry keyed by `scope.id` | the page's `PlayxScope` (optionally mirrored into GetX) |
| Safe with the same route stacked twice | only if you key by hand | yes | yes |
| Views read it with | `Get.find`, `Provider`, ... | `PlayxView<T>` / `context.controller<T>()` / `Get.find(tag:)` | `PlayxView<T>` / `context.controller<T>()` |
| Lifecycle hooks | binding methods | binding methods | `PlayxPageLifecycle` mixin on the controller (and binding methods if you also add a binding) |
| Best for | app-level setup (`onInitApp`), redirects, several resources per page | pages needing async setup or several controllers | the common "one controller per page" case |

## Decision guide

- **A page needs one controller and a view that uses it** → route controller
  ([guide](controllers-and-views.md)).
- **A page needs async setup, several controllers, or special cleanup** → binding with a scope
  ([guide](scopes.md)).
- **You only need to register app-wide services at startup, or validate parameters** → a binding's
  `onInitApp` / `redirect`.
- **The page has no state at all** → a plain `PlayxRoute` without binding or controller.

## The same page three ways

=== "Binding only"

    ```dart
    class JobsBinding extends PlayxBinding {
      @override
      Future<void> onEnter(BuildContext context, GoRouterState state) async {
        Get.put(JobsController());
      }

      @override
      Future<void> onExit(BuildContext context) async {
        Get.delete<JobsController>();
      }
    }

    PlayxRoute(path: '/jobs', binding: JobsBinding(), builder: (_, __) => const JobsView());
    ```

    Simple, but two stacked pages of the same type share one registration.

=== "Binding + scope"

    ```dart
    class JobsBinding extends PlayxBinding {
      @override
      Future<void> onEnter(BuildContext context, GoRouterState state) async {
        Get.put(JobsController(), tag: PlayxScope.of(context).id);
      }

      @override
      Future<void> onExit(BuildContext context) async {
        Get.delete<JobsController>(tag: PlayxScope.of(context).id);
      }
    }
    ```

    The tag is unique per page, so stacked pages get their own controller.

=== "Route controller"

    ```dart
    PlayxRoute<JobsController>(
      path: '/jobs',
      controller: (context, state) => JobsController(),
      disposeController: (controller) => controller.onClose(),
      builder: (_, __) => const JobsView(), // a PlayxView<JobsController>
    )
    ```

    No binding class. The package creates, scopes and disposes the controller.

---

*Imported from the [playx_navigation 3.0.0 documentation](https://github.com/playx-flutter/playx_navigation/blob/main/docs/choosing-an-approach.md). [Package site](https://playx-flutter.github.io/playx_navigation/) · [pub.dev](https://pub.dev/packages/playx_navigation).*
