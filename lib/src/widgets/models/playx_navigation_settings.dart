import 'package:flutter/material.dart';
import 'package:playx_navigation/playx_navigation.dart';

///Default navigation settings
class PlayxNavigationSettings {
  final GlobalKey<NavigatorState>? navigatorKey;
  final Map<String, WidgetBuilder>? routes;
  final String? initialRoute;
  final RouteFactory? onGenerateRoute;
  final InitialRouteListFactory? onGenerateInitialRoutes;
  final RouteFactory? onUnknownRoute;

  /// The navigator observers to use for the navigator.
  /// Works only with Navigator1.
  /// To add observers to Navigator2 Router, use the RouterDelegate.
  final List<NavigatorObserver>? navigatorObservers;
  final TransitionBuilder? builder;
  final Widget? home;

  final RouteInformationProvider? routeInformationProvider;
  final RouteInformationParser<Object>? routeInformationParser;
  final RouterDelegate<Object>? routerDelegate;
  final BackButtonDispatcher? backButtonDispatcher;

  /// The GoRouter instance to use for the navigation.
  final GoRouter? goRouter;

  /// Whether should include sentry navigator observer or not.
  /// Works only with Navigator. To add the sentry observer to Navigator2 Router, use the RouterDelegate.
  final bool includeSentryNavigationObserver;

  final bool useRouter;

  const PlayxNavigationSettings({
    this.home,
    this.navigatorKey,
    this.routes = const <String, WidgetBuilder>{},
    this.initialRoute,
    this.onGenerateRoute,
    this.onGenerateInitialRoutes,
    this.onUnknownRoute,
    this.navigatorObservers = const <NavigatorObserver>[],
    this.builder,
    this.includeSentryNavigationObserver = false,
  })  : useRouter = false,
        routeInformationProvider = null,
        routeInformationParser = null,
        routerDelegate = null,
        goRouter = null,
        backButtonDispatcher = null;

  ///Creates a navigation settings that uses the Router instead of a Navigator.
  const PlayxNavigationSettings.router({
    this.routeInformationProvider,
    this.routeInformationParser,
    this.routerDelegate,
    this.backButtonDispatcher,
    this.navigatorKey,
    this.builder,
  })  : useRouter = true,
        routes = null,
        initialRoute = null,
        onGenerateRoute = null,
        onGenerateInitialRoutes = null,
        onUnknownRoute = null,
        goRouter = null,
        home = null,
        includeSentryNavigationObserver = false,
        navigatorObservers = null;

  /// Creates a navigation settings that uses the GoRouter instead of a Navigator.
  const PlayxNavigationSettings.goRouter({
    required GoRouter this.goRouter,
    this.navigatorKey,
    this.builder,
  })  : useRouter = true,
        routes = null,
        initialRoute = null,
        onGenerateRoute = null,
        onGenerateInitialRoutes = null,
        onUnknownRoute = null,
        routeInformationProvider = null,
        routeInformationParser = null,
        routerDelegate = null,
        backButtonDispatcher = null,
        navigatorObservers = null,
        includeSentryNavigationObserver = false,
        home = null;
}
