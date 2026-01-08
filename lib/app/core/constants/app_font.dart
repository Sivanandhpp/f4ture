import 'package:flutter/material.dart';

/// App-wide font/typography constants

class AppFont {
  AppFont._();

  // Font Family
  static const String family = 'SF Pro Display';
  static const String familyMono = 'SF Mono';

  // Font Sizes
  static const double sizeCaption = 11.0;
  static const double sizeSmall = 13.0;
  static const double sizeBody = 15.0;
  static const double sizeSubtitle = 17.0;
  static const double sizeTitle = 20.0;
  static const double sizeHeading = 24.0;
  static const double sizeDisplay = 32.0;
  static const double sizeHero = 40.0;

  // Font Weights
  static const FontWeight thin = FontWeight.w100;
  static const FontWeight extraLight = FontWeight.w200;
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight extraBold = FontWeight.w800;
  static const FontWeight black = FontWeight.w900;

  // Line Heights
  static const double lineHeightTight = 1.2;
  static const double lineHeightNormal = 1.5;
  static const double lineHeightRelaxed = 1.75;

  // Letter Spacing
  static const double letterSpacingTight = -0.5;
  static const double letterSpacingNormal = 0.0;
  static const double letterSpacingWide = 0.5;

  // Text Colors - Light
  static const Color colorPrimary = Color(0xFF000000);
  static const Color colorSecondary = Color(0xFF3C3C43);
  static const Color colorTertiary = Color(0xFF8E8E93);
  static const Color colorDisabled = Color(0xFFC7C7CC);
  static const Color colorLink = Color(0xFF007AFF);

  // Text Colors - Dark
  static const Color colorPrimaryDark = Color(0xFFFFFFFF);
  static const Color colorSecondaryDark = Color(0xFFEBEBF5);
  static const Color colorTertiaryDark = Color(0xFF8E8E93);
  static const Color colorLinkDark = Color(0xFF0A84FF);

  // Pre-built TextStyles
  static const TextStyle caption = TextStyle(
    fontSize: sizeCaption,
    fontWeight: regular,
    color: colorTertiary,
  );
  static const TextStyle bodySmall = TextStyle(
    fontSize: sizeSmall,
    fontWeight: regular,
    color: colorSecondary,
  );
  static const TextStyle body = TextStyle(
    fontSize: sizeBody,
    fontWeight: regular,
    color: colorPrimary,
  );
  static const TextStyle subtitle = TextStyle(
    fontSize: sizeSubtitle,
    fontWeight: medium,
    color: colorPrimary,
  );
  static const TextStyle title = TextStyle(
    fontSize: sizeTitle,
    fontWeight: semiBold,
    color: colorPrimary,
  );
  static const TextStyle heading = TextStyle(
    fontSize: sizeHeading,
    fontWeight: bold,
    color: colorPrimary,
  );
  static const TextStyle display = TextStyle(
    fontSize: sizeDisplay,
    fontWeight: bold,
    color: colorPrimary,
  );
  static const TextStyle hero = TextStyle(
    fontSize: sizeHero,
    fontWeight: bold,
    color: colorPrimary,
  );

  // Pre-built TextStyles - Dark
  static const TextStyle captionDark = TextStyle(
    fontSize: sizeCaption,
    fontWeight: regular,
    color: colorTertiaryDark,
  );
  static const TextStyle bodySmallDark = TextStyle(
    fontSize: sizeSmall,
    fontWeight: regular,
    color: colorSecondaryDark,
  );
  static const TextStyle bodyDark = TextStyle(
    fontSize: sizeBody,
    fontWeight: regular,
    color: colorPrimaryDark,
  );
  static const TextStyle subtitleDark = TextStyle(
    fontSize: sizeSubtitle,
    fontWeight: medium,
    color: colorPrimaryDark,
  );
  static const TextStyle titleDark = TextStyle(
    fontSize: sizeTitle,
    fontWeight: semiBold,
    color: colorPrimaryDark,
  );
  static const TextStyle headingDark = TextStyle(
    fontSize: sizeHeading,
    fontWeight: bold,
    color: colorPrimaryDark,
  );
  static const TextStyle displayDark = TextStyle(
    fontSize: sizeDisplay,
    fontWeight: bold,
    color: colorPrimaryDark,
  );
  static const TextStyle heroDark = TextStyle(
    fontSize: sizeHero,
    fontWeight: bold,
    color: colorPrimaryDark,
  );
}
