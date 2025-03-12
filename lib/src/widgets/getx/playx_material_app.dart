import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:playx/src/models/playx_app_settings.dart';
import 'package:playx/src/models/playx_screen_settings.dart';
import 'package:playx/src/models/playx_theme_settings.dart';
import 'package:playx_localization/playx_localization.dart';
import 'package:playx_theme/playx_theme.dart';
import 'package:playx_widget/playx_widget.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../models/playx_get_navigation_settings.dart';



/// [PlayxGetMaterialApp] is a widget that integrates [GetMaterialApp] with [PlayXThemeBuilder] and [ScreenUtilInit].
///
/// This widget allows for configuration of theme settings, screen settings, and navigation settings. It also
/// provides options to include a Sentry navigator observer for error tracking and customization of app behavior
/// such as orientation, localization, and theming.
///
/// **Note:** This class might be removed in the future as part of ongoing refactoring and improvements. Users
/// should be aware of this potential change and be prepared to migrate to alternative solutions if necessary.
class PlayxGetMaterialApp extends StatelessWidget {
  // Orientation settings for the Material app.
  /// Sets the preferred orientations for the Material app.
  final List<DeviceOrientation> preferredOrientations;

  // Screen utility settings for initializing [ScreenUtil].
  /// Configuration for screen utility settings, including design size, text adaptation, and responsive widgets.
  final PlayxScreenSettings screenSettings;

  // Theme settings for the app.
  /// Settings related to app themes, including light and dark themes, and theme modes.
  final PlayxThemeSettings themeSettings;

  // Navigation settings for the app.
  /// Configuration for navigation, including route settings, custom transitions, and router delegates.
  final PlayxGetNavigationSettings navigationSettings;

  // General app settings.
  /// General settings for app behavior, including logging, performance overlays, and shortcuts.
  final PlayxAppSettings appSettings;

  // GetMaterialApp parameters.
  final GlobalKey<ScaffoldMessengerState>? scaffoldMessengerKey;
  final String title;
  final GenerateAppTitle? onGenerateTitle;
  final Color? color;
  final TextDirection? textDirection;
  final VoidCallback? onInit;
  final VoidCallback? onReady;
  final VoidCallback? onDispose;
  final LogWriterCallback? logWriterCallback;
  final bool? popGesture;

  const PlayxGetMaterialApp({
    super.key,
    this.preferredOrientations = const [
      DeviceOrientation.portraitUp,
    ],
    this.screenSettings = const PlayxScreenSettings(),
    this.themeSettings = const PlayxThemeSettings(),
    this.navigationSettings = const PlayxGetNavigationSettings(),
    this.appSettings = const PlayxAppSettings(),
    this.scaffoldMessengerKey,
    this.textDirection,
    this.title = '',
    this.onGenerateTitle,
    this.color,
    this.onInit,
    this.onReady,
    this.onDispose,
    this.logWriterCallback,
    this.popGesture,
  });

  @override
  Widget build(BuildContext context) {
    return PlayxThemeBuilder(builder: (ctx, xTheme) {
      // Trigger the theme change callback if provided.
      themeSettings.onThemeChanged?.call(xTheme);

      // Set the preferred orientations for the app.
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
              // Return a GetMaterialApp with router capabilities or standard GetMaterialApp based on settings.
              return navigationSettings.useRouter
                  ? GetMaterialApp.router(
                      theme: themeSettings.theme ??
                          xTheme.themeBuilder?.call(locale.locale) ??
                          xTheme.themeData,
                      debugShowCheckedModeBanner:
                          appSettings.debugShowCheckedModeBanner,
                      routeInformationProvider:
                          navigationSettings.routeInformationProvider,
                      routerDelegate: navigationSettings.routerDelegate,
                      routeInformationParser:
                          navigationSettings.routeInformationParser,
                      backButtonDispatcher:
                          navigationSettings.backButtonDispatcher,
                      navigatorObservers:
                          navigationSettings.navigatorObservers ??
                              [
                                if (navigationSettings
                                    .includeSentryNavigationObserver)
                                  SentryNavigatorObserver(),
                              ],
                      scaffoldMessengerKey: scaffoldMessengerKey,
                      builder: navigationSettings.builder,
                      textDirection: textDirection,
                      title: title,
                      onGenerateTitle: onGenerateTitle,
                      color: color,
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
                      customTransition: navigationSettings.customTransition,
                      onInit: onInit,
                      onReady: onReady,
                      onDispose: onDispose,
                      routingCallback: navigationSettings.routingCallback,
                      defaultTransition: navigationSettings.defaultTransition,
                      getPages: navigationSettings.getPages,
                      opaqueRoute: navigationSettings.opaqueRoute,
                      enableLog: appSettings.enableLog,
                      logWriterCallback: logWriterCallback,
                      popGesture: popGesture,
                      transitionDuration: navigationSettings.transitionDuration,
                      defaultGlobalState: navigationSettings.defaultGlobalState,
                      smartManagement: navigationSettings.smartManagement,
                      initialBinding: navigationSettings.initialBinding,
                      unknownRoute: navigationSettings.unknownRoute,
                      highContrastTheme: themeSettings.highContrastTheme,
                      highContrastDarkTheme:
                          themeSettings.highContrastDarkTheme,
                      actions: appSettings.actions,
                    )
                  : GetMaterialApp(
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
                      scaffoldMessengerKey: scaffoldMessengerKey,
                      home: navigationSettings.home,
                      routes: navigationSettings.routes ?? {},
                      initialRoute: navigationSettings.initialRoute,
                      onGenerateRoute: navigationSettings.onGenerateRoute,
                      onGenerateInitialRoutes:
                          navigationSettings.onGenerateInitialRoutes,
                      onUnknownRoute: navigationSettings.onUnknownRoute,
                      builder: navigationSettings.builder,
                      textDirection: textDirection,
                      title: title,
                      onGenerateTitle: onGenerateTitle,
                      color: color,
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
                      customTransition: navigationSettings.customTransition,
                      onInit: onInit,
                      onReady: onReady,
                      onDispose: onDispose,
                      routingCallback: navigationSettings.routingCallback,
                      defaultTransition: navigationSettings.defaultTransition,
                      getPages: navigationSettings.getPages,
                      opaqueRoute: navigationSettings.opaqueRoute,
                      enableLog: appSettings.enableLog,
                      logWriterCallback: logWriterCallback,
                      popGesture: popGesture,
                      transitionDuration: navigationSettings.transitionDuration,
                      defaultGlobalState: navigationSettings.defaultGlobalState,
                      smartManagement: navigationSettings.smartManagement,
                      initialBinding: navigationSettings.initialBinding,
                      unknownRoute: navigationSettings.unknownRoute,
                      highContrastTheme: themeSettings.highContrastTheme,
                      highContrastDarkTheme:
                          themeSettings.highContrastDarkTheme,
                      actions: appSettings.actions,
                    );
            });
          });
    });
  }
}
