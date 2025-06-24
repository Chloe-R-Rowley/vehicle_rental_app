import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/vehicle_type_model.dart';

abstract class VehicleTypeState {}

class VehicleTypeLoading extends VehicleTypeState {}

class VehicleTypeLoaded extends VehicleTypeState {
  final List<VehicleTypeModel> vehicleTypes;
  VehicleTypeLoaded(this.vehicleTypes);
}

class VehicleTypeError extends VehicleTypeState {
  final String message;
  VehicleTypeError(this.message);
}

class VehicleTypeBloc {
  final _stateController = StreamController<VehicleTypeState>();
  Stream<VehicleTypeState> get state => _stateController.stream;

  Future<void> fetchVehicleTypes() async {
    _stateController.add(VehicleTypeLoading());
    try {
      final response = await http.get(
        Uri.parse(
          'https://octalogic-test-frontend.vercel.app/api/v1/vehicleTypes',
        ),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> typesJson = data['data'];
        final vehicleTypes = typesJson
            .map((json) => VehicleTypeModel.fromJson(json))
            .toList();
        _stateController.add(VehicleTypeLoaded(vehicleTypes));
      } else {
        _stateController.add(VehicleTypeError('Failed to load vehicle types'));
      }
    } catch (e) {
      _stateController.add(VehicleTypeError('Network error: ' + e.toString()));
    }
  }

  void dispose() {
    _stateController.close();
  }
}
