enum AuthMethod { email, phone }

class AuthCredentials {
  const AuthCredentials({
    required this.method,
    this.email,
    this.phone,
    this.password,
    this.otp,
  });

  final AuthMethod method;
  final String? email;
  final String? phone;
  final String? password;
  final String? otp;
}

class RegistrationRequest {
  const RegistrationRequest({
    required this.name,
    required this.credentials,
    this.confirmPassword,
  });

  final String name;
  final AuthCredentials credentials;
  final String? confirmPassword;
}
