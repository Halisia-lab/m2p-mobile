import 'package:m2p/models/parking_place.dart';

class CreateSearchResponse {
  final int id;
  final int userId;
  final String createdDate;
  final int associatedReportId;
  final String status;
  final ParkingPlace parkingPlace;

  CreateSearchResponse(
      {required this.id,
      required this.userId,
      required this.createdDate,
      required this.associatedReportId,
      required this.status,
      required this.parkingPlace});

  factory CreateSearchResponse.fromJson(Map<String, dynamic> json) {
    int id = json["id"];
    int userId = json["userId"];
    String createdDate = json["createdDate"];
    int associatedReportId = json["associatedReportId"];
    ParkingPlace parkingPlace = ParkingPlace.fromJson(json["parkingPlace"]);
    String status = json["status"];

    return CreateSearchResponse(
      id: id,
      userId: userId,
      createdDate: createdDate,
      associatedReportId: associatedReportId,
      status: status,
      parkingPlace: parkingPlace,
    );
  }

  @override
  String toString() {
    return 'CreateSearchResponse{id: $id, userId: $userId, createdDate: $createdDate, associatedReportId: $associatedReportId, status: $status, parkingPlace: $parkingPlace}';
  }
}
