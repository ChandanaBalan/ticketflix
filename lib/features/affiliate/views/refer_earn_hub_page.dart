import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../../../core/design_system/widgets.dart';
import '../../../core/responsive/responsive.dart';
import '../models/affiliate_models.dart';
import '../view_models/affiliate_providers.dart';

class ReferEarnHubPage extends ConsumerWidget {
  const ReferEarnHubPage({super.key});

  void _copy(BuildContext context, String value, String label) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$label copied.')));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final affiliateState = ref.watch(affiliateStateProvider);

    return Scaffold(
      body: Column(
        children: [
          DesktopHeader(onSignIn: () => context.push('/login')),
          const TicketflixPageHeader(
            title: 'Refer & Earn',
            subtitle: 'Invite friends and grow with Ticketflix',
            showBack: true,
          ),
          const Divider(height: 1),
          Expanded(
            child: affiliateState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) =>
                  Center(child: Text('Unable to load rewards: $error')),
              data: (state) => SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  context.isDesktop ? 24 : 16,
                  20,
                  context.isDesktop ? 24 : 16,
                  36,
                ),
                child: ContentWidth(
                  padding: EdgeInsets.zero,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _ReferEarnHero(
                        referral: state.referral,
                        onCopyCode: () => _copy(
                          context,
                          state.referral.referralCode,
                          'Referral code',
                        ),
                        onCopyLink: () => _copy(
                          context,
                          state.referral.referralLink,
                          'Referral link',
                        ),
                        onShare: () => ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(
                            const SnackBar(
                              content: Text('Share sheet will open in Phase 2.'),
                            ),
                          ),
                      ),
                      const SizedBox(height: 28),
                      Text(
                        'How Refer & Earn works',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 14),
                      const _StepRow(
                        step: '1',
                        title: 'Share your link',
                        subtitle:
                            'Send your personal Ticketflix referral link to friends.',
                      ),
                      const _StepRow(
                        step: '2',
                        title: 'Friends book tickets',
                        subtitle:
                            'They sign up and complete their first booking through your link.',
                      ),
                      const _StepRow(
                        step: '3',
                        title: 'You earn rewards',
                        subtitle:
                            'Get wallet credits when their booking is confirmed.',
                      ),
                      const SizedBox(height: 28),
                      Text(
                        'Affiliate Program',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sell tickets with your coupon code. You earn 3% commission and your audience gets 3% off.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 14),
                      _AffiliateProgramCard(
                        status: state.status,
                        profile: state.profile,
                        onTap: () => context.push('/refer-earn/affiliate'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReferEarnHero extends StatelessWidget {
  const _ReferEarnHero({
    required this.referral,
    required this.onCopyCode,
    required this.onCopyLink,
    required this.onShare,
  });

  final ReferralProgram referral;
  final VoidCallback onCopyCode;
  final VoidCallback onCopyLink;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.midnight, AppColors.primary],
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            children: [
              Icon(Icons.card_giftcard_rounded, color: Colors.white, size: 28),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Your referral rewards',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  label: 'Friends invited',
                  value: '${referral.friendsInvited}',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatTile(
                  label: 'Rewards earned',
                  value: '₹${referral.rewardsEarned}',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatTile(
                  label: 'Pending',
                  value: '₹${referral.pendingRewards}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Referral code',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        referral.referralCode,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          letterSpacing: .4,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Copy code',
                  onPressed: onCopyCode,
                  icon: const Icon(Icons.copy_rounded, color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onCopyLink,
                  icon: const Icon(Icons.link_rounded, size: 18),
                  label: const Text('Copy link'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white54),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: onShare,
                  icon: const Icon(Icons.share_rounded, size: 18),
                  label: const Text('Share'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: AppColors.midnight,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.step,
    required this.title,
    required this.subtitle,
  });

  final String step;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondaryContainer,
              shape: BoxShape.circle,
            ),
            child: Text(
              step,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
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

class _AffiliateProgramCard extends StatelessWidget {
  const _AffiliateProgramCard({
    required this.status,
    required this.profile,
    required this.onTap,
  });

  final AffiliateApplicationStatus status;
  final AffiliateProfile? profile;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (title, subtitle, action, icon) = switch (status) {
      AffiliateApplicationStatus.approved => (
        'Affiliate dashboard',
        profile == null
            ? 'Manage your coupon code, wallet, and sales.'
            : '${profile!.couponCode}  •  Wallet ₹${profile!.walletBalance}',
        'Open dashboard',
        Icons.dashboard_rounded,
      ),
      AffiliateApplicationStatus.pending => (
        'Application under review',
        'Our team is verifying your details. Approval is selective.',
        'View status',
        Icons.hourglass_top_rounded,
      ),
      AffiliateApplicationStatus.rejected => (
        'Application not approved',
        'You can review the feedback and apply again.',
        'View details',
        Icons.info_outline_rounded,
      ),
      AffiliateApplicationStatus.none => (
        'Become an affiliate partner',
        'Apply with your details. Earn 3% commission on every ticket sold.',
        'Apply now',
        Icons.handshake_outlined,
      ),
    };

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
