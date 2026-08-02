import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../../../core/design_system/widgets.dart';
import '../../../core/responsive/responsive.dart';
import '../view_models/movie_providers.dart';

class MovieListPage extends ConsumerWidget {
  const MovieListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(movieListViewModelProvider);
    final viewModel = ref.read(movieListViewModelProvider.notifier);
    final movies = state.visibleMovies;
    final columns = context.viewportWidth >= 1180
        ? 5
        : context.viewportWidth >= 820
        ? 4
        : context.viewportWidth >= 600
        ? 3
        : 2;

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: context.isMobile
          ? FloatingActionButton.extended(
              heroTag: 'cinema-browse',
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cinema discovery is coming soon.'),
                ),
              ),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.location_on_outlined),
              label: const Text('Browse by Cinemas'),
            )
          : null,
      body: Column(
        children: [
          DesktopHeader(onSignIn: () => context.push('/login')),
          TicketflixPageHeader(
            title: state.searching ? '' : 'Now Showing',
            subtitle: state.searching
                ? null
                : 'Kochi  |  ${state.movies.valueOrNull?.length ?? 0} Movies',
            actions: [
              if (state.searching)
                SizedBox(
                  width: context.isMobile ? 220 : 360,
                  child: TextField(
                    autofocus: true,
                    onChanged: viewModel.setQuery,
                    decoration: const InputDecoration(
                      hintText: 'Search movies',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
              IconButton(
                tooltip: state.searching ? 'Close search' : 'Search',
                onPressed: viewModel.toggleSearch,
                icon: Icon(
                  state.searching ? Icons.close : Icons.search,
                  size: 30,
                ),
              ),
            ],
          ),
          const Divider(height: 1),
          Expanded(
            child: state.movies.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) =>
                  Center(child: Text('Unable to load movies: $error')),
              data: (_) => CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: ContentWidth(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.isDesktop ? 24 : 16,
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 18),
                          SizedBox(
                            height: 44,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: MovieListViewModel.filters.length + 1,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(width: 10),
                              itemBuilder: (context, index) {
                                if (index == 0) {
                                  return IconButton.outlined(
                                    tooltip: 'Filters',
                                    onPressed: () {},
                                    icon: Icon(
                                      Icons.filter_alt_outlined,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                                  );
                                }
                                final filter =
                                    MovieListViewModel.filters[index - 1];
                                return ChoiceChip(
                                  label: Text(filter),
                                  selected: state.selectedFilter == filter,
                                  selectedColor: Theme.of(
                                    context,
                                  ).colorScheme.secondaryContainer,
                                  onSelected: (_) =>
                                      viewModel.selectFilter(filter),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 22),
                          Container(
                            height: 74,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppColors.midnight, AppColors.primary],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              children: [
                                Text(
                                  'Coming Soon',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 19,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'Explore Upcoming Movies',
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                  if (movies.isEmpty)
                    const SliverFillRemaining(
                      child: Center(child: Text('No movies found')),
                    )
                  else
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        context.isDesktop ? 24 : 16,
                        0,
                        context.isDesktop ? 24 : 16,
                        100,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: ContentWidth(
                          padding: EdgeInsets.zero,
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: columns,
                                  crossAxisSpacing: context.isMobile ? 16 : 22,
                                  mainAxisSpacing: 24,
                                  childAspectRatio: context.isMobile
                                      ? .46
                                      : .50,
                                ),
                            itemCount: movies.length,
                            itemBuilder: (context, index) => MoviePosterCard(
                              width: double.infinity,
                              title: movies[index].title,
                              posterUrl: movies[index].posterUrl,
                              likes: movies[index].likes,
                              genres: movies[index].genres,
                              showLikes: true,
                              onTap: () =>
                                  context.push('/movies/${movies[index].id}'),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
