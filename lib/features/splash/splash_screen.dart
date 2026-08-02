import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import 'view_models/splash_view_model.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    )..forward();
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _scale = Tween<double>(
      begin: .86,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    ref.listenManual(splashViewModelProvider, (_, next) {
      next.whenOrNull(
        data: (_) {
          if (mounted) context.go('/login');
        },
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(splashViewModelProvider);
    return Scaffold(
      backgroundColor: AppColors.midnight,
      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: ScaleTransition(
            scale: _scale,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 92,
                  height: 92,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x55E63946),
                        blurRadius: 28,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.local_activity_rounded,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Ticketflix',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -.6,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your movie night starts here',
                  style: TextStyle(
                    color: AppColors.accent,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: .2,
                  ),
                ),
                const SizedBox(height: 44),
                const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    color: AppColors.accent,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
