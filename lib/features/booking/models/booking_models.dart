import '../../movies/models/movie.dart';

enum SeatStatus { available, selected, sold }

class Showtime {
  const Showtime({
    required this.id,
    required this.time,
    required this.experience,
    required this.price,
    this.fillingFast = false,
    this.soldOut = false,
  });

  final String id;
  final String time;
  final String experience;
  final int price;
  final bool fillingFast;
  final bool soldOut;
}

class Cinema {
  const Cinema({
    required this.id,
    required this.shortName,
    required this.name,
    required this.showtimes,
    this.cancellationAvailable = true,
  });

  final String id;
  final String shortName;
  final String name;
  final List<Showtime> showtimes;
  final bool cancellationAvailable;
}

class Seat {
  const Seat({
    required this.id,
    required this.row,
    required this.number,
    required this.price,
    this.status = SeatStatus.available,
  });

  final String id;
  final String row;
  final int number;
  final int price;
  final SeatStatus status;
}

class BookingDraft {
  const BookingDraft({
    this.language = MovieLanguage.english,
    this.format = MovieFormat.threeD,
    this.ticketCount = 2,
    this.showtimeId = '07-00',
    this.selectedSeatIds = const {'D7', 'D8'},
  });

  final MovieLanguage language;
  final MovieFormat format;
  final int ticketCount;
  final String showtimeId;
  final Set<String> selectedSeatIds;

  BookingDraft copyWith({
    MovieLanguage? language,
    MovieFormat? format,
    int? ticketCount,
    String? showtimeId,
    Set<String>? selectedSeatIds,
  }) {
    return BookingDraft(
      language: language ?? this.language,
      format: format ?? this.format,
      ticketCount: ticketCount ?? this.ticketCount,
      showtimeId: showtimeId ?? this.showtimeId,
      selectedSeatIds: Set.unmodifiable(
        selectedSeatIds ?? this.selectedSeatIds,
      ),
    );
  }
}

class ShowtimesQuery {
  const ShowtimesQuery({
    required this.movieId,
    required this.dayIndex,
    required this.language,
    required this.format,
  });

  final String movieId;
  final int dayIndex;
  final MovieLanguage language;
  final MovieFormat format;
}

class SeatMapQuery {
  const SeatMapQuery({
    required this.movieId,
    required this.cinemaId,
    required this.showtimeId,
    required this.dayIndex,
  });

  final String movieId;
  final String cinemaId;
  final String showtimeId;
  final int dayIndex;
}
