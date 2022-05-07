import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:weather_app_ferolino/src/controllers/search_controller.dart';
import 'package:weather_app_ferolino/src/controllers/weather_controller.dart';
import 'package:weather_app_ferolino/src/screens/homepage.dart';
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
    wcController = WeatherController(scController = SearchController());

    super.initState();
  }

  @override
  void dispose() {
    scController.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //print(scController.searchHistory);
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: FloatingSearchBar(
        controller: scController.controller,
        body: FloatingSearchBarScrollNotifier(
          child: HomePage(wc: wcController),
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
            wcController.setCity(scController.selectedTerm!);
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
                            wcController.setCity(scController.selectedTerm!);
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
                              onTap: () {
                                setState(() {
                                  scController.putSearchTermFirst(term);
                                  scController.selectedTerm = term;
                                  wcController
                                      .setCity(scController.selectedTerm!);
                                });
                                scController.controller.close();
                              },
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
}
