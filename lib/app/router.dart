import 'package:go_router/go_router.dart';

import '../features/booking/seat_selection_page.dart';
import '../features/booking/showtimes_page.dart';
import '../features/auth/forgot_password_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/home/home_page.dart';
import '../features/movies/movie_detail_page.dart';
import '../features/movies/movie_list_page.dart';
import '../features/splash/splash_screen.dart';

final ticketflixRouter = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/home', builder: (context, state) => const HomePage()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/movies',
      builder: (context, state) => const MovieListPage(),
    ),
    GoRoute(
      path: '/movies/:movieId',
      builder: (context, state) => MovieDetailPage(
        movieId: state.pathParameters['movieId'] ?? 'spider-man-brand-new-day',
      ),
      routes: [
        GoRoute(
          path: 'shows',
          builder: (context, state) => ShowtimesPage(
            movieId:
                state.pathParameters['movieId'] ?? 'spider-man-brand-new-day',
          ),
          routes: [
            GoRoute(
              path: ':showId/seats',
              builder: (context, state) => SeatSelectionPage(
                movieId:
                    state.pathParameters['movieId'] ??
                    'spider-man-brand-new-day',
                showId: state.pathParameters['showId'] ?? '07-00',
              ),
            ),
          ],
        ),
      ],
    ),
  ],
);
