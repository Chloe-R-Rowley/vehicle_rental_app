import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vehicle_rental_app/screens/booking_complete_screen.dart';
import '../../bloc/vehicle_booking_bloc.dart';
import '../../models/vehicle_booking_model.dart';

class Step5Screen extends StatefulWidget {
  final String firstName;
  final String lastName;
  final int numberOfWheels;
  final String vehicleType;
  final String modelId;
  final String modelName;
  final String modelImage;
  const Step5Screen({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.numberOfWheels,
    required this.vehicleType,
    required this.modelId,
    required this.modelName,
    required this.modelImage,
  });

  @override
  State<Step5Screen> createState() => _Step5ScreenState();
}

class _Step5ScreenState extends State<Step5Screen>
    with SingleTickerProviderStateMixin {
  bool _loading = false;
  DateTimeRange? _selectedRange;

  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  late BookingBloc _bookingBloc;
  List<BookingModel> _bookings = [];
  BookingState _bookingState = BookingLoading();

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _progressAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );
    _bookingBloc = BookingBloc();
    _fetchBookings();
  }

  void _fetchBookings() {
    _bookingBloc.fetchBookings(widget.modelId);
    _bookingBloc.state.listen((state) {
      if (!mounted) return;
      setState(() {
        _bookingState = state;
        if (state is BookingLoaded) {
          _bookings = state.bookings;
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
    _bookingBloc.dispose();
    super.dispose();
  }

  bool _isDateBooked(DateTime day) {
    for (final booking in _bookings) {
      if (!day.isBefore(booking.startDate) && !day.isAfter(booking.endDate)) {
        return true;
      }
    }
    return false;
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020, 1, 1),
      lastDate: DateTime(2026, 12, 31),
      selectableDayPredicate: (day, _, __) => !_isDateBooked(day),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color.fromARGB(255, 0, 149, 255),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      bool hasBooked = false;
      for (
        DateTime d = picked.start;
        !d.isAfter(picked.end);
        d = d.add(const Duration(days: 1))
      ) {
        if (_isDateBooked(d)) {
          hasBooked = true;
          break;
        }
      }
      if (hasBooked) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Selected range includes unavailable dates.',
              style: TextStyle(color: Colors.black),
            ),
            backgroundColor: Colors.white,
          ),
        );
        return;
      }
      setState(() {
        _selectedRange = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBookingLoading = _bookingState is BookingLoading;
    final isBookingError = _bookingState is BookingError;
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
                  const SizedBox(height: 24),
                  if (isBookingLoading) ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        height: 20,
                        width: 180,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        margin: const EdgeInsets.only(bottom: 8),
                      ),
                    ),
                    Container(
                      height: 80,
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ] else if (isBookingError)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        (_bookingState as BookingError).message,
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                      ),
                    )
                  else
                    Align(
                      alignment: Alignment.centerLeft,
                      child: _loading
                          ? Container(
                              height: 20,
                              width: 180,
                              decoration: BoxDecoration(
                                color: Colors.white24,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            )
                          : Text(
                              'Select Rental Dates',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  const SizedBox(height: 8),
                  if (_loading)
                    Container(
                      height: 80,
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    )
                  else if (!isBookingLoading)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: isBookingLoading || isBookingError
                              ? null
                              : _pickDateRange,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              vertical: 20,
                              horizontal: 20,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                              border: Border.all(
                                color: _selectedRange != null
                                    ? const Color.fromARGB(255, 0, 149, 255)
                                    : Colors.white24,
                                width: 2,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(
                                      255,
                                      0,
                                      149,
                                      255,
                                    ).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.all(10),
                                  child: Icon(
                                    Icons.calendar_month_rounded,
                                    color: const Color.fromARGB(
                                      255,
                                      0,
                                      149,
                                      255,
                                    ),
                                    size: 32,
                                  ),
                                ),
                                const SizedBox(width: 18),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _selectedRange == null
                                            ? 'Pick Date Range'
                                            : 'Rental Dates',
                                        style: TextStyle(
                                          color: const Color.fromARGB(
                                            255,
                                            0,
                                            149,
                                            255,
                                          ),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      _selectedRange == null
                                          ? Text(
                                              isBookingLoading
                                                  ? 'Loading bookings...'
                                                  : isBookingError
                                                  ? 'Error loading bookings'
                                                  : 'Tap to select your rental period',
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 14,
                                              ),
                                            )
                                          : Text(
                                              '${DateFormat('MMM d, yyyy').format(_selectedRange!.start)}  →  ${DateFormat('MMM d, yyyy').format(_selectedRange!.end)}',
                                              style: const TextStyle(
                                                color: Colors.black87,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.chevron_right_rounded,
                                  color: Color.fromARGB(255, 0, 149, 255),
                                  size: 28,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (_selectedRange != null)
                          Text(
                            'Selected: ${DateFormat('yMMMd').format(_selectedRange!.start)} - ${DateFormat('yMMMd').format(_selectedRange!.end)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                      ],
                    ),
                  const SizedBox(height: 32),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Step 5 of 5',
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
                        onPressed: _selectedRange != null
                            ? () {
                                Navigator.of(context).push(
                                  PageRouteBuilder(
                                    pageBuilder:
                                        (
                                          context,
                                          animation,
                                          secondaryAnimation,
                                        ) => BookingCompleteScreen(
                                          bookingDetails: BookingDetails(
                                            firstName: widget.firstName,
                                            lastName: widget.lastName,
                                            numberOfWheels:
                                                widget.numberOfWheels,
                                            vehicleType: widget.vehicleType,
                                            modelName: widget.modelName,
                                            modelImage: widget.modelImage,
                                            rentalDates: _selectedRange!,
                                          ),
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
                          'Finish',
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
