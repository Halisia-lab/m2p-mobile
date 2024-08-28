import 'associated_report.dart';

class Search {
  final String id;
  final String userId;
  final String createdDate;
  final AssociatedReport associatedReport;
  final String status;

  Search({
    required this.id,
    required this.userId,
    required this.createdDate,
    required this.associatedReport,
    required this.status,
  });

  factory Search.fromJson(Map<String, dynamic> json) {
    String id = json["id"];
    String userId = json["userId"];
    String createdDate = json["createdDate"];
    AssociatedReport associatedReport = AssociatedReport.fromJson(json["associatedReport"]);
    String status = json["status"];

    return Search(
      id: id,
      userId: userId,
      createdDate: createdDate,
      associatedReport: associatedReport,
      status: status,
    );
  }

  @override
  String toString() {
    return 'Search{id: $id, userId: $userId, createdDate: $createdDate, associatedReport: $associatedReport, status: $status}';
  }
}