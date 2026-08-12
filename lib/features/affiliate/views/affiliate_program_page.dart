import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/affiliate_models.dart';
import '../view_models/affiliate_providers.dart';
import 'affiliate_apply_view.dart';
import 'affiliate_dashboard_view.dart';
import 'affiliate_status_view.dart';

class AffiliateProgramPage extends ConsumerWidget {
  const AffiliateProgramPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(affiliateStateProvider);

    return state.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) =>
          Scaffold(body: Center(child: Text('Unable to load affiliate: $error'))),
      data: (data) => switch (data.status) {
        AffiliateApplicationStatus.approved when data.profile != null =>
          AffiliateDashboardView(profile: data.profile!),
        AffiliateApplicationStatus.pending =>
          AffiliateStatusView(application: data.application!),
        AffiliateApplicationStatus.rejected =>
          AffiliateStatusView(application: data.application!),
        _ => const AffiliateApplyView(),
      },
    );
  }
}
