# Migration guides

Playx 3.0 moves every ecosystem package to a new major version. Start with the Playx guide, then
read the guide of each package you use directly.

| Package | From → to | Guide |
| --- | --- | --- |
| `playx` | 2.x → 3.0 | [Migrating to Playx 3.0](migration-3.0.md) |
| `playx_core` | 1.x → 2.0 | [Migrating to playx_core 2.0](packages/playx_core/migration-2.0.md) |
| `playx_theme` | 2.0 → 2.1 (and 1.x → 2.0) | [Migrating playx_theme](packages/playx_theme/migration.md) |
| `playx_localization` | 0.x → 1.0 | [Migrating to playx_localization 1.0](packages/playx_localization/migration.md) |
| `playx_navigation` | 2.x → 3.0 | [Migrating to playx_navigation 3.0](packages/playx_navigation/migration.md) |
| `playx_network` | 1.x → 2.0 | [Migrating to playx_network 2.0](packages/playx_network/migration.md) |
| `playx_widget` | 0.5 → 0.6 | [Migrating to playx_widget 0.6](packages/playx_widget/migration.md) |

## Suggested order

1. Upgrade Flutter to **3.44 or newer** (Dart 3.12). Every package needs it.
2. Update `playx` to `^3.0.0` and fix the `runPlayx` / `boot` parameters
   ([Playx 3.0 guide](migration-3.0.md)).
3. Fix compile errors, package by package:
   - `playx_core`: synchronous `PlayxEnv` getters, secure prefs settings.
   - `playx_network`: new exception types in `switch` statements.
   - `playx_widget`: weighted Lucide icons, `FavoriteButton`.
4. Review behavior changes that don't fail to compile:
   - `playx_navigation`: page lifecycle timing.
   - `playx_localization`: plural rules (the saved locale migrates automatically).
5. Run `flutter analyze` and your tests.

If you depend on only `playx`, you rarely need to add the individual packages to your
`pubspec.yaml`: everything is re-exported (see [Exports](exports.md)).
