import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:playx/playx.dart';

import 'helpers/boot_helpers.dart';

GoRouter createRouter() => GoRouter(
  routes: [GoRoute(path: '/', builder: (_, _) => const Text('router home'))],
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    mockBootPlatform();
    await Playx.boot(
      appConfigBuilder: () => FakeAppConfig(<String>[]),
      localeConfigBuilder: fakeLocaleConfig,
      themeConfigBuilder: fakeThemeConfig,
      securePrefsSettings: testSecurePrefsSettings,
      workManagerSettings: testWorkManagerSettings,
    );
  });

  tearDownAll(() async {
    await Playx.dispose();
  });

  group('PlayxMaterialApp', () {
    testWidgets('shows the home widget with the app title', (tester) async {
      await tester.pumpWidget(
        const PlayxMaterialApp(
          appSettings: PlayxAppSettings(title: 'Playx'),
          navigationSettings: PlayxNavigationSettings(home: Text('home')),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('home'), findsOneWidget);
      expect(
        tester.widget<MaterialApp>(find.byType(MaterialApp)).title,
        'Playx',
      );
    });

    testWidgets('reports the current theme to onThemeChanged', (tester) async {
      XTheme? reported;
      await tester.pumpWidget(
        PlayxMaterialApp(
          themeSettings: PlayxThemeSettings(
            onThemeChanged: (t) => reported = t,
          ),
          navigationSettings: const PlayxNavigationSettings(home: Text('home')),
        ),
      );
      await tester.pumpAndSettle();

      expect(reported, isNotNull);
    });

    testWidgets('uses the custom theme and settings when provided', (
      tester,
    ) async {
      final theme = ThemeData(primaryColor: Colors.red);
      await tester.pumpWidget(
        PlayxMaterialApp(
          themeSettings: PlayxThemeSettings(
            theme: theme,
            themeMode: ThemeMode.light,
          ),
          navigationSettings: const PlayxNavigationSettings(
            home: Text('home'),
            includeSentryNavigationObserver: true,
            navigatorObservers: null,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.theme, theme);
      expect(app.themeMode, ThemeMode.light);
    });

    testWidgets('adds extra localization delegates', (tester) async {
      await tester.pumpWidget(
        const PlayxMaterialApp(
          appSettings: PlayxAppSettings(localizationsDelegates: []),
          navigationSettings: PlayxNavigationSettings(home: Text('home')),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('home'), findsOneWidget);
    });

    testWidgets('supports a GoRouter', (tester) async {
      await tester.pumpWidget(
        PlayxMaterialApp(
          navigationSettings: PlayxNavigationSettings.goRouter(
            goRouter: createRouter(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('router home'), findsOneWidget);
    });

    testWidgets('supports the router constructor', (tester) async {
      final router = createRouter();
      await tester.pumpWidget(
        PlayxMaterialApp(
          navigationSettings: PlayxNavigationSettings.router(
            routeInformationProvider: router.routeInformationProvider,
            routeInformationParser: router.routeInformationParser,
            routerDelegate: router.routerDelegate,
            backButtonDispatcher: router.backButtonDispatcher,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('router home'), findsOneWidget);
    });
  });

  group('PlayxPlatformApp', () {
    testWidgets('shows the home widget', (tester) async {
      await tester.pumpWidget(
        const PlayxPlatformApp(
          appSettings: PlayxAppSettings(title: 'Playx'),
          navigationSettings: PlayxNavigationSettings(home: Text('home')),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('home'), findsOneWidget);
    });

    testWidgets('reports the current theme to onThemeChanged', (tester) async {
      XTheme? reported;
      await tester.pumpWidget(
        PlayxPlatformApp(
          themeSettings: PlayxThemeSettings(
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            onThemeChanged: (t) => reported = t,
          ),
          navigationSettings: const PlayxNavigationSettings(home: Text('home')),
        ),
      );
      await tester.pumpAndSettle();

      expect(reported, isNotNull);
    });

    testWidgets('supports a GoRouter', (tester) async {
      await tester.pumpWidget(
        PlayxPlatformApp(
          navigationSettings: PlayxNavigationSettings.goRouter(
            goRouter: createRouter(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('router home'), findsOneWidget);
    });

    testWidgets('supports the router constructor', (tester) async {
      final router = createRouter();
      await tester.pumpWidget(
        PlayxPlatformApp(
          navigationSettings: PlayxNavigationSettings.router(
            routeInformationProvider: router.routeInformationProvider,
            routeInformationParser: router.routeInformationParser,
            routerDelegate: router.routerDelegate,
            backButtonDispatcher: router.backButtonDispatcher,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('router home'), findsOneWidget);
    });
  });

  group('PlayxGetMaterialApp', () {
    testWidgets('shows the home widget', (tester) async {
      await tester.pumpWidget(
        const PlayxGetMaterialApp(
          appSettings: PlayxAppSettings(title: 'Playx'),
          navigationSettings: PlayxGetNavigationSettings(home: Text('home')),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('home'), findsOneWidget);
    });

    testWidgets('reports the current theme to onThemeChanged', (tester) async {
      XTheme? reported;
      await tester.pumpWidget(
        PlayxGetMaterialApp(
          themeSettings: PlayxThemeSettings(
            onThemeChanged: (t) => reported = t,
          ),
          navigationSettings: const PlayxGetNavigationSettings(
            home: Text('home'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(reported, isNotNull);
    });

    testWidgets('supports GetX pages', (tester) async {
      await tester.pumpWidget(
        PlayxGetMaterialApp(
          navigationSettings: PlayxGetNavigationSettings(
            initialRoute: '/',
            getPages: [GetPage(name: '/', page: () => const Text('get page'))],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('get page'), findsOneWidget);
    });

    testWidgets('supports the router constructor', (tester) async {
      final router = createRouter();
      await tester.pumpWidget(
        PlayxGetMaterialApp(
          navigationSettings: PlayxGetNavigationSettings.router(
            routeInformationProvider: router.routeInformationProvider,
            routeInformationParser: router.routeInformationParser,
            routerDelegate: router.routerDelegate,
            backButtonDispatcher: router.backButtonDispatcher,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('router home'), findsOneWidget);
    });
  });

  group('PlayxGetPlatformApp', () {
    testWidgets('shows the home widget', (tester) async {
      await tester.pumpWidget(
        const PlayxGetPlatformApp(
          appSettings: PlayxAppSettings(title: 'Playx'),
          home: Text('home'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('home'), findsOneWidget);
    });

    testWidgets('supports GetX pages', (tester) async {
      await tester.pumpWidget(
        PlayxGetPlatformApp(
          navigationSettings: PlayxGetNavigationSettings(
            initialRoute: '/',
            getPages: [GetPage(name: '/', page: () => const Text('get page'))],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('get page'), findsOneWidget);
    });

    testWidgets('supports the router constructor', (tester) async {
      final router = createRouter();
      await tester.pumpWidget(
        PlayxGetPlatformApp(
          navigationSettings: PlayxGetNavigationSettings.router(
            routeInformationProvider: router.routeInformationProvider,
            routeInformationParser: router.routeInformationParser,
            routerDelegate: router.routerDelegate,
            backButtonDispatcher: router.backButtonDispatcher,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('router home'), findsOneWidget);
    });
  });

  group('Cupertino platform apps', () {
    const ios = PlayxPlatformSettings(initialPlatform: TargetPlatform.iOS);

    testWidgets('PlayxPlatformApp shows the home widget on iOS', (
      tester,
    ) async {
      await tester.pumpWidget(
        const PlayxPlatformApp(
          platformSettings: ios,
          themeSettings: PlayxThemeSettings(
            cupertinoTheme: CupertinoThemeData(),
          ),
          navigationSettings: PlayxNavigationSettings(
            home: Text('home'),
            navigatorObservers: null,
            includeSentryNavigationObserver: true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('home'), findsOneWidget);
    });

    testWidgets('PlayxPlatformApp supports a GoRouter on iOS', (tester) async {
      await tester.pumpWidget(
        PlayxPlatformApp(
          platformSettings: ios,
          navigationSettings: PlayxNavigationSettings.goRouter(
            goRouter: createRouter(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('router home'), findsOneWidget);
    });

    testWidgets('PlayxGetPlatformApp shows the home widget on iOS', (
      tester,
    ) async {
      await tester.pumpWidget(
        const PlayxGetPlatformApp(
          platformSettings: ios,
          home: Text('home'),
          themeSettings: PlayxThemeSettings(
            cupertinoTheme: CupertinoThemeData(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('home'), findsOneWidget);
    });

    testWidgets('PlayxGetPlatformApp supports the router on iOS', (
      tester,
    ) async {
      final router = createRouter();
      await tester.pumpWidget(
        PlayxGetPlatformApp(
          platformSettings: ios,
          navigationSettings: PlayxGetNavigationSettings.router(
            routeInformationProvider: router.routeInformationProvider,
            routeInformationParser: router.routeInformationParser,
            routerDelegate: router.routerDelegate,
            backButtonDispatcher: router.backButtonDispatcher,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('router home'), findsOneWidget);
    });
  });
}
