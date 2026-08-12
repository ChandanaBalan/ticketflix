import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../../../core/design_system/widgets.dart';
import '../../../core/responsive/responsive.dart';
import '../models/affiliate_models.dart';
import '../view_models/affiliate_providers.dart';

class AffiliateStatusView extends ConsumerWidget {
  const AffiliateStatusView({required this.application, super.key});

  final AffiliateApplication application;

  static String _formatDateTime(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final period = date.hour >= 12 ? 'PM' : 'AM';
    final minute = date.minute.toString().padLeft(2, '0');
    return '${date.day} ${months[date.month - 1]} ${date.year}, $hour:$minute $period';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPending = application.status == AffiliateApplicationStatus.pending;
    final isRejected =
        application.status == AffiliateApplicationStatus.rejected;
    final submitted = application.submittedAt;
    final dateLabel = submitted == null ? '' : _formatDateTime(submitted);

    return Scaffold(
      body: Column(
        children: [
          DesktopHeader(onSignIn: () => context.push('/login')),
          TicketflixPageHeader(
            title: isPending ? 'Application pending' : 'Application update',
            subtitle: isPending ? 'Awaiting admin review' : 'Review complete',
            showBack: true,
          ),
          const Divider(height: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                context.isDesktop ? 24 : 16,
                24,
                context.isDesktop ? 24 : 16,
                32,
              ),
              child: ContentWidth(
                maxWidth: 560,
                padding: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      isPending
                          ? Icons.hourglass_top_rounded
                          : Icons.cancel_outlined,
                      size: 56,
                      color: isPending ? AppColors.warning : AppColors.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isPending
                          ? 'We are reviewing your application'
                          : 'Your application was not approved',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      isPending
                          ? 'Affiliate onboarding is selective. Our admin team verifies your audience details before issuing a coupon code and wallet access.'
                          : application.rejectionReason ??
                                'Please contact support if you have questions.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                    if (dateLabel.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      _DetailTile(label: 'Submitted on', value: dateLabel),
                    ],
                    const SizedBox(height: 20),
                    _DetailTile(
                      label: 'Applicant',
                      value: application.request.fullName,
                    ),
                    _DetailTile(
                      label: 'Email',
                      value: application.request.email,
                    ),
                    _DetailTile(
                      label: 'Platform',
                      value: application.request.platform,
                    ),
                    const SizedBox(height: 28),
                    if (isRejected)
                      TicketflixButton(
                        label: 'Apply again',
                        onPressed: () => ref
                            .read(affiliateStateProvider.notifier)
                            .resetApplication(),
                      ),
                    if (isPending) ...[
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'Typical review time: 24–48 hours. You will receive an email once a decision is made.',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton(
                        onPressed: () => ref
                            .read(affiliateStateProvider.notifier)
                            .simulateApproval(),
                        child: const Text('Demo: simulate admin approval'),
                      ),
                    ],
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

class _DetailTile extends StatelessWidget {
  const _DetailTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}
