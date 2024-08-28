import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../exceptions/not_found.exception.dart';
import '../exceptions/unauthorized.exception.dart';
import '../models/ranking.dart';
import '../models/scores.dart';

class ScoreService {
  static String _apiUrl = dotenv.env['API_URL'].toString();
  static String _baseUrl = "https://api.map2place.com/map2place/v1/scores";

  static Future getUsersRanking(
      String token, int pageNumber, int pageSize) async {
    final response = await http.get(
      Uri.parse("$_baseUrl/ranking?pageNumber=$pageNumber&pageSize=$pageSize"),
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
    final RankingModel ranking = RankingModel.fromJson(responseData);
    return ranking;
  }

  static getUserScore(String token, int pageSize, int pageNumber) async {
    final response = await http.get(
      Uri.parse(
          "$_baseUrl/user?pageSize=$pageSize&pageNumber=$pageNumber"),
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
    final Scores scores = Scores.fromJson(responseData);
    return scores;
  }
}