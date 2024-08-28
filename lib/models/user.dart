class User {
  final int id;
  final String firstname;
  final String lastname;
  final String username;
  final String role;
  final String email;
  final String? birthday;
  final String createDate;
  final int vehicleId;
  final String avatar;
  final int points;
  final int level;

  User({
    required this.id,
    required this.firstname,
    required this.lastname,
    required this.username,
    required this.role,
    required this.email,
    required this.birthday,
    required this.createDate,
    required this.vehicleId,
    required this.avatar,
    required this.points,
    required this.level,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    int id = json["id"];
    String firstname = json["firstName"];
    String lastname = json["lastName"];
    String username = json["userName"];
    String role = json["role"];
    String email = json["email"];
    String createDate = json["createDate"];
    String birthday = json["birthday"] ?? "";
    int vehicleId = json["vehicleId"];
    String avatar = json["avatar"];
    int points = json["points"] ?? 0;
    int level = json["level"] ?? 0;

    return User(
        id: id,
        firstname: firstname,
        lastname: lastname,
        username: username,
        role: role,
        email: email,
        createDate: createDate,
        birthday: birthday,
        vehicleId: vehicleId,
        avatar: avatar,
        points: points,
        level: level);
  }

  @override
  String toString() {
    return 'User{firstname: $firstname, lastname: $lastname, username: $username, role: $role, email: $email, birthday: $birthday, createDate: $createDate, vehicleId: $vehicleId, avatar: $avatar, points: $points, level: $level}';
  }
}
