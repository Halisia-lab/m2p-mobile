import 'associated_parking_place.dart';

class AssociatedReport {
  final String createdDate;
  final AssociatedParkingPlace associatedParkingPlace;
  final String status;

  AssociatedReport(
      {required this.createdDate,
      required this.associatedParkingPlace,
      required this.status});

  factory AssociatedReport.fromJson(Map<String, dynamic> json) {
    String createdDate = json['createdDate'];
    AssociatedParkingPlace associatedParkingPlace =
        AssociatedParkingPlace.fromJson(json['associatedParkingPlace']);
    String status = json['status'];

    return AssociatedReport(
        createdDate: createdDate,
        associatedParkingPlace: associatedParkingPlace,
        status: status);
  }

  Map<String, dynamic> toJson() => {
        'createdDate': createdDate,
        'associatedParkingPlace': associatedParkingPlace,
        'status': status,
      };

  @override
  String toString() {
    return 'AssociatedReport{createdDate: $createdDate, associatedParkingPlace: $associatedParkingPlace, status: $status}';
  }
}