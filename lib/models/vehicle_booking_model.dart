class BookingModel {
  final String id;
  final String vehicleId;
  final DateTime startDate;
  final DateTime endDate;

  BookingModel({
    required this.id,
    required this.vehicleId,
    required this.startDate,
    required this.endDate,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'],
      vehicleId: json['vehicleId'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
    );
  }
}
