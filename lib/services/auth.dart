import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:m2p/models/user_dto.dart';

import '../exceptions/account_disabled.exception.dart';
import '../exceptions/email_unverified.exception.dart';
import '../exceptions/wrong_credentials.exception.dart';
import '../exceptions/conflict.exception.dart';
import '../exceptions/not_found.exception.dart';
import '../exceptions/unauthorized.exception.dart';

class AuthService {
  static String _apiUrl = dotenv.env['API_URL'].toString();
  static String _baseUrl = "https://api.map2place.com/map2place/v1/auth";

  static Future login(String email, String password) async {
    final response = await http.post(
      Uri.parse("$_baseUrl/login"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'login': email,
        'password': password,
      }),
    );
    if (response.statusCode != 200) {
      switch (response.statusCode) {
        case 400:
          if (response.body.contains('Wrong credentials')) {
            throw WrongCredentialsException('Wrong credentials');
          } else if (response.body.contains('Account disabled login not possible')) {
            throw AccountDisabledException('Account disabled login not possible');
          } else if (response.body.contains('Email not verified')) {
            throw EmailUnverifiedException('Email not verified');
          }
          throw Exception('Bad request');
        case 401:
          throw UnauthorizedException('Unauthorized');
        case 404:
          throw NotFoundException('Not Found');
        case 429:
          throw Exception('Too Many Request');
        case 500:
          if (response.body.contains('User not found')) {
            throw WrongCredentialsException('Not Found');
          }
          throw Exception('Internal Server Error');
        case 503:
          throw Exception('Service Unavailable');
      }
    }
    final responseData = json.decode(response.body);
    return responseData;
  }

  static Future register(UserDto userDto) async {
    final request =
        http.MultipartRequest('POST', Uri.parse("$_baseUrl/signup"));
    final avatar = userDto.avatar;
    if (avatar != null) {
      request.files.add(await http.MultipartFile.fromPath('avatar', avatar.path));
    }
    request.fields['firstName'] = userDto.firstname;
    request.fields['lastName'] = userDto.lastname;
    request.fields['userName'] = userDto.username;
    request.fields['email'] = userDto.email;
    request.fields['password'] = userDto.password!;
    request.fields['vehicleType'] = userDto.vehicleType!;
    request.fields['vehicleUsage'] = userDto.vehicleUsage!;
    final birthday = userDto.birthday;
    if (birthday != null && !birthday.isEmpty) request.fields['birthday'] = birthday;
    final response = await request.send();
    if (response.statusCode != 201) {
      switch (response.statusCode) {
        case 400:
          var responseString = await response.stream.bytesToString();
          if (responseString.contains('User already exist')) {
            throw ConflictException('User already exist');
          }
          throw Exception('400: Bad request');
        case 401:
          throw Exception('401: Unauthorized');
        case 404:
          throw NotFoundException('404: Not Found');
        case 409:
          throw ConflictException('409: Conflict');
        case 429:
          throw Exception('429: Too Many Request');
        case 500:
          throw Exception('500: Internal Server Error');
        case 503:
          throw Exception('503: Service Unavailable');
      }
    }
  }

  static Future resetPassword(String email) async {
    final response = await http.post(
      Uri.parse("$_baseUrl/passwordReset"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
      }),
    );
    if (response.statusCode != 200) {
      switch (response.statusCode) {
        case 400:
          if (response.body.contains('user not found')) {
            throw NotFoundException('user not found');
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
}
