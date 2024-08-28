import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../models/place_filters.dart';

class PlaceService with ChangeNotifier {
  static Map<PlaceFilters, String> placesFilters = {
    PlaceFilters.PLACE_TYPES: "TOUTES",
    PlaceFilters.PLACE_LOCALISATIONS: "TOUTES",
    PlaceFilters.PLACE_PRIORITY_REGIMES: "TOUTES"
  };

  static void clearPlacesFilters() {
    placesFilters = {
      PlaceFilters.PLACE_TYPES: "TOUTES",
      PlaceFilters.PLACE_LOCALISATIONS: "TOUTES",
      PlaceFilters.PLACE_PRIORITY_REGIMES: "TOUTES"
    };
  }

  static Map<String, String> placeTypeDescription = {
    PlaceTypes.EPI.name: "Stationnement en Epi",
    PlaceTypes.BATAILLE.name: "Stationnement en Bataille",
    PlaceTypes.LONGITUDINAL.name: "Stationnement Longitudinal",
  };
  static Map<String, String> placeLocalisationDescription = {
    PlaceLocalisations.CHAUSSEE.name: "Située sur la chaussée",
    PlaceLocalisations.CONTRE_ALLEE.name: "Située en contre allée",
    PlaceLocalisations.CONTRE_TERRE_PLEIN.name: "Située en contre terre-plein",
    PlaceLocalisations.FAUX_LINCOLN.name: "Située en faux lincoln",
    PlaceLocalisations.LINCOLN.name: "Située en lincoln",
    PlaceLocalisations.TERRE_PLEIN.name: "Située sur un terre-plein",
    PlaceLocalisations.TROTTOIR.name: "Située sur un trottoir",
  };

  static bool areFiltersEnabled() {
    return placesFilters[PlaceFilters.PLACE_TYPES] != "TOUTES" ||
        placesFilters[PlaceFilters.PLACE_LOCALISATIONS] != "TOUTES" ||
        placesFilters[PlaceFilters.PLACE_PRIORITY_REGIMES] != "TOUTES";
  }

  void addFilter(PlaceFilters filterType, String value) {
    placesFilters[filterType] = value;
    notifyListeners();
  }

  static List<DropdownMenuItem<String>> placeTypes = [
    DropdownMenuItem(child: Text("Toutes"), value: "TOUTES"),
    DropdownMenuItem(child: Text("Longitudinal"), value: "LONGITUDINAL"),
    DropdownMenuItem(child: Text("Epi"), value: "EPI"),
    DropdownMenuItem(child: Text("Bataille"), value: "BATAILLE"),
  ];

  static List<DropdownMenuItem<String>> placePriorityRegimes = [
    DropdownMenuItem(child: Text("Toutes"), value: "TOUTES"),
    DropdownMenuItem(child: Text("Gratuit"), value: "GRATUIT"),
    DropdownMenuItem(child: Text("Payant"), value: "PAYANT"),
    DropdownMenuItem(child: Text("Electrique"), value: "ELECTRIQUE"),
    DropdownMenuItem(child: Text("Livraison"), value: "LIVRAISON"),
    DropdownMenuItem(child: Text("Deux roues"), value: "DEUX_ROUES"),
    DropdownMenuItem(child: Text("Handicapé"), value: "GIG_GIC"),
    DropdownMenuItem(child: Text("Location"), value: "LOCATION"),
  ];

  static List<DropdownMenuItem<String>> placeLocalisations = [
    DropdownMenuItem(child: Text("Toutes"), value: "TOUTES"),
    DropdownMenuItem(child: Text("Trottoir"), value: "TROTTOIR"),
    DropdownMenuItem(child: Text("Chaussée"), value: "CHAUSSEE"),
    DropdownMenuItem(child: Text("Lincoln"), value: "LINCOLN"),
    DropdownMenuItem(child: Text("Faux lincoln"), value: "FAUX_LINCOLN"),
    DropdownMenuItem(child: Text("Terre-plein"), value: "TERRE_PLEIN"),
    DropdownMenuItem(
        child: Text("Contre terre-plein"), value: "CONTRE_TERRE_PLEIN"),
    DropdownMenuItem(child: Text("Contre allée"), value: "CONTRE_ALLEE"),
  ];

  Future<String?> getSuggestions(String searchValue,
      {Map<String, String>? headers}) async {
    Uri uri =
        Uri.https("maps.googleapis.com", "maps/api/place/autocomplete/json", {
      "input": searchValue,
      "key": dotenv.env["GOOGLE_API_KEY"],
      "location":
          "48.86226965580183, 2.344497857155462", // show addresses around the center of Paris
      "radius": "10000", // 10km radius priority
    });
    try {
      final response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
        return response.body;
      }
    } catch (e) {}

    return null;
  }
}
