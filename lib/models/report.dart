import 'package:m2p/models/associated_parking_place.dart';

class Report {
  final String id;
  final String userId;
  final String createdDate;
  final AssociatedParkingPlace associatedParkingPlace;
  final String status;

  Report({
    required this.id,
    required this.userId,
    required this.createdDate,
    required this.associatedParkingPlace,
    required this.status,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    String id = json["id"];
    String userId = json["userId"];
    String createdDate = json["createdDate"];
    AssociatedParkingPlace associatedParkingPlace = AssociatedParkingPlace.fromJson(json["associatedParkingPlace"]);
    String status = json["status"];

    return Report(
      id: id,
      userId: userId,
      createdDate: createdDate,
      associatedParkingPlace: associatedParkingPlace,
      status: status,
    );
  }

  @override
  String toString() {
    return 'Report{id: $id, userId: $userId, createdDate: $createdDate, associatedParkingPlace: $associatedParkingPlace, status: $status}';
  }
}