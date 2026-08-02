import 'package:flutter_riverpod/flutter_riverpod.dart';

final splashViewModelProvider =
    FutureProvider.autoDispose<void>((ref) async {
  await Future<void>.delayed(const Duration(milliseconds: 1550));
});
