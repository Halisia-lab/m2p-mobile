import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../exceptions/not_found.exception.dart';
import '../exceptions/unauthorized.exception.dart';
import '../models/search.dart';
import '../models/searches.dart';

class SearchService {
  static String _apiUrl = dotenv.env['API_URL'].toString();
  static String _baseUrl = "https://api.map2place.com/map2place/v1/searches";
  

  static Future getUserSearches(
      String token, int pageNumber, int pageSize) async {
    final response = await http.get(
      Uri.parse("$_baseUrl/users/user?pageNumber=$pageNumber&pageSize=$pageSize"),
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
    final Searches searches = Searches.fromJson(responseData);
    return searches;
  }

  static Future getSearchById(
      String token, int searchId) async {
    final response = await http.get(
      Uri.parse("$_baseUrl/$searchId"),
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
    final search = Search.fromJson(responseData);
    return search;
  }

   static Future addSearch(
      double latitude, double longitude, String token) async {

    final response = await http.post(
      Uri.parse("$_baseUrl"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, dynamic>{
        "latitude": latitude,
        "longitude": longitude,
      },),
    );
    if (response.statusCode != 201) {
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
    return response;
  }


   static Future updateSearchStatus(
      int searchId, String status, String token) async {

    final response = await http.patch(
      Uri.parse("$_baseUrl/search/status"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, dynamic>{
        'searchId':searchId,
        'newStatus':status,
      }),
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
    return response;
  }
}
