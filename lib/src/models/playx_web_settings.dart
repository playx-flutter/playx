
/// Settings for Web apps.
class PlayxWebSettings {
  /// Whether to use the path URL strategy for web.
  final bool usePathUrlStrategy;
  /// Whether the URL reflects imperative APIs of GoRouter.
  final bool optionURLReflectsImperativeAPIs;

  const PlayxWebSettings({
     this.usePathUrlStrategy =true,
     this.optionURLReflectsImperativeAPIs = true,
  });
}
