import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:weather/weather.dart';
import 'package:weather_app_ferolino/src/controllers/search_controller.dart';
import 'package:weather_app_ferolino/src/shared/constants.dart';
import 'package:location/location.dart';

class WeatherController {
  late String cityName = '';
  late Weather currentWeather;
  late List<Weather> currentForecast;

  late WeatherFactory ws;
  late SearchController sc;
  late Location lc;
  late LocationData currentLocation;
  final StreamController<String?> _controller = StreamController();
  Stream<String?> get stream => _controller.stream;

  WeatherController(SearchController sCtr) {
    lc = Location();
    sc = sCtr;
    ws = WeatherFactory(apiKey);
    setCity(cityName);
  }

  void onStartUp() async {
    _controller.add(null);
    try {
      currentLocation = await getLocation();
      currentWeather = await ws.currentWeatherByLocation(
          currentLocation.latitude!, currentLocation.longitude!);
      currentForecast = await ws.fiveDayForecastByLocation(
          currentLocation.latitude!, currentLocation.longitude!);
      _controller.add("success");
    } catch (e) {
      print(e);
      _controller.addError((e));
    }
  }

  getLocation() async {
    Location location = new Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();
    currentLocation = _locationData;
    return currentLocation;
  }

  void setCity(String city) {
    print(sc.searchHistory);
    if (sc.searchHistory.isNotEmpty) {
      print('Im here1');
      cityName = city;
      setWeather();
      setForecast();
    } else if (sc.searchHistory.isEmpty) {
      print('Im here2');
      onStartUp();
    }
  }

  void setWeather() async {
    _controller.add(null);

    try {
      http.Response response = await queryCurrentWeather();

      if (response.statusCode == 200) {
        _controller.add("success");
      } else {
        print(response.statusCode);
        _controller.addError(Future.error(response.statusCode));
      }
    } catch (e) {
      print(e);
      _controller.addError((e));
    }
  }

  void setForecast() async {
    _controller.add(null);

    try {
      http.Response response = await queryCurrentForecast();

      if (response.statusCode == 200) {
        _controller.add("success");
      } else {
        print(response.statusCode);
        _controller.addError(Future.error(response.statusCode));
      }
    } catch (e) {
      print(e);
      _controller.addError((e));
    }
  }

  Future<http.Response> queryCurrentWeather() async {
    currentWeather = await ws.currentWeatherByCityName(cityName);

    final url = Uri.https(
      'api.openweathermap.org',
      'data/2.5/onecall',
      {
        'lat': currentWeather.latitude.toString(),
        'lon': currentWeather.longitude.toString(),
        'exclude': 'minutely',
        'units': 'metric',
        'appid': apiKey,
      },
    );

    final response = await http.get(url);
    return response;
  }

  String temperatureTrim() {
    return currentWeather.temperature.toString().replaceAll(" Celsius", "°");
  }

  String temperatureTrimFC(index) {
    return currentForecast[index]
        .temperature
        .toString()
        .replaceAll(" Celsius", "°");
  }

  String formatTime() {
    return DateFormat.yMMMMd('en_US')
        .add_jm()
        .format(currentWeather.date!)
        .toString();
  }

  String formatTimeFC(index) {
    return DateFormat.yMMMMd('en_US')
        .format(currentForecast[index].date!)
        .toString();
  }

  String formatTimeOfDayFC(index) {
    return DateFormat.jm().format(currentForecast[index].date!).toString();
  }

  Future<http.Response> queryCurrentForecast() async {
    currentForecast = await ws.fiveDayForecastByCityName(cityName);

    final url = Uri.https(
      'api.openweathermap.org',
      'data/2.5/onecall',
      {
        'lat': currentWeather.latitude.toString(),
        'lon': currentWeather.longitude.toString(),
        'exclude': 'minutely',
        'units': 'metric',
        'appid': apiKey,
      },
    );

    final response = await http.get(url);
    return response;
  }
}
