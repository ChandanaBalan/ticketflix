import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../movies/models/movie.dart';
import '../../movies/view_models/movie_providers.dart';

final homeViewModelProvider = FutureProvider.autoDispose<List<Movie>>((ref) {
  return ref.read(movieRepositoryProvider).fetchMovies();
});
