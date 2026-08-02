import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../../core/responsive/responsive.dart';

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
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.border,
          disabledForegroundColor: AppColors.muted,
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
      color: AppColors.surface,
      child: SafeArea(
        bottom: false,
        child: ContentWidth(
          child: SizedBox(
            height: subtitle == null ? 64 : 78,
            child: Row(
              children: [
                if (showBack)
                  Transform.translate(
                    offset: const Offset(-8, 0),
                    child: IconButton(
                      tooltip: 'Back',
                      onPressed: () => Navigator.of(context).maybePop(),
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                      constraints: const BoxConstraints.tightFor(
                        width: 40,
                        height: 44,
                      ),
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 19,
                      ),
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
  const DesktopHeader({this.onSignIn, super.key});

  final VoidCallback? onSignIn;

  @override
  Widget build(BuildContext context) {
    if (!context.isDesktop) return const SizedBox.shrink();
    return Material(
      color: AppColors.midnight,
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
                onPressed: onSignIn,
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
    required this.title,
    required this.posterUrl,
    required this.likes,
    this.genres = const [],
    required this.onTap,
    this.showLikes = false,
    this.width = 145,
    super.key,
  });

  final String title;
  final String posterUrl;
  final String likes;
  final List<String> genres;
  final VoidCallback onTap;
  final bool showLikes;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$title, $likes likes',
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
                  child: TicketflixRemoteImage(
                    url: posterUrl,
                    fit: BoxFit.cover,
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
                        '$likes likes',
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
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 2),
              Text(
                genres.join(' • '),
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

class TicketflixRemoteImage extends StatelessWidget {
  const TicketflixRemoteImage({
    required this.url,
    this.fit = BoxFit.cover,
    super.key,
  });

  final String url;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      _imageRequestUrl(url),
      fit: fit,
      filterQuality: FilterQuality.medium,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return ColoredBox(
          color: AppColors.midnight,
          child: Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              value: progress.expectedTotalBytes == null
                  ? null
                  : progress.cumulativeBytesLoaded /
                        progress.expectedTotalBytes!,
              color: AppColors.accent,
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) => const ColoredBox(
        color: AppColors.midnight,
        child: Center(
          child: Icon(
            Icons.local_movies_outlined,
            color: AppColors.accent,
            size: 32,
          ),
        ),
      ),
    );
  }
}

String _imageRequestUrl(String sourceUrl) {
  if (!kIsWeb) return sourceUrl;
  return Uri.base
      .resolve('/image-proxy')
      .replace(queryParameters: {'url': sourceUrl})
      .toString();
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
    backgroundColor: AppColors.surface,
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
          color: AppColors.border,
          borderRadius: BorderRadius.circular(99),
        ),
      ),
    );
  }
}
