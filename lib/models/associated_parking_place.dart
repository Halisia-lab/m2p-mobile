class AssociatedParkingPlace {
  final String address;
  final String postalCode;
  final String city;

  AssociatedParkingPlace({
    required this.address,
    required this.postalCode,
    required this.city,
  });

  factory AssociatedParkingPlace.fromJson(Map<String, dynamic> json) {
    String address = json['address'];
    String postalCode = json['postalCode'];
    String city = json['city'];

    return AssociatedParkingPlace(
      address: address,
      postalCode: postalCode,
      city: city,
    );
  }

  Map<String, dynamic> toJson() => {
        'address': address,
        'postalCode': postalCode,
        'city': city,
      };

  @override
  String toString() {
    return 'AssociatedParkingPlace{address: $address, postalCode: $postalCode, city: $city}';
  }
}
