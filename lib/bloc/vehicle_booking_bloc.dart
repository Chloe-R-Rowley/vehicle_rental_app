import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/vehicle_booking_model.dart';

abstract class BookingState {}

class BookingLoading extends BookingState {}

class BookingLoaded extends BookingState {
  final List<BookingModel> bookings;
  BookingLoaded(this.bookings);
}

class BookingError extends BookingState {
  final String message;
  BookingError(this.message);
}

class BookingBloc {
  final _stateController = StreamController<BookingState>();
  Stream<BookingState> get state => _stateController.stream;

  Future<void> fetchBookings(String vehicleId) async {
    _stateController.add(BookingLoading());
    try {
      final response = await http.get(
        Uri.parse(
          'https://octalogic-test-frontend.vercel.app/api/v1/bookings/$vehicleId',
        ),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> bookingsJson = data['data'];
        final bookings = bookingsJson
            .map((json) => BookingModel.fromJson(json))
            .toList();
        _stateController.add(BookingLoaded(bookings));
      } else {
        _stateController.add(BookingError('Failed to load bookings'));
      }
    } catch (e) {
      _stateController.add(BookingError('Network error: ' + e.toString()));
    }
  }

  void dispose() {
    _stateController.close();
  }
}
