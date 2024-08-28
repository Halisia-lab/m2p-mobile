import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import 'package:m2p/common/user_interface_dialog.utils.dart';
import 'package:m2p/services/parking_places.dart';
import 'package:m2p/services/user.dart';
import 'package:url_launcher/url_launcher.dart';

import '../components/map_search_bar.dart';
import '../main.dart';
import '../models/createSearchResponse.dart';
import '../models/parking_place.dart';
import '../models/place_filters.dart';
import 'locator.dart';
import 'place.dart';
import 'search.dart';

class MapService {
  static List<LatLng> polylineCoordinates = [];
  static LatLng destination = LatLng(0, 0);
  static bool navigationModeEnabled = false;
  static bool wazeModeEnabled = false;

  static CreateSearchResponse? currentSearch;
  static ParkingPlace? chosenParking;

  static Color getCircleColor(double? percentage) {
    if (percentage == null) {
      return Color.fromARGB(255, 51, 153, 221).withOpacity(0.6);
    } else {
      if (percentage < 0.15) {
        return Color.fromARGB(255, 243, 81, 56).withOpacity(0.6);
      }
      if (percentage >= 0.5) {
        return Color.fromARGB(255, 82, 197, 86).withOpacity(0.6);
      }
    }

    return Color.fromARGB(255, 255, 157, 0).withOpacity(0.6);
  }

  static bool isUserNearDestination(LatLng userCurrentLocation) {
    return calculateStraightDistance(
            userCurrentLocation.latitude,
            userCurrentLocation.longitude,
            destination.latitude,
            destination.longitude) <
        0.05;
  }

  static Future<MinMaxZoomPreference> getMaxZoomFromUserLevel() async {
    var token = await storage.read(key: "token");
    int userLevel = await UserService.getUserLevel(token!);
    if (await UserService.isPremium(token)) {
      return MinMaxZoomPreference(null, null);
    } else {
      if (navigationModeEnabled) {
        return MinMaxZoomPreference(null, null);
      }
      if (userLevel < 3) {
        return MinMaxZoomPreference(null, 14.5);
      } else if (4 >= userLevel && userLevel < 6) {
        return MinMaxZoomPreference(null, 16);
      } else if (7 >= userLevel && userLevel < 9) {
        return MinMaxZoomPreference(null, 17.5);
      }else {
        //no zoom restrictions for higher levels
        return MinMaxZoomPreference(null, null);
      }
    }
  }

  static Future<String> getAddressFromLatLng(
      double latitude, double longitude) async {
    try {
      final parkingAddress = await GeocodingPlatform.instance
          .placemarkFromCoordinates(latitude, longitude)
          .then((list) => list[0]);
      if (parkingAddress.street != "") {
        return "${parkingAddress.street}, ${parkingAddress.postalCode} ${parkingAddress.locality}";
      } else {
        return "dans ${parkingAddress.postalCode} ${parkingAddress.locality}";
      }
    } catch (e) {
      print(e);
    }
    return "addresse inconnue";
  }

  static Future<List<LatLng>> getPolyPoints(
      LatLng sourceLocation, LatLng destination) async {
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      dotenv.env["GOOGLE_API_KEY"].toString(), // Your Google Map Key
      PointLatLng(sourceLocation.latitude, sourceLocation.longitude),
      PointLatLng(destination.latitude, destination.longitude),
    );

    if (result.points.isNotEmpty) {
      result.points.forEach(
        (PointLatLng point) => polylineCoordinates.add(
          LatLng(point.latitude, point.longitude),
        ),
      );
    }
    return polylineCoordinates;
  }

  static Future<bool> userCantZoomMore(
      GoogleMapController mapController) async {
    bool cantZoomMore = await MapService.getMaxZoomFromUserLevel().then(
        (minMaxZoom) async =>
            minMaxZoom.maxZoom == await mapController.getZoomLevel());
    return cantZoomMore;
  }

  static void onFinalCircleTap(
      GlobalKey<ScaffoldState> _scaffoldKey,
      GoogleMapController mapController,
      Cluster<ParkingPlace> circle,
      LatLng currentLocation,
      Function startNavigationMode) async {
    int placesCount = 0;
    int freePlacesCount = 0;
    bool userHasNoRestrictions = await MapService.userHasNoRestrictions();

    circle.items.forEach((parkingPlace) {
      placesCount = placesCount + 1;
      if (parkingPlace.status == "FREE") {
        freePlacesCount += 1;
      }
    });

    final circleAddress = await MapService.getAddressFromLatLng(
        circle.location.latitude, circle.location.longitude);

    showDialog(
      context: _scaffoldKey.currentContext!,
      builder: (BuildContext context) {
        double distance = MapService.calculateStraightDistance(
            currentLocation.latitude,
            currentLocation.longitude,
            circle.location.latitude,
            circle.location.longitude);

        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          title: Wrap(
            alignment: WrapAlignment.start,
            children: [
              Text(
                "Zone de stationnement à ${distance.toStringAsFixed(2)} km",
                overflow: TextOverflow.fade,
                textAlign: TextAlign.center,
              ),
            ],
          ),
          content: Container(
            height: userHasNoRestrictions ? 250.0 : 200,
            width: 300.0,
            child: ListView(
              children: [
                ListTile(
                  leading: Icon(
                    Icons.location_pin,
                    size: 30.0,
                    color: Colors.red,
                  ),
                  title: Text(
                    "Aux alentours de $circleAddress",
                    overflow: TextOverflow.fade,
                  ),
                ),
                ListTile(
                  leading: Icon(
                    Icons.directions_car,
                    size: 30.0,
                    color: Colors.black,
                  ),
                  title: placesCount > 1
                      ? Text('$placesCount places')
                      : Text('$placesCount place'),
                ),
                ListTile(
                  leading: freePlacesCount > 0
                      ? Icon(
                          Icons.done,
                          color: Colors.green,
                          size: 30,
                        )
                      : Icon(Icons.cancel, color: Colors.orange, size: 30),
                  title: freePlacesCount > 0
                      ? Text(
                          'Au moins une place disponible',
                          overflow: TextOverflow.fade,
                        )
                      : Text('Toutes les places sont occupées.',
                          overflow: TextOverflow.fade),
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
                    color: const Color.fromARGB(255, 107, 107, 107)),
              ),
              onPressed: () {
                Navigator.of(_scaffoldKey.currentContext!).pop();
              },
            ),

            if(freePlacesCount > 0)
            TextButton(
              child: Text(
                "Y ALLER",
                style: TextStyle(fontSize: 15, color: Colors.black),
              ),
              onPressed: () async {

         
                  Navigator.of(_scaffoldKey.currentContext!).pop();
                openNavigationChoice(circle.location, currentLocation,
                    _scaffoldKey, startNavigationMode);
                
                
              },
            ),
          ],
        );
      },
    );
  }

  static void onMultipleCircleTap(
      GlobalKey<ScaffoldState> _scaffoldKey,
      GoogleMapController mapController,
      Cluster<ParkingPlace> circle,
      LatLng currentLocation) async {
    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
            target: LatLng(circle.location.latitude, circle.location.longitude),
            zoom: await mapController.getZoomLevel() + 2),
      ),
    );
  }

  static Future<bool> userHasNoRestrictions() async {
    var token = await storage.read(key: "token");
    int userLevel = await UserService.getUserLevel(token!);
    bool isPremium = await UserService.isPremium(token);
    return userLevel >= 5 || isPremium;
  }

  static void onParkingTap(
      GlobalKey<ScaffoldState> _scaffoldKey,
      ParkingPlace parking,
      LatLng currentLocation,
      Function startNavigationMode) async {
    bool userHasNoRestrictions = await MapService.userHasNoRestrictions();
    polylineCoordinates = [];

    final parkingAddress = await MapService.getAddressFromLatLng(
        parking.latitude, parking.longitude);

    double distance = MapService.calculateStraightDistance(
        currentLocation.latitude,
        currentLocation.longitude,
        parking.latitude,
        parking.longitude);
    showDialog(
      context: _scaffoldKey.currentContext!,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          title: Wrap(
            alignment: WrapAlignment.start,
            children: [
              Text(
                "Place de parking à ${distance.toStringAsFixed(2)} km",
                overflow: TextOverflow.fade,
                textAlign: TextAlign.center,
              ),
            ],
          ),
          content: Container(
            height: userHasNoRestrictions ? 270.0 : 180,
            width: 300.0,
            child: Center(
              child: ListView(
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.location_pin,
                      size: 30.0,
                      color: Colors.red,
                    ),
                    title: Text(
                      "$parkingAddress",
                      overflow: TextOverflow.fade,
                    ),
                  ),
                  if (userHasNoRestrictions)
                    ParkingPlacesService.getPriorityRegime(
                        parking.priorityRegime),
                  ListTile(
                    leading: parking.status == "FREE"
                        ? Icon(
                            Icons.done,
                            size: 30.0,
                            color: Colors.green,
                          )
                        : Icon(
                            Icons.cancel,
                            size: 30.0,
                            color: Colors.orange,
                          ),
                    title: parking.status == "FREE"
                        ? Text('Disponible')
                        : Text('Occupée'),
                  ),
                  if (userHasNoRestrictions)
                    ListTile(
                      title: Text(
                        PlaceService.placeLocalisationDescription[
                                parking.localisation] ??
                            "",
                        overflow: TextOverflow.fade,
                      ),
                    ),
                  if (userHasNoRestrictions)
                    ListTile(
                      title: Text(
                        PlaceService.placeTypeDescription[parking.type] ??
                            "Type de stationnement inconnu",
                        overflow: TextOverflow.fade,
                      ),
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              child: Text(
                "ANNULER",
                style: TextStyle(
                    fontSize: 15,
                    color: const Color.fromARGB(255, 107, 107, 107)),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),

            if(parking.status == "FREE")
            TextButton(
              child: Text(
                "Y ALLER",
                style: TextStyle(fontSize: 15, color: Colors.black),
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                openNavigationChoice(parking.location, currentLocation,
                    _scaffoldKey, startNavigationMode);
              },
            ),
          ],
        );
      },
    );
  }

  static void openNavigationChoice(
      LatLng parkingLocation,
      LatLng currentLocation,
      GlobalKey<ScaffoldState> _scaffoldKey,
      Function startNavigationMode) async {
    final sourceLocation =
        LatLng(currentLocation.latitude, currentLocation.longitude);
    destination = LatLng(parkingLocation.latitude, parkingLocation.longitude);

    polylineCoordinates =
        await MapService.getPolyPoints(sourceLocation, destination);

    if (await MapService.isUserTooFar()) {
      showDialog(
        context: _scaffoldKey.currentContext!,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0))),
            title: Row(
              children: [
                Icon(
                  Icons.lock_clock_outlined,
                  size: 30.0,
                  color: Colors.orange,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    "Longue distance",
                    overflow: TextOverflow.fade,
                    //  textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            content: Text(
                "Il est possible que la place selectionnée ne soit plus disponible à votre arrivée, voulez-vous continuer ?"),
            actions: [
              TextButton(
                child: Text(
                  "ANNULER",
                  style: TextStyle(
                      fontSize: 15,
                      color: const Color.fromARGB(255, 107, 107, 107)),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text(
                  "CONTINUER",
                  style: TextStyle(fontSize: 15, color: Colors.black),
                ),
                onPressed: () async {
                  Navigator.of(context).pop();
                  showNavigationBottomSheet(parkingLocation, _scaffoldKey,
                      startNavigationMode, sourceLocation);
                },
              ),
            ],
          );
        },
      );
    } else {
      showNavigationBottomSheet(
          parkingLocation, _scaffoldKey, startNavigationMode, sourceLocation);
    }
  }

  static void showNavigationBottomSheet(
      LatLng parking,
      GlobalKey<ScaffoldState> _scaffoldKey,
      Function startNavigationMode,
      LatLng sourceLocation) {
    showModalBottomSheet(
      context: _scaffoldKey.currentContext!,
      shape: Platform.isIOS
          ? const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(20.0),
              ),
            )
          : null,
      builder: (BuildContext bc) {
        return Padding(
          padding: const EdgeInsets.all(10),
          child: Container(
            child: new Wrap(
              children: <Widget>[
                ListTile(
                  title: new Text(
                    'Choisir une application',
                  ),
                ),
                new ListTile(
                  title:
                      new Text('Map 2 Place', style: TextStyle(fontSize: 18)),
                  onTap: () {
                    Navigator.pop(_scaffoldKey.currentContext!);
                    startNavigationMode();
                  },
                ),
                new ListTile(
                  title: new Text(
                    'Waze',
                    style: TextStyle(fontSize: 18),
                  ),
                  onTap: () async {
                    Navigator.pop(_scaffoldKey.currentContext!);
                    MapService.launchWaze(parking.latitude, parking.longitude,
                        _scaffoldKey.currentContext!);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static void moveToCurrentLocation(
      GoogleMapController mapController, BuildContext context) {
    LocatorService.getUserCurrentLocation(context).then((value) async {
      CameraPosition cameraPosition = new CameraPosition(
          target: LatLng(value.latitude, value.longitude),
          zoom: 15,
          bearing: navigationModeEnabled ? value.heading : 0);

      mapController.animateCamera(
        CameraUpdate.newCameraPosition(cameraPosition),
      );
    },);
  }

  static Future<BitmapDescriptor> customParkingPin() async {
    BitmapDescriptor parkingPin = BitmapDescriptor.defaultMarker;

    parkingPin = await BitmapDescriptor.fromAssetImage(
            ImageConfiguration(),
            Platform.isIOS
                ? "images/parking-pin.png"
                : "images/parking-pin-android.png")
        .then(
      (icon) {
        return icon;
      },
    );
    return parkingPin;
  }

  static Future<BitmapDescriptor> customUserPin() async {
    BitmapDescriptor userPin = BitmapDescriptor.defaultMarker;
    userPin = await BitmapDescriptor.fromAssetImage(
            ImageConfiguration(),
            Platform.isIOS
                ? "images/user-pin.png"
                : "images/user-pin-android.png")
        .then(
      (icon) {
        return icon;
      },
    );
    return userPin;
  }

  static Future<List<ParkingPlace>> getParkingPlaces(
      double latitude, double longitude) async {
    List<ParkingPlace> places = [];
   

    try { 
      var token = await storage.read(key: "token");
      await ParkingPlacesService.getParkingPlaces(token!, latitude, longitude)
        .then(
      (parkings) => {
        parkings.forEach(
          (parking) {
            places.add(parking);
          },
        )
      },
    );
    } catch(e) {
      print(e);
    }
    
    return places;
  }

  static Future<List<ParkingPlace>> getParkingPlacesAroundAddress() async {
    List<ParkingPlace> places = [];
    var token = await storage.read(key: "token");

    List<ParkingPlace> parkingPlaces =
        await ParkingPlacesService.getParkingPlaces(
            token!,
            MapSearchBar.addressCoordinates.latitude,
            MapSearchBar.addressCoordinates.longitude);

    parkingPlaces.forEach(
      (parking) {
        places.add(parking);
      },
    );

    return places;
  }

  static Future<List<ParkingPlace>> filterParkingPlaces() async {
    var token = await storage.read(key: "token");
    List<ParkingPlace> parkingPlaces =
        await ParkingPlacesService.getParkingPlaces(
            token!,
            MapSearchBar.addressCoordinates.latitude,
            MapSearchBar.addressCoordinates.longitude);
    List<ParkingPlace> typeFilteredParkingPlaces = [];

    List<ParkingPlace> localisationFilteredParkingPlaces = [];
    List<ParkingPlace> regimeFilteredParkingPlaces = [];

    if (PlaceService.placesFilters[PlaceFilters.PLACE_TYPES] != "TOUTES") {
      parkingPlaces.forEach((parkingPlace) {
        if (parkingPlace.type ==
            PlaceService.placesFilters[PlaceFilters.PLACE_TYPES]) {
          typeFilteredParkingPlaces.add(parkingPlace);
        }
      });
    } else {
      typeFilteredParkingPlaces = parkingPlaces;
    }

    if (PlaceService.placesFilters[PlaceFilters.PLACE_LOCALISATIONS] !=
        "TOUTES") {
      parkingPlaces.forEach((parkingPlace) {
        if (parkingPlace.localisation ==
            PlaceService.placesFilters[PlaceFilters.PLACE_LOCALISATIONS]) {
          localisationFilteredParkingPlaces.add(parkingPlace);
        }
      });
    } else {
      localisationFilteredParkingPlaces = parkingPlaces;
    }

    if (PlaceService.placesFilters[PlaceFilters.PLACE_PRIORITY_REGIMES] !=
        "TOUTES") {
      parkingPlaces.forEach((parkingPlace) {
        if (parkingPlace.priorityRegime.contains(PlaceService
            .placesFilters[PlaceFilters.PLACE_PRIORITY_REGIMES]
            .toString())) {
          regimeFilteredParkingPlaces.add(parkingPlace);
        }
      });
    } else {
      regimeFilteredParkingPlaces = parkingPlaces;
    }

    typeFilteredParkingPlaces.removeWhere(
        (item) => !localisationFilteredParkingPlaces.contains(item));
    typeFilteredParkingPlaces
        .removeWhere((item) => !regimeFilteredParkingPlaces.contains(item));
    return typeFilteredParkingPlaces;
  }

  static Future<bool> isUserTooFar() async {
    return await getPreciseDistanceBetweenTwoPoints(polylineCoordinates) > 4;
  }

  static Future<double> getPreciseDistanceBetweenTwoPoints(
      List<LatLng> polylineCoordinates) async {
    double totalDistance = 0.0;

    for (int i = 0; i < polylineCoordinates.length - 1; i++) {
      totalDistance += MapService.calculateStraightDistance(
        polylineCoordinates[i].latitude,
        polylineCoordinates[i].longitude,
        polylineCoordinates[i + 1].latitude,
        polylineCoordinates[i + 1].longitude,
      );
    }
    return totalDistance;
  }

  static double calculateStraightDistance(
      latitude1, longitude1, latitude2, longitude2) {
    var p = 0.017453292519943295;
    var a = 0.5 -
        cos((latitude2 - latitude1) * p) / 2 +
        cos(latitude1 * p) *
            cos(latitude2 * p) *
            (1 - cos((longitude2 - longitude1) * p)) /
            2;
    return 12742 * asin(sqrt(a));
  }

  static void launchWaze(double lat, double lng, BuildContext context) async {
    try {
      var token = await storage.read(key: "token");
      Response response = await SearchService.addSearch(lat, lng, token!);

      CreateSearchResponse createSearchResponse =
          CreateSearchResponse.fromJson(jsonDecode(response.body));
      MapService.currentSearch = createSearchResponse;

      if (response.statusCode == 201) {
        var url = 'waze://?ll=${lat.toString()},${lng.toString()}';
        var fallbackUrl =
            'https://waze.com/ul?ll=${lat.toString()},${lng.toString()}&navigate=yes';
        try {
          bool launched =
              await launch(url, forceSafariVC: false, forceWebView: false);
          if (!launched) {
            await launch(fallbackUrl,
                forceSafariVC: false, forceWebView: false);
          }
        } catch (e) {
          await launch(fallbackUrl, forceSafariVC: false, forceWebView: false);
        }
        wazeModeEnabled = true;
      }
    } catch (e) {
      print(e);
      UserInterfaceDialog.displayAlertDialog(context, "Navigation impossible",
          "Aucun signalement n'a été trouvé.");
    }
  }
}