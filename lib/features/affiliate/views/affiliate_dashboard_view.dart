import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../../../core/design_system/widgets.dart';
import '../../../core/responsive/responsive.dart';
import '../models/affiliate_models.dart';
import '../view_models/affiliate_providers.dart';

class AffiliateDashboardView extends ConsumerWidget {
  const AffiliateDashboardView({required this.profile, super.key});

  final AffiliateProfile profile;

  void _copy(BuildContext context, String value, String label) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$label copied.')));
  }

  static String _formatDate(DateTime date) {
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
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commissionPercent = (profile.commissionRate * 100).round();
    final discountPercent = (profile.customerDiscountRate * 100).round();

    return Scaffold(
      body: Column(
        children: [
          DesktopHeader(onSignIn: () => context.push('/login')),
          TicketflixPageHeader(
            title: 'Affiliate dashboard',
            subtitle: profile.fullName,
            showBack: true,
          ),
          const Divider(height: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                context.isDesktop ? 24 : 16,
                20,
                context.isDesktop ? 24 : 16,
                36,
              ),
              child: ContentWidth(
                maxWidth: 720,
                padding: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.midnight, AppColors.primary],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Wallet balance',
                            style: TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '₹${profile.walletBalance}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Pending payout: ₹${profile.pendingPayout}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: profile.walletBalance >= 500
                                      ? () async {
                                          final success = await ref
                                              .read(
                                                affiliateStateProvider.notifier,
                                              )
                                              .withdrawWallet(
                                                profile.walletBalance,
                                              );
                                          if (context.mounted && success) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Withdrawal request submitted.',
                                                ),
                                              ),
                                            );
                                          }
                                        }
                                      : null,
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    disabledForegroundColor: Colors.white60,
                                    backgroundColor: Colors.white.withValues(alpha: .14),
                                    disabledBackgroundColor:
                                        Colors.white.withValues(alpha: .08),
                                    side: const BorderSide(color: Colors.white70),
                                    disabledMouseCursor: SystemMouseCursors.basic,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ).copyWith(
                                    side: WidgetStateProperty.resolveWith((
                                      states,
                                    ) {
                                      if (states.contains(WidgetState.disabled)) {
                                        return BorderSide(
                                          color: Colors.white.withValues(
                                            alpha: .35,
                                          ),
                                        );
                                      }
                                      return const BorderSide(
                                        color: Colors.white70,
                                      );
                                    }),
                                  ),
                                  child: const Text('Withdraw'),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Min. withdrawal ₹500',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: .8),
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _MetricCard(
                            label: 'Tickets sold',
                            value: '${profile.ticketsSold}',
                            icon: Icons.confirmation_number_outlined,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _MetricCard(
                            label: 'Total earnings',
                            value: '₹${profile.totalEarnings}',
                            icon: Icons.payments_outlined,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _MetricCard(
                            label: 'Your commission',
                            value: '$commissionPercent%',
                            icon: Icons.trending_up_rounded,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _MetricCard(
                            label: 'Customer offer',
                            value: '$discountPercent% off',
                            icon: Icons.local_offer_outlined,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Your coupon code',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    _CodeCard(
                      label: 'Coupon code',
                      value: profile.couponCode,
                      hint:
                          'Share this code — customers get $discountPercent% off and you earn $commissionPercent% commission',
                      onCopy: () => _copy(context, profile.couponCode, 'Coupon code'),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Profile',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    _InfoCard(
                      rows: [
                        ('Email', profile.email),
                        ('Phone', profile.phone),
                        ('City', profile.city),
                        ('Partner since', _formatDate(profile.approvedAt)),
                        ('Active bookings', '${profile.activeBookings}'),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Recent sales',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    if (profile.transactions.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'No ticket sales yet. Share your coupon code to start earning commission.',
                        ),
                      )
                    else
                      ...profile.transactions.map(
                        (tx) => _TransactionTile(transaction: tx),
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

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _CodeCard extends StatelessWidget {
  const _CodeCard({
    required this.label,
    required this.value,
    required this.hint,
    required this.onCopy,
  });

  final String label;
  final String value;
  final String hint;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accent),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: .5,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Copy',
                onPressed: onCopy,
                icon: const Icon(Icons.copy_rounded, color: AppColors.primary),
              ),
            ],
          ),
          Text(
            hint,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.rows});

  final List<(String, String)> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          for (final (label, value) in rows)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  SizedBox(
                    width: 130,
                    child: Text(
                      label,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      value,
                      style: const TextStyle(fontWeight: FontWeight.w500),
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

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.transaction});

  final AffiliateTransaction transaction;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.movieTitle,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  '${transaction.tickets} tickets  •  ₹${transaction.orderAmount}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Text(
            '+₹${transaction.commission}',
            style: const TextStyle(
              color: AppColors.success,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
