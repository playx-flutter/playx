import 'package:flutter/material.dart';
import 'package:playx/playx.dart';
import 'package:playx_example/colors/base_color_scheme.dart';
import 'package:playx_example/model/weather.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final PlayxNetworkClient apiClient = Get.find<PlayxNetworkClient>();
  //Message for displaying current weather temperature from api.
  String _weatherMsg = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    getWeatherFromApi();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Playx Example'),
        ),
        body: OptimizedScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                width: context.width * .5,
                color: colorScheme.onBackground,
                padding: const EdgeInsets.all(8),
                child: Text(
                  AppTheme.name,
                  style: TextStyle(color: colorScheme.background),
                ),
              ),
              const AppVersion(),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  'Current Weather is :',
                ),
              ),
             if( _isLoading) const CenterLoading() else Text(
                _weatherMsg,
                style: Theme.of(context).textTheme.headlineMedium,
              ),

              ImageViewer.network(
                'https://avatars.githubusercontent.com/u/35397170?s=200&v=4',
                height: 100.w,
              ),
              CachedNetworkImage(
                imageUrl:
                'https://avatars.githubusercontent.com/u/35397170?s=200&v=4',
                height: 100.h,
              ),
              OptimizedButton.elevated(child: const Text('Refresh Weather'), onPressed: (){
                getWeatherFromApi();
              })

            ],
          ),
        ),
        floatingActionButton: const FloatingActionButton(
          onPressed: AppTheme.next,
          tooltip: 'Increment',
          child: Icon(Icons.style),
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

}
