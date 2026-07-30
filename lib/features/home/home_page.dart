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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final movies = ref.watch(mockRepositoryProvider).movies;
    return Scaffold(
      bottomNavigationBar: context.isDesktop
          ? null
          : NavigationBar(
              height: 72,
              selectedIndex: 0,
              indicatorColor: const Color(0xFFFFE6EA),
              onDestinationSelected: (index) {
                if (index == 3) {
                  context.push('/movies');
                } else if (index != 0) {
                  _comingSoon(
                    context,
                    const [
                      'Home',
                      'HSBC Lounge',
                      'Live Events',
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
                  label: 'HSBC Lounge',
                ),
                NavigationDestination(
                  icon: Icon(Icons.confirmation_number_outlined),
                  label: 'Live Events',
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
                        const SizedBox(height: 22),
                        _WelcomeHeader(
                          onProfileTap: () => _comingSoon(context, 'Sign in'),
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
                      horizontal: context.isDesktop ? 24 : 0,
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
                        const _PromoCarousel(),
                        const SizedBox(height: 14),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            'assets/images/live_offer.jpg',
                            width: double.infinity,
                            height: context.isDesktop ? 156 : 68,
                            fit: BoxFit.cover,
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
        padding: EdgeInsets.symmetric(horizontal: context.isDesktop ? 0 : 16),
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
                  Icon(item.$1, color: AppColors.primary, size: 31),
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
  const _PromoCarousel();

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
                child: Image.asset(
                  'assets/images/stream_banner.jpg',
                  fit: BoxFit.cover,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(13),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF20284A), Color(0xFF6C1D3D)],
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
