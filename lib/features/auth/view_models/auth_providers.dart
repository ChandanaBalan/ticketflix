import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/auth_models.dart';
import '../repositories/auth_repository.dart';
import '../repositories/mock_auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return const MockAuthRepository();
});

class AuthFormState {
  const AuthFormState({
    this.method = AuthMethod.email,
    this.otpSent = false,
    this.isLoading = false,
    this.submitted = false,
    this.error,
  });

  final AuthMethod method;
  final bool otpSent;
  final bool isLoading;
  final bool submitted;
  final Object? error;

  AuthFormState copyWith({
    AuthMethod? method,
    bool? otpSent,
    bool? isLoading,
    bool? submitted,
    Object? error,
    bool clearError = false,
  }) {
    return AuthFormState(
      method: method ?? this.method,
      otpSent: otpSent ?? this.otpSent,
      isLoading: isLoading ?? this.isLoading,
      submitted: submitted ?? this.submitted,
      error: clearError ? null : error ?? this.error,
    );
  }
}

final loginViewModelProvider =
    NotifierProvider<LoginViewModel, AuthFormState>(LoginViewModel.new);

class LoginViewModel extends Notifier<AuthFormState> {
  @override
  AuthFormState build() => const AuthFormState();

  void setMethod(bool usePhone) {
    state = state.copyWith(
      method: usePhone ? AuthMethod.phone : AuthMethod.email,
      otpSent: false,
      clearError: true,
    );
  }

  void resetOtp() => state = state.copyWith(otpSent: false);

  Future<bool> sendOtp(String phone) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await ref.read(authRepositoryProvider).requestOtp(phone);
      state = state.copyWith(isLoading: false, otpSent: true);
      return true;
    } catch (error) {
      state = state.copyWith(isLoading: false, error: error);
      return false;
    }
  }

  Future<bool> signIn(AuthCredentials credentials) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await ref.read(authRepositoryProvider).signIn(credentials);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (error) {
      state = state.copyWith(isLoading: false, error: error);
      return false;
    }
  }
}

final registerViewModelProvider =
    NotifierProvider<RegisterViewModel, AuthFormState>(RegisterViewModel.new);

class RegisterViewModel extends Notifier<AuthFormState> {
  @override
  AuthFormState build() => const AuthFormState();

  void setMethod(bool usePhone) {
    state = state.copyWith(
      method: usePhone ? AuthMethod.phone : AuthMethod.email,
      otpSent: false,
      clearError: true,
    );
  }

  void resetOtp() => state = state.copyWith(otpSent: false);

  Future<bool> sendOtp(String phone) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await ref.read(authRepositoryProvider).requestOtp(phone);
      state = state.copyWith(isLoading: false, otpSent: true);
      return true;
    } catch (error) {
      state = state.copyWith(isLoading: false, error: error);
      return false;
    }
  }

  Future<bool> register(RegistrationRequest request) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await ref.read(authRepositoryProvider).register(request);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (error) {
      state = state.copyWith(isLoading: false, error: error);
      return false;
    }
  }
}

final forgotPasswordViewModelProvider = NotifierProvider.autoDispose<
    ForgotPasswordViewModel, AuthFormState>(ForgotPasswordViewModel.new);

class ForgotPasswordViewModel extends AutoDisposeNotifier<AuthFormState> {
  @override
  AuthFormState build() => const AuthFormState();

  Future<bool> sendResetLink(String email) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await ref.read(authRepositoryProvider).requestPasswordReset(email);
      state = state.copyWith(isLoading: false, submitted: true);
      return true;
    } catch (error) {
      state = state.copyWith(isLoading: false, error: error);
      return false;
    }
  }
}
