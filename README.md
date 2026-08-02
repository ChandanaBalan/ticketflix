# Ticketflix

Ticketflix is a mobile-first Flutter Web prototype inspired by modern cinema
discovery and ticket-booking experiences. Phase 1 is entirely frontend-driven:
all content comes from local mock repositories and no authentication, API,
database, payment, or seat-hold service is connected.

The startup flow is splash screen → authentication → home. Users can sign in,
create an account, use phone OTP authentication, or continue as a guest.

## Routes

- `/` — discovery home
- `/login` — sign in
- `/register` — create an account
- `/forgot-password` — request a password reset link
- `/movies` — now-showing catalogue
- `/movies/:movieId` — movie details and language/format selection
- `/movies/:movieId/shows` — date, cinema, and showtime selection
- `/movies/:movieId/shows/:showId/seats` — ticket count, seat map, and terms

## Architecture

The project uses a lightweight feature-based MVVM structure. Each feature owns
its models, repository contracts and implementations, ViewModels, views, and
feature widgets. Views render Riverpod state and handle Flutter-only concerns
such as controllers, focus, animations, dialogs, snackbars, and navigation.
ViewModels own user-visible state and business rules, while repositories hide
mock or future network data sources.

`lib/app` contains composition, routing, and theme assembly. `lib/core`
contains feature-neutral design-system and responsive helpers. Features may
depend on core and on public models or repositories from another feature, but
core must never import a feature and ViewModels must not depend on `BuildContext`
or GoRouter.

Repository providers are typed to interfaces, so production implementations can
replace the current mock implementations through Riverpod overrides. The
booking session ViewModel is the single source of truth for selected format,
showtime, ticket count, and seats across the booking flow.

## Responsive behavior

- Below 600 px: screenshot-matched mobile composition and bottom navigation.
- 600–1023 px: expanded gutters and denser grids.
- 1024 px and above: desktop header, wide content rails, multi-column discovery,
  and constrained booking surfaces.

## Development

```sh
flutter pub get
flutter run -d chrome
flutter analyze
flutter test
flutter build web --release
```

The `hosting/sites_worker.js` entry provides static-asset delivery and
single-page route fallback for the hosted Flutter build.

Phase 2 integration points include customer identity, discovery APIs, timed seat
holds, checkout, referrals, payment webhooks, ticket issuance, and booking
history.
