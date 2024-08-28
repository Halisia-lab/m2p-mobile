import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../exceptions/not_found.exception.dart';
import '../exceptions/unauthorized.exception.dart';
import '../models/parking_place.dart';

class ParkingPlacesService {
  static String _apiUrl = dotenv.env['API_URL'].toString();
  static String _baseUrl = "https://api.map2place.com/map2place/v1/parkingPlaces";

  static Future<ParkingPlace> getParkingPlaceById(
      String parkingPlaceId, String token) async {
    final response = await http.get(
      Uri.parse("$_baseUrl/$parkingPlaceId"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode != 200) {
      switch (response.statusCode) {
        case 400:
          throw Exception('Bad request');
        case 401:
          throw UnauthorizedException('Unauthorized');
        case 404:
          throw NotFoundException('Not Found');
        case 429:
          throw Exception('Too Many Request');
        case 500:
          throw Exception('Internal Server Error');
        case 503:
          throw Exception('Service Unavailable');
        default:
          throw NotFoundException('Not Found');
      }
    }
    final responseData = json.decode(response.body);
    return ParkingPlace.fromJson(responseData);
  }

  static Future<List<ParkingPlace>> getParkingPlaces(
      String token, double latitude, double longitude) async {
    final response = await http.get(
      Uri.parse("$_baseUrl?latitude=$latitude&longitude=$longitude"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      switch (response.statusCode) {
        case 400:
          throw Exception('Bad request');
        case 401:
          throw UnauthorizedException('Unauthorized');
        case 404:
          throw NotFoundException('Not Found');
        case 429:
          throw Exception('Too Many Request');
        case 500:
          throw Exception('Internal Server Error');
        case 503:
          throw Exception('Service Unavailable');
      }
    }

    final responseData = json.decode(response.body);
    final List<dynamic> parkingPlaces = responseData["items"];

    final List<ParkingPlace> result = [];
    parkingPlaces.forEach(
      (jsonObject) {
        result.add(
          ParkingPlace.fromJson(jsonObject),
        );
      },
    );
    return result;
  }

  static dynamic getPriorityRegime(String priorityRegime) {
    switch (priorityRegime) {
      case "PAYANT_MIXTE":
        return ListTile(
          leading: Icon(
            Icons.euro,
            color: Colors.orange,
          ),
          title: Text("Payant"),
        );
      case "GRATUIT":
        return ListTile(
          leading: Icon(
            Icons.euro,
            color: Colors.green,
          ),
          title: Text("Gratuit"),
        );
      case "DEUX_ROUES":
        return ListTile(
          leading: Icon(
            Icons.directions_bike,
            color: Colors.black,
          ),
          title: Text("Deux roues"),
        );
      case "LIVRAISON":
        return ListTile(
          leading: Icon(
            Icons.fire_truck_outlined,
            color: Colors.amber,
          ),
          title: Text("Livraison"),
        );
      case "ELECTRIQUE":
        return ListTile(
          leading: Icon(
            Icons.electric_car,
            color: Colors.blue,
          ),
          title: Text("Electrique"),
        );
      case "LOCATION":
        return ListTile(
          leading: Icon(
            Icons.car_rental,
            color: Colors.grey,
          ),
          title: Text("Parking de Location"),
        );
      case "GIG_GIC":
        return ListTile(
          leading: Icon(
            Icons.personal_injury,
            color: Colors.blue,
          ),
          title: Text("Parking handicapé"),
        );
      default:
        return Container();
    }
  }
}
