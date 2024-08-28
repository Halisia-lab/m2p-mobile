import 'package:flutter/material.dart';

import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/place_filters.dart';
import '../models/suggestions_response.dart';
import '../services/place.dart';
import '../models/suggestion.dart';
import '../services/map.dart';
import 'place_filters_drop_down.dart';

class MapSearchBar extends StatefulWidget {
  final GoogleMapController mapController;
  final Function onFiltersChange;
  final Function onMoveToAddress;

  static LatLng addressCoordinates = LatLng(0, 0);

  MapSearchBar(
      {required this.mapController,
      required this.onFiltersChange,
      required this.onMoveToAddress,
      super.key});

  @override
  State<MapSearchBar> createState() => _MapSearchBarState();
}

class _MapSearchBarState extends State<MapSearchBar> {
  TextEditingController _searchController = TextEditingController();

  String placeTypesValue = "";
  String placePriorityRegimesValue = "";
  String placeLocalisationsValue = "";

  List<Suggestion> suggestions = [];
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: PlaceService.areFiltersEnabled()
            ? BottomAppBar(
                clipBehavior: Clip.antiAliasWithSaveLayer,
                height: 80,
                child: Container(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: FilledButton(
                      onPressed: () {
                        PlaceService.clearPlacesFilters();
                        widget.onFiltersChange();
                      },
                      child: Text("Effacer les filtres"),
                    ),
                  ),
                ),
              )
            : buildSearchBar());
  }

  void getSuggestions(String searchValue) async {
    String? response = await PlaceService().getSuggestions(searchValue);
    if (response != null) {
      SuggestionsResponse suggestionsResponse =
          SuggestionsResponse.parseSuggestions(response);
      if (suggestionsResponse.predictions != null) {
        setState(() {
          suggestions = suggestionsResponse.predictions!;
        });
      }
    }
  }

  Future<Location> moveToAddress(String address) async {
    Location coordinates = await GeocodingPlatform.instance
        .locationFromAddress(address)
        .then((list) => list[0]);

    setState(() {
      MapSearchBar.addressCoordinates =
          LatLng(coordinates.latitude, coordinates.longitude);
      widget.onMoveToAddress();
    });

    widget.mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
            target: LatLng(coordinates.latitude, coordinates.longitude),
            zoom: 19),
      ),
    );
    return coordinates;
  }

  Widget buildSearchBar() {
    return BottomAppBar(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      height:
          suggestions.isEmpty ? 80 : MediaQuery.of(context).size.height * 2 / 5,
      child: Container(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: ListView(
            children: [
              Container(
                decoration: BoxDecoration(
                    color: Color.fromARGB(255, 232, 239, 241),
                    borderRadius: BorderRadius.circular(50)),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => getSuggestions(value),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    prefixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () => {},
                      color: Colors.black,
                    ),
                    hintText: 'Où se garer ?',
                  ),
                ),
              ),
              for (Suggestion suggestion in suggestions)
                FutureBuilder(
                    future: MapService.userHasNoRestrictions(),
                    builder: (context, noRestriction) {
                      return ListTile(
                        leading: Icon(Icons.location_pin),
                        title: Text(suggestion.description!),
                        onTap: () => {
                          setState(
                            () {
                              suggestions = [];
                              _searchController.text = "";
                              FocusScopeNode currentFocus =
                                  FocusScope.of(context);
                              if (!currentFocus.hasPrimaryFocus) {
                                currentFocus.unfocus();
                              }
                            },
                          ),
                          moveToAddress(suggestion.description!),
                          if (noRestriction.data != null && noRestriction.data!)
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10.0))),
                                  title: Wrap(
                                    alignment: WrapAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.filter_list,
                                            color: Colors.blue,
                                          ),
                                          Text(
                                            "Filtrer la recherche",
                                            overflow: TextOverflow.fade,
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  content: Container(
                                    height: 250.0,
                                    width: 300.0,
                                    child: ListView(
                                      children: [
                                        SizedBox(
                                          height: 20,
                                        ),
                                        Text(
                                          "Régime prioritaire:",
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelSmall,
                                        ),
                                        PlaceFiltersDropDown(
                                          items:
                                              PlaceService.placePriorityRegimes,
                                          placeFiltersType: PlaceFilters
                                              .PLACE_PRIORITY_REGIMES,
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          "Type de stationnement:",
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelSmall,
                                        ),
                                        PlaceFiltersDropDown(
                                          items: PlaceService.placeTypes,
                                          placeFiltersType:
                                              PlaceFilters.PLACE_TYPES,
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          "Localisation:",
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelSmall,
                                        ),
                                        PlaceFiltersDropDown(
                                          items:
                                              PlaceService.placeLocalisations,
                                          placeFiltersType:
                                              PlaceFilters.PLACE_LOCALISATIONS,
                                        ),
                                      ],
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      child: Text(
                                        "ANNULER",
                                        style: TextStyle(
                                            fontSize: 15,
                                            color: const Color.fromARGB(
                                                255, 107, 107, 107)),
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    TextButton(
                                      child: Text(
                                        "APPLIQUER",
                                        style: TextStyle(
                                            fontSize: 15, color: Colors.black),
                                      ),
                                      onPressed: () async {
                                        setState(() {
                                          widget.onFiltersChange();
                                        });
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            ),
                        },
                      );
                    })
            ],
          ),
        ),
      ),
    );
  }
}
