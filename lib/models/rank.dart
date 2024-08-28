class Rank {
  final String userName;
  final int points;

  Rank({
    required this.userName,
    required this.points,
  });

  factory Rank.fromJson(Map<String, dynamic> json) {
    String userName = json["username"];
    int points = json["points"];

    return Rank(
      userName: userName,
      points: points,
    );
  }

  @override
  String toString() {
    return 'Rank{userName: $userName, points: $points}';
  }
}