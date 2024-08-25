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

///PlayxMaterialApp : A widget that wraps [MaterialApp] with [PlayXThemeBuilder] to update the app with current theme  and [ScreenUtilInit] that initializes [ScreenUtil]
/// With the ability to set app orientation and more.
class PlayxMaterialApp extends StatelessWidget {
  //orientation
  /// Sets your preferred orientations of the Material app.
  final List<DeviceOrientation> preferredOrientations;

  /// Screen util settings
  final PlayxScreenSettings screenSettings;

  // App theme settings
  final PlayxThemeSettings themeSettings;

  // App navigation settings
  final PlayxNavigationSettings navigationSettings;

  // App settings
  final PlayxAppSettings appSettings;

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
                      routeInformationProvider: navigationSettings
                              .goRouter?.routeInformationProvider ??
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
                          PlayxLocalization.localizationDelegates,
                      locale: locale.locale,
                      debugShowMaterialGrid: appSettings.debugShowMaterialGrid,
                      showPerformanceOverlay:
                          appSettings.showPerformanceOverlay,
                      checkerboardRasterCacheImages:
                          appSettings.checkerboardRasterCacheImages,
                      checkerboardOffscreenLayers:
                          appSettings.checkerboardOffscreenLayers,
                      showSemanticsDebugger: appSettings.showSemanticsDebugger,
                      shortcuts: appSettings.shortcuts,
                      scrollBehavior: appSettings.scrollBehavior,
                      highContrastTheme: themeSettings.highContrastTheme,
                      highContrastDarkTheme:
                          themeSettings.highContrastDarkTheme,
                      actions: appSettings.actions,
                    )
                  : MaterialApp(
                      title: appSettings.title,
                      theme: themeSettings.theme ??
                          xTheme.themeBuilder?.call(locale.locale) ??
                          xTheme.themeData,
                      debugShowCheckedModeBanner:
                          appSettings.debugShowCheckedModeBanner,
                      navigatorObservers:
                          navigationSettings.navigatorObservers ??
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
                          PlayxLocalization.localizationDelegates,
                      locale: locale.locale,
                      debugShowMaterialGrid: appSettings.debugShowMaterialGrid,
                      showPerformanceOverlay:
                          appSettings.showPerformanceOverlay,
                      checkerboardRasterCacheImages:
                          appSettings.checkerboardRasterCacheImages,
                      checkerboardOffscreenLayers:
                          appSettings.checkerboardOffscreenLayers,
                      showSemanticsDebugger: appSettings.showSemanticsDebugger,
                      shortcuts: appSettings.shortcuts,
                      scrollBehavior: appSettings.scrollBehavior,
                      highContrastTheme: themeSettings.highContrastTheme,
                      highContrastDarkTheme:
                          themeSettings.highContrastDarkTheme,
                      actions: appSettings.actions,
                    );

              return navigationSettings.goRouter != null
                  ? PlayxNavigationBuilder(
                      builder: (ctx) => materialApp,
                      router: navigationSettings.goRouter!)
                  : materialApp;
            });
          });
    });
  }
}
