enum AffiliateApplicationStatus { none, pending, approved, rejected }

class ReferralProgram {
  const ReferralProgram({
    required this.referralCode,
    required this.referralLink,
    required this.friendsInvited,
    required this.rewardsEarned,
    required this.pendingRewards,
  });

  final String referralCode;
  final String referralLink;
  final int friendsInvited;
  final int rewardsEarned;
  final int pendingRewards;
}

class AffiliateApplicationRequest {
  const AffiliateApplicationRequest({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.city,
    required this.platform,
    required this.audienceSize,
    required this.reason,
  });

  final String fullName;
  final String email;
  final String phone;
  final String city;
  final String platform;
  final String audienceSize;
  final String reason;
}

class AffiliateApplication {
  const AffiliateApplication({
    required this.request,
    required this.status,
    this.submittedAt,
    this.reviewedAt,
    this.rejectionReason,
  });

  final AffiliateApplicationRequest request;
  final AffiliateApplicationStatus status;
  final DateTime? submittedAt;
  final DateTime? reviewedAt;
  final String? rejectionReason;
}

class AffiliateTransaction {
  const AffiliateTransaction({
    required this.id,
    required this.movieTitle,
    required this.tickets,
    required this.orderAmount,
    required this.commission,
    required this.date,
  });

  final String id;
  final String movieTitle;
  final int tickets;
  final int orderAmount;
  final int commission;
  final DateTime date;
}

class AffiliateProfile {
  const AffiliateProfile({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.city,
    required this.couponCode,
    required this.referralCode,
    required this.commissionRate,
    required this.customerDiscountRate,
    required this.walletBalance,
    required this.pendingPayout,
    required this.totalEarnings,
    required this.ticketsSold,
    required this.activeBookings,
    required this.transactions,
    required this.approvedAt,
  });

  final String fullName;
  final String email;
  final String phone;
  final String city;
  final String couponCode;
  final String referralCode;
  final double commissionRate;
  final double customerDiscountRate;
  final int walletBalance;
  final int pendingPayout;
  final int totalEarnings;
  final int ticketsSold;
  final int activeBookings;
  final List<AffiliateTransaction> transactions;
  final DateTime approvedAt;
}

class AffiliateState {
  const AffiliateState({
    this.application,
    this.profile,
    this.referral = const ReferralProgram(
      referralCode: 'TFX-CHAND7',
      referralLink: 'https://ticketflix.app/r/TFX-CHAND7',
      friendsInvited: 4,
      rewardsEarned: 120,
      pendingRewards: 40,
    ),
  });

  final AffiliateApplication? application;
  final AffiliateProfile? profile;
  final ReferralProgram referral;

  AffiliateApplicationStatus get status =>
      application?.status ?? AffiliateApplicationStatus.none;

  AffiliateState copyWith({
    AffiliateApplication? application,
    AffiliateProfile? profile,
    ReferralProgram? referral,
    bool clearApplication = false,
    bool clearProfile = false,
  }) {
    return AffiliateState(
      application: clearApplication ? null : application ?? this.application,
      profile: clearProfile ? null : profile ?? this.profile,
      referral: referral ?? this.referral,
    );
  }
}
