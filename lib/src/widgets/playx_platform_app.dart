import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:playx/src/widgets/models/playx_app_settings.dart';
import 'package:playx/src/widgets/models/playx_navigation_settings.dart';
import 'package:playx/src/widgets/models/playx_platform_settings.dart';
import 'package:playx/src/widgets/models/playx_screen_settings.dart';
import 'package:playx/src/widgets/models/playx_theme_settings.dart';
import 'package:playx_localization/playx_localization.dart';
import 'package:playx_navigation/playx_navigation.dart';
import 'package:playx_theme/playx_theme.dart';
import 'package:playx_widget/playx_widget.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// PlayxPlatformApp: A widget that wraps [MaterialApp] or [CupertinoApp] based on the platform,
/// with additional PlayX functionality such as theme management, screen adaptation, and localization.
///
/// This widget allows you to configure your app for both Android and iOS platforms with a unified API,
/// handling platform-specific app setup and integrating with the PlayX ecosystem.
class PlayxPlatformApp extends StatelessWidget {
  /// Sets the preferred orientations of the app.
  ///
  /// This defines which screen orientations are allowed in the app. Defaults to [DeviceOrientation.portraitUp].
  final List<DeviceOrientation> preferredOrientations;

  /// Configuration settings specific to the platform (Android/iOS).
  ///
  /// This includes settings for platform-specific widgets and behaviors.
  final PlayxPlatformSettings platformSettings;

  /// Configuration settings for screen size and responsiveness.
  ///
  /// Controls how the app adapts to different screen sizes and orientations.
  final PlayxScreenSettings screenSettings;

  /// Configuration settings for the app's theme.
  ///
  /// Includes options for light and dark themes, theme mode, and platform-specific themes.
  final PlayxThemeSettings themeSettings;

  /// Configuration settings for the app's navigation.
  ///
  /// Allows you to choose between using a standard navigator or a [GoRouter] for routing.
  final PlayxNavigationSettings navigationSettings;

  /// General settings for the application.
  ///
  /// Includes options like app title, performance overlays, debug banners, and more.
  final PlayxAppSettings appSettings;

  /// Constructs a [PlayxPlatformApp] with customizable settings for orientation,
  /// platform-specific widgets, screen size, theme, navigation, and general app behavior.
  const PlayxPlatformApp({
    super.key,
    this.preferredOrientations = const [
      DeviceOrientation.portraitUp,
    ],
    this.platformSettings = const PlayxPlatformSettings(),
    this.screenSettings = const PlayxScreenSettings(),
    this.themeSettings = const PlayxThemeSettings(),
    this.navigationSettings = const PlayxNavigationSettings(),
    this.appSettings = const PlayxAppSettings(),
  });

  @override
  Widget build(BuildContext context) {
    return PlayxThemeBuilder(builder: (ctx, xTheme) {
      themeSettings.onThemeChanged?.call(xTheme);
      SystemChrome.setPreferredOrientations(preferredOrientations);
      return ScreenUtilInit(
        designSize: screenSettings.designSize,
        minTextAdapt: screenSettings.minTextAdapt,
        splitScreenMode: screenSettings.splitScreenMode,
        useInheritedMediaQuery: screenSettings.useInheritedMediaQuery,
        rebuildFactor: screenSettings.rebuildFactor,
        fontSizeResolver: screenSettings.fontSizeResolver,
        responsiveWidgets: screenSettings.responsiveWidgets,
        ensureScreenSize: screenSettings.ensureScreenSize,
        builder: (context, child) {
          return PlayxLocalizationBuilder(builder: (ctx, locale) {
            final platformApp = navigationSettings.useRouter
                ? PlatformApp.router(
                    debugShowCheckedModeBanner:
                        appSettings.debugShowCheckedModeBanner,
                    routeInformationProvider:
                        navigationSettings.goRouter?.routeInformationProvider ??
                            navigationSettings.routeInformationProvider,
                    routerDelegate:
                        navigationSettings.goRouter?.routerDelegate ??
                            navigationSettings.routerDelegate,
                    routeInformationParser:
                        navigationSettings.goRouter?.routeInformationParser ??
                            navigationSettings.routeInformationParser,
                    backButtonDispatcher:
                        navigationSettings.goRouter?.backButtonDispatcher ??
                            navigationSettings.backButtonDispatcher,
                    builder: navigationSettings.builder,
                    supportedLocales: PlayxLocalization.supportedLocales,
                    localizationsDelegates:
                        PlayxLocalization.localizationDelegates,
                    locale: locale.locale,
                    showPerformanceOverlay: appSettings.showPerformanceOverlay,
                    checkerboardRasterCacheImages:
                        appSettings.checkerboardRasterCacheImages,
                    checkerboardOffscreenLayers:
                        appSettings.checkerboardOffscreenLayers,
                    showSemanticsDebugger: appSettings.showSemanticsDebugger,
                    shortcuts: appSettings.shortcuts,
                    scrollBehavior: appSettings.scrollBehavior,
                    actions: appSettings.actions,
                    material: (c, _) => MaterialAppRouterData(
                      debugShowMaterialGrid: appSettings.debugShowMaterialGrid,
                      darkTheme: themeSettings.darkTheme,
                      themeMode: themeSettings.themeMode,
                      theme: themeSettings.theme ??
                          xTheme.themeBuilder?.call(locale.locale) ??
                          xTheme.themeData,
                    ),
                  )
                : PlatformApp(
                    debugShowCheckedModeBanner:
                        appSettings.debugShowCheckedModeBanner,
                    navigatorObservers: navigationSettings.navigatorObservers ??
                        [
                          if (navigationSettings
                              .includeSentryNavigationObserver)
                            SentryNavigatorObserver(),
                        ],
                    navigatorKey: navigationSettings.navigatorKey,
                    home: navigationSettings.home,
                    routes: navigationSettings.routes ?? {},
                    initialRoute: navigationSettings.initialRoute,
                    onGenerateRoute: navigationSettings.onGenerateRoute,
                    onGenerateInitialRoutes:
                        navigationSettings.onGenerateInitialRoutes,
                    onUnknownRoute: navigationSettings.onUnknownRoute,
                    builder: navigationSettings.builder,
                    supportedLocales: PlayxLocalization.supportedLocales,
                    localizationsDelegates:
                        PlayxLocalization.localizationDelegates,
                    locale: locale.locale,
                    showPerformanceOverlay: appSettings.showPerformanceOverlay,
                    checkerboardRasterCacheImages:
                        appSettings.checkerboardRasterCacheImages,
                    checkerboardOffscreenLayers:
                        appSettings.checkerboardOffscreenLayers,
                    showSemanticsDebugger: appSettings.showSemanticsDebugger,
                    shortcuts: appSettings.shortcuts,
                    scrollBehavior: appSettings.scrollBehavior,
                    actions: appSettings.actions,
                    material: (c, _) => MaterialAppData(
                      debugShowMaterialGrid: appSettings.debugShowMaterialGrid,
                      darkTheme: themeSettings.darkTheme,
                      themeMode: themeSettings.themeMode,
                      theme: themeSettings.theme ??
                          xTheme.themeBuilder?.call(locale.locale) ??
                          xTheme.themeData,
                    ),
                    cupertino: (c, _) => CupertinoAppData(
                      theme: themeSettings.cupertinoTheme ??
                          xTheme.cupertinoThemeBuilder?.call(locale.locale) ??
                          xTheme.cupertinoThemeData,
                    ),
                  );

            return navigationSettings.goRouter != null
                ? PlayxNavigationBuilder(
                    builder: (ctx) => platformApp,
                    router: navigationSettings.goRouter!)
                : platformApp;
          });
        },
      );
    });
  }
}
