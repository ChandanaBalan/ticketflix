import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ticketflix_v2/app/ticketflix_app.dart';
import 'package:ticketflix_v2/features/booking/showtimes_page.dart';
import 'package:ticketflix_v2/features/movies/views/movie_list_view.dart';

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

  testWidgets('showtime filters narrow theatre results', (tester) async {
    tester.view.physicalSize = const Size(2400, 1600);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: ShowtimesPage(movieId: 'chithram')),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('PVR: Forum Mall, Kochi'), findsOneWidget);
    await tester.tap(find.text('Cancellable'));
    await tester.pumpAndSettle();
    expect(
      find.text('Vanitha-Vineetha Cineplex: MG Road, Kochi'),
      findsNothing,
    );

    await tester.tap(find.text('Cancellable'));
    await tester.tap(find.text('Special Formats'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView).last, const Offset(0, -1000));
    await tester.pumpAndSettle();
    expect(find.text('INOX: Lulu Mall, Edappally'), findsOneWidget);
    expect(
      find.text('Vanitha-Vineetha Cineplex: MG Road, Kochi'),
      findsNothing,
    );
  });
}
