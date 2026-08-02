import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ticketflix_v2/features/auth/models/auth_models.dart';
import 'package:ticketflix_v2/features/auth/repositories/auth_repository.dart';
import 'package:ticketflix_v2/features/auth/view_models/auth_providers.dart';

class _FakeAuthRepository implements AuthRepository {
  var otpRequests = 0;
  var signInRequests = 0;
  var resetRequests = 0;

  @override
  Future<void> requestOtp(String phoneNumber) async => otpRequests++;

  @override
  Future<void> signIn(AuthCredentials credentials) async => signInRequests++;

  @override
  Future<void> register(RegistrationRequest request) async {}

  @override
  Future<void> requestPasswordReset(String email) async => resetRequests++;
}

void main() {
  test('login ViewModel owns OTP and sign-in transitions', () async {
    final repository = _FakeAuthRepository();
    final container = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    final viewModel = container.read(loginViewModelProvider.notifier);
    viewModel.setMethod(true);

    expect(await viewModel.sendOtp('+91 98765 43210'), isTrue);
    expect(container.read(loginViewModelProvider).otpSent, isTrue);
    expect(repository.otpRequests, 1);

    expect(
      await viewModel.signIn(
        const AuthCredentials(
          method: AuthMethod.phone,
          phone: '+91 98765 43210',
          otp: '123456',
        ),
      ),
      isTrue,
    );
    expect(repository.signInRequests, 1);
    expect(container.read(loginViewModelProvider).isLoading, isFalse);
  });

  test('forgot-password ViewModel publishes submitted state', () async {
    final repository = _FakeAuthRepository();
    final container = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    final viewModel = container.read(forgotPasswordViewModelProvider.notifier);

    expect(await viewModel.sendResetLink('guest@example.com'), isTrue);
    expect(container.read(forgotPasswordViewModelProvider).submitted, isTrue);
    expect(repository.resetRequests, 1);
  });
}
