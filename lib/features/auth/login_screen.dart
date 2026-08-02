import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../core/design_system/widgets.dart';
import 'models/auth_models.dart';
import 'auth_widgets.dart';
import 'view_models/auth_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _otpController = TextEditingController();
  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await ref.read(loginViewModelProvider.notifier).sendOtp(
      _phoneController.text.trim(),
    );
  }

  void _setAuthMethod(bool usePhone) {
    ref.read(loginViewModelProvider.notifier).setMethod(usePhone);
    _otpController.clear();
  }

  Future<void> _login() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final state = ref.read(loginViewModelProvider);
    final success = await ref.read(loginViewModelProvider.notifier).signIn(
      AuthCredentials(
        method: state.method,
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        password: _passwordController.text,
        otp: _otpController.text.trim(),
      ),
    );
    if (success && mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loginViewModelProvider);
    final usePhone = state.method == AuthMethod.phone;
    final otpSent = state.otpSent;
    final isLoading = state.isLoading;
    return AuthShell(
      showBack: false,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Welcome back',
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: 8),
            const Text(
              'Sign in to pick up your next movie night.',
              style: TextStyle(color: AppColors.muted, fontSize: 15),
            ),
            const SizedBox(height: 28),
            AuthMethodToggle(usePhone: usePhone, onChanged: _setAuthMethod),
            const SizedBox(height: 16),
            if (usePhone)
              AuthTextField(
                controller: _phoneController,
                label: 'Mobile number',
                hintText: '+91 98765 43210',
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.telephoneNumber],
                validator: phoneValidator,
              )
            else
              AuthTextField(
                controller: _emailController,
                label: 'Email address',
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [
                  AutofillHints.username,
                  AutofillHints.email,
                ],
                validator: emailValidator,
              ),
            const SizedBox(height: 16),
            if (usePhone && otpSent) ...[
              Text(
                'We sent a 6-digit OTP to ${_phoneController.text.trim()}.',
                style: const TextStyle(color: AppColors.muted, fontSize: 14),
              ),
              const SizedBox(height: 16),
              AuthTextField(
                controller: _otpController,
                label: 'Enter OTP',
                hintText: '6-digit code',
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                validator: otpValidator,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    ref.read(loginViewModelProvider.notifier).resetOtp();
                    _otpController.clear();
                  },
                  child: const Text('Change number'),
                ),
              ),
            ] else if (!usePhone) ...[
              AuthTextField(
                controller: _passwordController,
                label: 'Password',
                obscureText: true,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.password],
                validator: passwordValidator,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => context.push('/forgot-password'),
                  child: const Text('Forgot password?'),
                ),
              ),
            ],
            TicketflixButton(
              label: isLoading
                  ? 'Signing in...'
                  : usePhone && !otpSent
                  ? 'Send OTP'
                  : 'Sign in',
              icon: usePhone && !otpSent
                  ? Icons.sms_outlined
                  : Icons.login_rounded,
              onPressed: isLoading
                  ? null
                  : usePhone && !otpSent
                  ? _sendOtp
                  : _login,
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: isLoading ? null : () => context.go('/home'),
              icon: const Icon(Icons.explore_outlined),
              label: const Text('Continue as guest'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                foregroundColor: AppColors.ink,
                side: const BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'OR',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 18),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.g_mobiledata_rounded, size: 26),
              label: const Text('Continue with Google'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                foregroundColor: AppColors.ink,
                side: const BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 26),
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Text('New to Ticketflix?'),
                TextButton(
                  onPressed: () => context.push('/register'),
                  child: const Text('Create an account'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
