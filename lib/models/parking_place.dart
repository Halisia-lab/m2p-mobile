import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ParkingPlace with ClusterItem {
  final int id;
  final String priorityRegime;
  final String specialRegime;
  final String type;
  final int nombreOfPlaces;
  final String localisation;
  final String country;
  final String address;
  final String postcalCode;
  final String city;
  final double latitude;
  final double longitude;
  final String status;

  ParkingPlace({
    required this.id,
    required this.priorityRegime,
    required this.specialRegime,
    required this.type,
    required this.nombreOfPlaces,
    required this.localisation,
    required this.country,
    required this.address,
    required this.postcalCode,
    required this.city,
    required this.latitude,
    required this.longitude,
    required this.status,
  });

  factory ParkingPlace.fromJson(Map<String, dynamic> json) {
    int id = json["id"];
    String priorityRegime = json["priorityRegime"] ?? "";
    String specialRegime = json["specialRegime"] ?? "";
    String type = json["type"] ?? "";
    int nombreOfPlaces = json["numberOfPlaces"] ?? 0;
    String localisation = json["localisation"] ?? "";
    String country = json["country"] ?? "";
    String address = json["address"] ?? "";
    String postcalCode = json["postcalCode"] ?? "";
    String city = json["city"] ?? "";
    double latitude = json["latitude"] ?? "";
    double longitude = json["longitude"] ?? "";
    String status = json["status"] ?? "";

    return ParkingPlace(
        id: id,
        priorityRegime: priorityRegime,
        specialRegime: specialRegime,
        type: type,
        nombreOfPlaces: nombreOfPlaces,
        localisation: localisation,
        country: country,
        address: address,
        postcalCode: postcalCode,
        city: city,
        latitude: latitude,
        longitude: longitude,
        status: status);
  }

  @override
  String toString() {
    return "Id: $id, ParkingPlace{priorityRegime: $priorityRegime, specialRegime: $specialRegime, type: $type, nombreOfPlaces: $nombreOfPlaces, localisation: $localisation, country: $country, address: $address, postcalCode: $postcalCode, city: $city, latitude: $latitude, longitude: $longitude}";
  }

  @override
  LatLng get location => LatLng(latitude, longitude);
}
