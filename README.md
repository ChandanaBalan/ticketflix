# Ticketflix

Ticketflix is a mobile-first Flutter Web prototype inspired by modern cinema
discovery and ticket-booking experiences. Phase 1 is entirely frontend-driven:
all content comes from local mock repositories and no authentication, API,
database, payment, or seat-hold service is connected.

## Routes

- `/` — discovery home
- `/movies` — now-showing catalogue
- `/movies/:movieId` — movie details and language/format selection
- `/movies/:movieId/shows` — date, cinema, and showtime selection
- `/movies/:movieId/shows/:showId/seats` — ticket count, seat map, and terms

## Architecture

The project is organized by feature under `lib/features`, with application
routing and theming in `lib/app`, reusable visual primitives in `lib/core`, mock
data in `lib/data`, and API-ready domain models in `lib/shared`.

`MockRepository` is the temporary source for movies, cast, cinemas, and
showtimes. A future backend integration should implement the same repository
boundary and map API payloads to the existing domain models. `BookingDraft` is
the single source of truth for the selected format, showtime, ticket count, and
seats.

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
