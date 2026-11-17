# Breadcrumbs and page titles

Breadcrumbs are derived from navigation. Give routes a label, place a `PlayxBreadcrumbs` widget,
and every page gets a correct, tappable trail, also after a web refresh or deep link.

```dart
PlayxShellBranch(
  path: '/jobs',
  breadcrumb: (context, state) => context.l10n.jobs,     // localized labels work
  builder: (context, state) => const JobsView(),
  routes: [
    PlayxRoute(
      path: ':id',
      breadcrumb: (context, state) => 'Job #${state.pathParameters['id']}',
      builder: (context, state) => const JobDetailsView(),
      routes: [
        PlayxRoute(
          path: 'edit',
          breadcrumb: (context, state) => context.l10n.edit,
          builder: (context, state) => const EditJobView(),
        ),
      ],
    ),
  ],
)

// In the shell layout or any page (rebuilds on every navigation):
const PlayxBreadcrumbs(mode: PlayxBreadcrumbMode.shellBranch)   // Jobs > Job #5 > Edit
```

## Modes

| Mode | Trail | Tapping a crumb |
|---|---|---|
| `hierarchy` (default) | The current page and its parents, using the same parent rule as `back()`: `parentLocation`, otherwise the nearest shorter matching path. `rootLocation: '/home'` prepends a root: `Home > Jobs > Job #5 > Edit`. | Goes to it. |
| `shellBranch` | Like `hierarchy`, but starting at the current shell branch's root: `Jobs > Job #5 > Edit`. Outside a shell it is the same as `hierarchy`. | Goes to it. |
| `history` | The pages actually in the stack, bottom to top. Depends on how the user navigated and resets on refresh. | Pops back to it. |

- Pages without a label are left out, but the trail still continues to their parents.
- The last item is the current page and is not tappable.
- `rootLocation` is only used by `hierarchy`, and is not duplicated if already part of the trail.

## Labels

A crumb's label comes from the first of these that provides one:

1. **A runtime label** set by a live page, for loaded data:
   ```dart
   Obx(() => PlayxBreadcrumbLabel(label: controller.job.value?.title))
   // or from a binding callback / any widget in the page:
   PlayxNavigation.setBreadcrumbLabel(context, job.title);
   ```
   The label stays while the page is in the stack, so a child page shows
   `Jobs > Plumbing repair > Edit`. It is removed when the page goes away. A `null` label falls back
   to the route's label. It also works inside plain `GoRoute` pages.
2. **The route's** `breadcrumb: (context, state) => ...`.
3. **The binding's** `breadcrumb` override, which keeps route definitions short:
   ```dart
   class JobDetailsBinding extends PlayxBinding {
     @override
     String? breadcrumb(BuildContext context, GoRouterState state) =>
         'Job #${state.pathParameters['id']}';
   }
   ```

`context` is the context of the widget showing the breadcrumbs, so `context.l10n` works even in a
shell header placed above the pages.

## The widget

```dart
PlayxBreadcrumbs(
  mode: PlayxBreadcrumbMode.hierarchy,
  rootLocation: '/home',
  maxItems: 4,                 // Home > ... > last 3; the "..." opens a menu with the hidden items
  hideIfSingle: true,
  separator: const Icon(Icons.chevron_right, size: 16),
  itemBuilder: (context, item) => CustomText(
    item.label,
    color: item.isCurrent ? context.colors.onSurface : context.colors.subtitleTextColor,
  ),
)
```

| Parameter | Default | Meaning |
|---|---|---|
| `mode`, `rootLocation` | `hierarchy`, none | Which trail. |
| `maxItems` | `4` | More items collapse to first, `...`, last `maxItems - 1`. `null` never collapses. |
| `collapsedMenu` | `true` | Tapping `...` opens a menu with the hidden items. |
| `hideIfSingle` | `false` | Render nothing for a trail of one item or less. |
| `separator`, `spacing` | chevron icon, `8` | Between items. |
| `style`, `currentStyle` | theme `bodyMedium` | Text styles (tappable and current). |
| `itemBuilder` | `Text` | Your own item content. Taps are handled for you. |
| `ellipsisBuilder` | `...` text | Your own collapsed content. |

The widget scrolls horizontally when it doesn't fit, provides its own transparent `Material` (so it
works in a header above the router's `Navigator`), and rebuilds on navigation and label changes.

### Keep your own widget

`PlayxBreadcrumbsBuilder` gives you the items and rebuilds when they change:

```dart
PlayxBreadcrumbsBuilder(
  mode: PlayxBreadcrumbMode.shellBranch,
  builder: (context, items) => BreadcrumbHeader(
    items: [for (final item in items) BreadcrumbItem(title: item.label, onTap: item.navigate)],
  ),
)
```

Each `PlayxBreadcrumbItem` has `label`, `location`, `state` (path parameters, ...), `isCurrent`, and
`navigate()` (goes to it, or pops back to it in `history` mode; does nothing for the current page).

For one-off reads use `PlayxNavigation.breadcrumbs(context, mode: ...)`, and listen to
`PlayxNavigation.breadcrumbsListenable` to rebuild yourself.

## Browser tab titles

The tab title can follow the current page, reusing the same labels. Pass a `PlayxPageTitle` to
`PlayxNavigationBuilder`:

```dart
PlayxNavigationBuilder(
  router: router,
  pageTitle: const PlayxPageTitle(appName: 'Jobs Dashboard'),
  builder: (context) => MaterialApp.router(
    routerConfig: router,
    // Keeps the page title if MaterialApp rebuilds (see below).
    onGenerateTitle: (context) => PlayxNavigation.pageTitle ?? 'Jobs Dashboard',
  ),
)
// /jobs/5 once the job has loaded: "Plumbing repair · Jobs · Jobs Dashboard"
```

| Parameter | Default | Meaning |
|---|---|---|
| `appName` | none | Appended after the page labels. Used alone when the page has no label. |
| `separator` | `' · '` | Between parts. |
| `maxItems` | `2` | How many labels to include, current page first, then its parents. `null` includes all. |
| `mode`, `rootLocation` | `hierarchy`, none | Which trail the title is built from. |
| `builder` | none | Build the whole title yourself from the trail. Return `null` to leave the title unchanged. |

The title updates after every navigation and whenever a label changes (for example when the job's
name loads). It is applied with `SystemChrome.setApplicationSwitcherDescription`, which sets the
document title on web (and the task label on Android).

!!! warning "MaterialApp resets the title when it rebuilds"
    Flutter's `MaterialApp` sets the tab title to its own `title` each time it rebuilds (theme or
    locale changes, a rebuilt parent). Return `PlayxNavigation.pageTitle` from `onGenerateTitle`, as
    shown above, so a rebuild keeps the current page title.

---

*Imported from the [playx_navigation 3.0.0 documentation](https://github.com/playx-flutter/playx_navigation/blob/main/docs/breadcrumbs.md). [Package site](https://playx-flutter.github.io/playx_navigation/) · [pub.dev](https://pub.dev/packages/playx_navigation).*
