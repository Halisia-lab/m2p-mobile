class Vehicle {
  final int id;
  final String usage;
  final String type;
  final String? brand;
  final String? model;

  Vehicle({
    required this.id,
    required this.usage,
    required this.type,
    this.brand,
    this.model,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    int id = json['id'];
    String usage = json['usage'];
    String type = json['type'];
    String brand = json['brand'] ?? "";
    String model = json['model'] ?? "";

    return Vehicle(
      id: id,
      usage: usage,
      type: type,
      brand: brand,
      model: model,
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "usage": usage,
    "type": type
  };

  @override
  String toString() {
    return 'Vehicle{id: $id, usage: $usage, type: $type, brand: $brand, model: $model}';
  }
}