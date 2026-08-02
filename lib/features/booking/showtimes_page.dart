import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../core/design_system/widgets.dart';
import '../../core/responsive/responsive.dart';
import '../../shared/models.dart';
import 'booking_state.dart';

class ShowtimesPage extends ConsumerStatefulWidget {
  const ShowtimesPage({required this.movieId, super.key});

  final String movieId;

  @override
  ConsumerState<ShowtimesPage> createState() => _ShowtimesPageState();
}

class _ShowtimesPageState extends ConsumerState<ShowtimesPage> {
  var selectedDay = 0;
  var sortSelected = false;
  var favouritesOnly = false;

  @override
  Widget build(BuildContext context) {
    final repository = ref.watch(mockRepositoryProvider);
    final movie = repository.movie(widget.movieId);
    final draft = ref.watch(bookingProvider);
    final formatLabel = draft.format.label;
    final languageLabel = draft.language.label;

    return Scaffold(
      backgroundColor: AppColors.surfaceTint,
      body: Column(
        children: [
          const DesktopHeader(),
          ColoredBox(
            color: AppColors.surface,
            child: TicketflixPageHeader(
              title: movie.title,
              subtitle: 'Movie runtime: ${movie.runtime}',
              actions: [
                IconButton(
                  tooltip: 'Search cinemas',
                  onPressed: () {},
                  icon: const Icon(Icons.search, size: 28),
                ),
                IconButton(
                  tooltip: 'Showtime filters',
                  onPressed: () {},
                  icon: const Icon(Icons.tune, size: 27),
                ),
              ],
            ),
          ),
          _DateStrip(
            selectedDay: selectedDay,
            onSelected: (value) => setState(() => selectedDay = value),
          ),
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: ContentWidth(
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '$languageLabel  •  $formatLabel',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.pop(),
                    child: const Text(
                      'Change ›',
                      style: TextStyle(color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: double.infinity,
            color: AppColors.surface,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: ContentWidth(
              padding: EdgeInsets.zero,
              child: Text(
                movie.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 13,
                  height: 1.35,
                ),
              ),
            ),
          ),
          const Divider(height: 1),
          Container(
            height: 72,
            color: Colors.white,
            alignment: Alignment.center,
            child: ContentWidth(
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  FilterChip(
                    avatar: const Icon(Icons.swap_vert, size: 18),
                    label: const Text('Sort by'),
                    selected: sortSelected,
                    onSelected: (value) => setState(() => sortSelected = value),
                  ),
                  const SizedBox(width: 10),
                  FilterChip(
                    label: const Text('Special Formats'),
                    selected: false,
                    onSelected: (_) {},
                  ),
                  const SizedBox(width: 10),
                  FilterChip(
                    label: const Text('Cancellable'),
                    selected: true,
                    onSelected: (_) {},
                  ),
                  const SizedBox(width: 10),
                  FilterChip(
                    avatar: const Icon(Icons.favorite_border, size: 18),
                    label: const Text('Favourites'),
                    selected: favouritesOnly,
                    onSelected: (value) =>
                        setState(() => favouritesOnly = value),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.fromLTRB(
                context.isDesktop ? 24 : 12,
                22,
                context.isDesktop ? 24 : 12,
                36,
              ),
              itemCount: repository.cinemas.length,
              separatorBuilder: (_, _) => const SizedBox(height: 18),
              itemBuilder: (context, index) => ContentWidth(
                padding: EdgeInsets.zero,
                maxWidth: 980,
                child: _CinemaCard(
                  cinema: repository.cinemas[index],
                  onShowtime: (showtime) {
                    if (showtime.soldOut) return;
                    ref.read(bookingProvider.notifier).setShowtime(showtime.id);
                    context.push(
                      '/movies/${movie.id}/shows/${showtime.id}/seats',
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DateStrip extends StatelessWidget {
  const _DateStrip({required this.selectedDay, required this.onSelected});

  final int selectedDay;
  final ValueChanged<int> onSelected;

  static const dates = [
    ('THU', '30', 'JUL'),
    ('FRI', '31', 'JUL'),
    ('SAT', '01', 'AUG'),
    ('SUN', '02', 'AUG'),
    ('MON', '03', 'AUG'),
    ('TUE', '04', 'AUG'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 98,
      color: AppColors.surface,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: Breakpoints.maxContent),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: dates.length,
            itemBuilder: (context, index) {
              final selected = selectedDay == index;
              final date = dates[index];
              return Semantics(
                button: true,
                selected: selected,
                label: '${date.$1}, ${date.$2} ${date.$3}',
                child: InkWell(
                  onTap: () => onSelected(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: context.isMobile ? 74 : 90,
                    color: selected ? AppColors.primary : AppColors.surface,
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    child: Column(
                      children: [
                        Text(
                          date.$1,
                          style: TextStyle(
                            color: selected ? Colors.white : AppColors.muted,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          date.$2,
                          style: TextStyle(
                            color: selected ? Colors.white : AppColors.ink,
                            fontSize: 23,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          date.$3,
                          style: TextStyle(
                            color: selected ? Colors.white : AppColors.muted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _CinemaCard extends StatelessWidget {
  const _CinemaCard({required this.cinema, required this.onShowtime});

  final Cinema cinema;
  final ValueChanged<Showtime> onShowtime;

  @override
  Widget build(BuildContext context) {
    final columns = context.isDesktop ? 5 : 3;
    return Container(
      padding: EdgeInsets.all(context.isMobile ? 12 : 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(7),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.accent),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'PVR',
                  style: TextStyle(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  cinema.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              IconButton(
                tooltip: 'Cinema information',
                onPressed: () {},
                icon: const Icon(Icons.info_outline, size: 20),
              ),
              IconButton(
                tooltip: 'Add cinema to favourites',
                onPressed: () {},
                icon: const Icon(Icons.favorite_border, size: 25),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            cinema.cancellationAvailable
                ? 'Cancellation available'
                : 'Non-cancellable',
            style: const TextStyle(color: AppColors.muted, fontSize: 12),
          ),
          const SizedBox(height: 14),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: cinema.showtimes.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              childAspectRatio: context.isMobile ? 1.35 : 1.7,
              crossAxisSpacing: 9,
              mainAxisSpacing: 9,
            ),
            itemBuilder: (context, index) {
              final showtime = cinema.showtimes[index];
              final borderColor = showtime.soldOut
                  ? AppColors.border
                  : showtime.fillingFast
                  ? AppColors.warning
                  : AppColors.success;
              return Semantics(
                button: !showtime.soldOut,
                enabled: !showtime.soldOut,
                label:
                    '${showtime.time}, ${showtime.experience}, ₹${showtime.price}',
                child: OutlinedButton(
                  onPressed: showtime.soldOut
                      ? null
                      : () => onShowtime(showtime),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    side: BorderSide(color: borderColor, width: 1.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        showtime.time,
                        style: TextStyle(
                          color: showtime.soldOut
                              ? AppColors.border
                              : AppColors.muted,
                          fontSize: context.isMobile ? 12 : 13,
                        ),
                      ),
                      if (showtime.experience.isNotEmpty)
                        Text(
                          showtime.experience,
                          style: TextStyle(
                            color: showtime.soldOut
                                ? AppColors.border
                                : AppColors.muted,
                            fontSize: 9,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 14),
          const Row(
            children: [
              Icon(Icons.subtitles_outlined, size: 18, color: AppColors.muted),
              SizedBox(width: 7),
              Text(
                'Indicates subtitle language, if available',
                style: TextStyle(color: AppColors.muted, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
