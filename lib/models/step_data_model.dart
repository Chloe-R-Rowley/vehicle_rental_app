class StepData {
  final int? id;
  final String key;
  final String value;

  StepData({this.id, required this.key, required this.value});

  Map<String, dynamic> toMap() {
    return {'id': id, 'key': key, 'value': value};
  }

  factory StepData.fromMap(Map<String, dynamic> map) {
    return StepData(
      id: map['id'] as int?,
      key: map['key'] as String,
      value: map['value'] as String,
    );
  }
}
