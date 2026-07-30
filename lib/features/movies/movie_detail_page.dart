import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../core/design_system/widgets.dart';
import '../../core/responsive/responsive.dart';
import '../../shared/models.dart';
import '../booking/booking_state.dart';

class MovieDetailPage extends ConsumerWidget {
  const MovieDetailPage({required this.movieId, super.key});

  final String movieId;

  Future<void> _openFormats(
    BuildContext context,
    WidgetRef ref,
    Movie movie,
  ) async {
    final choice = await showTicketflixSheet<_FormatChoice>(
      context: context,
      builder: (context) => _FormatSheet(movie: movie),
    );
    if (choice == null || !context.mounted) return;
    ref
        .read(bookingProvider.notifier)
        .setFormat(choice.language, choice.format);
    context.push('/movies/${movie.id}/shows');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.watch(mockRepositoryProvider);
    final movie = repository.movie(movieId);
    final isDesktop = context.isDesktop;

    return Scaffold(
      bottomNavigationBar: isDesktop
          ? null
          : SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: TicketflixButton(
                  label: 'Book tickets',
                  onPressed: () => _openFormats(context, ref, movie),
                ),
              ),
            ),
      body: Column(
        children: [
          const DesktopHeader(),
          TicketflixPageHeader(
            title: movie.title,
            actions: [
              IconButton(
                tooltip: 'Share',
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Share link copied.')),
                ),
                icon: const Icon(Icons.share_outlined),
              ),
            ],
          ),
          const Divider(height: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: isDesktop ? 48 : 16),
              child: ContentWidth(
                padding: EdgeInsets.symmetric(horizontal: isDesktop ? 24 : 16),
                child: isDesktop
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 5,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 30),
                              child: _Hero(movie: movie),
                            ),
                          ),
                          const SizedBox(width: 42),
                          Expanded(
                            flex: 5,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 30),
                              child: _MovieInformation(
                                movie: movie,
                                cast: repository.cast,
                                onBook: () => _openFormats(context, ref, movie),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          const SizedBox(height: 14),
                          _Hero(movie: movie),
                          const SizedBox(height: 14),
                          _MovieInformation(
                            movie: movie,
                            cast: repository.cast,
                            onBook: null,
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.movie});

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.78,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          movie.heroAsset ?? movie.posterAsset,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class _MovieInformation extends StatelessWidget {
  const _MovieInformation({
    required this.movie,
    required this.cast,
    required this.onBook,
  });

  final Movie movie;
  final List<CastMember> cast;
  final VoidCallback? onBook;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFF8FAF7), Color(0xFFFFF5F6)],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.thumb_up_alt,
                color: AppColors.success,
                size: 22,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${movie.likes} are interested',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const Text(
                      'Mark interested to add it to your Wishlist',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                ),
                child: const Text("I'm interested"),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text(
          '${movie.runtime}  •  ${movie.genres.join(', ')}  •  ${movie.certificate}',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 10),
        const Wrap(
          spacing: 7,
          runSpacing: 7,
          children: [
            _MetadataLabel('2D, 3D SCREEN X, EPIQ, DOLBY CINEMA 3D, +8'),
            _MetadataLabel('ENGLISH, MALAYALAM, +4'),
          ],
        ),
        const SizedBox(height: 12),
        RichText(
          text: TextSpan(
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.muted),
            children: const [
              TextSpan(
                text:
                    "Accessibility: Closed Captions (CC) & Audio Description (AD) available. Download the 'MovieReading' ",
              ),
              TextSpan(
                text: '...Read more',
                style: TextStyle(color: AppColors.primary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Container(
          height: 48,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFB7C8F5)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Container(
                height: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: const BoxDecoration(
                  color: Color(0xFF5D8DF4),
                  borderRadius: BorderRadius.horizontal(
                    left: Radius.circular(7),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.trending_up, color: Colors.white),
                    SizedBox(width: 6),
                    Text('Trending', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '42.53K ',
                        style: TextStyle(
                          color: AppColors.success,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextSpan(text: 'tickets booked in last 1 hour'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Top offers for you',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 70,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) => Container(
              width: 260,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF9E8),
                border: Border.all(color: const Color(0xFFFFE6A6)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.local_offer_outlined,
                    color: AppColors.primary,
                    size: 30,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'YES Private Debit Card Offer\nTap to view details',
                      maxLines: 2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text('Cast', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 14),
        SizedBox(
          height: 126,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: cast.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) => SizedBox(
              width: 104,
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      cast[index].asset,
                      width: 104,
                      height: 88,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    cast[index].name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (onBook != null) ...[
          const SizedBox(height: 24),
          TicketflixButton(label: 'Book tickets', onPressed: onBook),
        ],
      ],
    );
  }
}

class _MetadataLabel extends StatelessWidget {
  const _MetadataLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F3),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _FormatChoice {
  const _FormatChoice(this.language, this.format);

  final MovieLanguage language;
  final MovieFormat format;
}

class _FormatSheet extends StatelessWidget {
  const _FormatSheet({required this.movie});

  final Movie movie;

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
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(movie.title),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: Text(
                'Select language and format',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            _LanguageFormats(
              title: 'MALAYALAM',
              choices: const [
                _FormatChoice(MovieLanguage.malayalam, MovieFormat.threeD),
              ],
            ),
            _LanguageFormats(
              title: 'ENGLISH',
              choices: const [
                _FormatChoice(MovieLanguage.english, MovieFormat.fourDx3D),
                _FormatChoice(MovieLanguage.english, MovieFormat.threeD),
                _FormatChoice(MovieLanguage.english, MovieFormat.twoD),
              ],
            ),
            _LanguageFormats(
              title: 'HINDI',
              choices: const [
                _FormatChoice(MovieLanguage.hindi, MovieFormat.threeD),
              ],
            ),
            const SizedBox(height: 22),
          ],
        ),
      ),
    );
  }
}

class _LanguageFormats extends StatelessWidget {
  const _LanguageFormats({required this.title, required this.choices});

  final String title;
  final List<_FormatChoice> choices;

  String _formatLabel(MovieFormat format) => switch (format) {
    MovieFormat.twoD => '2D',
    MovieFormat.threeD => '3D',
    MovieFormat.fourDx3D => '4DX 3D',
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          color: AppColors.surfaceTint,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          child: Text(
            title,
            style: const TextStyle(
              color: AppColors.muted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final choice in choices)
                OutlinedButton(
                  key: ValueKey(
                    'format-${title.toLowerCase()}-${_formatLabel(choice.format)}',
                  ),
                  onPressed: () => Navigator.of(context).pop(choice),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 13,
                    ),
                    side: const BorderSide(color: AppColors.border),
                    shape: const StadiumBorder(),
                  ),
                  child: Text(_formatLabel(choice.format)),
                ),
              if (title == 'ENGLISH')
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(choices[1]),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 13,
                    ),
                    side: const BorderSide(color: AppColors.border),
                    shape: const StadiumBorder(),
                  ),
                  child: const Text('Select all'),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
