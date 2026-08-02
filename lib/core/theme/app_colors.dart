import 'package:flutter/material.dart';

abstract final class AppColors {
  // A cinematic palette: electric violet, mint, and indigo.
  // These tokens are kept for artwork and branded surfaces; text/surfaces that
  // need to follow light/dark mode come from Theme.of(context).colorScheme.
  static const primary = Color(0xFF7C3AED);
  static const accent = Color(0xFFB8E986);
  static const locationBlue = Color(0xFF51429B);
  static const success = Color(0xFF2F9E83);
  static const warning = Color(0xFFE5A93D);
  static const surface = Color(0xFFF7F5FC);
  static const surfaceTint = Color(0xFFEEEAF8);
  static const softAccent = Color(0xFFD9F3E6);
  static const coralWash = Color(0xFFE7E1F8);
  static const ink = Color(0xFF211A33);
  static const muted = Color(0xFF6F6880);
  static const border = Color(0xFFD8D1E6);
  static const midnight = Color(0xFF17152E);
}
