
import 'package:flutter/material.dart';

/// Palette officielle de l'application LOBOKO.
abstract final class AppColors {
  AppColors._();

  // Palette principale.
  static const Color primary = Color(0xFF176B45);
  static const Color secondary = Color(0xFF4CAF72);
  static const Color lightGreen = Color(0xFFE8F5ED);
  static const Color gold = Color(0xFFF2C94C);

  // Couleurs neutres.
  static const Color white = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF5F7F6);
  static const Color textSecondary = Color(0xFF66736C);
  static const Color textPrimary = Color(0xFF17221C);

  // Couleurs de bordure et de séparation.
  static const Color border = lightGreen;
  static const Color divider = lightGreen;

  // Succès.
  static const Color successBackground = Color(0xFFE8F5ED);
  static const Color successText = Color(0xFF176B45);

  // Erreur.
  static const Color errorBackground = Color(0xFFFDECEC);
  static const Color errorText = Color(0xFFB42323);

  // Avertissement.
  static const Color warningBackground = Color(0xFFFFF4DF);
  static const Color warningText = Color(0xFF8A4B08);

  // Information.
  static const Color infoBackground = Color(0xFFEBF3F9);
  static const Color infoText = Color(0xFF1D6193);

  // Couleurs associées à l'état désactivé.
  static const Color disabledBackground = Color(0xFFE8ECE9);
  static const Color disabledText = Color(0xFF66736C);
}
