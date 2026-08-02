import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/movie.dart';
import '../repositories/mock_movie_repository.dart';
import '../repositories/movie_repository.dart';

final movieRepositoryProvider = Provider<MovieRepository>((ref) {
  return const MockMovieRepository();
});

class MovieListState {
  const MovieListState({
    this.movies = const AsyncValue.loading(),
    this.selectedFilter = 'New Releases',
    this.searching = false,
    this.query = '',
  });

  final AsyncValue<List<Movie>> movies;
  final String selectedFilter;
  final bool searching;
  final String query;

  List<Movie> get visibleMovies {
    final normalized = query.trim().toLowerCase();
    return movies.valueOrNull
            ?.where((movie) {
              return normalized.isEmpty ||
                  movie.title.toLowerCase().contains(normalized);
            })
            .toList() ??
        const [];
  }

  MovieListState copyWith({
    AsyncValue<List<Movie>>? movies,
    String? selectedFilter,
    bool? searching,
    String? query,
  }) {
    return MovieListState(
      movies: movies ?? this.movies,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      searching: searching ?? this.searching,
      query: query ?? this.query,
    );
  }
}

final movieListViewModelProvider =
    NotifierProvider<MovieListViewModel, MovieListState>(
  MovieListViewModel.new,
);

class MovieListViewModel extends Notifier<MovieListState> {
  static const filters = [
    'New Releases',
    'English',
    'Malayalam',
    'Hindi',
    'Tamil',
  ];

  @override
  MovieListState build() {
    Future<void>(() async {
      try {
        final movies = await ref.read(movieRepositoryProvider).fetchMovies();
        state = state.copyWith(movies: AsyncValue.data(movies));
      } catch (error, stackTrace) {
        state = state.copyWith(movies: AsyncValue.error(error, stackTrace));
      }
    });
    return const MovieListState();
  }

  void setQuery(String query) {
    state = state.copyWith(query: query);
  }

  void toggleSearch() {
    state = state.copyWith(searching: !state.searching, query: '');
  }

  void selectFilter(String filter) {
    state = state.copyWith(selectedFilter: filter);
  }
}

final movieDetailViewModelProvider =
    FutureProvider.autoDispose.family<Movie?, String>((ref, movieId) {
  return ref.read(movieRepositoryProvider).fetchMovieById(movieId);
});
