import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:playx/src/widgets/models/playx_app_settings.dart';
import 'package:playx/src/widgets/models/playx_navigation_settings.dart';
import 'package:playx/src/widgets/models/playx_screen_settings.dart';
import 'package:playx/src/widgets/models/playx_theme_settings.dart';
import 'package:playx_localization/playx_localization.dart';
import 'package:playx_navigation/playx_navigation.dart';
import 'package:playx_theme/playx_theme.dart';
import 'package:playx_widget/playx_widget.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// PlayxMaterialApp: A custom widget that extends [StatelessWidget] and wraps
/// the [MaterialApp] with additional configurations for theme, screen settings,
/// and navigation.
///
/// This widget makes it easy to set up a Flutter application with pre-configured
/// settings for app orientation, screen size adaptation, theming, localization,
/// and navigation, all while integrating the PlayX ecosystem.
class PlayxMaterialApp extends StatelessWidget {
  /// Sets the preferred orientations of the app.
  ///
  /// This determines the allowed screen orientations when the app is in use.
  /// Defaults to [DeviceOrientation.portraitUp].
  final List<DeviceOrientation> preferredOrientations;

  /// Configuration settings for screen size and responsiveness.
  ///
  /// These settings control how the app adapts to different screen sizes,
  /// text scaling, and split-screen mode.
  final PlayxScreenSettings screenSettings;

  /// Configuration settings for the app's theme.
  ///
  /// Includes options for light and dark themes, theme mode, and high contrast themes.
  final PlayxThemeSettings themeSettings;

  /// Configuration settings for the app's navigation.
  ///
  /// Allows you to use a standard navigator or a [GoRouter] for declarative routing.
  final PlayxNavigationSettings navigationSettings;

  /// General settings for the application.
  ///
  /// Includes options like app title, performance overlays, debug banners, and more.
  final PlayxAppSettings appSettings;

  /// Constructs a [PlayxMaterialApp] with customizable settings for orientation,
  /// screen size, theme, navigation, and general app behavior.
  const PlayxMaterialApp({
    super.key,
    this.preferredOrientations = const [
      DeviceOrientation.portraitUp,
    ],
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
            final materialApp = navigationSettings.useRouter
                ? MaterialApp.router(
                    title: appSettings.title,
                    theme: themeSettings.theme ??
                        xTheme.themeBuilder?.call(locale.locale) ??
                        xTheme.themeData,
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
                    darkTheme: themeSettings.darkTheme,
                    themeMode: themeSettings.themeMode,
                    supportedLocales: PlayxLocalization.supportedLocales,
                    localizationsDelegates:
                        appSettings.localizationsDelegates == null
                            ? PlayxLocalization.localizationDelegates
                            : [
                                ...PlayxLocalization.localizationDelegates,
                                ...appSettings.localizationsDelegates!,
                              ],
                    locale: locale.locale,
                    debugShowMaterialGrid: appSettings.debugShowMaterialGrid,
                    showPerformanceOverlay: appSettings.showPerformanceOverlay,
                    checkerboardRasterCacheImages:
                        appSettings.checkerboardRasterCacheImages,
                    checkerboardOffscreenLayers:
                        appSettings.checkerboardOffscreenLayers,
                    showSemanticsDebugger: appSettings.showSemanticsDebugger,
                    shortcuts: appSettings.shortcuts,
                    scrollBehavior: appSettings.scrollBehavior,
                    highContrastTheme: themeSettings.highContrastTheme,
                    highContrastDarkTheme: themeSettings.highContrastDarkTheme,
                    actions: appSettings.actions,
                  )
                : MaterialApp(
                    title: appSettings.title,
                    theme: themeSettings.theme ??
                        xTheme.themeBuilder?.call(locale.locale) ??
                        xTheme.themeData,
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
                    darkTheme: themeSettings.darkTheme,
                    themeMode: themeSettings.themeMode,
                    supportedLocales: PlayxLocalization.supportedLocales,
                    localizationsDelegates:
                        appSettings.localizationsDelegates == null
                            ? PlayxLocalization.localizationDelegates
                            : [
                                ...PlayxLocalization.localizationDelegates,
                                ...appSettings.localizationsDelegates!,
                              ],
                    locale: locale.locale,
                    debugShowMaterialGrid: appSettings.debugShowMaterialGrid,
                    showPerformanceOverlay: appSettings.showPerformanceOverlay,
                    checkerboardRasterCacheImages:
                        appSettings.checkerboardRasterCacheImages,
                    checkerboardOffscreenLayers:
                        appSettings.checkerboardOffscreenLayers,
                    showSemanticsDebugger: appSettings.showSemanticsDebugger,
                    shortcuts: appSettings.shortcuts,
                    scrollBehavior: appSettings.scrollBehavior,
                    highContrastTheme: themeSettings.highContrastTheme,
                    highContrastDarkTheme: themeSettings.highContrastDarkTheme,
                    actions: appSettings.actions,
                  );

            return navigationSettings.goRouter != null
                ? PlayxNavigationBuilder(
                    builder: (ctx) => materialApp,
                    router: navigationSettings.goRouter!)
                : materialApp;
          });
        },
      );
    });
  }
}
