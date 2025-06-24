import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

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
  final BookingDetails bookingDetails;
  const BookingCompleteScreen({super.key, required this.bookingDetails});

  @override
  State<BookingCompleteScreen> createState() => _BookingCompleteScreenState();
}

class _BookingCompleteScreenState extends State<BookingCompleteScreen> {
  bool _animationDone = false;
  bool _showDetails = false;

  void _onLottieLoaded(Duration duration) {
    Future.delayed(duration, () async {
      if (mounted) {
        setState(() {
          _animationDone = true;
        });
        // Optional: add a short delay before fade-in
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
                  child: _buildDetails(context),
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

  Widget _buildDetails(BuildContext context) {
    final bookingDetails = widget.bookingDetails;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 32),
        Image.asset('assets/logo/logo.png', height: 200),
        const SizedBox(height: 24),
        Text(
          'Booking Complete!',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        _buildDetailRow('First Name', bookingDetails.firstName),
        _buildDetailRow('Last Name', bookingDetails.lastName),
        _buildDetailRow(
          'Number of Wheels',
          bookingDetails.numberOfWheels.toString(),
        ),
        _buildDetailRow('Vehicle Type', bookingDetails.vehicleType),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Model',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.10),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Image.asset(
                bookingDetails.modelImage,
                height: 80,
                width: 80,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.directions_car, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  bookingDetails.modelName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildDetailRow(
          'Rental Dates',
          '${DateFormat('MMM d, yyyy').format(bookingDetails.rentalDates.start)} → ${DateFormat('MMM d, yyyy').format(bookingDetails.rentalDates.end)}',
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
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text(
              'Back to Home',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
