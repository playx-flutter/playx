# Playx

helps with redundant features , less code , more productivity with better organization

## Features

| name                | short description                                                                  |
| ------------------- | ---------------------------------------------------------------------------------- |
| `Prefs` facade      | Key value pair storage powered by `SharedPreferences`                              |
| `runPlayX` function | wraps`runApp` to inject , init ..etc what ever is necessary for using this package |
| exports             | packages like `get` , `queen_validators`, `readable`                               |

## Getting started

### installation

in `pubspec.yaml` add these lines to `dependencies`

```yaml
playx:
  git:
    url: https://github.com/playx-flutter/playx.git
```

### usage

in `main` method call `runPlayX` instead of `runApp`
