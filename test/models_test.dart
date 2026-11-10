import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:playx/playx.dart';

void main() {
  group('PlayxWebSettings', () {
    test('has path url strategy defaults', () {
      const settings = PlayxWebSettings();
      expect(settings.usePathUrlStrategy, isTrue);
      expect(settings.optionURLReflectsImperativeAPIs, isTrue);
    });

    test('accepts custom values', () {
      const settings = PlayxWebSettings(
        usePathUrlStrategy: false,
        optionURLReflectsImperativeAPIs: false,
      );
      expect(settings.usePathUrlStrategy, isFalse);
      expect(settings.optionURLReflectsImperativeAPIs, isFalse);
    });
  });

  group('PlayxAppSettings', () {
    test('has sensible defaults', () {
      const settings = PlayxAppSettings();
      expect(settings.title, '');
      expect(settings.showPerformanceOverlay, isFalse);
      expect(settings.debugShowCheckedModeBanner, isFalse);
      expect(settings.debugShowMaterialGrid, isFalse);
      expect(settings.showSemanticsDebugger, isFalse);
      expect(settings.checkerboardOffscreenLayers, isFalse);
      expect(settings.checkerboardRasterCacheImages, isFalse);
      expect(settings.enableLog, isNotNull);
      expect(settings.shortcuts, isNull);
      expect(settings.actions, isNull);
      expect(settings.scrollBehavior, isNull);
      expect(settings.localizationsDelegates, isNull);
    });

    test('keeps custom values', () {
      const settings = PlayxAppSettings(
        title: 'Playx',
        enableLog: false,
        showPerformanceOverlay: true,
      );
      expect(settings.title, 'Playx');
      expect(settings.enableLog, isFalse);
      expect(settings.showPerformanceOverlay, isTrue);
    });
  });

  group('PlayxScreenSettings', () {
    test('has defaults', () {
      const settings = PlayxScreenSettings();
      expect(settings.designSize, const Size(360, 690));
      expect(settings.splitScreenMode, isTrue);
      expect(settings.minTextAdapt, isTrue);
      expect(settings.useInheritedMediaQuery, isFalse);
      expect(settings.ensureScreenSize, isFalse);
      expect(settings.responsiveWidgets, isNull);
    });

    test('keeps custom values', () {
      const settings = PlayxScreenSettings(
        designSize: Size(400, 800),
        responsiveWidgets: ['a'],
      );
      expect(settings.designSize, const Size(400, 800));
      expect(settings.responsiveWidgets, ['a']);
    });
  });

  group('PlayxThemeSettings', () {
    test('has defaults', () {
      const settings = PlayxThemeSettings();
      expect(settings.themeMode, ThemeMode.system);
      expect(settings.theme, isNull);
      expect(settings.darkTheme, isNull);
      expect(settings.cupertinoTheme, isNull);
      expect(settings.onThemeChanged, isNull);
    });

    test('keeps custom values', () {
      final theme = ThemeData.light();
      final settings = PlayxThemeSettings(
        theme: theme,
        themeMode: ThemeMode.dark,
      );
      expect(settings.theme, theme);
      expect(settings.themeMode, ThemeMode.dark);
    });
  });

  group('PlayxPlatformSettings', () {
    test('has defaults', () {
      const settings = PlayxPlatformSettings();
      expect(settings.initialPlatform, isNull);
      expect(settings.iosUsesMaterialWidgets, isTrue);
      expect(settings.iosUseZeroPaddingForAppbarPlatformIcon, isFalse);
      expect(settings.wrapCupertinoAppBarMiddleWithMediaQuery, isTrue);
    });
  });

  group('PlayxNavigationSettings', () {
    test('uses the navigator by default', () {
      const settings = PlayxNavigationSettings();
      expect(settings.useRouter, isFalse);
      expect(settings.goRouter, isNull);
    });

    test('uses the router for a GoRouter', () {
      final router = GoRouter(
        routes: [GoRoute(path: '/', builder: (_, _) => const SizedBox())],
      );
      final settings = PlayxNavigationSettings.goRouter(goRouter: router);
      expect(settings.useRouter, isTrue);
      expect(settings.goRouter, router);
    });
  });

  group('PlayxBootException', () {
    test('keeps the step, error and stack trace', () {
      final stack = StackTrace.current;
      final exception = PlayxBootException('Theme', StateError('boom'), stack);
      expect(exception.step, 'Theme');
      expect(exception.error, isA<StateError>());
      expect(exception.stackTrace, stack);
      expect(exception.toString(), contains('"Theme"'));
      expect(exception.toString(), contains('boom'));
    });
  });
}
