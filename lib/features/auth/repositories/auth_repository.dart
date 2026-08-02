import '../models/auth_models.dart';

abstract interface class AuthRepository {
  Future<void> requestOtp(String phoneNumber);

  Future<void> signIn(AuthCredentials credentials);

  Future<void> register(RegistrationRequest request);

  Future<void> requestPasswordReset(String email);
}
