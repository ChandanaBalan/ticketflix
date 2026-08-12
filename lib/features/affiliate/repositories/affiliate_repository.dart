import '../models/affiliate_models.dart';

abstract interface class AffiliateRepository {
  Future<AffiliateState> fetchState();

  Future<void> submitApplication(AffiliateApplicationRequest request);

  Future<void> withdrawWallet(int amount);
}
