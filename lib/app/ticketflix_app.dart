import 'package:flutter/material.dart';

import 'router.dart';
import 'theme.dart';

class TicketflixApp extends StatelessWidget {
  const TicketflixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Ticketflix',
      theme: buildTicketflixTheme(),
      routerConfig: ticketflixRouter,
    );
  }
}
