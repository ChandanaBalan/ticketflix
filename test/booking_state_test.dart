import 'package:flutter_test/flutter_test.dart';
import 'package:ticketflix_v2/features/booking/booking_state.dart';
import 'package:ticketflix_v2/shared/models.dart';

void main() {
  group('BookingController', () {
    test('stores language and format selections', () {
      final controller = BookingController();

      controller.setFormat(MovieLanguage.malayalam, MovieFormat.threeD);

      expect(controller.state.language, MovieLanguage.malayalam);
      expect(controller.state.format, MovieFormat.threeD);
    });

    test('enforces the requested number of seats', () {
      final controller = BookingController()..setTicketCount(1);
      const first = Seat(id: 'A1', row: 'A', number: 1, price: 780);
      const second = Seat(id: 'A2', row: 'A', number: 2, price: 780);

      expect(controller.toggleSeat(first), isTrue);
      expect(controller.toggleSeat(second), isFalse);
      expect(controller.state.selectedSeatIds, {'A1'});
    });

    test('rejects sold seats and calculates selected total', () {
      final controller = BookingController()..setTicketCount(2);
      const available = Seat(id: 'D7', row: 'D', number: 7, price: 880);
      const sold = Seat(
        id: 'D8',
        row: 'D',
        number: 8,
        price: 880,
        status: SeatStatus.sold,
      );

      expect(controller.toggleSeat(available), isTrue);
      expect(controller.toggleSeat(sold), isFalse);
      expect(controller.totalFor([available, sold]), 880);
    });
  });
}
