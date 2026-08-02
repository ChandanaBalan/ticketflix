import '../../../data/mock/mock_repository.dart';
import '../models/booking_models.dart';
import 'booking_repository.dart';

class MockBookingRepository implements BookingRepository {
  const MockBookingRepository({this.source = const MockRepository()});

  final MockRepository source;

  @override
  Future<List<Cinema>> fetchCinemas(ShowtimesQuery query) async {
    return source.cinemas;
  }

  @override
  Future<List<Seat>> fetchSeats(SeatMapQuery query) async {
    return _createSeats();
  }

  static List<Seat> _createSeats() {
    const sold = {
      'G1', 'G2', 'G3', 'G4', 'G5', 'G6', 'G7', 'F4', 'F5', 'F6',
      'E2', 'E3', 'E4', 'E5', 'E6', 'E7', 'E8', 'D5', 'B3', 'B4', 'B5', 'B6',
    };
    return [
      for (final row in const ['G', 'F', 'E', 'D', 'C', 'B', 'A'])
        for (var number = 1; number <= (row == 'F' ? 10 : 8); number++)
          Seat(
            id: '$row$number',
            row: row,
            number: number,
            price: ['B', 'A'].contains(row) ? 780 : 880,
            status: sold.contains('$row$number')
                ? SeatStatus.sold
                : SeatStatus.available,
          ),
    ];
  }
}
