import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/affiliate_models.dart';
import '../repositories/affiliate_repository.dart';
import '../repositories/mock_affiliate_repository.dart';

final affiliateRepositoryProvider = Provider<AffiliateRepository>((ref) {
  return MockAffiliateRepository();
});

final affiliateStateProvider =
    AsyncNotifierProvider<AffiliateStateNotifier, AffiliateState>(
      AffiliateStateNotifier.new,
    );

class AffiliateStateNotifier extends AsyncNotifier<AffiliateState> {
  MockAffiliateRepository get _mockRepo =>
      ref.read(affiliateRepositoryProvider) as MockAffiliateRepository;

  @override
  Future<AffiliateState> build() =>
      ref.read(affiliateRepositoryProvider).fetchState();

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(affiliateRepositoryProvider).fetchState(),
    );
  }

  Future<bool> submitApplication(AffiliateApplicationRequest request) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(affiliateRepositoryProvider).submitApplication(request);
      state = AsyncValue.data(await _mockRepo.fetchState());
      return true;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return false;
    }
  }

  Future<void> simulateApproval() async {
    await _mockRepo.simulateApproval();
    state = AsyncValue.data(await _mockRepo.fetchState());
  }

  Future<void> simulateRejection() async {
    await _mockRepo.simulateRejection();
    state = AsyncValue.data(await _mockRepo.fetchState());
  }

  Future<void> resetApplication() async {
    await _mockRepo.resetApplication();
    state = AsyncValue.data(await _mockRepo.fetchState());
  }

  Future<bool> withdrawWallet(int amount) async {
    final current = state.valueOrNull;
    if (current?.profile == null) return false;
    try {
      await ref.read(affiliateRepositoryProvider).withdrawWallet(amount);
      state = AsyncValue.data(await _mockRepo.fetchState());
      return true;
    } catch (_) {
      return false;
    }
  }
}

class AffiliateApplicationFormState {
  const AffiliateApplicationFormState({
    this.isLoading = false,
    this.error,
  });

  final bool isLoading;
  final Object? error;

  AffiliateApplicationFormState copyWith({bool? isLoading, Object? error}) {
    return AffiliateApplicationFormState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

final affiliateApplicationFormProvider =
    NotifierProvider<AffiliateApplicationFormNotifier,
        AffiliateApplicationFormState>(
      AffiliateApplicationFormNotifier.new,
    );

class AffiliateApplicationFormNotifier
    extends Notifier<AffiliateApplicationFormState> {
  @override
  AffiliateApplicationFormState build() => const AffiliateApplicationFormState();

  Future<bool> submit(AffiliateApplicationRequest request) async {
    state = state.copyWith(isLoading: true);
    final success = await ref
        .read(affiliateStateProvider.notifier)
        .submitApplication(request);
    state = state.copyWith(isLoading: false);
    return success;
  }
}
