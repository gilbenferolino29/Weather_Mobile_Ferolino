import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:weather/weather.dart';
import 'package:weather_app_ferolino/src/controllers/search_controller.dart';
import 'package:weather_app_ferolino/src/shared/constants.dart';
import 'package:location/location.dart';
import 'dart:convert' as convert;
import 'package:lat_lng_to_timezone/lat_lng_to_timezone.dart' as tzmap;
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class WeatherController {
  late String cityName = '';
  late Weather currentWeather;
  late List<Weather> currentForecast;
  late String timezone;

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

  DateTime setTime(lat, lon) {
    try {
      final timezoneTime =
          tz.getLocation(tzmap.latLngToTimezoneString(lat, lon));
      var ct = tz.TZDateTime.now(timezoneTime);

      print(ct);
      return ct;
    } catch (e) {
      return DateTime.now();
    }
  }

  getLocation() async {
    Location location = Location();

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
      print(currentWeather);
    } else if (sc.searchHistory.isEmpty) {
      print('Im here2');
      onStartUp();
    }
  }

  Image bgGuide(lat, lon) {
    if (bgTime(lat, lon) > 18 || bgTime(lat, lon) < 4) {
      return Image.asset(
        "assets/images/night.jpg",
        fit: BoxFit.cover,
        height: double.infinity,
        width: double.infinity,
      );
    } else if (bgTime(lat, lon) > 15) {
      return Image.asset(
        "assets/images/afternoon.jpg",
        fit: BoxFit.cover,
        height: double.infinity,
        width: double.infinity,
      );
    } else if (bgTime(lat, lon) > 6) {
      return Image.asset(
        "assets/images/morning.jpg",
        fit: BoxFit.cover,
        height: double.infinity,
        width: double.infinity,
      );
    } else if (bgTime(lat, lon) >= 4) {
      return Image.asset(
        "assets/images/afternoon.jpg",
        fit: BoxFit.cover,
        height: double.infinity,
        width: double.infinity,
      );
    } else {
      return Image.asset(
        "assets/images/morning.jpg",
        fit: BoxFit.cover,
        height: double.infinity,
        width: double.infinity,
      );
    }
  }

  void setWeather() async {
    _controller.add(null);
    tz.initializeTimeZones();
    try {
      final response = await queryCurrentWeather();

      if (response.statusCode == 200) {
        final res = convert.jsonDecode(response.body);
        timezone = res['timezone'];
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
        //print(timezone);
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

  formatTime(lat, lon) {
    return DateFormat.yMMMMd('en_US')
        .add_jm()
        .format(setTime(lat, lon))
        .toString();
  }

  bgTime(lat, lon) {
    return setTime(lat, lon).hour;
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
