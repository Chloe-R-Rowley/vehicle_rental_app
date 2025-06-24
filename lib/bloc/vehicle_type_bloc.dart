import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:vehicle_rental_app/models/vehicle_app_db.dart';
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

  Future<bool> _isOnline() async {
    try {
      final result = await http
          .get(Uri.parse('https://www.google.com'))
          .timeout(const Duration(seconds: 3));
      return result.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<void> fetchVehicleTypes() async {
    _stateController.add(VehicleTypeLoading());
    final db = VehicleDb();
    if (await _isOnline()) {
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
          await db.clearVehicleTypes();
          await db.insertVehicleTypes(vehicleTypes);
          _stateController.add(VehicleTypeLoaded(vehicleTypes));
        } else {
          final cached = await db.getVehicleTypes();
          if (cached.isNotEmpty) {
            _stateController.add(VehicleTypeLoaded(cached));
          } else {
            _stateController.add(
              VehicleTypeError('Failed to load vehicle types'),
            );
          }
        }
      } catch (e) {
        final cached = await db.getVehicleTypes();
        if (cached.isNotEmpty) {
          _stateController.add(VehicleTypeLoaded(cached));
        } else {
          _stateController.add(VehicleTypeError(e.toString()));
        }
      }
    } else {
      try {
        final cached = await db.getVehicleTypes();
        if (cached.isNotEmpty) {
          _stateController.add(VehicleTypeLoaded(cached));
        } else {
          _stateController.add(VehicleTypeError('No cached data available.'));
        }
      } catch (e) {
        _stateController.add(
          VehicleTypeError('Offline and failed to load cached data.'),
        );
      }
    }
  }

  void dispose() {
    _stateController.close();
  }
}
