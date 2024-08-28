import 'page.dart';
import 'report.dart';

class Reports {
  final List<Report> reports;
  final Page page;

  Reports({
    required this.reports,
    required this.page,
  });

  factory Reports.fromJson(Map<String, dynamic> json) {
    var reportObjsJson = json['items'] as List;
    List<Report> reports =
        reportObjsJson.map((reportJson) => Report.fromJson(reportJson)).toList();
    Page page = Page.fromJson(json["page"]);

    return Reports(
      reports: reports,
      page: page,
    );
  }

  @override
  String toString() {
    return 'Reports{reports: $reports, page: $page}';
  }
}