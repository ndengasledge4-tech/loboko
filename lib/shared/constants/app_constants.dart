
import 'package:flutter/material.dart';

/// Dimensions et espacements partagés de LOBOKO.
abstract final class AppConstants {
  AppConstants._();

  // Espacements en multiples de 4.
  static const double spacing2 = 8;
  static const double spacing3 = 12;
  static const double spacing4 = 16;
  static const double spacing5 = 20;
  static const double spacing6 = 24;
  static const double spacing8 = 32;
  static const double spacing10 = 40;

  // Marges courantes.
  static const EdgeInsets screenPadding = EdgeInsets.all(spacing4);
  static const EdgeInsets cardPadding = EdgeInsets.all(spacing4);
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    horizontal: spacing5,
    vertical: spacing3,
  );

  // Rayons des bordures.
  static const double buttonRadius = 12;
  static const double inputRadius = 12;
  static const double cardRadius = 16;
  static const double badgeRadius = 20;
  static const double dialogRadius = 16;

  // Dimensions standard.
  static const double buttonHeight = 50;
  static const double buttonMinHeight = 48;
  static const double buttonMaxHeight = 52;
  static const double iconSize = 24;
  static const double smallIconSize = 18;
  static const double avatarSize = 48;

  // Animations.
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationNormal = Duration(milliseconds: 250);
  static const Duration animationSlow = Duration(milliseconds: 350);
}
