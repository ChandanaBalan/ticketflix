import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../movies/models/movie.dart';
import '../../movies/view_models/movie_providers.dart';
import '../models/booking_models.dart';
import '../repositories/booking_repository.dart';
import '../repositories/mock_booking_repository.dart';

final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  return const MockBookingRepository();
});

final bookingSessionProvider =
    NotifierProvider<BookingSessionViewModel, BookingDraft>(
  BookingSessionViewModel.new,
);

class BookingSessionViewModel extends Notifier<BookingDraft> {
  @override
  BookingDraft build() => const BookingDraft();

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

class ShowtimeListing {
  const ShowtimeListing({required this.cinema, required this.showtimes});

  final Cinema cinema;
  final List<Showtime> showtimes;
}

enum ShowtimeSort { recommended, lowestPrice, highestPrice, earliest }

class ShowtimesState {
  const ShowtimesState({
    required this.movie,
    required this.cinemas,
    this.selectedDay = 0,
    this.sort = ShowtimeSort.recommended,
    this.specialFormatsOnly = false,
    this.cancellableOnly = false,
    this.favouritesOnly = false,
    this.searching = false,
    this.searchQuery = '',
    this.favouriteCinemaIds = const {},
  });

  final Movie? movie;
  final List<ShowtimeListing> cinemas;
  final int selectedDay;
  final ShowtimeSort sort;
  final bool specialFormatsOnly;
  final bool cancellableOnly;
  final bool favouritesOnly;
  final bool searching;
  final String searchQuery;
  final Set<String> favouriteCinemaIds;

  List<ShowtimeListing> get visibleCinemas {
    final normalizedSearch = searchQuery.trim().toLowerCase();
    final filtered = cinemas
        .map((listing) {
          final cinemaMatches = normalizedSearch.isEmpty ||
              listing.cinema.name.toLowerCase().contains(normalizedSearch) ||
              listing.cinema.shortName.toLowerCase().contains(normalizedSearch);
          final showtimes = listing.showtimes.where((showtime) {
            if (specialFormatsOnly &&
                (showtime.experience.isEmpty || showtime.experience == '2D')) {
              return false;
            }
            if (cinemaMatches || normalizedSearch.isEmpty) return true;
            return showtime.time.toLowerCase().contains(normalizedSearch) ||
                showtime.experience.toLowerCase().contains(normalizedSearch);
          }).toList();
          return ShowtimeListing(cinema: listing.cinema, showtimes: showtimes);
        })
        .where((listing) {
          if (cancellableOnly && !listing.cinema.cancellationAvailable) {
            return false;
          }
          if (favouritesOnly &&
              !favouriteCinemaIds.contains(listing.cinema.id)) {
            return false;
          }
          return listing.showtimes.isNotEmpty;
        })
        .toList();

    if (sort == ShowtimeSort.recommended) return filtered;
    int timeInMinutes(Showtime showtime) {
      final match = RegExp(
        r'^(\d{1,2}):(\d{2})\s*(AM|PM)$',
        caseSensitive: false,
      ).firstMatch(showtime.time);
      if (match == null) return 1 << 30;
      var hour = int.parse(match.group(1)!);
      final minute = int.parse(match.group(2)!);
      final period = match.group(3)!.toUpperCase();
      if (period == 'AM' && hour == 12) hour = 0;
      if (period == 'PM' && hour != 12) hour += 12;
      return hour * 60 + minute;
    }
    int price(ShowtimeListing listing) => listing.showtimes.fold(
          1 << 30,
          (value, showtime) => showtime.price < value ? showtime.price : value,
        );
    int earliest(ShowtimeListing listing) => listing.showtimes.fold(
          1 << 30,
          (value, showtime) {
            final minutes = timeInMinutes(showtime);
            return minutes < value ? minutes : value;
          },
        );
    filtered.sort((a, b) {
      final comparison = switch (sort) {
        ShowtimeSort.lowestPrice => price(a).compareTo(price(b)),
        ShowtimeSort.highestPrice => price(b).compareTo(price(a)),
        ShowtimeSort.earliest => earliest(a).compareTo(earliest(b)),
        ShowtimeSort.recommended => 0,
      };
      return comparison;
    });
    return filtered;
  }

  ShowtimesState copyWith({
    Movie? movie,
    List<ShowtimeListing>? cinemas,
    int? selectedDay,
    ShowtimeSort? sort,
    bool? specialFormatsOnly,
    bool? cancellableOnly,
    bool? favouritesOnly,
    bool? searching,
    String? searchQuery,
    Set<String>? favouriteCinemaIds,
  }) {
    return ShowtimesState(
      movie: movie ?? this.movie,
      cinemas: cinemas ?? this.cinemas,
      selectedDay: selectedDay ?? this.selectedDay,
      sort: sort ?? this.sort,
      specialFormatsOnly: specialFormatsOnly ?? this.specialFormatsOnly,
      cancellableOnly: cancellableOnly ?? this.cancellableOnly,
      favouritesOnly: favouritesOnly ?? this.favouritesOnly,
      searching: searching ?? this.searching,
      searchQuery: searchQuery ?? this.searchQuery,
      favouriteCinemaIds: Set.unmodifiable(
        favouriteCinemaIds ?? this.favouriteCinemaIds,
      ),
    );
  }
}

final showtimesViewModelProvider =
    NotifierProvider.family<ShowtimesViewModel, ShowtimesState, String>(
  ShowtimesViewModel.new,
);

class ShowtimesViewModel
    extends FamilyNotifier<ShowtimesState, String> {
  @override
  ShowtimesState build(String movieId) {
    final movie = ref.watch(movieRepositoryProvider).fetchMovieById(movieId);
    Future<void>(() async {
      final loadedMovie = await movie;
      final cinemas = await ref.read(bookingRepositoryProvider).fetchCinemas(
        ShowtimesQuery(
          movieId: movieId,
          dayIndex: 0,
          language: ref.read(bookingSessionProvider).language,
          format: ref.read(bookingSessionProvider).format,
        ),
      );
      state = state.copyWith(
        movie: loadedMovie,
        cinemas: cinemas
            .map((cinema) => ShowtimeListing(
                  cinema: cinema,
                  showtimes: cinema.showtimes,
                ))
            .toList(),
      );
    });
    return const ShowtimesState(movie: null, cinemas: []);
  }

  void setDay(int day) => state = state.copyWith(selectedDay: day);

  void setSort(ShowtimeSort sort) => state = state.copyWith(sort: sort);

  void setSpecialFormats(bool value) =>
      state = state.copyWith(specialFormatsOnly: value);

  void setCancellable(bool value) =>
      state = state.copyWith(cancellableOnly: value);

  void setFavouritesOnly(bool value) =>
      state = state.copyWith(favouritesOnly: value);

  void setSearching(bool value) =>
      state = state.copyWith(searching: value, searchQuery: '');

  void setSearchQuery(String value) => state = state.copyWith(searchQuery: value);

  void toggleFavourite(String cinemaId) {
    final next = {...state.favouriteCinemaIds};
    if (!next.add(cinemaId)) next.remove(cinemaId);
    state = state.copyWith(favouriteCinemaIds: next);
  }
}
