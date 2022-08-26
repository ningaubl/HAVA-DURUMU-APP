import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:untitled/widgets/loading_widget.dart';
import 'search_page.dart';
import 'package:http/http.dart' as http;
import 'daily_weather_card.dart';
import 'package:flutter/cupertino.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String location = '';
  double? temperature;
  final String key = 'de55da5e46ce11f683d64c5a838aab8a';
  var locationData;
  String code = 'home';
  String? icon;
  Position? devicePosition;

  // lat=41.015137&lon=28.979530

  List<String> icons = [];
  List<double> temperatures = [];
  List<String> dates = [];

  Future<void> getLocationData() async {
    locationData = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?q=$location&appid=$key&units=metric'));
    final locationDataParsed = jsonDecode(locationData.body);

    setState(() {
      temperature = locationDataParsed['main']['temp'];
      location = locationDataParsed['name'];
      code = locationDataParsed['weather'].first['main'];
      icon = locationDataParsed['weather'].first['icon'];
    });
  }

  Future<void> getLocationDataFromAPIByLatLon() async {
    if (devicePosition != null) {
      locationData = await http.get(Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?lat=${devicePosition!.latitude}&lon=${devicePosition!.longitude}&appid=$key&units=metric'));
      final locationDataParsed = jsonDecode(locationData.body);

      setState(() {
        temperature = locationDataParsed['main']['temp'];
        location = locationDataParsed['name'];
        code = locationDataParsed['weather'].first['main'];
        icon = locationDataParsed['weather'].first['icon'];
      });
    }
  }

  Future<void> getDevicePosition() async {
    devicePosition = await _determinePosition();
    print(devicePosition);
  }

  Future<void> getDailyForecastByLatLon() async {
    var forecastData = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/forecast?lat=${devicePosition!.latitude}&lon=${devicePosition!.longitude}&appid=$key&units=metric'));
    var forecastDataParsed = jsonDecode(forecastData.body);
    temperatures.clear();
    icons.clear();
    dates.clear();

    setState(() {
      temperatures.add(forecastDataParsed['list'][7]['main']['temp']);
      temperatures.add(forecastDataParsed['list'][15]['main']['temp']);
      temperatures.add(forecastDataParsed['list'][23]['main']['temp']);
      temperatures.add(forecastDataParsed['list'][31]['main']['temp']);
      temperatures.add(forecastDataParsed['list'][39]['main']['temp']);

      icons.add(forecastDataParsed['list'][7]['weather'][0]['icon']);
      icons.add(forecastDataParsed['list'][15]['weather'][0]['icon']);
      icons.add(forecastDataParsed['list'][23]['weather'][0]['icon']);
      icons.add(forecastDataParsed['list'][31]['weather'][0]['icon']);
      icons.add(forecastDataParsed['list'][39]['weather'][0]['icon']);

      dates.add(forecastDataParsed['list'][7]['dt_txt']);
      dates.add(forecastDataParsed['list'][15]['dt_txt']);
      dates.add(forecastDataParsed['list'][23]['dt_txt']);
      dates.add(forecastDataParsed['list'][31]['dt_txt']);
      dates.add(forecastDataParsed['list'][39]['dt_txt']);
    });
  }

  Future<void> getDailyForecastByLocation() async {
    var forecastData = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/forecast?q=$location&appid=$key&units=metric'));
    var forecastDataParsed = jsonDecode(forecastData.body);

    temperatures.clear();
    icons.clear();
    dates.clear();

    setState(() {
      temperatures.add(forecastDataParsed['list'][7]['main']['temp']);
      temperatures.add(forecastDataParsed['list'][15]['main']['temp']);
      temperatures.add(forecastDataParsed['list'][23]['main']['temp']);
      temperatures.add(forecastDataParsed['list'][31]['main']['temp']);
      temperatures.add(forecastDataParsed['list'][39]['main']['temp']);

      icons.add(forecastDataParsed['list'][7]['weather'][0]['icon']);
      icons.add(forecastDataParsed['list'][15]['weather'][0]['icon']);
      icons.add(forecastDataParsed['list'][23]['weather'][0]['icon']);
      icons.add(forecastDataParsed['list'][31]['weather'][0]['icon']);
      icons.add(forecastDataParsed['list'][39]['weather'][0]['icon']);

      dates.add(forecastDataParsed['list'][7]['dt_txt']);
      dates.add(forecastDataParsed['list'][15]['dt_txt']);
      dates.add(forecastDataParsed['list'][23]['dt_txt']);
      dates.add(forecastDataParsed['list'][31]['dt_txt']);
      dates.add(forecastDataParsed['list'][39]['dt_txt']);
    });
  }

  void getInitialData() async {
    await getDevicePosition();
    await getLocationDataFromAPIByLatLon();
    await getDailyForecastByLatLon();
  }

  @override
  void initState() {
    getInitialData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/$code.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: (temperature == null ||
              devicePosition == null ||
              icons.isEmpty ||
              temperatures.isEmpty)
          ? const LoadingWidget()
          : Scaffold(
              backgroundColor: Colors.transparent,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 150,
                      child: Image.network(
                          'http://openweathermap.org/img/wn/$icon@4x.png'),
                    ),
                    Text(
                      "$temperature°C",
                      style: const TextStyle(
                          fontSize: 65,
                          fontWeight: FontWeight.bold,
                          shadows: <Shadow>[
                            Shadow(
                                color: Colors.black87,
                                blurRadius: 5,
                                offset: Offset(-2, 2))
                          ]),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(location,
                            style: const TextStyle(
                              fontSize: 30,
                              shadows: <Shadow>[
                                Shadow(
                                  color: Colors.black87,
                                  blurRadius: 2,
                                  offset: Offset(-1, 1),
                                )
                              ]
                            )),
                        IconButton(
                            onPressed: () async {
                              final selectedCity = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const SearchPage()));
                              location = selectedCity;
                              getLocationData();
                              getDailyForecastByLocation();
                            },
                            icon: const Icon(Icons.search))
                      ],
                    ),
                    buildWeatherCards(context)
                  ],
                ),
              ),
            ),
    );
  }

  Widget buildWeatherCards(BuildContext context) {
    List<DailyWeatherCards> cards = [];

    for (int i = 0; i < 5; i++) {
      cards.add(DailyWeatherCards(
        date: dates[i],
        temp: temperatures[i].toString(),
        image: icons[i],
      ));
    }

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.22,
      width: MediaQuery.of(context).size.width * 0.92,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: cards,
      ),
    );
  }
}

class DailyWeatherCards extends StatelessWidget {
  final String image;
  final String temp;
  final String date;

  const DailyWeatherCards({
    Key? key,
    required this.image,
    required this.temp,
    required this.date,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<String> weekdays = [
      'Pazartesi',
      'Salı',
      'Çarşamba',
      'Perşembe',
      'Cuma',
      'Cumartesi',
      'Pazar'
    ];

    String weekday = weekdays[DateTime.parse(date).weekday - 1];

    return Card(
      elevation: 2,
      color: Colors.transparent,
      child: Container(
        height: 120,
        width: 100,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.network(
              'http://openweathermap.org/img/wn/$image.png',
              height: 50,
              width: 50,
            ),
            Text(
              '$temp °C',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(weekday)
          ],
        ),
      ),
    );
  }
}

Future<Position> _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the
    // App to enable the location services.
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately.
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }

  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.
  return await Geolocator.getCurrentPosition();
}
