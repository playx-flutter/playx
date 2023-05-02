import 'package:example/config.dart';
import 'package:flutter/material.dart';
import 'package:playx/playx.dart';

void main() async {
  final config = AppConfig();
  Playx.runPlayx(appConfig: config, app: const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PlayXThemeBuilder(
      builder: (xTheme) {
        return MaterialApp(
          title: 'Flutter Demo',
          theme: xTheme.theme,
          home: Scaffold(
            appBar: AppBar(
              title: const Text('Playx Example'),
            ),
            body: OptimizedScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Center(
                    child: Text(AppTheme.xTheme.nameBuilder()),
                  ),
                  const AppVersion(),
                  ImageViewer.network(
                    'https://avatars.githubusercontent.com/u/35397170?s=200&v=4',
                    height: 100,
                  ),
                  CachedNetworkImage(
                    imageUrl:
                        'https://avatars.githubusercontent.com/u/35397170?s=200&v=4',
                    height: 100,
                  )
                ],
              ),
            ),
            floatingActionButton: const FloatingActionButton(
              onPressed: AppTheme.next,
              tooltip: 'Increment',
              child: Icon(Icons.add),
            ),
          ),
        );
      },
    );
  }
}
