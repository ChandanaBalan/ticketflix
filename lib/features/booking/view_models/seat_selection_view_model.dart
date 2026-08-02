import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../movies/models/movie.dart';
import '../../movies/view_models/movie_providers.dart';
import '../models/booking_models.dart';
import 'booking_providers.dart';

class SeatSelectionArgs {
  const SeatSelectionArgs({
    required this.movieId,
    required this.showId,
    required this.cinemaId,
    required this.dayIndex,
  });

  final String movieId;
  final String showId;
  final String cinemaId;
  final int dayIndex;

  @override
  bool operator ==(Object other) {
    return other is SeatSelectionArgs &&
        other.movieId == movieId &&
        other.showId == showId &&
        other.cinemaId == cinemaId &&
        other.dayIndex == dayIndex;
  }

  @override
  int get hashCode => Object.hash(movieId, showId, cinemaId, dayIndex);
}

class SeatSelectionState {
  const SeatSelectionState({
    required this.movie,
    required this.cinema,
    required this.showtime,
    required this.seats,
  });

  final Movie movie;
  final Cinema cinema;
  final Showtime showtime;
  final List<Seat> seats;
}

final seatSelectionViewModelProvider = FutureProvider.autoDispose
    .family<SeatSelectionState, SeatSelectionArgs>((ref, args) async {
      final movie = await ref
          .read(movieRepositoryProvider)
          .fetchMovieById(args.movieId);
      final cinemas = await ref
          .read(bookingRepositoryProvider)
          .fetchCinemas(
            ShowtimesQuery(
              movieId: args.movieId,
              dayIndex: args.dayIndex,
              language: ref.read(bookingSessionProvider).language,
              format: ref.read(bookingSessionProvider).format,
            ),
          );
      final selectedMovie = movie ?? (throw StateError('Movie not found'));
      final cinema = cinemas.firstWhere(
        (value) => value.id == args.cinemaId,
        orElse: () => cinemas.first,
      );
      final showtime = cinema.showtimes.firstWhere(
        (value) => value.id == args.showId,
        orElse: () => cinema.showtimes.first,
      );
      final seats = await ref
          .read(bookingRepositoryProvider)
          .fetchSeats(
            SeatMapQuery(
              movieId: args.movieId,
              cinemaId: cinema.id,
              showtimeId: showtime.id,
              dayIndex: args.dayIndex,
            ),
          );
      return SeatSelectionState(
        movie: selectedMovie,
        cinema: cinema,
        showtime: showtime,
        seats: seats,
      );
    });
