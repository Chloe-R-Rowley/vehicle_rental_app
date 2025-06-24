import 'dart:convert';

class VehicleTypeModel {
  final String id;
  final String name;
  final int wheels;
  final String type;
  final List<Vehicle> vehicles;

  VehicleTypeModel({
    required this.id,
    required this.name,
    required this.wheels,
    required this.type,
    required this.vehicles,
  });

  factory VehicleTypeModel.fromJson(Map<String, dynamic> json) {
    return VehicleTypeModel(
      id: json['id'],
      name: json['name'],
      wheels: json['wheels'],
      type: json['type'],
      vehicles:
          (json['vehicles'] as List<dynamic>?)
              ?.map((v) => Vehicle.fromJson(v))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'wheels': wheels,
      'type': type,
      'vehicles': vehicles.map((v) => v.toJson()).toList(),
    };
  }

  Map<String, dynamic> toDbJson() {
    return {
      'id': id,
      'name': name,
      'wheels': wheels,
      'type': type,
      'vehicles': jsonEncode(vehicles.map((v) => v.toJson()).toList()),
    };
  }

  factory VehicleTypeModel.fromDbJson(Map<String, dynamic> json) {
    return VehicleTypeModel(
      id: json['id'],
      name: json['name'],
      wheels: json['wheels'],
      type: json['type'],
      vehicles: (json['vehicles'] != null)
          ? (jsonDecode(json['vehicles']) as List<dynamic>)
                .map((v) => Vehicle.fromJson(v))
                .toList()
          : [],
    );
  }
}

class Vehicle {
  final String id;
  final String name;

  Vehicle({required this.id, required this.name});

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(id: json['id'], name: json['name']);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}
