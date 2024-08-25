import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:playx/playx.dart';

/// A widget that represents [GetMaterialApp] for android or material platforms and [GetCupertinoApp] for iOS devices or cupertino platforms.
class GetPlatformApp
    extends PlatformWidgetBase<GetCupertinoApp, GetMaterialApp> {
  final GlobalKey<NavigatorState>? navigatorKey;
  final GlobalKey<ScaffoldMessengerState>? scaffoldMessengerKey;
  final Widget? home;
  final Map<String, WidgetBuilder>? routes;
  final String? initialRoute;
  final RouteFactory? onGenerateRoute;
  final InitialRouteListFactory? onGenerateInitialRoutes;
  final RouteFactory? onUnknownRoute;
  final List<NavigatorObserver>? navigatorObservers;
  final TransitionBuilder? builder;
  final String title;
  final GenerateAppTitle? onGenerateTitle;
  final ThemeData? theme;
  final ThemeData? darkTheme;
  final ThemeMode themeMode;
  final CustomTransition? customTransition;
  final Color? color;
  final Map<String, Map<String, String>>? translationsKeys;
  final TextDirection? textDirection;
  final Locale? locale;
  final Locale? fallbackLocale;
  final Iterable<LocalizationsDelegate<dynamic>>? localizationsDelegates;
  final LocaleListResolutionCallback? localeListResolutionCallback;
  final LocaleResolutionCallback? localeResolutionCallback;
  final Iterable<Locale> supportedLocales;
  final bool showPerformanceOverlay;
  final bool checkerboardRasterCacheImages;
  final bool checkerboardOffscreenLayers;
  final bool showSemanticsDebugger;
  final bool debugShowCheckedModeBanner;
  final Map<LogicalKeySet, Intent>? shortcuts;
  final ScrollBehavior? scrollBehavior;
  final ThemeData? highContrastTheme;
  final ThemeData? highContrastDarkTheme;
  final Map<Type, Action<Intent>>? actions;
  final bool debugShowMaterialGrid;
  final ValueChanged<Routing?>? routingCallback;
  final Transition? defaultTransition;
  final bool? opaqueRoute;
  final VoidCallback? onInit;
  final VoidCallback? onReady;
  final VoidCallback? onDispose;
  final bool? enableLog;
  final LogWriterCallback? logWriterCallback;
  final bool? popGesture;
  final SmartManagement smartManagement;
  final Bindings? initialBinding;
  final Duration? transitionDuration;
  final bool? defaultGlobalState;
  final List<GetPage>? getPages;
  final GetPage? unknownRoute;
  final RouteInformationProvider? routeInformationProvider;
  final RouteInformationParser<Object>? routeInformationParser;
  final RouterDelegate<Object>? routerDelegate;
  final BackButtonDispatcher? backButtonDispatcher;
  final bool useInheritedMediaQuery;
  final CupertinoThemeData? cupertinoTheme;
  final bool _useRouter;

  @override
  GetCupertinoApp createCupertinoWidget(BuildContext context) {
    return _useRouter
        ? GetCupertinoApp.router(
            theme: cupertinoTheme,
            routeInformationProvider: routeInformationProvider,
            routeInformationParser: routeInformationParser,
            routerDelegate: routerDelegate,
            backButtonDispatcher: backButtonDispatcher,
            debugShowCheckedModeBanner: debugShowCheckedModeBanner,
            builder: builder,
            textDirection: textDirection,
            title: title,
            onGenerateTitle: onGenerateTitle,
            color: color,
            supportedLocales: PlayxLocalization.supportedLocales,
            localizationsDelegates: PlayxLocalization.localizationDelegates,
            locale: PlayxLocalization.currentLocale,
            showPerformanceOverlay: showPerformanceOverlay,
            checkerboardRasterCacheImages: checkerboardRasterCacheImages,
            checkerboardOffscreenLayers: checkerboardOffscreenLayers,
            showSemanticsDebugger: showSemanticsDebugger,
            shortcuts: shortcuts,
            customTransition: customTransition,
            translationsKeys: translationsKeys,
            onInit: onInit,
            onReady: onReady,
            onDispose: onDispose,
            routingCallback: routingCallback,
            defaultTransition: defaultTransition,
            getPages: getPages,
            opaqueRoute: opaqueRoute,
            enableLog: enableLog,
            logWriterCallback: logWriterCallback,
            popGesture: popGesture,
            transitionDuration: transitionDuration,
            defaultGlobalState: defaultGlobalState,
            smartManagement: smartManagement,
            initialBinding: initialBinding,
            unknownRoute: unknownRoute,
            highContrastTheme: highContrastTheme,
            highContrastDarkTheme: highContrastDarkTheme,
            actions: actions,
          )
        : GetCupertinoApp(
            theme: cupertinoTheme,
            debugShowCheckedModeBanner: debugShowCheckedModeBanner,
            navigatorObservers:
                navigatorObservers ?? const <NavigatorObserver>[],
            navigatorKey: navigatorKey,
            home: home,
            routes: routes ?? const <String, WidgetBuilder>{},
            initialRoute: initialRoute,
            onGenerateRoute: onGenerateRoute,
            onGenerateInitialRoutes: onGenerateInitialRoutes,
            onUnknownRoute: onUnknownRoute,
            builder: builder,
            textDirection: textDirection,
            title: title,
            onGenerateTitle: onGenerateTitle,
            color: color,
            supportedLocales: PlayxLocalization.supportedLocales,
            localizationsDelegates: PlayxLocalization.localizationDelegates,
            locale: PlayxLocalization.currentLocale,
            showPerformanceOverlay: showPerformanceOverlay,
            checkerboardRasterCacheImages: checkerboardRasterCacheImages,
            checkerboardOffscreenLayers: checkerboardOffscreenLayers,
            showSemanticsDebugger: showSemanticsDebugger,
            shortcuts: shortcuts,
            customTransition: customTransition,
            translationsKeys: translationsKeys,
            onInit: onInit,
            onReady: onReady,
            onDispose: onDispose,
            routingCallback: routingCallback,
            defaultTransition: defaultTransition,
            getPages: getPages,
            opaqueRoute: opaqueRoute,
            enableLog: enableLog,
            logWriterCallback: logWriterCallback,
            popGesture: popGesture,
            transitionDuration: transitionDuration,
            defaultGlobalState: defaultGlobalState,
            smartManagement: smartManagement,
            initialBinding: initialBinding,
            unknownRoute: unknownRoute,
            highContrastTheme: highContrastTheme,
            highContrastDarkTheme: highContrastDarkTheme,
            actions: actions,
          );
  }

  @override
  GetMaterialApp createMaterialWidget(BuildContext context) {
    return _useRouter
        ? GetMaterialApp.router(
            theme: theme,
            debugShowCheckedModeBanner: debugShowCheckedModeBanner,
            navigatorObservers: navigatorObservers,
            scaffoldMessengerKey: scaffoldMessengerKey,
            builder: builder,
            textDirection: textDirection,
            title: title,
            onGenerateTitle: onGenerateTitle,
            color: color,
            darkTheme: darkTheme,
            themeMode: themeMode,
            supportedLocales: PlayxLocalization.supportedLocales,
            localizationsDelegates: PlayxLocalization.localizationDelegates,
            locale: PlayxLocalization.currentLocale,
            debugShowMaterialGrid: debugShowMaterialGrid,
            showPerformanceOverlay: showPerformanceOverlay,
            checkerboardRasterCacheImages: checkerboardRasterCacheImages,
            checkerboardOffscreenLayers: checkerboardOffscreenLayers,
            showSemanticsDebugger: showSemanticsDebugger,
            shortcuts: shortcuts,
            scrollBehavior: scrollBehavior,
            customTransition: customTransition,
            translationsKeys: translationsKeys,
            onInit: onInit,
            onReady: onReady,
            onDispose: onDispose,
            routingCallback: routingCallback,
            defaultTransition: defaultTransition,
            getPages: getPages,
            opaqueRoute: opaqueRoute,
            enableLog: enableLog,
            logWriterCallback: logWriterCallback,
            popGesture: popGesture,
            transitionDuration: transitionDuration,
            defaultGlobalState: defaultGlobalState,
            smartManagement: smartManagement,
            initialBinding: initialBinding,
            unknownRoute: unknownRoute,
            highContrastTheme: highContrastTheme,
            highContrastDarkTheme: highContrastDarkTheme,
            actions: actions,
            routeInformationProvider: routeInformationProvider,
            routeInformationParser: routeInformationParser,
            routerDelegate: routerDelegate,
            backButtonDispatcher: backButtonDispatcher,
          )
        : GetMaterialApp(
            theme: theme,
            debugShowCheckedModeBanner: debugShowCheckedModeBanner,
            navigatorObservers:
                navigatorObservers ?? const <NavigatorObserver>[],
            navigatorKey: navigatorKey,
            scaffoldMessengerKey: scaffoldMessengerKey,
            home: home,
            routes: routes ?? const <String, WidgetBuilder>{},
            initialRoute: initialRoute,
            onGenerateRoute: onGenerateRoute,
            onGenerateInitialRoutes: onGenerateInitialRoutes,
            onUnknownRoute: onUnknownRoute,
            builder: builder,
            textDirection: textDirection,
            title: title,
            onGenerateTitle: onGenerateTitle,
            color: color,
            darkTheme: darkTheme,
            themeMode: themeMode,
            supportedLocales: PlayxLocalization.supportedLocales,
            localizationsDelegates: PlayxLocalization.localizationDelegates,
            locale: PlayxLocalization.currentLocale,
            debugShowMaterialGrid: debugShowMaterialGrid,
            showPerformanceOverlay: showPerformanceOverlay,
            checkerboardRasterCacheImages: checkerboardRasterCacheImages,
            checkerboardOffscreenLayers: checkerboardOffscreenLayers,
            showSemanticsDebugger: showSemanticsDebugger,
            shortcuts: shortcuts,
            scrollBehavior: scrollBehavior,
            customTransition: customTransition,
            translationsKeys: translationsKeys,
            onInit: onInit,
            onReady: onReady,
            onDispose: onDispose,
            routingCallback: routingCallback,
            defaultTransition: defaultTransition,
            getPages: getPages,
            opaqueRoute: opaqueRoute,
            enableLog: enableLog,
            logWriterCallback: logWriterCallback,
            popGesture: popGesture,
            transitionDuration: transitionDuration,
            defaultGlobalState: defaultGlobalState,
            smartManagement: smartManagement,
            initialBinding: initialBinding,
            unknownRoute: unknownRoute,
            highContrastTheme: highContrastTheme,
            highContrastDarkTheme: highContrastDarkTheme,
            actions: actions,
          );
  }

  const GetPlatformApp({
    super.key,
    this.navigatorKey,
    this.scaffoldMessengerKey,
    this.home,
    this.initialRoute,
    this.onGenerateRoute,
    this.onGenerateInitialRoutes,
    this.onUnknownRoute,
    this.routes,
    this.useInheritedMediaQuery = false,
    this.navigatorObservers,
    this.builder,
    this.title = '',
    this.onGenerateTitle,
    this.theme,
    this.darkTheme,
    this.themeMode = ThemeMode.system,
    this.customTransition,
    this.color,
    this.translationsKeys,
    this.textDirection,
    this.locale,
    this.fallbackLocale,
    this.localizationsDelegates,
    this.localeListResolutionCallback,
    this.localeResolutionCallback,
    this.supportedLocales = const <Locale>[Locale('en', 'US')],
    this.debugShowMaterialGrid = false,
    this.showPerformanceOverlay = false,
    this.checkerboardRasterCacheImages = false,
    this.checkerboardOffscreenLayers = false,
    this.showSemanticsDebugger = false,
    this.debugShowCheckedModeBanner = true,
    this.shortcuts,
    this.scrollBehavior,
    this.highContrastTheme,
    this.highContrastDarkTheme,
    this.actions,
    this.routingCallback,
    this.defaultTransition,
    this.opaqueRoute,
    this.onInit,
    this.onReady,
    this.onDispose,
    this.enableLog = kDebugMode,
    this.logWriterCallback,
    this.popGesture,
    this.smartManagement = SmartManagement.full,
    this.initialBinding,
    this.transitionDuration,
    this.defaultGlobalState,
    this.getPages,
    this.unknownRoute,
    this.cupertinoTheme,
  })  : _useRouter = false,
        routeInformationProvider = null,
        routeInformationParser = null,
        routerDelegate = null,
        backButtonDispatcher = null;

  const GetPlatformApp.router({
    super.key,
    this.scaffoldMessengerKey,
    this.useInheritedMediaQuery = false,
    this.builder,
    this.title = '',
    this.onGenerateTitle,
    this.theme,
    this.darkTheme,
    this.themeMode = ThemeMode.system,
    this.customTransition,
    this.color,
    this.translationsKeys,
    this.textDirection,
    this.locale,
    this.fallbackLocale,
    this.localizationsDelegates,
    this.localeListResolutionCallback,
    this.localeResolutionCallback,
    this.supportedLocales = const <Locale>[Locale('en', 'US')],
    this.debugShowMaterialGrid = false,
    this.showPerformanceOverlay = false,
    this.checkerboardRasterCacheImages = false,
    this.checkerboardOffscreenLayers = false,
    this.showSemanticsDebugger = false,
    this.debugShowCheckedModeBanner = true,
    this.shortcuts,
    this.scrollBehavior,
    this.highContrastTheme,
    this.highContrastDarkTheme,
    this.actions,
    this.routingCallback,
    this.defaultTransition,
    this.opaqueRoute,
    this.onInit,
    this.onReady,
    this.onDispose,
    this.enableLog = kDebugMode,
    this.logWriterCallback,
    this.popGesture,
    this.smartManagement = SmartManagement.full,
    this.initialBinding,
    this.transitionDuration,
    this.defaultGlobalState,
    this.getPages,
    this.routeInformationProvider,
    this.routeInformationParser,
    this.routerDelegate,
    this.backButtonDispatcher,
    this.cupertinoTheme,
  })  : _useRouter = true,
        navigatorKey = null,
        onGenerateRoute = null,
        home = null,
        onGenerateInitialRoutes = null,
        onUnknownRoute = null,
        routes = null,
        initialRoute = null,
        navigatorObservers = null,
        unknownRoute = null;
}
