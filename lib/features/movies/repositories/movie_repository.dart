import '../models/movie.dart';

abstract interface class MovieRepository {
  Future<List<Movie>> fetchMovies();

  Future<Movie?> fetchMovieById(String movieId);
}
