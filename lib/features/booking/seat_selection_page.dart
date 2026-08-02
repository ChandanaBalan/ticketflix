import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../core/design_system/widgets.dart';
import '../../core/responsive/responsive.dart';
import 'models/booking_models.dart';
import 'view_models/booking_providers.dart';
import 'view_models/seat_selection_view_model.dart';

class SeatSelectionPage extends ConsumerStatefulWidget {
  const SeatSelectionPage({
    required this.movieId,
    required this.showId,
    required this.cinemaId,
    required this.dayIndex,
    super.key,
  });

  final String movieId;
  final String showId;
  final String cinemaId;
  final int dayIndex;

  @override
  ConsumerState<SeatSelectionPage> createState() => _SeatSelectionPageState();
}

class _SeatSelectionPageState extends ConsumerState<SeatSelectionPage> {
  var promptedForCount = false;

  static const _weekdays = [
    '',
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];
  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _askSeatCount());
  }

  Future<void> _askSeatCount() async {
    if (promptedForCount || !mounted) return;
    promptedForCount = true;
    final current = ref.read(bookingSessionProvider).ticketCount;
    final count = await showTicketflixSheet<int>(
      context: context,
      builder: (context) => _SeatCountSheet(initialCount: current),
    );
    if (!mounted) return;
    if (count == null) {
      Navigator.of(context).maybePop();
      return;
    }
    ref.read(bookingSessionProvider.notifier).setTicketCount(count);
  }

  Future<void> _showTerms() async {
    await showTicketflixSheet<void>(
      context: context,
      builder: (context) => const _TermsSheet(),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Checkout and payment will be added in Phase 2.'),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final selection = ref.watch(
      seatSelectionViewModelProvider(
        SeatSelectionArgs(
          movieId: widget.movieId,
          showId: widget.showId,
          cinemaId: widget.cinemaId,
          dayIndex: widget.dayIndex,
        ),
      ),
    );

    return selection.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) => Scaffold(body: Center(child: Text('Unable to load seats: $error'))),
      data: (loaded) {
    final movie = loaded.movie;
    final cinema = loaded.cinema;
    final showtime = loaded.showtime;
    final seats = loaded.seats;
    final bookingDate = DateTime.now().add(Duration(days: widget.dayIndex));
    final bookingDateLabel =
        '${_weekdays[bookingDate.weekday]}, ${bookingDate.day} ${_months[bookingDate.month - 1]}';
    final topShowtimes = cinema.showtimes.take(3).toList();
    final draft = ref.watch(bookingSessionProvider);
    final total = ref.read(bookingSessionProvider.notifier).totalFor(seats);
    final canPay = draft.selectedSeatIds.length == draft.ticketCount;

    return Scaffold(
      backgroundColor: AppColors.surface,
      bottomNavigationBar: SafeArea(
        top: false,
        child: Material(
          color: AppColors.surface,
          elevation: 10,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
            child: TicketflixButton(
              label: canPay
                  ? 'Pay  ₹$total'
                  : 'Select ${draft.ticketCount - draft.selectedSeatIds.length} more',
              onPressed: canPay ? _showTerms : null,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          DesktopHeader(onSignIn: () => context.push('/login')),
          TicketflixPageHeader(title: movie.title, subtitle: cinema.name),
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Container(
                    color: AppColors.surfaceTint,
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                    child: ContentWidth(
                      padding: EdgeInsets.zero,
                      maxWidth: 940,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  bookingDateLabel,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              TextButton.icon(
                                onPressed: _askSeatCount,
                                icon: const Icon(Icons.edit_outlined, size: 18),
                                label: Text('${draft.ticketCount} Tickets'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              for (
                                var index = 0;
                                index < topShowtimes.length;
                                index++
                              ) ...[
                                if (index > 0) const SizedBox(width: 9),
                                Expanded(
                                  child: _TopShowtime(
                                    time: topShowtimes[index].time,
                                    experience: topShowtimes[index].experience,
                                    selected:
                                        topShowtimes[index].id == showtime.id,
                                    fillingFast:
                                        topShowtimes[index].fillingFast,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: ContentWidth(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.isDesktop ? 24 : 10,
                    ),
                    maxWidth: 940,
                    child: Column(
                      children: [
                        const SizedBox(height: 28),
                        _SeatSection(
                          title: 'Rs.880  LUXE PRIME',
                          rows: const ['G', 'F', 'E', 'D', 'C'],
                          seats: seats,
                          selectedIds: draft.selectedSeatIds,
                          onTap: _toggleSeat,
                        ),
                        const SizedBox(height: 24),
                        _SeatSection(
                          title: 'Rs.780  LUXE',
                          rows: const ['B', 'A'],
                          seats: seats,
                          selectedIds: draft.selectedSeatIds,
                          onTap: _toggleSeat,
                        ),
                        const SizedBox(height: 72),
                        const _Screen(),
                        const SizedBox(height: 120),
                        const _SeatLegend(),
                        const SizedBox(height: 18),
                        const _OfferStrip(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
      },
    );
  }

  void _toggleSeat(Seat seat) {
    final changed = ref.read(bookingSessionProvider.notifier).toggleSeat(seat);
    if (!changed && seat.status != SeatStatus.sold) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              'You can select up to ${ref.read(bookingSessionProvider).ticketCount} seats.',
            ),
          ),
        );
    }
  }

}

class _TopShowtime extends StatelessWidget {
  const _TopShowtime({
    required this.time,
    required this.experience,
    this.selected = false,
    this.fillingFast = false,
  });

  final String time;
  final String experience;
  final bool selected;
  final bool fillingFast;

  @override
  Widget build(BuildContext context) {
    final color = fillingFast ? AppColors.warning : AppColors.success;
    return Container(
      height: 54,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected ? AppColors.accent : AppColors.surface,
        border: Border.all(color: color, width: 1.5),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            time,
            style: TextStyle(
              color: selected ? AppColors.ink : AppColors.muted,
              fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              fontSize: 13,
            ),
          ),
          if (experience.isNotEmpty)
            Text(
              experience,
              style: TextStyle(
                color: selected
                    ? AppColors.ink.withValues(alpha: .65)
                    : AppColors.muted,
                fontSize: 9,
              ),
            ),
        ],
      ),
    );
  }
}

class _SeatSection extends StatelessWidget {
  const _SeatSection({
    required this.title,
    required this.rows,
    required this.seats,
    required this.selectedIds,
    required this.onTap,
  });

  final String title;
  final List<String> rows;
  final List<Seat> seats;
  final Set<String> selectedIds;
  final ValueChanged<Seat> onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 32),
          child: SizedBox(
            width: double.infinity,
            child: Text(title, style: const TextStyle(fontSize: 13)),
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(left: 32, top: 4, bottom: 8),
          child: Divider(height: 1),
        ),
        for (final row in rows)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 24,
                  child: Text(
                    row,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 11,
                    ),
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _rowSeats(row),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  List<Widget> _rowSeats(String row) {
    final rowSeats = seats.where((seat) => seat.row == row).toList();
    return [
      for (var index = 0; index < rowSeats.length; index++) ...[
        if (index == rowSeats.length ~/ 2) const SizedBox(width: 26),
        _SeatSquare(
          seat: rowSeats[index],
          selected: selectedIds.contains(rowSeats[index].id),
          onTap: () => onTap(rowSeats[index]),
        ),
        if (index != rowSeats.length - 1) const SizedBox(width: 5),
      ],
    ];
  }
}

class _SeatSquare extends StatelessWidget {
  const _SeatSquare({
    required this.seat,
    required this.selected,
    required this.onTap,
  });

  final Seat seat;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final sold = seat.status == SeatStatus.sold;
    return Semantics(
      button: !sold,
      selected: selected,
      enabled: !sold,
      label:
          'Seat ${seat.id}, ${sold
              ? 'sold'
              : selected
              ? 'selected'
              : 'available'}, ₹${seat.price}',
      child: InkWell(
        onTap: sold ? null : onTap,
        borderRadius: BorderRadius.circular(3),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: context.isMobile ? 26 : 31,
          height: context.isMobile ? 26 : 31,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: sold
                ? const Color(0xFFE7E7E7)
                : selected
                ? AppColors.accent
                : AppColors.surface,
            border: sold
                ? null
                : Border.all(color: AppColors.success, width: 1.2),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Text(
            '${seat.number}',
            style: TextStyle(
              color: sold
                  ? AppColors.surface
                  : selected
                  ? AppColors.ink
                  : AppColors.muted,
              fontSize: 10,
            ),
          ),
        ),
      ),
    );
  }
}

class _Screen extends StatelessWidget {
  const _Screen();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, .002)
            ..rotateX(-.65),
          child: Container(
            width: context.isDesktop ? 520 : 260,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFDDF4FF),
              border: Border.all(color: const Color(0xFFB5D5E3)),
              borderRadius: BorderRadius.circular(4),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x22006A99),
                  blurRadius: 18,
                  offset: Offset(0, 7),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 15),
        const Text('All eyes this way please!', style: TextStyle(fontSize: 11)),
      ],
    );
  }
}

class _SeatLegend extends StatelessWidget {
  const _SeatLegend();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _LegendItem(
          label: 'Available',
          color: AppColors.surface,
          outlined: true,
        ),
        SizedBox(width: 20),
        _LegendItem(label: 'Selected', color: AppColors.accent),
        SizedBox(width: 20),
        _LegendItem(label: 'Sold', color: Color(0xFFE7E7E7)),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.label,
    required this.color,
    this.outlined = false,
  });

  final String label;
  final Color color;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: color,
            border: outlined ? Border.all(color: AppColors.success) : null,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class _OfferStrip extends StatelessWidget {
  const _OfferStrip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      color: AppColors.surfaceTint,
      child: const Row(
        children: [
          Icon(Icons.local_offer_outlined, color: AppColors.primary),
          SizedBox(width: 10),
          Expanded(child: Text('YES Private Debit Card Offer')),
          Text('1/3', style: TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _SeatCountSheet extends StatefulWidget {
  const _SeatCountSheet({required this.initialCount});

  final int initialCount;

  @override
  State<_SeatCountSheet> createState() => _SeatCountSheetState();
}

class _SeatCountSheetState extends State<_SeatCountSheet> {
  late var count = widget.initialCount;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SheetHandle(),
            Text(
              'How many seats?',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 28),
            Container(
              height: 132,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: const LinearGradient(
                  colors: [AppColors.midnight, AppColors.primary],
                ),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.local_movies_outlined,
                    color: AppColors.accent,
                    size: 44,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Pick your perfect seats',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 50,
              child: Row(
                children: [
                  for (var index = 0; index < 10; index++)
                    Expanded(
                      child: InkWell(
                        key: ValueKey('seat-count-${index + 1}'),
                        onTap: () => setState(() => count = index + 1),
                        borderRadius: BorderRadius.circular(50),
                        child: Center(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 160),
                            width: 40,
                            height: 40,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: index + 1 == count
                                  ? AppColors.primary
                                  : Colors.transparent,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: index + 1 == count
                                    ? Colors.white
                                    : AppColors.ink,
                                fontSize: 14,
                                fontWeight: index + 1 == count
                                    ? FontWeight.w700
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const Divider(height: 20),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _PriceAvailability(label: 'LUXE PRIME', price: 880),
                SizedBox(width: 54),
                _PriceAvailability(label: 'LUXE', price: 780),
              ],
            ),
            const SizedBox(height: 18),
            TicketflixButton(
              label: 'Select Seats',
              onPressed: () => Navigator.of(context).pop(count),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _PriceAvailability extends StatelessWidget {
  const _PriceAvailability({required this.label, required this.price});

  final String label;
  final int price;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12)),
        Text(
          '₹$price',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const Text(
          'AVAILABLE',
          style: TextStyle(
            color: AppColors.success,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _TermsSheet extends StatelessWidget {
  const _TermsSheet();

  static const terms = [
    'Seat layouts shown are indicative; actual auditorium layouts may vary.',
    'Tickets are mandatory for children aged 3+ (5+ in Uttarakhand).',
    'Entry is restricted for patrons below 18 years for A certified films.',
    'Baggage counter facilities are unavailable; avoid carrying large/restricted items.',
    '3D ticket prices include charges for 3D glasses usage.',
    'Outside food & beverages are strictly prohibited, including deliveries via third-party apps.',
    'Prohibited items include laptops, tablets, cameras, weapons, and hazardous or inflammable objects.',
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SheetHandle(),
            Text(
              'Terms & Conditions',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var index = 0; index < terms.length; index++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          '${index + 1}. ${terms[index]}',
                          style: const TextStyle(fontSize: 15, height: 1.45),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            TicketflixButton(
              label: 'Okay',
              onPressed: () => Navigator.of(context).pop(),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
