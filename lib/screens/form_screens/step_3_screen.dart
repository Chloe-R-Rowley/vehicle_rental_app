import 'package:flutter/material.dart';
import 'dart:async';
import 'package:vehicle_rental_app/bloc/vehicle_type_bloc.dart';
import 'package:vehicle_rental_app/models/vehicle_type_model.dart';
import 'package:vehicle_rental_app/screens/form_screens/step_4_screen.dart';

class Step3Screen extends StatefulWidget {
  final String firstName;
  final String lastName;
  final int numberOfWheels;
  const Step3Screen({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.numberOfWheels,
  });

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
    _bloc.fetchVehicleTypes();
    _blocSubscription = _bloc.state.listen((state) {
      if (!mounted) return;
      setState(() {
        if (state is VehicleTypeLoading) {
          _loading = true;
          _error = null;
        } else if (state is VehicleTypeLoaded) {
          _loading = false;
          _error = null;
          _vehicleTypes = state.vehicleTypes
              .where((e) => e.wheels == widget.numberOfWheels)
              .toList();
        } else if (state is VehicleTypeError) {
          _loading = false;
          _error = state.message;
        }
      });
    });
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
                      child: Text(
                        _error!,
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    )
                  else if (_vehicleTypes.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Text(
                        'No vehicle types found for ${widget.numberOfWheels} wheels.',
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
                            ? () {
                                final selectedType = _vehicleTypes.firstWhere(
                                  (e) => e.id == _selectedVehicleTypeId,
                                );
                                final vehicleIds = selectedType.vehicles
                                    .map((v) => v.id)
                                    .toList();
                                Navigator.of(context).push(
                                  PageRouteBuilder(
                                    pageBuilder:
                                        (
                                          context,
                                          animation,
                                          secondaryAnimation,
                                        ) => Step4Screen(
                                          firstName: widget.firstName,
                                          lastName: widget.lastName,
                                          numberOfWheels: widget.numberOfWheels,
                                          vehicleType:
                                              _selectedVehicleTypeName!,
                                          vehicleTypeId:
                                              _selectedVehicleTypeId!,
                                          vehicleIds: vehicleIds,
                                        ),
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
