import 'package:flutter/material.dart';
import 'dart:async';
import 'package:vehicle_rental_app/bloc/vehicle_type_bloc.dart';
import 'package:vehicle_rental_app/models/vehicle_type_model.dart';
import 'package:vehicle_rental_app/screens/form_screens/step_4_screen.dart';
import 'package:vehicle_rental_app/models/step_data_db.dart';
import 'package:vehicle_rental_app/models/step_data_model.dart';

class Step3Screen extends StatefulWidget {
  const Step3Screen({super.key});

  @override
  State<Step3Screen> createState() => _Step3ScreenState();
}

class _Step3ScreenState extends State<Step3Screen>
    with SingleTickerProviderStateMixin {
  List<VehicleTypeModel> _vehicleTypes = [];
  String? _selectedVehicleTypeId;
  String? _selectedVehicleTypeName;
  bool _loading = true;
  String? _error;
  int? _numberOfWheels;

  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  late VehicleTypeBloc _bloc;
  StreamSubscription? _blocSubscription;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _progressAnimation = Tween<double>(begin: 0.4, end: 0.6).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );
    _bloc = VehicleTypeBloc();
    _blocSubscription = _bloc.state.listen((state) {
      if (!mounted) return;
      setState(() {
        if (state is VehicleTypeLoading) {
          _loading = true;
          _error = null;
        } else if (state is VehicleTypeLoaded) {
          _loading = false;
          _error = null;
          if (_numberOfWheels != null) {
            _vehicleTypes = state.vehicleTypes
                .where((e) => e.wheels == _numberOfWheels)
                .toList();
          }
        } else if (state is VehicleTypeError) {
          _loading = false;
          _error = state.message;
        }
      });
    });
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    final typeData = await StepDataDB().getStepData('vehicleType');
    final typeIdData = await StepDataDB().getStepData('vehicleTypeId');
    final wheelsData = await StepDataDB().getStepData('numberOfWheels');
    int? loadedWheels;
    if (wheelsData != null) {
      loadedWheels = int.tryParse(wheelsData.value);
    }
    setState(() {
      if (typeData != null && typeIdData != null) {
        _selectedVehicleTypeName = typeData.value;
        _selectedVehicleTypeId = typeIdData.value;
      }
      _numberOfWheels = loadedWheels;
    });
    if (loadedWheels != null) {
      _bloc.fetchVehicleTypes();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _progressController.status == AnimationStatus.dismissed) {
        _progressController.forward();
      }
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    _blocSubscription?.cancel();
    _bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 149, 255),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset('assets/logo/logo.png', height: 200),
                  const SizedBox(height: 32),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: _loading
                        ? Container(
                            height: 20,
                            width: 140,
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          )
                        : Text(
                            'Vehicle Type',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                  ),
                  const SizedBox(height: 8),
                  if (_loading)
                    ...List.generate(
                      1,
                      (index) => Container(
                        height: 48,
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    )
                  else if (_error != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Column(
                        children: [
                          Text(
                            _error!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color.fromARGB(
                                255,
                                0,
                                149,
                                255,
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 24,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                _loading = true;
                                _error = null;
                              });
                              _bloc.fetchVehicleTypes();
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  else if (_vehicleTypes.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Text(
                        'No vehicle types found for ${_numberOfWheels ?? ''} wheels.',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  else
                    Column(
                      children: _vehicleTypes
                          .map(
                            (type) => Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
                              child: RadioListTile<String>(
                                value: type.name,
                                groupValue: _selectedVehicleTypeName,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedVehicleTypeName = value;
                                    _selectedVehicleTypeId = type.id;
                                  });
                                },
                                title: Text(
                                  type.name,
                                  style: const TextStyle(color: Colors.white),
                                ),
                                activeColor: Colors.white,
                                tileColor: Colors.white.withOpacity(0.10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  const SizedBox(height: 32),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Step 3 of 5',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      AnimatedBuilder(
                        animation: _progressController,
                        builder: (context, child) {
                          return LinearProgressIndicator(
                            value: _progressAnimation.value,
                            backgroundColor: Colors.white24,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                            minHeight: 8,
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  if (_loading)
                    Container(
                      height: 48,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    )
                  else
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color.fromARGB(
                            255,
                            0,
                            149,
                            255,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _selectedVehicleTypeId != null
                            ? () async {
                                final selectedType = _vehicleTypes.firstWhere(
                                  (e) => e.id == _selectedVehicleTypeId,
                                );
                                final vehicleIds = selectedType.vehicles
                                    .map((v) => v.id)
                                    .toList();
                                // Store in SQLite
                                await StepDataDB().insertOrUpdateStepData(
                                  StepData(
                                    key: 'vehicleType',
                                    value: _selectedVehicleTypeName!,
                                  ),
                                );
                                await StepDataDB().insertOrUpdateStepData(
                                  StepData(
                                    key: 'vehicleTypeId',
                                    value: _selectedVehicleTypeId!,
                                  ),
                                );
                                await StepDataDB().insertOrUpdateStepData(
                                  StepData(
                                    key: 'vehicleIds',
                                    value: vehicleIds.toString(),
                                  ),
                                );
                                Navigator.of(context).push(
                                  PageRouteBuilder(
                                    pageBuilder:
                                        (
                                          context,
                                          animation,
                                          secondaryAnimation,
                                        ) => Step4Screen(),
                                    transitionsBuilder:
                                        (
                                          context,
                                          animation,
                                          secondaryAnimation,
                                          child,
                                        ) {
                                          const begin = Offset(1.0, 0.0);
                                          const end = Offset.zero;
                                          const curve = Curves.easeInOut;
                                          final tween = Tween(
                                            begin: begin,
                                            end: end,
                                          ).chain(CurveTween(curve: curve));
                                          return SlideTransition(
                                            position: animation.drive(tween),
                                            child: child,
                                          );
                                        },
                                  ),
                                );
                              }
                            : null,
                        child: const Text(
                          'Next',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
