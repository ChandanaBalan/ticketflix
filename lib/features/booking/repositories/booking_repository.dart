import '../models/booking_models.dart';

abstract interface class BookingRepository {
  Future<List<Cinema>> fetchCinemas(ShowtimesQuery query);

  Future<List<Seat>> fetchSeats(SeatMapQuery query);
}
