import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../movies/models/movie.dart';
import '../repositories/mock_prebooking_repository.dart';
import '../repositories/prebooking_repository.dart';

final prebookingRepositoryProvider = Provider<PrebookingRepository>((ref) {
  return const MockPrebookingRepository();
});

class PrebookingListState {
  const PrebookingListState({
    this.movies = const AsyncValue.loading(),
    this.selectedFilter = 'All',
    this.searching = false,
    this.query = '',
  });

  final AsyncValue<List<Movie>> movies;
  final String selectedFilter;
  final bool searching;
  final String query;

  List<Movie> get visibleMovies {
    final normalized = query.trim().toLowerCase();
    final all = movies.valueOrNull ?? const <Movie>[];
    final filtered = switch (selectedFilter) {
      'This Month' => all.where((movie) {
        final date = movie.releaseDate;
        if (date == null) return false;
        return date.month == DateTime.now().month &&
            date.year == DateTime.now().year;
      }),
      'Next Month' => all.where((movie) {
        final date = movie.releaseDate;
        if (date == null) return false;
        final nextMonth = DateTime(DateTime.now().year, DateTime.now().month + 1);
        return date.month == nextMonth.month && date.year == nextMonth.year;
      }),
      'Blockbusters' => all.where(
        (movie) =>
            movie.genres.contains('Action') ||
            movie.genres.contains('Sci-Fi') ||
            movie.likes.contains('M+'),
      ),
      _ => all,
    };
    return filtered
        .where(
          (movie) =>
              normalized.isEmpty ||
              movie.title.toLowerCase().contains(normalized),
        )
        .toList();
  }

  PrebookingListState copyWith({
    AsyncValue<List<Movie>>? movies,
    String? selectedFilter,
    bool? searching,
    String? query,
  }) {
    return PrebookingListState(
      movies: movies ?? this.movies,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      searching: searching ?? this.searching,
      query: query ?? this.query,
    );
  }
}

final prebookingListViewModelProvider =
    NotifierProvider<PrebookingListViewModel, PrebookingListState>(
      PrebookingListViewModel.new,
    );

class PrebookingListViewModel extends Notifier<PrebookingListState> {
  static const filters = ['All', 'This Month', 'Next Month', 'Blockbusters'];

  @override
  PrebookingListState build() {
    Future<void>(() async {
      try {
        final movies = await ref
            .read(prebookingRepositoryProvider)
            .fetchPreReleaseMovies();
        state = state.copyWith(movies: AsyncValue.data(movies));
      } catch (error, stackTrace) {
        state = state.copyWith(movies: AsyncValue.error(error, stackTrace));
      }
    });
    return const PrebookingListState();
  }

  void setQuery(String query) => state = state.copyWith(query: query);

  void toggleSearch() {
    state = state.copyWith(searching: !state.searching, query: '');
  }

  void selectFilter(String filter) {
    state = state.copyWith(selectedFilter: filter);
  }
}

final prebookingDetailViewModelProvider = FutureProvider.autoDispose
    .family<Movie?, String>((ref, movieId) {
      return ref
          .read(prebookingRepositoryProvider)
          .fetchPreReleaseMovieById(movieId);
    });
