import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../core/responsive/responsive.dart';

class AuthShell extends StatelessWidget {
  const AuthShell({required this.child, this.showBack = true, super.key});

  final Widget child;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            child: ContentWidth(
              maxWidth: 440,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (showBack)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        tooltip: 'Back',
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      ),
                    ),
                  const SizedBox(height: 22),
                  const _AuthBrand(),
                  const SizedBox(height: 38),
                  child,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthBrand extends StatelessWidget {
  const _AuthBrand();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(13),
          ),
          child: const Icon(
            Icons.local_activity_rounded,
            color: Colors.white,
            size: 25,
          ),
        ),
        const SizedBox(width: 10),
        const Text(
          'ticketflix',
          style: TextStyle(
            color: AppColors.ink,
            fontSize: 25,
            fontWeight: FontWeight.w800,
            letterSpacing: -.7,
          ),
        ),
      ],
    );
  }
}

class AuthTextField extends StatelessWidget {
  const AuthTextField({
    required this.controller,
    required this.label,
    this.hintText,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.autofillHints,
    super.key,
  });

  final TextEditingController controller;
  final String label;
  final String? hintText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final Iterable<String>? autofillHints;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      autofillHints: autofillHints,
      validator: validator,
      decoration: InputDecoration(labelText: label, hintText: hintText),
    );
  }
}

class AuthMethodToggle extends StatelessWidget {
  const AuthMethodToggle({
    required this.usePhone,
    required this.onChanged,
    super.key,
  });

  final bool usePhone;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<bool>(
      segments: const [
        ButtonSegment(
          value: false,
          label: Text('Email'),
          icon: Icon(Icons.email_outlined),
        ),
        ButtonSegment(
          value: true,
          label: Text('Phone'),
          icon: Icon(Icons.phone_outlined),
        ),
      ],
      selected: {usePhone},
      onSelectionChanged: (selection) => onChanged(selection.first),
      style: ButtonStyle(
        visualDensity: VisualDensity.compact,
        side: const WidgetStatePropertyAll(BorderSide(color: AppColors.border)),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}

String? requiredField(String? value, String message) {
  if (value == null || value.trim().isEmpty) return message;
  return null;
}

String? emailValidator(String? value) {
  final required = requiredField(value, 'Enter your email address');
  if (required != null) return required;
  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value!.trim())) {
    return 'Enter a valid email address';
  }
  return null;
}

String? phoneValidator(String? value) {
  final required = requiredField(value, 'Enter your mobile number');
  if (required != null) return required;
  final digits = value!.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.length < 10 || digits.length > 15) {
    return 'Enter a valid mobile number';
  }
  return null;
}

String? otpValidator(String? value) {
  final required = requiredField(value, 'Enter the OTP');
  if (required != null) return required;
  if (!RegExp(r'^\d{6}$').hasMatch(value!.trim())) {
    return 'Enter the 6-digit OTP';
  }
  return null;
}

String? passwordValidator(String? value) {
  final required = requiredField(value, 'Enter a password');
  if (required != null) return required;
  if (value!.length < 6) return 'Use at least 6 characters';
  return null;
}
