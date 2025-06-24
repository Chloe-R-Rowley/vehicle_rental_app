import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/vehicle_detail_model.dart';

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

  Future<void> fetchMultipleVehicleDetails(List<String> vehicleIds) async {
    _stateController.add(VehicleDetailLoading());
    List<VehicleDetailModel> models = [];
    for (final id in vehicleIds) {
      try {
        final response = await http.get(
          Uri.parse(
            'https://octalogic-test-frontend.vercel.app/api/v1/vehicles/$id',
          ),
        );
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final vehicleDetail = VehicleDetailModel.fromJson(data['data']);
          models.add(vehicleDetail);
        }
      } catch (e) {
        _stateController.add(VehicleDetailError(e.toString()));
      }
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
