import 'package:flutter/material.dart';
import 'package:weather_app_ferolino/src/screens/home.dart';

import 'package:weather_app_ferolino/src/screens/weather.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Weather App - Ferolino',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
    );
  }
}
