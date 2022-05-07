import 'dart:async';

import 'package:flutter/material.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';

class SearchController {
  static const historyLength = 5;

  final List<String> searchHistory = [];
  late List<String> filteredSearch;
  String? selectedTerm;
  late FloatingSearchBarController controller;

  SearchController() {
    controller = FloatingSearchBarController();
    filteredSearch = filterSearchTerms(filter: null);
  }

  List<String> filterSearchTerms({
    @required String? filter,
  }) {
    if (filter != null && filter.isNotEmpty) {
      return searchHistory.reversed
          .where((term) => term.startsWith(filter))
          .toList();
    } else {
      return searchHistory.reversed.toList();
    }
  }

  void addSearchTerm(String term) {
    if (searchHistory.contains(term)) {
      putSearchTermFirst(term);
      return;
    }
    searchHistory.add(term);

    if (searchHistory.length > historyLength) {
      searchHistory.removeRange(0, (searchHistory.length - historyLength));
    }

    filteredSearch = filterSearchTerms(filter: null);
  }

  void putSearchTermFirst(String term) {
    deleteSearchTerm(term);
    addSearchTerm(term);
  }

  void deleteSearchTerm(String term) {
    searchHistory.removeWhere((t) => t == term);
    filteredSearch = filterSearchTerms(filter: null);
  }
}
