import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../core/design_system/widgets.dart';
import '../../core/responsive/responsive.dart';
import '../movies/models/movie.dart';
import '../booking/view_models/booking_providers.dart';
import 'view_models/prebooking_providers.dart';

class PrebookingDetailPage extends ConsumerWidget {
  const PrebookingDetailPage({required this.movieId, super.key});

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
        .read(bookingSessionProvider.notifier)
        .setFormat(choice.language, choice.format);
    context.push('/prebooking/${movie.id}/shows');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDesktop = context.isDesktop;
    final movieState = ref.watch(prebookingDetailViewModelProvider(movieId));

    return movieState.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) => Scaffold(
        body: Center(child: Text('Unable to load movie: $error')),
      ),
      data: (movie) {
        if (movie == null) {
          return const Scaffold(body: Center(child: Text('Movie not found')));
        }

        return Scaffold(
          bottomNavigationBar: isDesktop
              ? null
              : SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: TicketflixButton(
                      label: 'Pre-book tickets',
                      icon: Icons.event_available_rounded,
                      onPressed: () => _openFormats(context, ref, movie),
                    ),
                  ),
                ),
          body: Column(
            children: [
              DesktopHeader(onSignIn: () => context.push('/login')),
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
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 24 : 16,
                    ),
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
                                  child: _PrebookingInformation(
                                    movie: movie,
                                    onBook: () =>
                                        _openFormats(context, ref, movie),
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
                              _PrebookingInformation(movie: movie, onBook: null),
                            ],
                          ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.movie});

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AspectRatio(
          aspectRatio: 1.78,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: TicketflixRemoteImage(
              url: movie.bannerUrl ?? movie.posterUrl,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          left: 12,
          top: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.event_available_rounded, color: Colors.white, size: 16),
                SizedBox(width: 6),
                Text(
                  'Prebooking open',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PrebookingInformation extends StatelessWidget {
  const _PrebookingInformation({required this.movie, required this.onBook});

  final Movie movie;
  final VoidCallback? onBook;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (movie.formattedReleaseDate != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.accent),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_month_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Releasing ${movie.formattedReleaseDate}',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const Text(
                        'Reserve your seats now — show up on release day',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.secondaryContainer,
                Theme.of(context).colorScheme.tertiaryContainer,
              ],
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
                      'Mark interested to get release reminders',
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
        Wrap(
          spacing: 7,
          runSpacing: 7,
          children: [
            for (final format in movie.formats) _MetadataLabel(format.label),
            for (final language in movie.languages)
              _MetadataLabel(language.label),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'About ${movie.title}',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          movie.description,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 14),
        Container(
          height: 48,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.accent),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Container(
                height: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurface,
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(7),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.event_seat, color: Colors.white),
                    SizedBox(width: 6),
                    Text('Prebooking', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Seats reserved ',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      TextSpan(
                        text: 'until 24 hours before release',
                        style: TextStyle(color: AppColors.success),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text('Cast', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 14),
        SizedBox(
          height: 126,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: movie.cast.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final member = movie.cast[index];
              return CastMemberTile(
                name: member.name,
                role: member.role,
                photoUrl: member.photoUrl,
              );
            },
          ),
        ),
        if (onBook != null) ...[
          const SizedBox(height: 24),
          TicketflixButton(
            label: 'Pre-book tickets',
            icon: Icons.event_available_rounded,
            onPressed: onBook,
          ),
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
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
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
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Text(
                'Select language and format',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            if (movie.formattedReleaseDate != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Text(
                  'Releasing ${movie.formattedReleaseDate}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
              ),
            for (final language in movie.languages)
              _LanguageFormats(
                title: language.label,
                choices: [
                  for (final format in movie.formats)
                    _FormatChoice(language, format),
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          child: Text(
            title,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                    'format-${title.toLowerCase()}-${choice.format.label}',
                  ),
                  onPressed: () => Navigator.of(context).pop(choice),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 13,
                    ),
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                    shape: const StadiumBorder(),
                  ),
                  child: Text(choice.format.label),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
