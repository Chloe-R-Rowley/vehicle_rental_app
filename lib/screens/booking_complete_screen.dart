import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:vehicle_rental_app/models/step_data_db.dart';
import 'package:vehicle_rental_app/screens/form_screens/step_1_screen.dart';

class BookingDetails {
  final String firstName;
  final String lastName;
  final int numberOfWheels;
  final String vehicleType;
  final String modelName;
  final String modelImage;
  final DateTimeRange rentalDates;

  BookingDetails({
    required this.firstName,
    required this.lastName,
    required this.numberOfWheels,
    required this.vehicleType,
    required this.modelName,
    required this.modelImage,
    required this.rentalDates,
  });
}

class BookingCompleteScreen extends StatefulWidget {
  const BookingCompleteScreen({super.key});

  @override
  State<BookingCompleteScreen> createState() => _BookingCompleteScreenState();
}

class _BookingCompleteScreenState extends State<BookingCompleteScreen> {
  bool _animationDone = false;
  bool _showDetails = false;
  BookingDetails? _bookingDetails;

  @override
  void initState() {
    super.initState();
    _loadBookingDetails();
  }

  Future<void> _loadBookingDetails() async {
    final firstNameData = await StepDataDB().getStepData('firstName');
    final lastNameData = await StepDataDB().getStepData('lastName');
    final wheelsData = await StepDataDB().getStepData('numberOfWheels');
    final vehicleTypeData = await StepDataDB().getStepData('vehicleType');
    final modelNameData = await StepDataDB().getStepData('modelName');
    final modelImageData = await StepDataDB().getStepData('modelImage');
    final rentalStartData = await StepDataDB().getStepData('rentalStart');
    final rentalEndData = await StepDataDB().getStepData('rentalEnd');
    if (firstNameData != null &&
        lastNameData != null &&
        wheelsData != null &&
        vehicleTypeData != null &&
        modelNameData != null &&
        modelImageData != null &&
        rentalStartData != null &&
        rentalEndData != null) {
      setState(() {
        _bookingDetails = BookingDetails(
          firstName: firstNameData.value,
          lastName: lastNameData.value,
          numberOfWheels: int.tryParse(wheelsData.value) ?? 0,
          vehicleType: vehicleTypeData.value,
          modelName: modelNameData.value,
          modelImage: modelImageData.value,
          rentalDates: DateTimeRange(
            start: DateTime.parse(rentalStartData.value),
            end: DateTime.parse(rentalEndData.value),
          ),
        );
      });
    }
  }

  void _onLottieLoaded(Duration duration) {
    Future.delayed(duration, () async {
      if (mounted) {
        setState(() {
          _animationDone = true;
        });
        await Future.delayed(const Duration(milliseconds: 150));
        if (mounted) {
          setState(() {
            _showDetails = true;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 149, 255),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: _animationDone
              ? AnimatedOpacity(
                  opacity: _showDetails ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeIn,
                  child: _bookingDetails == null
                      ? const CircularProgressIndicator()
                      : _buildDetails(context, _bookingDetails!),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Lottie.asset(
                      'assets/animations/booking_completed_animation.json',
                      height: 250,
                      repeat: false,
                      onLoaded: (composition) {
                        _onLottieLoaded(composition.duration);
                      },
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Booking Complete!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildDetails(BuildContext context, BookingDetails bookingDetails) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset('assets/logo/logo.png', height: 100),
        const SizedBox(height: 32),
        const Text(
          'Booking Complete!',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 32),
        Card(
          color: Colors.white.withOpacity(0.12),
          elevation: 0,
          margin: const EdgeInsets.all(0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildIconDetailRow(
                  Icons.person,
                  'Name',
                  '${bookingDetails.firstName} ${bookingDetails.lastName}',
                ),
                const Divider(color: Colors.white24, thickness: 1, height: 8),
                _buildIconDetailRow(
                  Icons.donut_large,
                  'Number of Wheels',
                  bookingDetails.numberOfWheels.toString(),
                ),
                const Divider(color: Colors.white24, thickness: 1, height: 8),
                _buildIconDetailRow(
                  Icons.directions_car,
                  'Vehicle Type',
                  bookingDetails.vehicleType,
                ),
                const Divider(color: Colors.white24, thickness: 1, height: 8),
                Text(
                  'Model :',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          bookingDetails.modelImage,
                          height: 60,
                          width: 60,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                                Icons.directions_car,
                                color: Colors.white,
                                size: 40,
                              ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          bookingDetails.modelName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const Divider(color: Colors.white24, thickness: 1, height: 8),
                Text(
                  'Rental Dates :',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildIconDetailRow(
                  Icons.calendar_today,
                  'Start Date',
                  DateFormat(
                    'MMM d, yyyy',
                  ).format(bookingDetails.rentalDates.start),
                ),
                const Divider(color: Colors.white24, thickness: 1, height: 8),
                _buildIconDetailRow(
                  Icons.event_available,
                  'End Date',
                  DateFormat(
                    'MMM d, yyyy',
                  ).format(bookingDetails.rentalDates.end),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
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
            onPressed: () async {
              await StepDataDB().clearAll();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const Step1Screen()),
                (route) => false,
              );
            },
            child: const Text(
              'Back to Home',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIconDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(6),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
