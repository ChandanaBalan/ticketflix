import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../core/design_system/widgets.dart';
import '../../core/responsive/responsive.dart';
import '../booking/booking_state.dart';

class MovieListPage extends ConsumerStatefulWidget {
  const MovieListPage({super.key});

  @override
  ConsumerState<MovieListPage> createState() => _MovieListPageState();
}

class _MovieListPageState extends ConsumerState<MovieListPage> {
  var selectedFilter = 'New Releases';
  var searching = false;
  var query = '';

  static const filters = [
    'New Releases',
    'English',
    'Malayalam',
    'Hindi',
    'Tamil',
  ];

  @override
  Widget build(BuildContext context) {
    final repository = ref.watch(mockRepositoryProvider);
    final movies = repository.movies
        .where(
          (movie) => movie.title.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
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
          const DesktopHeader(),
          TicketflixPageHeader(
            title: searching ? '' : 'Now Showing',
            subtitle: searching
                ? null
                : 'Kochi  |  ${repository.movies.length} Movies',
            actions: [
              if (searching)
                SizedBox(
                  width: context.isMobile ? 220 : 360,
                  child: TextField(
                    autofocus: true,
                    onChanged: (value) => setState(() => query = value),
                    decoration: const InputDecoration(
                      hintText: 'Search movies',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
              IconButton(
                tooltip: searching ? 'Close search' : 'Search',
                onPressed: () => setState(() {
                  searching = !searching;
                  if (!searching) query = '';
                }),
                icon: Icon(searching ? Icons.close : Icons.search, size: 30),
              ),
            ],
          ),
          const Divider(height: 1),
          Expanded(
            child: CustomScrollView(
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
                            itemCount: filters.length + 1,
                            separatorBuilder: (_, _) =>
                                const SizedBox(width: 10),
                            itemBuilder: (context, index) {
                              if (index == 0) {
                                return IconButton.outlined(
                                  tooltip: 'Filters',
                                  onPressed: () {},
                                  icon: const Icon(
                                    Icons.filter_alt_outlined,
                                    color: AppColors.primary,
                                  ),
                                );
                              }
                              final filter = filters[index - 1];
                              return ChoiceChip(
                                label: Text(filter),
                                selected: selectedFilter == filter,
                                selectedColor: AppColors.softAccent,
                                onSelected: (_) =>
                                    setState(() => selectedFilter = filter),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 22),
                        InkWell(
                          onTap: () {},
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            height: 74,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppColors.midnight, AppColors.primary],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
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
                                // Includes poster, likes, a two-line title, and
                                // genre metadata. The previous ratio only
                                // budgeted for the poster and caused the card
                                // Column to overflow by roughly 52 px.
                                childAspectRatio: context.isMobile ? .46 : .50,
                              ),
                          itemCount: movies.length,
                          itemBuilder: (context, index) => MoviePosterCard(
                            width: double.infinity,
                            movie: movies[index],
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
        ],
      ),
    );
  }
}
