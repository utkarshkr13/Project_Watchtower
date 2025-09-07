import 'package:flutter/material.dart';

enum AmbientColor {
  blue('Ocean Blue', Colors.blue),
  purple('Royal Purple', Colors.purple),
  pink('Neon Pink', Colors.pink),
  orange('Sunset Orange', Colors.orange),
  green('Emerald Green', Colors.green),
  red('Crimson Red', Colors.red);

  const AmbientColor(this.displayName, this.color);

  final String displayName;
  final Color color;

  LinearGradient get gradient => LinearGradient(
    colors: [color, color.withOpacity(0.8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppTheme {
  // Design tokens from Figma
  static const _primaryFontFamily = 'SF Pro Display';
  static const _bodyFontFamily = 'Roboto';
  
  // Spacing scale from design system - Figma tokens
  static const double xxxs = 2;
  static const double xxs = 4;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;  // Added missing 12px
  static const double lg = 16;
  static const double xl = 20;  // Added missing 20px
  static const double xxl = 24;
  static const double xxxl = 32;

  // Additional spacing
  static const double sectionSpacing = 24;
  static const double cardSpacing = 12;
  static const double contentPadding = 16;
  
  // Grid system
  static const double gridMargin = 20;
  static const double gridGutter = 16;
  
  // Border radius tokens
  static const double radiusXs = 4;
  static const double radiusSm = 8;
  static const double radiusMd = 16;
  static const double radiusLg = 24;
  static const double radiusXl = 32;
  
  // Component specific sizes
  static const double trendingCardWidth = 160;
  static const double trendingCardHeight = 200;
  static const double pollCardWidth = 340;
  static const double pollCardHeight = 220;
  static const double navHeight = 72;
  
  // Button heights
  static const double buttonHeight = 44;
  static const double buttonHeightLarge = 56;
  static const double buttonHeightSmall = 36;
  
  // Colors - Light Theme
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFF9F9F9);
  static const Color lightPrimary = Color(0xFF3A7AFE);
  static const Color lightSecondary = Color(0xFFFF3366);
  static const Color lightTextPrimary = Color(0xFF000000);
  static const Color lightTextSecondary = Color(0xFF555555);
  
  // Colors - Dark Theme  
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkPrimary = Color(0xFF3A7AFE);
  static const Color darkSecondary = Color(0xFFFF3366);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFCCCCCC);
  
  // Trending card gradient colors
  static const List<Color> trendingGradients = [
    Color(0xFFFF6B6B), // Red
    Color(0xFFFFD93D), // Yellow
    Color(0xFF6BCB77), // Green
    Color(0xFF4D96FF), // Blue
  ];
  
  // Shadows
  static const BoxShadow cardShadow = BoxShadow(
    color: Color(0x1A000000),
    offset: Offset(0, 4),
    blurRadius: 12,
    spreadRadius: 0,
  );
  
  static const BoxShadow modalShadow = BoxShadow(
    color: Color(0x33000000),
    offset: Offset(0, 6),
    blurRadius: 20,
    spreadRadius: 0,
  );

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: _bodyFontFamily,
    colorScheme: const ColorScheme.light(
      primary: lightPrimary,
      secondary: lightSecondary,
      surface: lightSurface,
      background: lightBackground,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: lightTextPrimary,
      onBackground: lightTextPrimary,
    ),
    scaffoldBackgroundColor: lightBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: lightBackground,
      foregroundColor: lightTextPrimary,
      elevation: 0,
      centerTitle: false,
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: const CardThemeData(
      color: lightSurface,
      elevation: 0,
      shadowColor: Color(0x1A000000),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(radiusMd)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: lightPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        minimumSize: const Size(0, 56),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(radiusMd)),
        ),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: lightBackground,
      selectedItemColor: lightPrimary,
      unselectedItemColor: lightTextSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
  );

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: _bodyFontFamily,
    colorScheme: const ColorScheme.dark(
      primary: darkPrimary,
      secondary: darkSecondary,
      surface: darkSurface,
      background: darkBackground,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: darkTextPrimary,
      onBackground: darkTextPrimary,
    ),
    scaffoldBackgroundColor: darkBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: darkBackground,
      foregroundColor: darkTextPrimary,
      elevation: 0,
      centerTitle: false,
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: const CardThemeData(
      color: darkSurface,
      elevation: 0,
      shadowColor: Color(0x33000000),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(radiusMd)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: darkPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        minimumSize: const Size(0, 56),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(radiusMd)),
        ),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: darkBackground,
      selectedItemColor: darkPrimary,
      unselectedItemColor: darkTextSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
  );

  // Typography styles based on design system
  static const TextStyle heading1 = TextStyle(
    fontFamily: _primaryFontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 34 / 28,
  );

  static const TextStyle heading2 = TextStyle(
    fontFamily: _primaryFontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 28 / 22,
  );

  static const TextStyle body = TextStyle(
    fontFamily: _bodyFontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 24 / 16,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: _bodyFontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 18 / 13,
  );

  // Additional text styles 
  static const TextStyle largeTitle = TextStyle(
    fontFamily: _primaryFontFamily,
    fontSize: 34,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );

  static const TextStyle title1 = TextStyle(
    fontFamily: _primaryFontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  static const TextStyle title2 = TextStyle(
    fontFamily: _primaryFontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  static const TextStyle title3 = TextStyle(
    fontFamily: _primaryFontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  static const TextStyle headline = TextStyle(
    fontFamily: _bodyFontFamily,
    fontSize: 17,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static const TextStyle callout = TextStyle(
    fontFamily: _bodyFontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.3,
  );

  static const TextStyle subheadline = TextStyle(
    fontFamily: _bodyFontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.2,
  );

  static const TextStyle footnote = TextStyle(
    fontFamily: _bodyFontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.2,
  );

  static const TextStyle caption1 = TextStyle(
    fontFamily: _bodyFontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.2,
  );

  static const TextStyle caption2 = TextStyle(
    fontFamily: _bodyFontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 1.2,
  );

  // Dynamic color helpers
  static Color appBackground(Brightness brightness) =>
      brightness == Brightness.dark ? darkBackground : lightBackground;

  static Color appSurface(Brightness brightness) =>
      brightness == Brightness.dark ? darkSurface : lightSurface;

  static Color primaryText(Brightness brightness) =>
      brightness == Brightness.dark ? darkTextPrimary : lightTextPrimary;

  static Color secondaryText(Brightness brightness) =>
      brightness == Brightness.dark ? darkTextSecondary : lightTextSecondary;

  static Color primaryColor(Brightness brightness) =>
      brightness == Brightness.dark ? darkPrimary : lightPrimary;

  static Color secondaryColor(Brightness brightness) =>
      brightness == Brightness.dark ? darkSecondary : lightSecondary;

  // Minimal design helpers
  static Color minimalSurface(Brightness brightness) =>
      brightness == Brightness.dark ? const Color(0xFF1E1E1E) : const Color(0xFFF9F9F9);

  static Color minimalElevatedSurface(Brightness brightness) =>
      brightness == Brightness.dark ? const Color(0xFF2A2A2A) : const Color(0xFFE5E5E5);

  static Color minimalStroke(Brightness brightness) =>
      brightness == Brightness.dark ? Colors.white.withOpacity(0.1) : AppTheme.primaryText(brightness).withOpacity(0.1);

  static Color minimalDivider(Brightness brightness) =>
      brightness == Brightness.dark ? Colors.white.withOpacity(0.08) : AppTheme.primaryText(brightness).withOpacity(0.08);

  // Gradient helpers
  static LinearGradient cinematicGradient() => const LinearGradient(
    colors: [
      Color(0xFF020308),
      Color(0xFF060815),
      Color(0xFF121525),
      Color(0xFF182232),
      Color(0xFF222635),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Trending card gradients
  static LinearGradient getTrendingGradient(int index) {
    final color = trendingGradients[index % trendingGradients.length];
    return LinearGradient(
      colors: [
        color,
        color.withOpacity(0.8),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  // Card with shadow
  static BoxDecoration cardDecoration(Brightness brightness) {
    return BoxDecoration(
      color: appSurface(brightness),
      borderRadius: BorderRadius.circular(radiusMd),
      boxShadow: const [cardShadow],
    );
  }

  // Trending card decoration
  static BoxDecoration trendingCardDecoration(int index) {
    return BoxDecoration(
      gradient: getTrendingGradient(index),
      borderRadius: BorderRadius.circular(radiusLg),
      boxShadow: const [cardShadow],
    );
  }

  // Poll card decoration
  static BoxDecoration pollCardDecoration(Brightness brightness) {
    return BoxDecoration(
      color: appSurface(brightness),
      borderRadius: BorderRadius.circular(radiusLg),
      boxShadow: const [cardShadow],
    );
  }
}