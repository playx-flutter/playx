# Testing your app

Bindings, controllers and guards are easy to test with Flutter's widget tests: build a small router,
pump it inside `PlayxNavigationBuilder`, navigate, and assert on what happened. This package's own
test suite uses exactly this approach.

## Test setup

```dart
Future<GoRouter> pumpApp(WidgetTester tester, GoRouter router) async {
  await tester.pumpWidget(PlayxNavigationBuilder(
    router: router,
    builder: (_) => MaterialApp.router(routerConfig: router),
  ));
  await tester.pumpAndSettle();
  return router;
}
```

- Each test should build its own `GoRouter` and pump it. `PlayxNavigation` is static; the builder
  boots the new router (and re-runs `onInitApp`) for you.
- Use `unawaited(router.push('/path'))` followed by `pumpAndSettle()` to navigate.
- Test files run in separate isolates, so static state does not leak between files.

## Test the lifecycle of a binding

Record events in a list and assert on their order:

```dart
class RecordingBinding extends PlayxBinding {
  RecordingBinding(this.name, this.log);
  final String name;
  final List<String> log;

  @override
  Future<void> onEnter(BuildContext c, GoRouterState s) async => log.add('$name:enter');
  @override
  Future<void> onHidden(BuildContext c) async => log.add('$name:hidden');
  @override
  Future<void> onReEnter(BuildContext c, GoRouterState? s, bool popped) async =>
      log.add('$name:reEnter${popped ? '(popped)' : ''}');
  @override
  Future<void> onExit(BuildContext c) async => log.add('$name:exit');
}

testWidgets('details: push and pop', (tester) async {
  final log = <String>[];
  final router = GoRouter(initialLocation: '/jobs', routes: [
    PlayxRoute(
      path: '/jobs',
      binding: RecordingBinding('jobs', log),
      builder: (_, __) => const Text('jobs'),
      routes: [
        PlayxRoute(
          path: ':id',
          binding: RecordingBinding('details', log),
          builder: (_, __) => const Text('details'),
        ),
      ],
    ),
  ]);
  await pumpApp(tester, router);
  log.clear();

  unawaited(router.push('/jobs/5'));
  await tester.pumpAndSettle();
  expect(log, ['jobs:hidden', 'details:enter']);

  router.pop();
  await tester.pumpAndSettle();
  expect(log, [
    'jobs:hidden', 'details:enter',
    'details:hidden', 'jobs:reEnter(popped)', 'details:exit',
  ]);
});
```

To test **your own** bindings, build a router with your real binding and routes and assert on the
effects (registered controllers, repository calls) instead of a log.

## Test controllers

A route controller is a plain Dart class. Unit-test it directly; `PlayxPageLifecycle` hooks are
ordinary methods:

```dart
test('loads the job by id when extra is missing', () async {
  final controller = JobDetailsController(id: 5, job: null);
  await controller.onPageEnter(fakeState);       // any GoRouterState
  expect(controller.job.value?.id, 5);
});
```

To test the **wiring** (that the page creates, shows and disposes the controller), pump a router with
the real `PlayxRoute<T>` and a fake `controller:` factory:

```dart
testWidgets('disposes the controller on exit', (tester) async {
  var disposed = false;
  final router = GoRouter(routes: [
    PlayxRoute<JobsController>(
      path: '/',
      controller: (_, __) => FakeJobsController(),
      disposeController: (_) => disposed = true,
      builder: (_, __) => const JobsView(),
    ),
    PlayxRoute(path: '/other', builder: (_, __) => const Text('other')),
  ]);
  await pumpApp(tester, router);
  router.go('/other');
  await tester.pumpAndSettle();
  expect(disposed, isTrue);
});
```

`PlayxView` needs a page scope, so test views through a router like this (a scope can only be created
by a page).

## Test guards and redirects

```dart
testWidgets('redirects to login when logged out', (tester) async {
  final router = GoRouter(routes: [
    PlayxRoute(path: '/', builder: (_, __) => const Text('home')),
    PlayxRoute(path: '/login', builder: (_, __) => const Text('login')),
    PlayxRoute(
      path: '/account',
      guards: [PlayxGuard.from((_, __) => loggedIn ? null : '/login')],
      builder: (_, __) => const Text('account'),
    ),
  ]);
  await pumpApp(tester, router);
  router.go('/account');
  await tester.pumpAndSettle();
  expect(find.text('login'), findsOneWidget);
});
```

## Test navigation from code

Anything that calls `PlayxNavigation.*` can be tested the same way: pump a router, call your code,
assert `PlayxNavigation.currentState?.matchedLocation` or find widgets.

```dart
expect(PlayxNavigation.currentState?.matchedLocation, '/jobs/5');
```

## Test breadcrumbs and page titles

Breadcrumbs only need a router and a context inside the app (use `MaterialApp.router`'s `builder` to
capture one). For page titles, mock the platform channel and collect the labels:

```dart
final titles = <String>[];
tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
  SystemChannels.platform,
  (call) async {
    if (call.method == 'SystemChrome.setApplicationSwitcherDescription') {
      final label = (call.arguments as Map)['label'] as String;
      if (label.isNotEmpty) titles.add(label); // MaterialApp sends an empty one
    }
    return null;
  },
);
```

## Tips

- Use `--no-pub` (`flutter test --no-pub`) in CI after `flutter pub get` to skip a second resolve.
- Prefer `pumpAndSettle()` after navigation: lifecycle callbacks and transitions are asynchronous.
- Assertions about `onExit` must wait for the pop animation to finish.
- Run with `flutter test --coverage` to measure coverage. This package's suite covers 99% of its lines.

---

*Imported from the [playx_navigation 3.0.0 documentation](https://github.com/playx-flutter/playx_navigation/blob/main/docs/testing.md). [Package site](https://playx-flutter.github.io/playx_navigation/) · [pub.dev](https://pub.dev/packages/playx_navigation).*
