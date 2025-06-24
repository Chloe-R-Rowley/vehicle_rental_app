import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/vehicle_detail_model.dart';
import '../models/vehicle_app_db.dart';

abstract class VehicleDetailState {}

class VehicleDetailLoading extends VehicleDetailState {}

class VehicleDetailLoaded extends VehicleDetailState {
  final VehicleDetailModel vehicleDetail;
  VehicleDetailLoaded(this.vehicleDetail);
}

class VehicleDetailError extends VehicleDetailState {
  final String message;
  VehicleDetailError(this.message);
}

class VehicleModelsLoaded extends VehicleDetailState {
  final List<VehicleDetailModel> models;
  VehicleModelsLoaded(this.models);
}

class VehicleDetailBloc {
  final _stateController = StreamController<VehicleDetailState>();
  Stream<VehicleDetailState> get state => _stateController.stream;

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

  Future<void> fetchVehicleDetail(String vehicleId) async {
    _stateController.add(VehicleDetailLoading());
    final db = VehicleDb();
    if (await _isOnline()) {
      try {
        print(vehicleId);
        final response = await http.get(
          Uri.parse(
            'https://octalogic-test-frontend.vercel.app/api/v1/vehicles/$vehicleId',
          ),
        );
        print(response.body);
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          print(data);
          final vehicleDetail = VehicleDetailModel.fromJson(data['data']);
          await db.insertVehicleDetail(vehicleDetail);
          _stateController.add(VehicleDetailLoaded(vehicleDetail));
        } else {
          final cached = await db.getVehicleDetail(vehicleId);
          if (cached != null) {
            _stateController.add(VehicleDetailLoaded(cached));
          } else {
            _stateController.add(
              VehicleDetailError('Failed to load vehicle detail'),
            );
          }
        }
      } catch (e) {
        final cached = await db.getVehicleDetail(vehicleId);
        if (cached != null) {
          _stateController.add(VehicleDetailLoaded(cached));
        } else {
          _stateController.add(VehicleDetailError(e.toString()));
        }
      }
    } else {
      try {
        final cached = await db.getVehicleDetail(vehicleId);
        if (cached != null) {
          _stateController.add(VehicleDetailLoaded(cached));
        } else {
          _stateController.add(VehicleDetailError('No cached data available.'));
        }
      } catch (e) {
        _stateController.add(
          VehicleDetailError('Offline and failed to load cached data.'),
        );
      }
    }
  }

  Future<void> fetchVehicleModels(String vehicleTypeId) async {
    _stateController.add(VehicleDetailLoading());
    final db = VehicleDb();
    if (await _isOnline()) {
      try {
        final response = await http.get(
          Uri.parse(
            'https://octalogic-test-frontend.vercel.app/api/v1/vehicleTypes/$vehicleTypeId/vehicles',
          ),
        );
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final List<dynamic> modelsJson = data['data'];
          final models = modelsJson
              .map((json) => VehicleDetailModel.fromJson(json))
              .toList();
          _stateController.add(VehicleModelsLoaded(models));
        } else {
          _stateController.add(VehicleDetailError('Failed to load models'));
        }
      } catch (e) {
        _stateController.add(VehicleDetailError(e.toString()));
      }
    } else {
      _stateController.add(VehicleDetailError('Offline and no cached models.'));
    }
  }

  Future<void> fetchMultipleVehicleDetails(List<String> vehicleIds) async {
    _stateController.add(VehicleDetailLoading());
    final db = VehicleDb();
    List<VehicleDetailModel> models = [];
    for (final id in vehicleIds) {
      try {
        if (await _isOnline()) {
          final response = await http.get(
            Uri.parse(
              'https://octalogic-test-frontend.vercel.app/api/v1/vehicles/$id',
            ),
          );
          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            final vehicleDetail = VehicleDetailModel.fromJson(data['data']);
            await db.insertVehicleDetail(vehicleDetail);
            models.add(vehicleDetail);
          } else {
            final cached = await db.getVehicleDetail(id);
            if (cached != null) {
              models.add(cached);
            }
          }
        } else {
          final cached = await db.getVehicleDetail(id);
          if (cached != null) {
            models.add(cached);
          }
        }
      } catch (e) {}
    }
    if (models.isNotEmpty) {
      _stateController.add(VehicleModelsLoaded(models));
    } else {
      _stateController.add(VehicleDetailError('No models could be loaded.'));
    }
  }

  void dispose() {
    _stateController.close();
  }
}
