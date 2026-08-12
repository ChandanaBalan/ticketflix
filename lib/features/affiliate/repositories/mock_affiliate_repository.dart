import '../models/affiliate_models.dart';
import 'affiliate_repository.dart';

class MockAffiliateRepository implements AffiliateRepository {
  MockAffiliateRepository();

  AffiliateState _state = const AffiliateState();

  @override
  Future<AffiliateState> fetchState() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return _state;
  }

  @override
  Future<void> submitApplication(AffiliateApplicationRequest request) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    _state = _state.copyWith(
      application: AffiliateApplication(
        request: request,
        status: AffiliateApplicationStatus.pending,
        submittedAt: DateTime.now(),
      ),
      clearProfile: true,
    );
  }

  /// Demo helper simulating admin approval after review.
  Future<void> simulateApproval() async {
    final application = _state.application;
    if (application == null) return;
    final request = application.request;
    final code = _couponFromName(request.fullName);
    _state = _state.copyWith(
      application: AffiliateApplication(
        request: request,
        status: AffiliateApplicationStatus.approved,
        submittedAt: application.submittedAt,
        reviewedAt: DateTime.now(),
      ),
      profile: AffiliateProfile(
        fullName: request.fullName,
        email: request.email,
        phone: request.phone,
        city: request.city,
        couponCode: code,
        referralCode: 'TFX-${code.split('-').last}',
        commissionRate: 0.03,
        customerDiscountRate: 0.03,
        walletBalance: 0,
        pendingPayout: 0,
        totalEarnings: 0,
        ticketsSold: 0,
        activeBookings: 0,
        approvedAt: DateTime.now(),
        transactions: const [],
      ),
    );
  }

  Future<void> resetApplication() async {
    _state = _state.copyWith(clearApplication: true, clearProfile: true);
  }

  Future<void> simulateRejection({String? reason}) async {
    final application = _state.application;
    if (application == null) return;
    _state = _state.copyWith(
      application: AffiliateApplication(
        request: application.request,
        status: AffiliateApplicationStatus.rejected,
        submittedAt: application.submittedAt,
        reviewedAt: DateTime.now(),
        rejectionReason:
            reason ??
            'We could not verify your audience reach at this time. You may reapply after 30 days with updated details.',
      ),
      clearProfile: true,
    );
  }

  @override
  Future<void> withdrawWallet(int amount) async {
    final profile = _state.profile;
    if (profile == null || amount > profile.walletBalance) return;
    await Future<void>.delayed(const Duration(milliseconds: 400));
    _state = _state.copyWith(
      profile: AffiliateProfile(
        fullName: profile.fullName,
        email: profile.email,
        phone: profile.phone,
        city: profile.city,
        couponCode: profile.couponCode,
        referralCode: profile.referralCode,
        commissionRate: profile.commissionRate,
        customerDiscountRate: profile.customerDiscountRate,
        walletBalance: profile.walletBalance - amount,
        pendingPayout: profile.pendingPayout + amount,
        totalEarnings: profile.totalEarnings,
        ticketsSold: profile.ticketsSold,
        activeBookings: profile.activeBookings,
        transactions: profile.transactions,
        approvedAt: profile.approvedAt,
      ),
    );
  }

  String _couponFromName(String fullName) {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    final suffix = parts.isEmpty
        ? 'PARTNER'
        : parts.first.toUpperCase().substring(0, parts.first.length.clamp(1, 6));
    return 'TFX-$suffix';
  }
}
