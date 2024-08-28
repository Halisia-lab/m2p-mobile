import 'page.dart';
import 'search.dart';

class Searches {
  final List<Search> searches;
  final Page page;

  Searches({
    required this.searches,
    required this.page,
  });

  factory Searches.fromJson(Map<String, dynamic> json) {
    var searchObjsJson = json['items'] as List;
    List<Search> searches =
        searchObjsJson.map((searchJson) => Search.fromJson(searchJson)).toList();
    Page page = Page.fromJson(json["page"]);

    return Searches(
      searches: searches,
      page: page,
    );
  }

  @override
  String toString() {
    return 'Searches{searches: $searches, page: $page}';
  }
}
