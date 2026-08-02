import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ticketflix_v2/app/ticketflix_app.dart';
import 'package:ticketflix_v2/features/movies/movie_list_page.dart';

void main() {
  testWidgets('home renders at the target mobile width', (tester) async {
    tester.view.physicalSize = const Size(738, 1600);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const ProviderScope(child: TicketflixApp()));
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Continue as guest'), findsOneWidget);
    await tester.tap(find.text('Continue as guest'));
    await tester.pumpAndSettle();

    expect(find.text('It All Starts Here!'), findsOneWidget);
    expect(find.text('Recommended Movies'), findsOneWidget);
    expect(find.text('Search'), findsOneWidget);
  });

  testWidgets('movie cards do not overflow at the target mobile width', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(738, 1600);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: MovieListPage())),
    );
    await tester.pumpAndSettle();

    expect(find.text('Now Showing'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
