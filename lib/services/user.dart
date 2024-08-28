import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../exceptions/not_found.exception.dart';
import '../exceptions/unauthorized.exception.dart';
import '../exceptions/wrong_credentials.exception.dart';
import '../models/user.dart';
import '../models/user_dto.dart';

class UserService {
  static String _apiUrl = dotenv.env['API_URL'].toString();
  static String _baseUrl = "https://api.map2place.com/map2place/v1/users";

  static Future getUser(String token) async {
    final response = await http.get(
      Uri.parse("$_baseUrl/user"),
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
    final User user = User.fromJson(responseData);
    return user;
  }

  static Future deleteUser(String token) async {
    final response = await http.delete(
      Uri.parse("$_baseUrl/user"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode != 204) {
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
  }

  static Future updateUser(String token, UserDto userDto) async {
    final request = http.MultipartRequest('PATCH', Uri.parse("$_baseUrl"));
    request.headers['Content-Type'] = 'application/json; charset=UTF-8';
    request.headers['authorization'] = 'bearer $token';
    if (userDto.firstname.isNotEmpty)
      request.fields['firstName'] = userDto.firstname;
    if (userDto.lastname.isNotEmpty)
      request.fields['lastName'] = userDto.lastname;
    if (userDto.username.isNotEmpty)
      request.fields['userName'] = userDto.username;
    if (userDto.email.isNotEmpty) request.fields['email'] = userDto.email;
    if (userDto.birthday != null && userDto.birthday!.isNotEmpty)
      request.fields['birthday'] = userDto.birthday!;
    final avatar = userDto.avatar;
    if (avatar != null) {
      request.files.add(await http.MultipartFile.fromPath('avatar', avatar.path,
          contentType: MediaType('image', 'jpeg')));
    }
    final response = await request.send();
    if (response.statusCode != 200) {
      switch (response.statusCode) {
        case 400:
          throw Exception('400: Bad request');
        case 401:
          throw Exception('401: Unauthorized');
        case 404:
          throw Exception('404: Not Found');
        case 429:
          throw Exception('429: Too Many Request');
        case 500:
          throw Exception('500: Internal Server Error');
        case 503:
          throw Exception('503: Service Unavailable');
      }
    }
  }

  static Future updatePassword(
      String token, String currentPassword, String newPassword) async {
    final response = await http.put(
      Uri.parse("$_baseUrl/user/password"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, String>{
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      }),
    );
    if (response.statusCode != 200) {
      switch (response.statusCode) {
        case 400:
          if (response.body.contains('Wrong current password')) {
            throw WrongCredentialsException('Wrong current password');
          }
          throw Exception('400: Bad request');
        case 401:
          throw Exception('401: Unauthorized');
        case 404:
          throw Exception('404: Not Found');
        case 429:
          throw Exception('429: Too Many Request');
        case 500:
          throw Exception('500: Internal Server Error');
        case 503:
          throw Exception('503: Service Unavailable');
      }
    }
  }

  static Future<bool> isPremium(String token) async {
    User user = await getUser(token);
    return user.role == "PREMIUM" || user.role == "ADMIN";
  }

  static Future<int> getUserLevel(String token) async {
    User user = await getUser(token);
    return user.level;
  }

  static Future updateUserPremium(String token, bool premium) async {
    final response = await http.patch(
      Uri.parse("$_baseUrl/user"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, dynamic>{
        'premium': premium,
      }),
    );
    if (response.statusCode != 200) {
      switch (response.statusCode) {
        case 400:
          throw Exception('400: Bad request');
        case 401:
          throw Exception('401: Unauthorized');
        case 404:
          throw Exception('404: Not Found');
        case 429:
          throw Exception('429: Too Many Request');
        case 500:
          throw Exception('500: Internal Server Error');
        case 503:
          throw Exception('503: Service Unavailable');
      }
    }
  }
}
