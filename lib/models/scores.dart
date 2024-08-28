import 'page.dart';
import 'score.dart';

class Scores {
  final List<Score> scores;
  final Page page;

  Scores({
    required this.scores,
    required this.page,
  });

  factory Scores.fromJson(Map<String, dynamic> json) {
    var scoreObjsJson = json['items'] as List;
    List<Score> scores =
    scoreObjsJson.map((scoreJson) => Score.fromJson(scoreJson)).toList();
    Page page = Page.fromJson(json["page"]);

    return Scores(
      scores: scores,
      page: page,
    );
  }
}