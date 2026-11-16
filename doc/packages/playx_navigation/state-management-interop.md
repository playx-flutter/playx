# GetX and other registries

The package has no dependency on GetX or any state management library. If your app uses a global
registry (GetX, `get_it`, ...) you can mirror route controllers into it and let `PlayxView` find
controllers that bindings registered there. Configure it once, app-wide, with three optional
callbacks on `PlayxPageConfig`.

```dart
PlayxNavigationBuilder(
  router: router,
  config: PlayxPageConfig(
    // A route controller was created: register it.
    registerController: <T extends Object>(T controller, PlayxScope scope) =>
        Get.put<T>(controller, tag: scope.id),

    // A route controller is about to be disposed: unregister it.
    unregisterController: <T extends Object>(T controller, PlayxScope scope) =>
        Get.delete<T>(tag: scope.id),

    // PlayxView / context.controller<T>() found nothing in the page scope: look in the registry.
    findController: <T extends Object>(PlayxScope scope) =>
        Get.isRegistered<T>(tag: scope.id) ? Get.find<T>(tag: scope.id) : null,
  ),
  builder: (context) => const MyApp(),
)
```

| Callback | Called | Receives |
|---|---|---|
| `registerController` | Right after a `PlayxRoute<T>(controller: ...)` controller is created. | The controller as its route type `T`, and its page's `scope`. |
| `unregisterController` | Right before it is disposed (before `disposeController`). | Same. |
| `findController` | When `PlayxView<T>` / `context.controller<T>()` finds no `T` in the page scope. | The page's `scope`. Return `null` if there is none. |

The type parameter is the route's declared `T` (for `PlayxRoute<EditJobController>` it is
`EditJobController`), so registrations are typed.

## Tagged vs untagged

- **Tagged with `scope.id`** keeps stacked pages of the same type apart (`details/1` and
  `details/2` each have their controller). Look controllers up with
  `Get.find<T>(tag: PlayxScope.of(context).id)` or, simpler, `context.controller<T>()`.
- **Untagged** (`Get.put<T>(controller)` / `Get.find<T>()`) lets any code, for example another
  controller, find the controller without a tag. Stacked pages of the same type then share one
  registration, and with GetX `Get.put` keeps the first instance, so use it for pages that exist once.

## Without a registry

Skip the config entirely. Controllers live in the page's scope and are reached with
`PlayxView<T>` and `context.controller<T>()`. From a binding callback use
`PlayxScope.of(context).get<T>()`.

## Other state management

The same idea applies to anything that needs a per-page instance, for example Riverpod
overrides, Provider, or Bloc:

```dart
// Provider: expose the route controller to the subtree.
class JobDetailsView extends PlayxView<JobDetailsController> {
  const JobDetailsView({super.key});

  @override
  Widget buildView(BuildContext context, JobDetailsController controller) =>
      ChangeNotifierProvider.value(value: controller, child: const JobDetailsBody());
}
```

For Bloc, create the bloc in the route's `controller:` factory, close it in `disposeController`,
and use `BlocProvider.value` in the view.

---

*Imported from the [playx_navigation 3.0.0 documentation](https://github.com/playx-flutter/playx_navigation/blob/main/docs/state-management-interop.md). [Package site](https://playx-flutter.github.io/playx_navigation/) · [pub.dev](https://pub.dev/packages/playx_navigation).*
