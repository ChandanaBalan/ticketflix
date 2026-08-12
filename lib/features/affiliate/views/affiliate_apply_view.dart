import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme.dart';
import '../../../core/design_system/widgets.dart';
import '../../../core/responsive/responsive.dart';
import '../models/affiliate_models.dart';
import '../view_models/affiliate_providers.dart';

class AffiliateApplyView extends ConsumerStatefulWidget {
  const AffiliateApplyView({super.key});

  @override
  ConsumerState<AffiliateApplyView> createState() => _AffiliateApplyViewState();
}

class _AffiliateApplyViewState extends ConsumerState<AffiliateApplyView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController(text: 'Kochi');
  final _platformController = TextEditingController();
  final _audienceController = TextEditingController();
  final _reasonController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _platformController.dispose();
    _audienceController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final success = await ref
        .read(affiliateApplicationFormProvider.notifier)
        .submit(
          AffiliateApplicationRequest(
            fullName: _nameController.text.trim(),
            email: _emailController.text.trim(),
            phone: _phoneController.text.trim(),
            city: _cityController.text.trim(),
            platform: _platformController.text.trim(),
            audienceSize: _audienceController.text.trim(),
            reason: _reasonController.text.trim(),
          ),
        );
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Application submitted. Our team will review it within 24–48 hours.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(affiliateApplicationFormProvider);

    return Scaffold(
      body: Column(
        children: [
          DesktopHeader(onSignIn: () => context.push('/login')),
          const TicketflixPageHeader(
            title: 'Affiliate Application',
            subtitle: 'Selective partner program',
            showBack: true,
          ),
          const Divider(height: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                context.isDesktop ? 24 : 16,
                20,
                context.isDesktop ? 24 : 16,
                32,
              ),
              child: ContentWidth(
                maxWidth: 640,
                padding: EdgeInsets.zero,
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _ProgramBenefitsCard(),
                      const SizedBox(height: 24),
                      Text(
                        'Your details',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Ticketflix affiliates are reviewed manually. Not all applications are approved.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 18),
                      _Field(
                        controller: _nameController,
                        label: 'Full name',
                        hint: 'Enter your full name',
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? 'Name is required'
                            : null,
                      ),
                      const SizedBox(height: 14),
                      _Field(
                        controller: _emailController,
                        label: 'Email',
                        hint: 'you@example.com',
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) =>
                            value == null || !value.contains('@')
                            ? 'Enter a valid email'
                            : null,
                      ),
                      const SizedBox(height: 14),
                      _Field(
                        controller: _phoneController,
                        label: 'Phone number',
                        hint: '10-digit mobile number',
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        validator: (value) {
                          final digits = value?.replaceAll(RegExp(r'\D'), '') ?? '';
                          if (digits.length != 10) {
                            return 'Enter a 10-digit mobile number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      _Field(
                        controller: _cityController,
                        label: 'Primary city',
                        hint: 'Where do you sell most tickets?',
                      ),
                      const SizedBox(height: 14),
                      _Field(
                        controller: _platformController,
                        label: 'Platform / audience',
                        hint: 'Instagram, YouTube, college club, etc.',
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? 'Tell us where your audience is'
                            : null,
                      ),
                      const SizedBox(height: 14),
                      _Field(
                        controller: _audienceController,
                        label: 'Approx. audience size',
                        hint: 'e.g. 5,000 followers or 200 members',
                      ),
                      const SizedBox(height: 14),
                      _Field(
                        controller: _reasonController,
                        label: 'Why do you want to join?',
                        hint: 'How will you promote Ticketflix?',
                        maxLines: 4,
                        validator: (value) =>
                            value == null || value.trim().length < 20
                            ? 'Please share a bit more detail'
                            : null,
                      ),
                      const SizedBox(height: 24),
                      TicketflixButton(
                        label: formState.isLoading
                            ? 'Submitting...'
                            : 'Submit application',
                        onPressed: formState.isLoading ? null : _submit,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgramBenefitsCard extends StatelessWidget {
  const _ProgramBenefitsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accent),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Partner benefits',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const SizedBox(height: 12),
          const _BenefitRow(
            icon: Icons.percent_rounded,
            text: '3% commission on every ticket sold with your code',
          ),
          const _BenefitRow(
            icon: Icons.local_offer_outlined,
            text: 'Your audience gets 3% off when they use your coupon',
          ),
          const _BenefitRow(
            icon: Icons.account_balance_wallet_outlined,
            text: 'Track earnings in your affiliate wallet',
          ),
          const _BenefitRow(
            icon: Icons.verified_user_outlined,
            text: 'Approval required — selective partner onboarding',
          ),
        ],
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  const _BenefitRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    required this.hint,
    this.validator,
    this.keyboardType,
    this.maxLines = 1,
    this.maxLength,
    this.inputFormatters,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final int maxLines;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          maxLines: maxLines,
          maxLength: maxLength,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }
}
