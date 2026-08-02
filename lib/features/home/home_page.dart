import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../core/design_system/widgets.dart';
import '../../core/responsive/responsive.dart';
import '../booking/booking_state.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  void _comingSoon(BuildContext context, String label) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$label is coming soon.')));
  }

  Future<void> _showFeaturePreview(
    BuildContext context, {
    required String title,
    required String description,
    required String actionLabel,
  }) async {
    await showTicketflixSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SheetHandle(),
              Icon(
                title == 'Prebooking'
                    ? Icons.event_available_rounded
                    : Icons.handshake_outlined,
                color: AppColors.primary,
                size: 42,
              ),
              const SizedBox(height: 14),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                description,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.muted),
              ),
              const SizedBox(height: 20),
              TicketflixButton(
                label: actionLabel,
                onPressed: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$title setup saved for later.')),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final movies = ref.watch(mockRepositoryProvider).movies;
    return Scaffold(
      bottomNavigationBar: context.isDesktop
          ? null
          : NavigationBar(
              height: 72,
              selectedIndex: 0,
              indicatorColor: AppColors.softAccent,
              onDestinationSelected: (index) {
                if (index == 3) {
                  context.push('/movies');
                } else if (index == 1) {
                  _showFeaturePreview(
                    context,
                    title: 'Prebooking',
                    description:
                        'Get early access to popular releases and reserve your seats before regular bookings open.',
                    actionLabel: 'Join prebooking list',
                  );
                } else if (index == 2) {
                  _showFeaturePreview(
                    context,
                    title: 'Affiliate & Refer',
                    description:
                        'Share movies with friends, track referrals, and unlock Ticketflix rewards in one place.',
                    actionLabel: 'Create referral link',
                  );
                } else if (index != 0) {
                  _comingSoon(
                    context,
                    const [
                      'Home',
                      'Prebooking',
                      'Refer & Earn',
                      'Search',
                    ][index],
                  );
                }
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.local_activity_outlined),
                  selectedIcon: Icon(
                    Icons.local_activity,
                    color: AppColors.primary,
                  ),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.card_membership_outlined),
                  selectedIcon: Icon(Icons.event_available_rounded),
                  label: 'Prebooking',
                ),
                NavigationDestination(
                  icon: Icon(Icons.handshake_outlined),
                  selectedIcon: Icon(Icons.handshake),
                  label: 'Refer & Earn',
                ),
                NavigationDestination(
                  icon: Icon(Icons.search),
                  label: 'Search',
                ),
              ],
            ),
      body: Column(
        children: [
          const DesktopHeader(),
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: ContentWidth(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.isDesktop ? 24 : 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 36),
                        _WelcomeHeader(
                          onProfileTap: () => context.push('/login'),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: _LocationBanner()),
                SliverToBoxAdapter(
                  child: ContentWidth(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.isDesktop ? 24 : 16,
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        _CategoryRail(
                          onTap: (label) {
                            if (label == 'Movies') {
                              context.push('/movies');
                            } else {
                              _comingSoon(context, label);
                            }
                          },
                        ),
                        const SizedBox(height: 22),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 0),
                          child: _PromoCarousel(
                            imageUrl:
                                movies.first.bannerUrl ??
                                movies.first.posterUrl,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: SizedBox(
                              width: double.infinity,
                              height: context.isDesktop ? 156 : 68,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  TicketflixRemoteImage(
                                    url:
                                        movies[1].bannerUrl ??
                                        movies[1].posterUrl,
                                  ),
                                  DecoratedBox(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          AppColors.midnight.withValues(
                                            alpha: .9,
                                          ),
                                          Colors.transparent,
                                        ],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      ),
                                    ),
                                  ),
                                  const Align(
                                    alignment: Alignment.centerLeft,
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 20,
                                      ),
                                      child: Text(
                                        'CLASSIC SCREENINGS  •  FROM ₹149',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: .4,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 26),
                        _SectionTitle(
                          title: 'Recommended Movies',
                          onSeeAll: () => context.push('/movies'),
                        ),
                        const SizedBox(height: 14),
                      ],
                    ),
                  ),
                ),
                if (context.isDesktop)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 52),
                    sliver: SliverToBoxAdapter(
                      child: ContentWidth(
                        padding: EdgeInsets.zero,
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4,
                                crossAxisSpacing: 22,
                                mainAxisSpacing: 22,
                                childAspectRatio: .58,
                              ),
                          itemCount: movies.length,
                          itemBuilder: (context, index) => MoviePosterCard(
                            width: double.infinity,
                            movie: movies[index],
                            onTap: () =>
                                context.push('/movies/${movies[index].id}'),
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 310,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        scrollDirection: Axis.horizontal,
                        itemCount: movies.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 12),
                        itemBuilder: (context, index) => MoviePosterCard(
                          width: 145,
                          movie: movies[index],
                          onTap: () =>
                              context.push('/movies/${movies[index].id}'),
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

class _WelcomeHeader extends StatelessWidget {
  const _WelcomeHeader({required this.onProfileTap});

  final VoidCallback onProfileTap;

  @override
  Widget build(BuildContext context) {
    if (context.isDesktop) {
      return const Text(
        'Discover something unforgettable',
        style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
      );
    }
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'It All Starts Here!',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: 4),
              const Row(
                children: [
                  Text(
                    'Kochi',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Icon(Icons.chevron_right, size: 18, color: AppColors.primary),
                ],
              ),
            ],
          ),
        ),
        IconButton.outlined(
          tooltip: 'Profile',
          onPressed: onProfileTap,
          icon: const Icon(Icons.person_outline, size: 27),
          style: IconButton.styleFrom(
            minimumSize: const Size(56, 56),
            side: const BorderSide(color: AppColors.muted),
          ),
        ),
      ],
    );
  }
}

class _LocationBanner extends StatelessWidget {
  const _LocationBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      color: AppColors.locationBlue,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: Breakpoints.maxContent),
          child: const Row(
            children: [
              Icon(Icons.near_me_outlined, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Enable location to discover nearby events, movies, and more.',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryRail extends StatelessWidget {
  const _CategoryRail({required this.onTap});

  final ValueChanged<String> onTap;

  static const items = [
    (Icons.movie_creation_outlined, 'Movies'),
    (Icons.music_note_outlined, 'Music'),
    (Icons.science_outlined, 'Performances'),
    (Icons.mic_external_on_outlined, 'Comedy'),
    (Icons.ondemand_video_outlined, 'Stream'),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 78,
      child: ListView.separated(
        padding: EdgeInsets.zero,
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, _) =>
            SizedBox(width: context.isDesktop ? 54 : 30),
        itemBuilder: (context, index) {
          final item = items[index];
          return InkWell(
            onTap: () => onTap(item.$2),
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 64,
              child: Column(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: item.$2 == 'Movies'
                          ? AppColors.softAccent
                          : AppColors.surfaceTint,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.border),
                    ),
                    alignment: Alignment.center,
                    child: Icon(item.$1, color: AppColors.primary, size: 27),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    item.$2,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PromoCarousel extends StatefulWidget {
  const _PromoCarousel({required this.imageUrl});

  final String imageUrl;

  @override
  State<_PromoCarousel> createState() => _PromoCarouselState();
}

class _PromoCarouselState extends State<_PromoCarousel> {
  var page = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AspectRatio(
          aspectRatio: context.isDesktop ? 3.9 : 2.0,
          child: PageView(
            onPageChanged: (value) => setState(() => page = value),
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(13),
                child: TicketflixRemoteImage(url: widget.imageUrl),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(13),
                  gradient: const LinearGradient(
                    colors: [AppColors.midnight, AppColors.primary],
                  ),
                ),
                child: const Center(
                  child: Text(
                    'BIG SCREEN WEEKEND\nTickets from ₹149',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            2,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: index == page ? 16 : 7,
              height: 7,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color: index == page ? AppColors.primary : AppColors.border,
                borderRadius: BorderRadius.circular(9),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.onSeeAll});

  final String title;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
        TextButton(
          onPressed: onSeeAll,
          child: const Text(
            'See All ›',
            style: TextStyle(color: AppColors.primary),
          ),
        ),
      ],
    );
  }
}
