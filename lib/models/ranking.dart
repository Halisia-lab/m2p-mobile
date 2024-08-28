import 'page.dart';
import 'rank.dart';

class RankingModel {
  final List<Rank> ranks;
  final Page page;

  RankingModel({
    required this.ranks,
    required this.page,
  });

  factory RankingModel.fromJson(Map<String, dynamic> json) {
    var rankObjsJson = json['items'] as List;
    List<Rank> ranks =
    rankObjsJson.map((rankJson) => Rank.fromJson(rankJson)).toList();
    Page page = Page.fromJson(json["page"]);

    return RankingModel(
      ranks: ranks,
      page: page,
    );
  }

  @override
  String toString() {
    return 'Ranking{ranks: $ranks, page: $page}';
  }
}
