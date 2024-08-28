import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import 'package:m2p/common/user_interface_dialog.utils.dart';
import 'package:m2p/main.dart';
import 'package:m2p/models/createSearchResponse.dart';
import 'package:m2p/services/report.dart';

import '../components/navigation_bottom_bar.dart';
import '../components/location_disabled.dart';
import '../components/map_action_buttons.dart';
import '../models/search.dart';
import '../services/map.dart';
import '../services/place.dart';
import '../services/search.dart';
import '../utils/custom_colors.dart';
import '../components/drawer_menu.dart';
import '../components/map_search_bar.dart';
import '../models/parking_place.dart';
import '../services/locator.dart';
import '../components/cluster_icon.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  static const String routeName = '/home';

  static void navigateTo(BuildContext context) {
    Navigator.of(context).pushNamed(routeName);
  }

  @override
  State<Home> createState() => HomeState();
}

class HomeState extends State<Home> with WidgetsBindingObserver {
  // map configuration
  late GoogleMapController mapController;
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  ClusterManager? _manager;
  CameraPosition currentCameraPosition = CameraPosition(
      target: LatLng(48.84609858991689, 2.3855773550757515), zoom: 15);
  double currentZoom = 1;
  LatLng onCameraMoveLatLng = LatLng(0, 0);

// map data and icons
  BitmapDescriptor parkingPin = BitmapDescriptor.defaultMarker;
  BitmapDescriptor userPin = BitmapDescriptor.defaultMarker;
  List<ParkingPlace> parkingPlaces = [];
  Set<Marker> markers = Set();
  PlaceService placeService = PlaceService();

// navigation variables
  StreamSubscription<Position>? positionStream;
  StreamSubscription<CompassEvent>? compassStream;
  LatLng currentLocation = LatLng(0, 0);
  late LatLng sourceLocation;
  late LatLng destination;
  late Search currentSearch;

  bool showSearchBar = false;
  double distanceToDestination = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      init();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    placeService.removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (PlaceService.areFiltersEnabled()) {
      MapService.filterParkingPlaces().then((parkings) {
        parkingPlaces = parkings;
      });
    } else {
      MapService.getParkingPlaces(
              currentLocation.latitude, currentLocation.longitude)
          .then((parkings) {
        parkingPlaces = parkings;
      });
    }

    if (LocatorService.isPermissionGranted()) {
      print("ok permission");
      return buildMapScreen();
    } else {
      if (LocatorService.isPermissionWaiting()) {
        print("permission waiting");
        return Center(
          child: CircularProgressIndicator(),
        );
      } else {
        return LocationDisabled();
      }
    }
  }

  initBuild() async {
    
  }

  init()async {
     if (!LocatorService.isPermissionGranted()) {
      await Geolocator.requestPermission().then(
        (value) => _updateLocationPermission(value),
      );
    }
   await  _updateUserPosition().then((value) => currentLocation = value);

     await MapService.getParkingPlaces(currentLocation.latitude, currentLocation.longitude)
          .then((parkings) {
        parkingPlaces = parkings;
        _initClusterManager();
      });

     

    // setState(() {
      MapService.customParkingPin().then((value) => parkingPin = value);
      MapService.customUserPin().then((value) => userPin = value);
    // });

  }

  Widget buildMapScreen() {
     print("parkings : $parkingPlaces");
    return Scaffold(
      key: _scaffoldKey,
      drawer: DrawerMenu(),
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                Color.fromARGB(80, 0, 0, 0),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: buildFutureBuilderMap(),
      bottomNavigationBar: MapService.navigationModeEnabled
          ? NavigationBottomBar(
              endNavigationMode: () => _endNavigationMode(),
              polylineCoordinates: MapService.polylineCoordinates,
              distanceLeft: distanceToDestination,
            )
          : (showSearchBar
              ? MapSearchBar(
                  mapController: mapController,
                  onFiltersChange: () => _onFiltersChange(),
                  onMoveToAddress: () => _onMoveToAddress(),
                )
              : Center(
                  child: CircularProgressIndicator(),
                )),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: MapActionButtons(
          onReportButtonTap: () => _onReportButtonTap(),
          moveToCurrentLocation: () {
            MapService.moveToCurrentLocation(mapController, context);
            MapService.getParkingPlaces(
                    currentLocation.latitude, currentLocation.longitude)
                .then((parkings) {
                 
              setState(() {
                parkingPlaces = parkings;
                _initClusterManager();
                _manager!.setMapId(mapController.mapId);
              });
            });
          }),
    );
  }

  Widget buildFutureBuilderMap() {
    return FutureBuilder(
      future: LocatorService.getUserCurrentLocation(context),
      builder: (context, userCurrentLocation) {
    
        return userCurrentLocation.data == null || _manager == null
            ? AlertDialog(
                elevation: 500,
                backgroundColor: Colors.transparent,
                content: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              )
            : FutureBuilder(
                future: MapService.getMaxZoomFromUserLevel(),
                builder: (context, maxZoom) {
                  return GoogleMap(
                    minMaxZoomPreference: maxZoom.data != null
                        ? MinMaxZoomPreference(0, maxZoom.data!.maxZoom)
                        : MinMaxZoomPreference(0, null),
                    padding: EdgeInsets.only(
                      top: 40.0,
                    ),
                    zoomControlsEnabled: false,
                    mapType: MapType.normal,
                    myLocationEnabled: !MapService.navigationModeEnabled,
                    myLocationButtonEnabled: false,
                    initialCameraPosition: CameraPosition(
                        target: LatLng(userCurrentLocation.data!.latitude,
                            userCurrentLocation.data!.longitude),
                        zoom: 15),
                    markers: MapService.navigationModeEnabled
                        ? {
                            Marker(
                              icon: userPin,
                              markerId: const MarkerId("currentLocation"),
                              position: LatLng(currentLocation.latitude,
                                  currentLocation.longitude),
                            ),
                            Marker(
                              markerId: MarkerId("destination"),
                              position: MapService.destination,
                            ),
                          }
                        : markers,
                    polylines: MapService.navigationModeEnabled
                        ? {
                            Polyline(
                              startCap: Cap.roundCap,
                              endCap: Cap.roundCap,
                              polylineId: const PolylineId("route"),
                              points: MapService.polylineCoordinates,
                              color: primaryBlack,
                              width: 10,
                            ),
                          }
                        : {},
                    onCameraMove: onCameraMove,
                    onCameraIdle: onCameraIdle,
                    onMapCreated: (GoogleMapController controller) {
                      mapController = controller;
                      _manager!.setMapId(controller.mapId);
                      setState(() {
                        showSearchBar = true;
                      });
                    },
                  );
                });
      },
    );
  }

  void onCameraIdle() {

    
    MapService.getParkingPlaces(
            onCameraMoveLatLng.latitude, onCameraMoveLatLng.longitude)
        .then((parkings) {
      setState(() {
       
        parkingPlaces = parkings;
        _initClusterManager();
        _manager!.setMapId(mapController.mapId);
        _manager!.onCameraMove(CameraPosition(target: onCameraMoveLatLng));
      
      });
    });  _manager!.updateMap();
  }

  void onCameraMove(CameraPosition cameraPosition) {
    setState(() {
      _manager!.onCameraMove(cameraPosition);
      onCameraMoveLatLng = cameraPosition.target;
    });
  }

  void _onFiltersChange() async {
    if (PlaceService.areFiltersEnabled()) {
      await MapService.filterParkingPlaces().then((parkings) {
        setState(() {
          parkingPlaces = parkings;
          _initClusterManager();
          _manager!.setMapId(mapController.mapId);
        });
      });
    } else {
      if (await MapService.userHasNoRestrictions()) {}
      await MapService.getParkingPlacesAroundAddress().then((parkings) {
        setState(() {
          parkingPlaces = parkings;
          _initClusterManager();
          _manager!.setMapId(mapController.mapId);
        });
      });
    }
  }

  // when permissions are changed in app settings outside of app
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      if (MapService.wazeModeEnabled) {
        _endNavigationMode();
      }

      Geolocator.checkPermission().then(
        (value) => _updateLocationPermission(value),
      );
    }
  }

  void _updateLocationPermission(LocationPermission permission) {
    if (permission != LocatorService.locationPermission) {
      setState(
        () {
          LocatorService.updateLocationPermission(permission);
        },
      );
    }
  }

  void _initClusterManager() {
    setState(() {
      _manager = ClusterManager<ParkingPlace>(
          parkingPlaces, _updateParkingMarkers,
          markerBuilder: _markerBuilder);
    });
  }

  Future<Marker> Function(Cluster<ParkingPlace>) get _markerBuilder =>
      (cluster) async {
        int placesCount = 0;
        int freePlacesCount = 0;
        cluster.items.forEach((parkingPlace) {
          placesCount = placesCount + 1;
          if (parkingPlace.status == "FREE") {
            freePlacesCount = freePlacesCount + 1;
          }
        });
        Marker marker = Marker(
            markerId: MarkerId(cluster.getId()),
            anchor: const Offset(0.5, 0.5),
            position: cluster.location,
            icon: cluster.isMultiple
                ? await clusterIcon((150 + placesCount / 10).floor(),
                    freePlacesCount / placesCount,
                    text: placesCount.toString())
                : parkingPin,
            onTap: () async {
              _updateUserPosition();
              if (cluster.isMultiple) {
                if (await MapService.userCantZoomMore(mapController)) {
                  MapService.onFinalCircleTap(
                      _scaffoldKey,
                      mapController,
                      cluster,
                      currentLocation,
                      () => _startNavigationMode(cluster.location.latitude,
                          cluster.location.longitude));
                } else {
                  MapService.onMultipleCircleTap(
                    _scaffoldKey,
                    mapController,
                    cluster,
                    currentLocation,
                  );
                }
              } else {
                cluster.items.forEach(
                  (parking) {
                    MapService.onParkingTap(
                        _scaffoldKey,
                        parking,
                        currentLocation,
                        () => _startNavigationMode(
                            parking.latitude, parking.longitude));
                  },
                );
              }
            });

        return marker;
      };

  void _updateParkingMarkers(Set<Marker> updatedMarkers) {
    setState(
      () {
        markers = updatedMarkers;
      },
    );
  }

  void _onMoveToAddress() async {
    await MapService.getParkingPlacesAroundAddress().then((parkings) {
      parkingPlaces = parkings;
      _initClusterManager();
      _manager!.setMapId(mapController.mapId);
    });

    setState(() {});
  }

  void _onReportButtonTap() async {
    setState(() {
      _updateUserPosition();
    });

    final closerParkingAddress = await MapService.getAddressFromLatLng(
        currentLocation.latitude, currentLocation.longitude);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(15.0))),
          content: Container(
            height: 200,
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(50)),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Icon(
                      Icons.local_parking,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  'Signaler une place',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    Icon(
                      Icons.location_pin,
                      color: Colors.red,
                    ),
                    Flexible(
                      child: Text(
                        "Aux alentours de $closerParkingAddress",
                        overflow: TextOverflow.fade,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text(
                "ANNULER",
                style: TextStyle(fontSize: 15, color: Colors.grey.shade800),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                "SIGNALER ICI",
                style: TextStyle(fontSize: 15, color: Colors.green),
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                _onSignalerIciTap(LatLng(
                    currentLocation.latitude, currentLocation.longitude));
              },
            ),
          ],
        );
      },
    );
  }

  void _onSignalerIciTap(LatLng currentLocation) async {
    _updateUserPosition();
    try {
      var token = await storage.read(key: "token");
      await ReportService.addReport(
          currentLocation.latitude, currentLocation.longitude, token!);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          Timer(Duration(seconds: 2), () {
            Navigator.of(context).pop();
          });
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(15.0),
              ),
            ),
            content: Container(
              height: MediaQuery.of(context).size.height / 8,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(50)),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 50,
                      ),
                    ),
                  ),
                  Text(
                    'Place signalée',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } catch (e) {
      UserInterfaceDialog.displayAlertDialog(context, "Signalement impossible",
          "Une erreur est survenue. Veuillez réssayer plus tard.");
    }
  }

  Future<LatLng> _updateUserPosition() async {
    LatLng userPosition = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high)
        .then((position) {
      setState(() {
        currentLocation = LatLng(position.latitude, position.longitude);
      });
      return LatLng(position.latitude, position.longitude);
    });
    return LatLng(userPosition.latitude, userPosition.longitude);
  }

  void _startNavigationMode(double latitude, double longitude) async {
    try {
      var token = await storage.read(key: "token");

      Response response =
          await SearchService.addSearch(latitude, longitude, token!);

      if (response.statusCode == 201) {
        setState(() {
          CreateSearchResponse createSearchResponse =
              CreateSearchResponse.fromJson(jsonDecode(response.body));
          MapService.currentSearch = createSearchResponse;
        });
        MapService.navigationModeEnabled = true;
        positionStream =
            Geolocator.getPositionStream().listen((position) async {
          distanceToDestination =
              await MapService.getPreciseDistanceBetweenTwoPoints(
                  MapService.polylineCoordinates);
          setState(() {
            currentLocation = LatLng(position.latitude, position.longitude);
            mapController.animateCamera(CameraUpdate.zoomTo(17.5));
          });
        });

        compassStream = FlutterCompass.events?.listen((event) async {
          mapController
              .animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
                  target: LatLng(
                    currentLocation.latitude,
                    currentLocation.longitude,
                  ),
                  zoom: await mapController.getZoomLevel(),
                  bearing: event.heading!)));
        });
      }
    } catch (e) {
      UserInterfaceDialog.displayAlertDialog(context, "Navigation impossible",
          "Aucun signalement n'a été trouvé.");
    }
  }

  void _endNavigationMode() async {
    var token = await storage.read(key: "token");
    if (MapService.isUserNearDestination(currentLocation)) {
      showDialog(
        context: _scaffoldKey.currentContext!,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0))),
            title: Row(
              children: [
                Icon(
                  Icons.local_parking,
                  size: 30.0,
                  color: Colors.black,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    "Arrivé à destination",
                    overflow: TextOverflow.fade,
                  ),
                ),
              ],
            ),
            content: Text("Avez-vous trouvé votre place de parking ?"),
            actions: [
              TextButton(
                child: Text(
                  "NON",
                  style: TextStyle(
                      fontSize: 15,
                      color: const Color.fromARGB(255, 107, 107, 107)),
                ),
                onPressed: () async {
                  Navigator.of(context).pop();
                  try {
                    Response response = await SearchService.updateSearchStatus(
                        (MapService.currentSearch!.id), "failed", token!);

                    if (response.statusCode == 200) {
                      setState(() {
                        MapService.currentSearch = null;
                        UserInterfaceDialog.displaySnackBar(
                            context: context,
                            message:
                                "Votre réponse a bien été prise en compte, nous espérons que vous trouverez une autre place à proximité.",
                            messageType: MessageType.success);
                      });
                    } else {
                      UserInterfaceDialog.displayAlertDialog(context, "Erreur",
                          "Une erreur est survenue, votre réponse n'a pas été enregistrée.");
                    }
                  } catch (e) {
                    print(e);
                  }
                },
              ),
              TextButton(
                child: Text(
                  "OUI, J'Y SUIS !",
                  style: TextStyle(fontSize: 15, color: Colors.black),
                ),
                onPressed: () async {
                  Navigator.of(context).pop();
                  try {
                    Response response = await SearchService.updateSearchStatus(
                        MapService.currentSearch!.id, "successful", token!);

                    if (response.statusCode == 200) {
                      setState(() {
                        MapService.currentSearch = null;
                        UserInterfaceDialog.displaySnackBar(
                            context: context,
                            message:
                                "Votre stationnement a bien été enregistré !",
                            messageType: MessageType.success);
                      });
                    } else {
                      UserInterfaceDialog.displayAlertDialog(
                          context,
                          "Arrêt impossible",
                          "Une erreur est survenue, votre stationnement n'a pas été enregistré.");
                    }
                    _closeNavigationAndReplaceUser();
                  } catch (e) {
                    print(e);
                  }
                },
              ),
            ],
          );
        },
      );
      _closeNavigationAndReplaceUser();
    } else {
      showDialog(
        context: _scaffoldKey.currentContext!,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0))),
            title: Row(
              children: [
                Icon(
                  Icons.local_parking,
                  size: 30.0,
                  color: Colors.black,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    "Arrêt de la navigation",
                    overflow: TextOverflow.fade,
                  ),
                ),
              ],
            ),
            content: Text(
                "Il semblerait que vous ne soyez pas arrivé à destination, souhaitez-vous abandonner ?"),
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
                  "OUI, J'ABANDONNE'",
                  style: TextStyle(fontSize: 15, color: Colors.black),
                ),
                onPressed: () async {
                  Navigator.of(context).pop();
                  try {
                    Response response = await SearchService.updateSearchStatus(
                        MapService.currentSearch!.id, "abandoned", token!);

                    if (response.statusCode == 200) {
                      setState(() {
                        MapService.currentSearch = null;
                        UserInterfaceDialog.displaySnackBar(
                            context: context,
                            message:
                                "La recherche de place a bien été annulée.",
                            messageType: MessageType.success);
                      });

                      _closeNavigationAndReplaceUser();
                    } else {
                      UserInterfaceDialog.displayAlertDialog(
                          context,
                          "Arrêt impossible",
                          "Une erreur est survenue, il n'est pas possible d'annuler la recherche de place.");
                    }
                  } catch (e) {
                    print(e);
                  }
                },
              ),
            ],
          );
        },
      );
    }
  }

  void _closeNavigationAndReplaceUser() {
    setState(() {
      compassStream?.cancel();
      positionStream?.cancel();
      MapService.navigationModeEnabled = false;
      MapService.wazeModeEnabled = false;

      MapService.moveToCurrentLocation(mapController, context);

      PlaceService.clearPlacesFilters();

      MapService.getParkingPlaces(
              currentLocation.latitude, currentLocation.longitude)
          .then((parkings) {
        parkingPlaces = parkings;
        _initClusterManager();
        _manager!.setMapId(mapController.mapId);
      });
    });
    mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(
        currentLocation.latitude,
        currentLocation.longitude,
      ),
      zoom: 15,
      bearing: 0.0,
    )));
  }
}
