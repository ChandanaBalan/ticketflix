import '../../../data/mock/mock_repository.dart';
import '../../movies/models/movie.dart';
import 'prebooking_repository.dart';

class MockPrebookingRepository implements PrebookingRepository {
  const MockPrebookingRepository({this.source = const MockRepository()});

  final MockRepository source;

  @override
  Future<List<Movie>> fetchPreReleaseMovies() async => source.preReleaseMovies;

  @override
  Future<Movie?> fetchPreReleaseMovieById(String movieId) async {
    for (final movie in source.preReleaseMovies) {
      if (movie.id == movieId) return movie;
    }
    return null;
  }
}
