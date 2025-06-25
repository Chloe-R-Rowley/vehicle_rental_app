import 'package:flutter/material.dart';
import 'package:vehicle_rental_app/screens/form_screens/step_5_screen.dart';
import 'package:vehicle_rental_app/bloc/vehicle_detail_bloc.dart';
import 'package:vehicle_rental_app/models/vehicle_detail_model.dart';
import 'package:vehicle_rental_app/models/step_data_db.dart';
import 'package:vehicle_rental_app/models/step_data_model.dart';

class Step4Screen extends StatefulWidget {
  const Step4Screen({super.key});

  @override
  State<Step4Screen> createState() => _Step4ScreenState();
}

class _Step4ScreenState extends State<Step4Screen>
    with SingleTickerProviderStateMixin {
  List<VehicleDetailModel> _models = [];
  String? _selectedModelId;
  bool _loading = true;
  String? _error;

  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  VehicleDetailBloc? _bloc;
  Stream<VehicleDetailState>? _blocStream;

  List<String> _vehicleIds = [];

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _progressAnimation = Tween<double>(begin: 0.6, end: 0.8).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );
    _loadAllDataAndFetchModels();
  }

  Future<void> _loadAllDataAndFetchModels() async {
    final vehicleIdsData = await StepDataDB().getStepData('vehicleIds');
    final modelIdData = await StepDataDB().getStepData('modelId');

    setState(() {
      if (vehicleIdsData != null) {
        final raw = vehicleIdsData.value;
        _vehicleIds = raw
            .replaceAll('[', '')
            .replaceAll(']', '')
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }
      if (modelIdData != null) {
        _selectedModelId = modelIdData.value;
      }
    });
    _bloc = VehicleDetailBloc();
    _blocStream = _bloc!.state;
    if (_vehicleIds.isNotEmpty) {
      _bloc!.fetchMultipleVehicleDetails(_vehicleIds);
      _blocStream!.listen((state) {
        if (!mounted) return;
        if (state is VehicleDetailLoading) {
          setState(() {
            _loading = true;
          });
        } else if (state is VehicleModelsLoaded) {
          setState(() {
            _loading = false;
            _models = state.models;
            _error = null;
          });
        } else if (state is VehicleDetailError) {
          setState(() {
            _loading = false;
            _error = state.message;
          });
        }
      });
    } else {
      setState(() {
        _loading = false;
        _error = 'No vehicle IDs found.';
      });
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
    _bloc?.dispose();
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
                            'Select Model',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                  ),
                  const SizedBox(height: 8),
                  if (_loading)
                    ...List.generate(
                      2,
                      (index) => Container(
                        height: 120,
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    )
                  else if (_error != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Text(
                        _error!,
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    )
                  else
                    Column(
                      children: _models
                          .map(
                            (model) => Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
                              child: RadioListTile<String>(
                                value: model.id,
                                groupValue: _selectedModelId,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedModelId = value;
                                  });
                                },
                                title: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(16),

                                      child: Image.network(
                                        model.imageUrl,
                                        height: 84,
                                        width: 110,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Icon(
                                                  Icons.directions_car,
                                                  color: Colors.white,
                                                ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      model.name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
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
                        'Step 4 of 5',
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
                        onPressed: _selectedModelId != null
                            ? () async {
                                final selectedModel = _models.firstWhere(
                                  (m) => m.id == _selectedModelId,
                                );
                                await StepDataDB().insertOrUpdateStepData(
                                  StepData(
                                    key: 'modelId',
                                    value: selectedModel.id,
                                  ),
                                );
                                await StepDataDB().insertOrUpdateStepData(
                                  StepData(
                                    key: 'modelName',
                                    value: selectedModel.name,
                                  ),
                                );
                                await StepDataDB().insertOrUpdateStepData(
                                  StepData(
                                    key: 'modelImage',
                                    value: selectedModel.imageUrl,
                                  ),
                                );
                                Navigator.of(context).push(
                                  PageRouteBuilder(
                                    pageBuilder:
                                        (
                                          context,
                                          animation,
                                          secondaryAnimation,
                                        ) => Step5Screen(),
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
