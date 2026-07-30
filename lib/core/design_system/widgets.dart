import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../core/responsive/responsive.dart';
import '../../shared/models.dart';

class TicketflixButton extends StatelessWidget {
  const TicketflixButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.expanded = true,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final button = SizedBox(
      height: 52,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: icon == null ? const SizedBox.shrink() : Icon(icon, size: 20),
        label: Text(label, style: const TextStyle(fontSize: 16)),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.border,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
    return expanded ? SizedBox(width: double.infinity, child: button) : button;
  }
}

class TicketflixPageHeader extends StatelessWidget {
  const TicketflixPageHeader({
    required this.title,
    this.subtitle,
    this.actions = const [],
    this.showBack = true,
    super.key,
  });

  final String title;
  final String? subtitle;
  final List<Widget> actions;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: ContentWidth(
          child: SizedBox(
            height: subtitle == null ? 64 : 78,
            child: Row(
              children: [
                if (showBack)
                  IconButton(
                    tooltip: 'Back',
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 22,
                    ),
                  )
                else
                  const SizedBox(width: 4),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.muted),
                        ),
                    ],
                  ),
                ),
                ...actions,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DesktopHeader extends StatelessWidget {
  const DesktopHeader({super.key});

  @override
  Widget build(BuildContext context) {
    if (!context.isDesktop) return const SizedBox.shrink();
    return Material(
      color: const Color(0xFF222539),
      child: ContentWidth(
        child: SizedBox(
          height: 72,
          child: Row(
            children: [
              const Icon(
                Icons.local_activity_rounded,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              const Text(
                'ticketflix',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 23,
                  letterSpacing: -.6,
                ),
              ),
              const SizedBox(width: 44),
              Expanded(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: TextField(
                    readOnly: true,
                    decoration: const InputDecoration(
                      hintText: 'Search for movies, events and cinemas',
                      prefixIcon: Icon(Icons.search),
                      isDense: true,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.location_on_outlined),
                label: const Text('Kochi'),
                style: TextButton.styleFrom(foregroundColor: Colors.white),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.person_outline),
                label: const Text('Sign in'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white54),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MoviePosterCard extends StatelessWidget {
  const MoviePosterCard({
    required this.movie,
    required this.onTap,
    this.showLikes = false,
    this.width = 145,
    super.key,
  });

  final Movie movie;
  final VoidCallback onTap;
  final bool showLikes;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${movie.title}, ${movie.likes} likes',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: .675,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    movie.posterAsset,
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.medium,
                  ),
                ),
              ),
              if (showLikes) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.thumb_up_alt,
                      color: AppColors.success,
                      size: 15,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${movie.likes} likes',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 6),
              Text(
                movie.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 2),
              Text(
                movie.genres.join(' • '),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<T?> showTicketflixSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isDismissible = true,
}) {
  if (context.isDesktop) {
    return showDialog<T>(
      context: context,
      barrierDismissible: isDismissible,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560, maxHeight: 720),
          child: builder(context),
        ),
      ),
    );
  }
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    isDismissible: isDismissible,
    useSafeArea: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
    ),
    builder: builder,
  );
}

class SheetHandle extends StatelessWidget {
  const SheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 68,
        height: 5,
        margin: const EdgeInsets.only(top: 12, bottom: 18),
        decoration: BoxDecoration(
          color: const Color(0xFFE2E2E2),
          borderRadius: BorderRadius.circular(99),
        ),
      ),
    );
  }
}
