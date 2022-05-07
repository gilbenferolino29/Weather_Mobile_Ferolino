import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:weather_app_ferolino/src/controllers/search_controller.dart';
import 'package:weather_app_ferolino/src/controllers/weather_controller.dart';
import 'package:weather_app_ferolino/src/screens/weather.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final WeatherController wcController;
  late final SearchController scController;

  @override
  void initState() {
    wcController = WeatherController();
    scController = SearchController();
    super.initState();
  }

  @override
  void dispose() {
    scController.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: FloatingSearchBar(
        controller: scController.controller,
        body: FloatingSearchBarScrollNotifier(
          child: SafeArea(
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
                    stream: wcController.stream,
                    builder: (BuildContext context,
                        AsyncSnapshot<String?> snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.none:
                          return messageBox(
                            context,
                            "No Internet Connection",
                            "try again later",
                          );

                        case ConnectionState.waiting:
                          return const Center(
                              child: CircularProgressIndicator());

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
                        return const Center(child: CircularProgressIndicator());
                      } else {
                        return SingleWeather(wc: wcController);
                      }
                    }),
              ],
            ),
          ),
        ),
        transition: CircularFloatingSearchBarTransition(),
        physics: const BouncingScrollPhysics(),
        title: Text(
          scController.selectedTerm ?? 'City Name / Place',
          style: GoogleFonts.lato(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        hint: 'Cebu City...',
        actions: [
          FloatingSearchBarAction.searchToClear(),
        ],
        onQueryChanged: (query) {
          setState(() {
            scController.filteredSearch =
                scController.filterSearchTerms(filter: query);
          });
        },
        onSubmitted: (query) {
          setState(() {
            scController.addSearchTerm(query);
            scController.selectedTerm = query;
          });
          scController.controller.close;
        },
        builder: (context, transition) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Material(
              color: Colors.white,
              elevation: 4,
              child: Builder(
                builder: (context) {
                  if (scController.filteredSearch.isEmpty &&
                      scController.controller.query.isEmpty) {
                    return Container(
                      height: 56,
                      width: double.infinity,
                      alignment: Alignment.center,
                      child: Text(
                        'Search a city/place',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.lato(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black45,
                        ),
                      ),
                    );
                  } else if (scController.filteredSearch.isEmpty) {
                    return ListTile(
                      title: Text(scController.controller.query),
                      leading: const Icon(Icons.search),
                      onTap: () {
                        setState(
                          () {
                            scController
                                .addSearchTerm(scController.controller.query);
                            scController.selectedTerm =
                                scController.controller.query;
                          },
                        );
                        scController.controller.close();
                      },
                    );
                  } else {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: scController.filteredSearch
                          .map(
                            (term) => ListTile(
                              title: Text(
                                term,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              leading: const Icon(
                                Icons.history,
                              ),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.clear,
                                ),
                                onPressed: () {
                                  setState(() {
                                    scController.deleteSearchTerm(term);
                                  });
                                },
                              ),
                            ),
                          )
                          .toList(),
                    );
                  }
                },
              ),
            ),
          );
        },
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
