import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:weather_app_ferolino/src/controllers/weather_controller.dart';
import 'package:weather_app_ferolino/src/screens/weather.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final WeatherController wcController;

  @override
  void initState() {
    wcController = WeatherController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () {},
          icon: Icon(
            Icons.search,
            size: 30,
            color: Colors.white,
          ),
        ),
        actions: [],
      ),
      body: Container(
        child: Stack(
          children: [
            Image.asset(
              'assets/images/sample.png',
              fit: BoxFit.cover,
              height: double.infinity,
              width: double.infinity,
            ),
            Container(
              decoration: BoxDecoration(color: Colors.black38),
            ),
            StreamBuilder(
                stream: wcController.stream,
                builder:
                    (BuildContext context, AsyncSnapshot<String?> snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                      return messageBox(
                        context,
                        "No Internet Connection",
                        "try again later",
                      );

                    case ConnectionState.waiting:
                      return Center(child: CircularProgressIndicator());

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
                      '"${wcController.cityName}" not found',
                      'Try searching for a city name',
                    );
                  } else if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  } else {
                    return SingleWeather(wc: wcController);
                  }
                }),
          ],
        ),
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
