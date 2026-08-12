import '../../../data/mock/mock_repository.dart';
import '../models/movie.dart';
import 'movie_repository.dart';

class MockMovieRepository implements MovieRepository {
  const MockMovieRepository({this.source = const MockRepository()});

  final MockRepository source;

  @override
  Future<List<Movie>> fetchMovies() async => source.movies;

  @override
  Future<Movie?> fetchMovieById(String movieId) async {
    for (final movie in [...source.movies, ...source.preReleaseMovies]) {
      if (movie.id == movieId) return movie;
    }
    return null;
  }
}
