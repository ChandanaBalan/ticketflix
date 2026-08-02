import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../core/design_system/widgets.dart';
import 'auth_widgets.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  var _submitted = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _sendResetLink() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _submitted = true);
  }

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      child: _submitted
          ? _ResetLinkSent(email: _emailController.text.trim())
          : Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Forgot your password?',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Enter your email and we’ll send you a secure reset link.',
                    style: TextStyle(color: AppColors.muted, fontSize: 15),
                  ),
                  const SizedBox(height: 28),
                  AuthTextField(
                    controller: _emailController,
                    label: 'Email address',
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.email],
                    validator: emailValidator,
                  ),
                  const SizedBox(height: 24),
                  TicketflixButton(
                    label: 'Send reset link',
                    icon: Icons.mail_outline_rounded,
                    onPressed: _sendResetLink,
                  ),
                  const SizedBox(height: 14),
                  TextButton(
                    onPressed: () => context.go('/login'),
                    child: const Text('Back to sign in'),
                  ),
                ],
              ),
            ),
    );
  }
}

class _ResetLinkSent extends StatelessWidget {
  const _ResetLinkSent({required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: const BoxDecoration(
            color: AppColors.softAccent,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.mark_email_read_outlined,
            color: AppColors.primary,
            size: 36,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Check your inbox',
          style: Theme.of(context).textTheme.displaySmall,
        ),
        const SizedBox(height: 10),
        Text(
          'If an account exists for $email, we’ve sent instructions to reset your password.',
          style: const TextStyle(
            color: AppColors.muted,
            fontSize: 15,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 26),
        TicketflixButton(
          label: 'Back to sign in',
          onPressed: () => context.go('/login'),
        ),
        const SizedBox(height: 12),
        TextButton(onPressed: () {}, child: const Text('Resend email')),
      ],
    );
  }
}
