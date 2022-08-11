# Playx

helps with redundant features , less code , more productivity , better organizing ,

## Features

| name                      | short description                                                                  |
| ------------------------- | ---------------------------------------------------------------------------------- |
| `Prefs` facade            | Key value pair storage powered by `SharedPreferences`                              |
| `PlayX.runPlayX` function | wraps`runApp` to inject , init ..etc what ever is necessary for using this package |
| exports                   | packages like `get` , `queen_validators`, `readable` ,`playx_theme`                |

## Getting started

### installation

in `pubspec.yaml` add these lines to `dependencies`

```yaml
playx: ^0.0.1
```

### usage

in `main` method call `PlayX.runPlayX` instead of `runApp`
