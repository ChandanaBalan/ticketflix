import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/mock/mock_repository.dart';
import '../../shared/models.dart';

final mockRepositoryProvider = Provider<MockRepository>((ref) {
  return const MockRepository();
});

final bookingProvider = StateNotifierProvider<BookingController, BookingDraft>((
  ref,
) {
  return BookingController();
});

class BookingController extends StateNotifier<BookingDraft> {
  BookingController() : super(const BookingDraft());

  void setFormat(MovieLanguage language, MovieFormat format) {
    state = state.copyWith(language: language, format: format);
  }

  void setShowtime(String showtimeId) {
    state = state.copyWith(showtimeId: showtimeId);
  }

  void setTicketCount(int count) {
    state = state.copyWith(
      ticketCount: count,
      selectedSeatIds: count == state.ticketCount ? state.selectedSeatIds : {},
    );
  }

  bool toggleSeat(Seat seat) {
    if (seat.status == SeatStatus.sold) return false;

    final next = {...state.selectedSeatIds};
    if (next.remove(seat.id)) {
      state = state.copyWith(selectedSeatIds: next);
      return true;
    }
    if (next.length >= state.ticketCount) return false;
    next.add(seat.id);
    state = state.copyWith(selectedSeatIds: next);
    return true;
  }

  int totalFor(Iterable<Seat> seats) {
    final byId = {for (final seat in seats) seat.id: seat};
    return state.selectedSeatIds.fold(
      0,
      (total, id) => total + (byId[id]?.price ?? 0),
    );
  }
}
