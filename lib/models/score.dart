class Score {
  final int id;
  final int earnedPoints;
  final String createdDate;
  final String status;

  Score(
      {required this.id,
      required this.earnedPoints,
      required this.createdDate,
      required this.status});

  factory Score.fromJson(Map<String, dynamic> json) {
    int id = json["id"];
    int earnedPoints = json["earnedPoints"];
    String createdDate = json["createDate"];
    String status = json["status"];

    return Score(
        id: id,
        earnedPoints: earnedPoints,
        createdDate: createdDate,
        status: status);
  }

  @override
  String toString() {
    return "Score{id: $id, earnedPoints: $earnedPoints, createdDate: $createdDate, status: $status}";
  }
}
