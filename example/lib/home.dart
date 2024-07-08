import 'package:flutter/material.dart';
import 'package:playx/playx.dart';
import 'package:playx_example/colors/base_colors.dart';
import 'package:playx_example/model/weather.dart';
import 'package:playx_example/translation/app_trans.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final PlayxNetworkClient apiClient = Get.find<PlayxNetworkClient>();

  //Message for displaying current weather temperature from api.
  String _weatherMsg = '';
  String _envText = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    getWeatherFromApi();
    getTextFromEnv();
    Get.find<ConnectionStatusController>().listenToConnectionStatus();
  }

  @override
  Widget build(BuildContext context) {
    return PlayxThemeSwitchingArea(
      child: PlatformScaffold(
        appBar: PlatformAppBar(
          title: Text(AppTrans.title.tr(context: context)),
        ),
        body: OptimizedScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                width: context.width * .5,
                color: context.colors.onSurface,
                padding: const EdgeInsets.all(8),
                child: Text(
                  PlayxTheme.name,
                  style: TextStyle(color: context.colors.surface),
                ),
              ),
              const AppVersion(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  AppTrans.weatherTitle.tr(context: context),
                ),
              ),
              if (_isLoading)
                const CenterLoading()
              else
                Text(
                  _weatherMsg,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              Text(
                _envText,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 26.sp, fontWeight: FontWeight.w400),
              ),
              GetX(
                builder: (ConnectionStatusController controller) {
                  return Text(
                    controller.isConnectedToInternet
                        ? 'Connected to Internet'
                        : 'Not Connected to Internet',
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 26.sp, fontWeight: FontWeight.w400),
                  );
                },
              ),
              ImageViewer.network(
                'https://avatars.githubusercontent.com/u/35397170?s=200&v=4',
                height: 100.w,
              ),
              ElevatedButton(
                child: Text(AppTrans.changeLanguageTitle.tr(context: context)),
                onPressed: () {
                  Get.dialog(
                    Center(
                      child: Card(
                        margin: const EdgeInsets.all(8),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              context.tr(AppTrans.changeLanguageTitle),
                              style: const TextStyle(fontSize: 20),
                            ),
                            ...PlayxLocalization.supportedXLocales
                                .map((e) => ListTile(
                                      onTap: () {
                                        PlayxLocalization.updateById(e.id);
                                        Get.back();
                                      },
                                      title: Text(e.name),
                                      trailing:
                                          PlayxLocalization.currentXLocale.id ==
                                                  e.id
                                              ? const Icon(
                                                  Icons.done,
                                                  color: Colors.lightBlue,
                                                )
                                              : const SizedBox.shrink(),
                                    )),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              SizedBox(
                height: 25.h,
              )
            ],
          ),
        ),
        material: (ctx, _) => MaterialScaffoldData(
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              showDialog<void>(
                context: context,
                barrierDismissible: true,
                // false = user must tap button, true = tap outside dialog
                builder: (BuildContext dialogContext) {
                  return AlertDialog(
                    title: const Text('title'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(
                          PlayxTheme.supportedThemes.length,
                          (index) => Card(
                                margin: const EdgeInsets.all(8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  side: BorderSide(
                                    color: PlayxTheme.id ==
                                            PlayxTheme.supportedThemes[index].id
                                        ? context.colors.primary
                                        : Colors.transparent,
                                  ),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(32),
                                  title: Text(
                                      PlayxTheme.supportedThemes[index].name),
                                  trailing: PlayxTheme.id ==
                                          PlayxTheme.supportedThemes[index].id
                                      ? const Icon(Icons.check)
                                      : null,
                                  onTap: () async {
                                    // PlayxTheme.updateByIndex(
                                    //   index,
                                    // );
                                    Navigator.of(dialogContext)
                                        .pop(); // Dismiss alert dialog

                                    PlayxTheme.updateById(
                                        PlayxTheme.supportedThemes[index].id);
                                  },
                                ),
                              )),
                    ),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('close'),
                        onPressed: () {
                          Navigator.of(dialogContext)
                              .pop(); // Dismiss alert dialog
                        },
                      ),
                    ],
                  );
                },
              );
            },
            label: Text(AppTrans.changeTheme.tr(context: context)),
            icon: const Icon(Icons.style),
          ),
        ),
      ),
    );
  }

  ///Perform GET Request to get [Weather] model from the API and return it's result.
  Future<void> getWeatherFromApi() async {
    setState(() {
      _isLoading = true;
    });

    final result = await apiClient.get('forecast',
        //your custom queries.
        query: {
          'latitude': '30.04',
          'longitude': '31.23',
          'current_weather': 'true',
        },
        //Function to convert response from json to weather model.
        fromJson: Weather.fromJson);

    result.when(
        //The request was performed successfully and returned the weather model.
        success: (weather) {
      setState(() {
        _weatherMsg = "${weather.currentWeather?.temperature ?? 0} C";
        _isLoading = false;
      });
    },
        //There was an error while performing the request and returned an instance of NetworkException.
        error: (error) {
      //handle error here
      _weatherMsg = "Error is : ${error.message}";
      _isLoading = false;
    });
  }

  //Shows how to get keys from environment variables.
  Future<void> getTextFromEnv() async {
    final apiKey = await PlayxEnv.getString('api_key');
    final isAvailable = await PlayxEnv.maybeGetBool('is_available');
    setState(() {
      _envText = 'Env Text:\n$apiKey\n\nAvailable: $isAvailable';
    });
  }

  @override
  void dispose() {
    Get.find<ConnectionStatusController>().stopListeningToConnectionStatus();
    super.dispose();
  }
}
