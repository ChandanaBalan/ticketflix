import '../../movies/models/movie.dart';

abstract interface class PrebookingRepository {
  Future<List<Movie>> fetchPreReleaseMovies();

  Future<Movie?> fetchPreReleaseMovieById(String movieId);
}
