import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../core/design_system/widgets.dart';
import '../../core/responsive/responsive.dart';
import '../../shared/models.dart';
import 'booking_state.dart';

enum _ShowtimeSort { recommended, lowestPrice, highestPrice, earliest }

class _FilterSelection {
  const _FilterSelection({
    required this.specialFormatsOnly,
    required this.cancellableOnly,
    required this.favouritesOnly,
  });

  final bool specialFormatsOnly;
  final bool cancellableOnly;
  final bool favouritesOnly;
}

class ShowtimesPage extends ConsumerStatefulWidget {
  const ShowtimesPage({required this.movieId, super.key});

  final String movieId;

  @override
  ConsumerState<ShowtimesPage> createState() => _ShowtimesPageState();
}

class _ShowtimesPageState extends ConsumerState<ShowtimesPage> {
  var selectedDay = 0;
  var sort = _ShowtimeSort.recommended;
  var specialFormatsOnly = false;
  var cancellableOnly = false;
  var favouritesOnly = false;
  var searching = false;
  var searchQuery = '';
  final favouriteCinemaIds = <String>{};

  Future<void> _openSortOptions() async {
    final selected = await showTicketflixSheet<_ShowtimeSort>(
      context: context,
      builder: (context) => _SortSheet(selected: sort),
    );
    if (selected != null && mounted) setState(() => sort = selected);
  }

  Future<void> _openFilterOptions() async {
    final selected = await showTicketflixSheet<_FilterSelection>(
      context: context,
      builder: (context) => _FilterSheet(
        specialFormatsOnly: specialFormatsOnly,
        cancellableOnly: cancellableOnly,
        favouritesOnly: favouritesOnly,
      ),
    );
    if (selected == null || !mounted) return;
    setState(() {
      specialFormatsOnly = selected.specialFormatsOnly;
      cancellableOnly = selected.cancellableOnly;
      favouritesOnly = selected.favouritesOnly;
    });
  }

  String get _sortLabel => switch (sort) {
    _ShowtimeSort.recommended => 'Sort by',
    _ShowtimeSort.lowestPrice => 'Price: low to high',
    _ShowtimeSort.highestPrice => 'Price: high to low',
    _ShowtimeSort.earliest => 'Earliest show',
  };

  @override
  Widget build(BuildContext context) {
    final repository = ref.watch(mockRepositoryProvider);
    final movie = repository.movie(widget.movieId);
    final draft = ref.watch(bookingProvider);
    final formatLabel = draft.format.label;
    final languageLabel = draft.language.label;
    final normalizedSearch = searchQuery.trim().toLowerCase();
    final cinemas = repository.cinemas
        .map((cinema) {
          final cinemaMatches =
              normalizedSearch.isEmpty ||
              cinema.name.toLowerCase().contains(normalizedSearch) ||
              cinema.shortName.toLowerCase().contains(normalizedSearch);
          final showtimes = cinema.showtimes.where((showtime) {
            if (!specialFormatsOnly) return true;
            if (showtime.experience.isEmpty || showtime.experience == '2D') {
              return false;
            }
            return cinemaMatches ||
                showtime.time.toLowerCase().contains(normalizedSearch) ||
                showtime.experience.toLowerCase().contains(normalizedSearch);
          }).toList();
          final searchedShowtimes = specialFormatsOnly
              ? showtimes
              : showtimes.where((showtime) {
                  if (cinemaMatches || normalizedSearch.isEmpty) return true;
                  return showtime.time.toLowerCase().contains(
                        normalizedSearch,
                      ) ||
                      showtime.experience.toLowerCase().contains(
                        normalizedSearch,
                      );
                }).toList();
          return (cinema: cinema, showtimes: searchedShowtimes);
        })
        .where((listing) {
          if (cancellableOnly && !listing.cinema.cancellationAvailable) {
            return false;
          }
          if (favouritesOnly &&
              !favouriteCinemaIds.contains(listing.cinema.id)) {
            return false;
          }
          return listing.showtimes.isNotEmpty;
        })
        .toList();
    int lowestPrice(Iterable<Showtime> showtimes) => showtimes.fold(
      1 << 30,
      (lowest, showtime) => showtime.price < lowest ? showtime.price : lowest,
    );
    int timeInMinutes(Showtime showtime) {
      final match = RegExp(
        r'^(\d{1,2}):(\d{2})\s*(AM|PM)$',
        caseSensitive: false,
      ).firstMatch(showtime.time);
      if (match == null) return 1 << 30;
      var hour = int.parse(match.group(1)!);
      final minute = int.parse(match.group(2)!);
      final period = match.group(3)!.toUpperCase();
      if (period == 'AM' && hour == 12) hour = 0;
      if (period == 'PM' && hour != 12) hour += 12;
      return hour * 60 + minute;
    }

    int earliestShow(Iterable<Showtime> showtimes) =>
        showtimes.fold(1 << 30, (earliest, showtime) {
          final minutes = timeInMinutes(showtime);
          return minutes < earliest ? minutes : earliest;
        });

    if (sort != _ShowtimeSort.recommended) {
      cinemas.sort((a, b) {
        switch (sort) {
          case _ShowtimeSort.lowestPrice:
            return lowestPrice(a.showtimes).compareTo(lowestPrice(b.showtimes));
          case _ShowtimeSort.highestPrice:
            return lowestPrice(b.showtimes).compareTo(lowestPrice(a.showtimes));
          case _ShowtimeSort.earliest:
            return earliestShow(
              a.showtimes,
            ).compareTo(earliestShow(b.showtimes));
          case _ShowtimeSort.recommended:
            return 0;
        }
      });
    }

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
                if (searching)
                  SizedBox(
                    width: context.isMobile ? 210 : 300,
                    child: TextField(
                      autofocus: true,
                      onChanged: (value) => setState(() => searchQuery = value),
                      decoration: InputDecoration(
                        hintText: 'Search theatres or shows',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: searchQuery.isEmpty
                            ? null
                            : IconButton(
                                tooltip: 'Clear search',
                                onPressed: () =>
                                    setState(() => searchQuery = ''),
                                icon: const Icon(Icons.close),
                              ),
                        isDense: true,
                      ),
                    ),
                  ),
                IconButton(
                  tooltip: searching ? 'Close search' : 'Search cinemas',
                  onPressed: () => setState(() {
                    searching = !searching;
                    if (!searching) searchQuery = '';
                  }),
                  icon: Icon(searching ? Icons.close : Icons.search, size: 28),
                ),
                IconButton(
                  tooltip: 'Showtime filters',
                  onPressed: _openFilterOptions,
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
                    label: Text(_sortLabel),
                    selected: sort != _ShowtimeSort.recommended,
                    onSelected: (_) => _openSortOptions(),
                  ),
                  const SizedBox(width: 10),
                  FilterChip(
                    label: const Text('Special Formats'),
                    selected: specialFormatsOnly,
                    onSelected: (value) =>
                        setState(() => specialFormatsOnly = value),
                  ),
                  const SizedBox(width: 10),
                  FilterChip(
                    label: const Text('Cancellable'),
                    selected: cancellableOnly,
                    onSelected: (value) =>
                        setState(() => cancellableOnly = value),
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
            child: cinemas.isEmpty
                ? const Center(child: Text('No theatres match these filters'))
                : ListView.separated(
                    padding: EdgeInsets.fromLTRB(
                      context.isDesktop ? 24 : 12,
                      22,
                      context.isDesktop ? 24 : 12,
                      36,
                    ),
                    itemCount: cinemas.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 18),
                    itemBuilder: (context, index) {
                      final listing = cinemas[index];
                      return ContentWidth(
                        padding: EdgeInsets.zero,
                        maxWidth: 980,
                        child: _CinemaCard(
                          cinema: listing.cinema,
                          showtimes: listing.showtimes,
                          isFavorite: favouriteCinemaIds.contains(
                            listing.cinema.id,
                          ),
                          onFavorite: () => setState(() {
                            if (!favouriteCinemaIds.add(listing.cinema.id)) {
                              favouriteCinemaIds.remove(listing.cinema.id);
                            }
                          }),
                          onShowtime: (showtime) {
                            if (showtime.soldOut) return;
                            ref
                                .read(bookingProvider.notifier)
                                .setShowtime(showtime.id);
                            context.push(
                              '/movies/${movie.id}/shows/${showtime.id}/seats?cinemaId=${listing.cinema.id}&day=$selectedDay',
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _SortSheet extends StatelessWidget {
  const _SortSheet({required this.selected});

  final _ShowtimeSort selected;

  static const options = [
    (_ShowtimeSort.recommended, 'Recommended'),
    (_ShowtimeSort.lowestPrice, 'Price: low to high'),
    (_ShowtimeSort.highestPrice, 'Price: high to low'),
    (_ShowtimeSort.earliest, 'Earliest show'),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SheetHandle(),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Text(
              'Sort theatres by',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          RadioGroup<_ShowtimeSort>(
            groupValue: selected,
            onChanged: (value) {
              if (value != null) Navigator.of(context).pop(value);
            },
            child: Column(
              children: [
                for (final option in options)
                  RadioListTile<_ShowtimeSort>(
                    value: option.$1,
                    title: Text(option.$2),
                    activeColor: AppColors.primary,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({
    required this.specialFormatsOnly,
    required this.cancellableOnly,
    required this.favouritesOnly,
  });

  final bool specialFormatsOnly;
  final bool cancellableOnly;
  final bool favouritesOnly;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late var specialFormatsOnly = widget.specialFormatsOnly;
  late var cancellableOnly = widget.cancellableOnly;
  late var favouritesOnly = widget.favouritesOnly;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SheetHandle(),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text(
                'Filter showtimes',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            CheckboxListTile(
              value: specialFormatsOnly,
              title: const Text('Special formats'),
              subtitle: const Text('Show premium or 3D experiences'),
              activeColor: AppColors.primary,
              onChanged: (value) =>
                  setState(() => specialFormatsOnly = value ?? false),
            ),
            CheckboxListTile(
              value: cancellableOnly,
              title: const Text('Cancellable only'),
              subtitle: const Text('Hide theatres without cancellation'),
              activeColor: AppColors.primary,
              onChanged: (value) =>
                  setState(() => cancellableOnly = value ?? false),
            ),
            CheckboxListTile(
              value: favouritesOnly,
              title: const Text('Favourite theatres'),
              subtitle: const Text('Show only theatres you saved'),
              activeColor: AppColors.primary,
              onChanged: (value) =>
                  setState(() => favouritesOnly = value ?? false),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() {
                        specialFormatsOnly = false;
                        cancellableOnly = false;
                        favouritesOnly = false;
                      }),
                      child: const Text('Clear all'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TicketflixButton(
                      label: 'Apply filters',
                      onPressed: () => Navigator.of(context).pop(
                        _FilterSelection(
                          specialFormatsOnly: specialFormatsOnly,
                          cancellableOnly: cancellableOnly,
                          favouritesOnly: favouritesOnly,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateStrip extends StatelessWidget {
  const _DateStrip({required this.selectedDay, required this.onSelected});

  final int selectedDay;
  final ValueChanged<int> onSelected;

  static const _weekdays = [
    '',
    'MON',
    'TUE',
    'WED',
    'THU',
    'FRI',
    'SAT',
    'SUN',
  ];
  static const _months = [
    'JAN',
    'FEB',
    'MAR',
    'APR',
    'MAY',
    'JUN',
    'JUL',
    'AUG',
    'SEP',
    'OCT',
    'NOV',
    'DEC',
  ];

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final dates = List.generate(7, (index) => today.add(Duration(days: index)));

    return Container(
      height: 98,
      color: AppColors.surface,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: Breakpoints.maxContent),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 7,
            itemBuilder: (context, index) {
              final selected = selectedDay == index;
              final date = dates[index];
              final dateLabel = (
                _weekdays[date.weekday],
                date.day.toString().padLeft(2, '0'),
                _months[date.month - 1],
              );
              return Semantics(
                button: true,
                selected: selected,
                label: '${dateLabel.$1}, ${dateLabel.$2} ${dateLabel.$3}',
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
                          dateLabel.$1,
                          style: TextStyle(
                            color: selected ? Colors.white : AppColors.muted,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          dateLabel.$2,
                          style: TextStyle(
                            color: selected ? Colors.white : AppColors.ink,
                            fontSize: 23,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          dateLabel.$3,
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
  const _CinemaCard({
    required this.cinema,
    required this.showtimes,
    required this.isFavorite,
    required this.onFavorite,
    required this.onShowtime,
  });

  final Cinema cinema;
  final List<Showtime> showtimes;
  final bool isFavorite;
  final VoidCallback onFavorite;
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
                child: Text(
                  cinema.shortName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
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
                onPressed: onFavorite,
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? AppColors.primary : null,
                  size: 25,
                ),
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
            itemCount: showtimes.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              childAspectRatio: context.isMobile ? 1.7 : 2.15,
              crossAxisSpacing: 9,
              mainAxisSpacing: 7,
            ),
            itemBuilder: (context, index) {
              final showtime = showtimes[index];
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
              Expanded(
                child: Text(
                  'Indicates subtitle language, if available',
                  style: TextStyle(color: AppColors.muted, fontSize: 11),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
