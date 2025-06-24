class VehicleDetailModel {
  final String id;
  final String name;
  final String imageUrl;

  VehicleDetailModel({
    required this.id,
    required this.name,
    required this.imageUrl,
  });

  factory VehicleDetailModel.fromJson(Map<String, dynamic> json) {
    return VehicleDetailModel(
      id: json['id'],
      name: json['name'],
      imageUrl: json['image'] is Map<String, dynamic>
          ? json['image']['publicURL'] ?? ''
          : (json['imageUrl'] ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'imageUrl': imageUrl};
  }

  Map<String, dynamic> toDbJson() {
    return {'id': id, 'name': name, 'imageUrl': imageUrl};
  }

  factory VehicleDetailModel.fromDbJson(Map<String, dynamic> json) {
    return VehicleDetailModel(
      id: json['id'],
      name: json['name'],
      imageUrl: json['imageUrl'],
    );
  }
}
