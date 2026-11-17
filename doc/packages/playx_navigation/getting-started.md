# Installation and setup

## Install

```yaml
dependencies:
  playx_navigation: ^3.0.0
```

```bash
flutter pub get
```

`playx_navigation` re-exports `go_router`, so a single import gives you both:

```dart
import 'package:playx_navigation/playx_navigation.dart';
```

## 1. Define route names and paths (optional)

```dart
abstract class Routes {
  static const home = 'home';
  static const products = 'products';
  static const productDetails = 'productDetails';
}

abstract class Paths {
  static const home = '/home';
  static const products = '/products';
  static const productDetails = ':id'; // relative: /products/:id
}
```

## 2. Create bindings

A binding attaches logic to a route's lifecycle. `onEnter` is the only method you must
implement; the rest are optional. See [Bindings and lifecycle](bindings.md) for the full contract.

```dart
class ProductsBinding extends PlayxBinding {
  @override
  Future<void> onInitApp() async {
    // Once, at boot, before any page is entered: register repositories, services...
  }

  @override
  Future<void> onEnter(BuildContext context, GoRouterState state) async {
    // The page is about to be shown for the first time: load data, create controllers.
  }

  @override
  Future<void> onExit(BuildContext context) async {
    // The page was removed: release resources.
  }
}
```

!!! tip "No binding needed?"
    For a page that only needs one controller you can skip the binding entirely and use a
    [route controller](controllers-and-views.md). See
    [Choosing an approach](choosing-an-approach.md).

## 3. Build the router with `PlayxRoute`

`PlayxRoute` extends go_router's `GoRoute`, so it works anywhere a `GoRoute` does (including
inside `StatefulShellRoute` and `ShellRoute`).

```dart
final router = GoRouter(
  initialLocation: Paths.home,
  routes: [
    PlayxRoute(
      path: Paths.home,
      name: Routes.home,
      builder: (context, state) => const HomePage(),
      binding: HomeBinding(),
    ),
    PlayxRoute(
      path: Paths.products,
      name: Routes.products,
      builder: (context, state) => const ProductsPage(),
      binding: ProductsBinding(),
      routes: [
        PlayxRoute(
          path: Paths.productDetails,
          name: Routes.productDetails,
          builder: (context, state) =>
              ProductDetailsPage(product: state.extraAs<Product>()),
          binding: ProductDetailsBinding(),
        ),
      ],
    ),
  ],
);
```

## 4. Wrap your app in `PlayxNavigationBuilder`

`PlayxNavigationBuilder` boots the navigation system: it finds every binding in the route tree,
runs each `onInitApp`, and provides global configuration to the pages.

```dart
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return PlayxNavigationBuilder(
      router: router,
      config: const PlayxPageConfig(
        loadingWidget: Center(child: CircularProgressIndicator()),
      ),
      builder: (context) => MaterialApp.router(routerConfig: router),
    );
  }
}
```

!!! note "Booting without the widget"
    You can call `await PlayxNavigation.boot(router: router)` yourself (for example before
    `runApp`) and omit `router:` from the builder. `await PlayxNavigation.ensureInitialized`
    completes once every `onInitApp` has finished.

## 5. Navigate from anywhere

```dart
PlayxNavigation.toNamed(Routes.productDetails,
    pathParameters: {'id': '5'}, extra: product);
PlayxNavigation.back();
```

No `BuildContext` is needed. See the [PlayxNavigation API](navigation-api.md).

## Web setup

Call this before `runApp` to use path URLs and have the browser URL reflect `push`:

```dart
void main() {
  PlayxNavigation.setupWeb();
  runApp(const MyApp());
}
```

See [Web](web.md) for refresh, deep links, back buttons and tab titles.

---

*Imported from the [playx_navigation 3.0.0 documentation](https://github.com/playx-flutter/playx_navigation/blob/main/docs/getting-started.md). [Package site](https://playx-flutter.github.io/playx_navigation/) · [pub.dev](https://pub.dev/packages/playx_navigation).*
