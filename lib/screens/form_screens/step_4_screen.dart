import 'package:flutter/material.dart';
import 'package:vehicle_rental_app/screens/form_screens/step_5_screen.dart';

class Step4Screen extends StatefulWidget {
  final String firstName;
  final String lastName;
  final int numberOfWheels;
  final String vehicleType;
  const Step4Screen({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.numberOfWheels,
    required this.vehicleType,
  });

  @override
  State<Step4Screen> createState() => _Step4ScreenState();
}

class _Step4ScreenState extends State<Step4Screen> {
  List<Map<String, String>> _modelOptions = [];
  String? _selectedModel;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchModelOptions();
  }

  Future<void> _fetchModelOptions() async {
    await Future.delayed(const Duration(seconds: 1));
    final options = <String, List<Map<String, String>>>{
      'Car': [
        {'name': 'Sedan', 'image': 'assets/images/cars/sedan.png'},
        {'name': 'SUV', 'image': 'assets/images/cars/suv.png'},
        {'name': 'Hatchback', 'image': 'assets/images/cars/hatchback.png'},
      ],
      'Motorcycle': [
        {'name': 'Sport Bike', 'image': 'assets/images/bikes/sportsbike.png'},
        {'name': 'Cruiser', 'image': 'assets/images/bikes/cruiser.png'},
      ],
      'Truck': [
        {'name': 'Pickup', 'image': 'assets/images/trucks/pickup.png'},
        {'name': 'Lorry', 'image': 'assets/images/trucks/lorry.png'},
      ],
      'Bus': [
        {'name': 'Mini Bus', 'image': 'assets/images/buses/minibus.png'},
        {'name': 'Coach', 'image': 'assets/images/buses/coach.png'},
      ],
      'Van': [
        {'name': 'Cargo Van', 'image': 'assets/images/vans/cargo.png'},
        {'name': 'Minivan', 'image': 'assets/images/vans/minivan.png'},
      ],
    };
    setState(() {
      _modelOptions = options[widget.vehicleType] ?? [];
      _loading = false;
    });
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
                    child: Text(
                      'Select Model',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (!_loading)
                    Column(
                      children: _modelOptions
                          .map(
                            (model) => Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 6.0,
                              ),
                              child: RadioListTile<String>(
                                value: model['name']!,
                                groupValue: _selectedModel,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedModel = value;
                                  });
                                },
                                title: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      model['name']!,
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Image.asset(
                                      model['image']!,
                                      height: 200,
                                      width: 200,
                                      fit: BoxFit.contain,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Icon(
                                                Icons.directions_car,
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
                      LinearProgressIndicator(
                        value: 0.8,
                        backgroundColor: Colors.white24,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                        minHeight: 8,
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color.fromARGB(255, 0, 149, 255),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _selectedModel != null
                          ? () {
                              final selectedModel = _modelOptions.firstWhere(
                                (m) => m['name'] == _selectedModel,
                              );
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Step5Screen(
                                    firstName: widget.firstName,
                                    lastName: widget.lastName,
                                    numberOfWheels: widget.numberOfWheels,
                                    vehicleType: widget.vehicleType,
                                    modelName: selectedModel['name']!,
                                    modelImage: selectedModel['image']!,
                                  ),
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
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          if (_loading)
            Container(
              color: const Color.fromARGB(180, 0, 149, 255),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
