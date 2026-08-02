import 'package:flutter/material.dart';

import 'router.dart';
import 'theme.dart';
import 'theme_mode.dart';

class TicketflixApp extends StatefulWidget {
  const TicketflixApp({super.key});

  @override
  State<TicketflixApp> createState() => _TicketflixAppState();
}

class _TicketflixAppState extends State<TicketflixApp> {
  late final ThemeModeController _themeController = ThemeModeController();

  @override
  void dispose() {
    _themeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _themeController,
      builder: (context, _) => ThemeModeScope(
        notifier: _themeController,
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'Ticketflix',
          theme: buildTicketflixTheme(),
          darkTheme: buildTicketflixTheme(brightness: Brightness.dark),
          themeMode: _themeController.mode,
          routerConfig: ticketflixRouter,
        ),
      ),
    );
  }
}
