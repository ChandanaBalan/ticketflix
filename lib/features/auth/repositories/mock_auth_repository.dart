import '../models/auth_models.dart';
import 'auth_repository.dart';

class MockAuthRepository implements AuthRepository {
  const MockAuthRepository();

  @override
  Future<void> requestOtp(String phoneNumber) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
  }

  @override
  Future<void> signIn(AuthCredentials credentials) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<void> register(RegistrationRequest request) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<void> requestPasswordReset(String email) async {}
}
