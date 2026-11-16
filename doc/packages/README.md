# The Playx ecosystem

Playx is built from small packages that can be used on their own. The `playx` package boots
them together and re-exports all of them.

```
                         playx
   ┌───────────┬───────────┴────────┬──────────────┬───────────────┐
 playx_core  playx_theme  playx_localization  playx_navigation  playx_network  playx_widget
     ▲            │               │                  │               │
     └────────────┴───────────────┴──────── depend on playx_core ────┘
```

`playx_core` is the base: preferences, secure storage, env and logging used by the theme
and localization packages (to save the user's choice) and by the network package.

## Versions used by Playx 3.0

| Package | 2.x used | 3.0 uses | Change in one line |
| --- | --- | --- | --- |
| [`playx_core`](playx_core.md) | 1.0.0 | **2.0.0** | Sync env, secure env, secure prefs backends, logging settings, new extensions. |
| [`playx_theme`](playx_theme.md) | 2.0.0 | **2.1.0** | Pluggable storage, `toggleMode`, `ThemeExtension` helpers, fixes. |
| [`playx_localization`](playx_localization.md) | 0.4.0 | **1.0.0** | Real plurals, id-based persistence, CLI tools, many fixes. |
| [`playx_navigation`](playx_navigation.md) | 2.1.0 | **3.0.0** | Per-page lifecycle, scopes, controllers, guards, breadcrumbs, web helpers. |
| [`playx_network`](playx_network.md) | 1.0.0 | **2.0.0** | Streaming/SSE, path parameters, richer errors, fixes. |
| [`playx_widget`](playx_widget.md) | 0.5.0 | **0.6.0** | `AppInfoNotifier`, many widget fixes, new image viewer behavior. |

Minimum SDKs: `playx_core`, `playx_theme`, `playx_localization` and `playx_network` require
Dart 3.12 / Flutter 3.44. `playx_widget` requires Dart 3.8 / Flutter 3.44. `playx_navigation`
keeps a lower floor (Dart 3.6 / Flutter 3.27). The highest floor decides what `playx` needs:
**Dart 3.12 / Flutter 3.44**.

## Other dependencies Playx exports

| Package | Version | Why |
| --- | --- | --- |
| `sentry_flutter` | ^10.3.0 | Crash reporting. |
| `connectivity_plus` | ^7.3.2 | Device connectivity for `ConnectionStatusController`. |
| `internet_connection_checker_plus` | ^3.1.2 | Real internet checks. |
| `get` | ^4.7.3 | GetX app widgets. |
| `flutter_animate` | ^4.5.2 | Animations. |
| `queen_validators` | ^1.0.1 | Form validation. |
| `async` | ^2.13.1 | Async utilities. |

## Documentation sites

| Package | Docs |
| --- | --- |
| `playx_core` | [`doc/`](https://github.com/playx-flutter/playx_core/tree/main/doc) in the repository |
| `playx_theme` | [pub.dev](https://pub.dev/packages/playx_theme) |
| `playx_localization` | <https://playx-flutter.github.io/playx_localization/> |
| `playx_navigation` | <https://playx-flutter.github.io/playx_navigation/> |
| `playx_network` | <https://playx-flutter.github.io/playx_network/> |
| `playx_widget` | <https://playx-flutter.github.io/playx_widget/> |
