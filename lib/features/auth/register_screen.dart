import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../core/design_system/widgets.dart';
import 'auth_widgets.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _otpController = TextEditingController();
  var _usePhone = false;
  var _otpSent = false;
  var _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _otpSent = true);
  }

  void _setAuthMethod(bool usePhone) {
    setState(() {
      _usePhone = usePhone;
      _otpSent = false;
      _otpController.clear();
    });
  }

  Future<void> _register() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isLoading = true);
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Create your account',
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: 8),
            const Text(
              'Save favourites, manage bookings, and never miss a premiere.',
              style: TextStyle(color: AppColors.muted, fontSize: 15),
            ),
            const SizedBox(height: 28),
            AuthTextField(
              controller: _nameController,
              label: 'Full name',
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.name],
              validator: (value) =>
                  requiredField(value, 'Enter your full name'),
            ),
            const SizedBox(height: 16),
            AuthMethodToggle(usePhone: _usePhone, onChanged: _setAuthMethod),
            const SizedBox(height: 16),
            if (_usePhone)
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
                autofillHints: const [AutofillHints.email],
                validator: emailValidator,
              ),
            const SizedBox(height: 16),
            if (_usePhone && _otpSent) ...[
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
                  onPressed: () => setState(() {
                    _otpSent = false;
                    _otpController.clear();
                  }),
                  child: const Text('Change number'),
                ),
              ),
            ] else if (!_usePhone) ...[
              AuthTextField(
                controller: _passwordController,
                label: 'Password',
                obscureText: true,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.newPassword],
                validator: passwordValidator,
              ),
              const SizedBox(height: 16),
              AuthTextField(
                controller: _confirmController,
                label: 'Confirm password',
                obscureText: true,
                textInputAction: TextInputAction.done,
                validator: (value) => value != _passwordController.text
                    ? 'Passwords do not match'
                    : null,
              ),
            ],
            const SizedBox(height: 24),
            TicketflixButton(
              label: _isLoading
                  ? 'Creating account...'
                  : _usePhone && !_otpSent
                  ? 'Send OTP'
                  : 'Create account',
              icon: _usePhone && !_otpSent
                  ? Icons.sms_outlined
                  : Icons.person_add_alt_rounded,
              onPressed: _isLoading
                  ? null
                  : _usePhone && !_otpSent
                  ? _sendOtp
                  : _register,
            ),
            const SizedBox(height: 22),
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Text('Already have an account?'),
                TextButton(
                  onPressed: () => context.go('/login'),
                  child: const Text('Sign in'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
