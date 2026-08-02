import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ticketflix_v2/features/booking/models/booking_models.dart';
import 'package:ticketflix_v2/features/booking/view_models/booking_providers.dart';
import 'package:ticketflix_v2/features/movies/models/movie.dart';

void main() {
  group('BookingSessionViewModel', () {
    late ProviderContainer container;

    setUp(() => container = ProviderContainer());
    tearDown(() => container.dispose());

    test('stores language and format selections', () {
      final controller = container.read(bookingSessionProvider.notifier);

      controller.setFormat(MovieLanguage.malayalam, MovieFormat.threeD);

      final state = container.read(bookingSessionProvider);
      expect(state.language, MovieLanguage.malayalam);
      expect(state.format, MovieFormat.threeD);
    });

    test('enforces the requested number of seats', () {
      final controller = container.read(bookingSessionProvider.notifier)
        ..setTicketCount(1);
      const first = Seat(id: 'A1', row: 'A', number: 1, price: 780);
      const second = Seat(id: 'A2', row: 'A', number: 2, price: 780);

      expect(controller.toggleSeat(first), isTrue);
      expect(controller.toggleSeat(second), isFalse);
      expect(container.read(bookingSessionProvider).selectedSeatIds, {'A1'});
    });

    test('rejects sold seats and calculates selected total', () {
      final controller = container.read(bookingSessionProvider.notifier)
        ..setTicketCount(2);
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
