import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocatorService {
  static LocationPermission locationPermission =
      LocationPermission.unableToDetermine;

        static bool isPermissionWaiting() {
    return locationPermission == LocationPermission.unableToDetermine; 
  }
  static bool isPermissionGranted() {
    return locationPermission == LocationPermission.always ||
        locationPermission == LocationPermission.whileInUse;
  }

  static void updateLocationPermission(
      LocationPermission newLocationPermission) {
    locationPermission = newLocationPermission;
  }

  static Future<Position> getUserCurrentLocation(BuildContext context) async {
    await Geolocator.requestPermission()
        .then(
      (value) {
        
      },
    )
        .onError((error, stackTrace) async {
      await Geolocator.requestPermission();
    });

    return await Geolocator.getCurrentPosition();
  }
}
