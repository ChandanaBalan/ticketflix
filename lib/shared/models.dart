enum MovieLanguage { english, malayalam, hindi }

enum MovieFormat { twoD, threeD, fourDx3D }

enum SeatStatus { available, selected, sold }

class Movie {
  const Movie({
    required this.id,
    required this.title,
    required this.posterAsset,
    required this.likes,
    required this.genres,
    this.heroAsset,
    this.runtime = '2h 25m',
    this.certificate = 'UA13+',
  });

  final String id;
  final String title;
  final String posterAsset;
  final String? heroAsset;
  final String likes;
  final List<String> genres;
  final String runtime;
  final String certificate;
}

class CastMember {
  const CastMember({
    required this.name,
    required this.role,
    required this.asset,
  });

  final String name;
  final String role;
  final String asset;
}

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
    required this.name,
    required this.showtimes,
    this.cancellationAvailable = true,
  });

  final String id;
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
      selectedSeatIds: selectedSeatIds ?? this.selectedSeatIds,
    );
  }
}
