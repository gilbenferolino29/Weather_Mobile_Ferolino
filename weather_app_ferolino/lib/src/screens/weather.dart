import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:weather_app_ferolino/src/controllers/weather_controller.dart';

class SingleWeather extends StatefulWidget {
  final WeatherController wc;
  const SingleWeather({Key? key, required this.wc}) : super(key: key);

  @override
  State<SingleWeather> createState() => _SingleWeatherState();
}

class _SingleWeatherState extends State<SingleWeather> {
  @override
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.wc.bgGuide(widget.wc.currentWeather.latitude,
            widget.wc.currentWeather.longitude),
        Container(
          decoration: const BoxDecoration(color: Colors.black38),
        ),
        Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 50,
                        ),
                        Text(
                          widget.wc.currentWeather.areaName.toString(),
                          style: GoogleFonts.lato(
                            fontSize: 45,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          widget.wc.formatTime(
                              widget.wc.currentWeather.latitude,
                              widget.wc.currentWeather.longitude),
                          style: GoogleFonts.lato(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.wc.temperatureTrim(),
                          style: GoogleFonts.lato(
                            fontSize: 85,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                        Row(
                          children: [
                            Image.network(
                                "http://openweathermap.org/img/wn/" +
                                    widget.wc.currentWeather.weatherIcon
                                        .toString() +
                                    "@2x.png",
                                width: 50,
                                height: 50),
                            Text(
                              widget.wc.currentWeather.weatherDescription
                                  .toString(),
                              style: GoogleFonts.lato(
                                fontSize: 25,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(
                      vertical: 20,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.white30,
                      ),
                    ),
                  ),
                  Text(
                    '5-Day Forecast',
                    style: GoogleFonts.lato(
                      fontSize: 25,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                    child: Container(
                        padding: EdgeInsets.all(5),
                        height: 150,
                        width: 350,
                        child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: widget.wc.currentForecast.length,
                            itemBuilder: (context, index) {
                              final data = widget.wc.currentForecast;
                              //print(data);
                              return Padding(
                                padding: const EdgeInsets.all(3.0),
                                child: Container(
                                  padding: EdgeInsets.all(5),
                                  height: 80,
                                  width: 120,
                                  decoration: BoxDecoration(
                                    color: Colors.white30,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        widget.wc.formatTimeFC(index),
                                        style: GoogleFonts.lato(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        widget.wc.formatTimeOfDayFC(index),
                                        style: GoogleFonts.lato(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        widget.wc.temperatureTrimFC(index),
                                        style: GoogleFonts.lato(
                                          fontSize: 25,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black,
                                        ),
                                      ),
                                      Image.network(
                                          "http://openweathermap.org/img/wn/" +
                                              widget
                                                  .wc.currentWeather.weatherIcon
                                                  .toString() +
                                              "@2x.png",
                                          width: 50,
                                          height: 50),
                                      Text(
                                        widget.wc.currentWeather
                                            .weatherDescription
                                            .toString(),
                                        style: GoogleFonts.lato(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            })),
                  )
                ],
              )
            ],
          ),
        ),
      ],
    );
  }
}
