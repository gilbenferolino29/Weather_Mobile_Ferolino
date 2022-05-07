import 'package:flutter/material.dart';
import 'package:weather_app_ferolino/src/controllers/weather_controller.dart';
import 'package:weather_app_ferolino/src/screens/weather.dart';

class HomePage extends StatelessWidget {
  final WeatherController wc;
  const HomePage({Key? key, required this.wc}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          Image.asset(
            'assets/images/sample.png',
            fit: BoxFit.cover,
            height: double.infinity,
            width: double.infinity,
          ),
          Container(
            decoration: const BoxDecoration(color: Colors.black38),
          ),
          StreamBuilder(
              stream: wc.stream,
              builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                    return messageBox(
                      context,
                      "No Internet Connection",
                      "try again later",
                    );

                  case ConnectionState.waiting:
                    return const Center(child: CircularProgressIndicator());

                  default:
                    messageBox(
                      context,
                      "Something is wrong",
                      "",
                    );
                }
                if (snapshot.hasError) {
                  return messageBox(
                    context,
                    '"${wc.cityName}" not found',
                    'Try searching for a city name',
                  );
                } else if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                } else {
                  //print(wc.currentWeather);
                  return SingleWeather(wc: wc);
                }
              }),
        ],
      ),
    );
  }

  SizedBox messageBox(BuildContext context, String s, String t) {
    return SizedBox(
      height: MediaQuery.of(context).size.height / 1.3,
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            t,
            style: Theme.of(context).textTheme.headline5,
          ),
          Text(
            s,
            style: TextStyle(color: Theme.of(context).primaryColor),
          ),
        ],
      ),
    );
  }
}
