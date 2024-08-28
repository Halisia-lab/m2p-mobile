import 'dart:io';

class UserDto {
  final String firstname;
  final String lastname;
  final String username;
  String? password;
  final String email;
  final String? birthday;
  final File? avatar;
  String? vehicleType;
  String? vehicleUsage;

  UserDto({
    required this.firstname,
    required this.lastname,
    required this.username,
    this.password,
    required this.email,
    required this.birthday,
    required this.avatar,
    this.vehicleType,
    this.vehicleUsage,
  });

  void updateVehicle(String vehicleType, String vehicleUsage) {
    this.vehicleType = vehicleType;
    this.vehicleUsage = vehicleUsage;
  }

  Map<String, dynamic> toJson() => {
    "firstName": firstname,
    "lastName": lastname,
    "userName": username,
    "password": password,
    "email": email,
    "birthday": birthday,
    "avatar": avatar,
    "vehicleType": vehicleType,
    "vehicleUsage": vehicleUsage,
  };
}