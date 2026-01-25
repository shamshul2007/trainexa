import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppSpacing {
  // Spacing values
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  // Edge insets shortcuts
  static const EdgeInsets paddingXs = EdgeInsets.all(xs);
  static const EdgeInsets paddingSm = EdgeInsets.all(sm);
  static const EdgeInsets paddingMd = EdgeInsets.all(md);
  static const EdgeInsets paddingLg = EdgeInsets.all(lg);
  static const EdgeInsets paddingXl = EdgeInsets.all(xl);

  // Horizontal padding
  static const EdgeInsets horizontalXs = EdgeInsets.symmetric(horizontal: xs);
  static const EdgeInsets horizontalSm = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets horizontalMd = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets horizontalLg = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets horizontalXl = EdgeInsets.symmetric(horizontal: xl);

  // Vertical padding
  static const EdgeInsets verticalXs = EdgeInsets.symmetric(vertical: xs);
  static const EdgeInsets verticalSm = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets verticalMd = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets verticalLg = EdgeInsets.symmetric(vertical: lg);
  static const EdgeInsets verticalXl = EdgeInsets.symmetric(vertical: xl);
}

/// Border radius constants for consistent rounded corners
class AppRadius {
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
}

// =============================================================================
// TEXT STYLE EXTENSIONS
// =============================================================================

/// Extension to add text style utilities to BuildContext
/// Access via context.textStyles
extension TextStyleContext on BuildContext {
  TextTheme get textStyles => Theme.of(this).textTheme;
}

/// Helper methods for common text style modifications
extension TextStyleExtensions on TextStyle {
  /// Make text bold
  TextStyle get bold => copyWith(fontWeight: FontWeight.bold);

  /// Make text semi-bold
  TextStyle get semiBold => copyWith(fontWeight: FontWeight.w600);

  /// Make text medium weight
  TextStyle get medium => copyWith(fontWeight: FontWeight.w500);

  /// Make text normal weight
  TextStyle get normal => copyWith(fontWeight: FontWeight.w400);

  /// Make text light
  TextStyle get light => copyWith(fontWeight: FontWeight.w300);

  /// Add custom color
  TextStyle withColor(Color color) => copyWith(color: color);

  /// Add custom size
  TextStyle withSize(double size) => copyWith(fontSize: size);
}

// =============================================================================
// COLORS
// =============================================================================

/// Trainexa color system (from the provided design spec)
class TrainexaColorsLight {
  static const primary = Color(0xFF0066FF); // CTA blue
  static const onPrimary = Color(0xFFFFFFFF);
  static const primaryContainer = Color(0xFFCCE0FF);
  static const onPrimaryContainer = Color(0xFF00214D);

  static const surface = Color(0xFFFFFFFF);
  static const onSurface = Color(0xFF000000);
  static const surfaceVariant = Color(0xFFF5F7FA);
  static const onSurfaceVariant = Color(0xFF4A5568);

  static const success = Color(0xFF22C55E);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);
  static const info = Color(0xFF3B82F6);

  static const outline = Color(0xFFCBD5E0);
}

class TrainexaColorsDark {
  static const primary = Color(0xFF0066FF);
  static const onPrimary = Color(0xFFFFFFFF);
  static const primaryContainer = Color(0xFF003D99);
  static const onPrimaryContainer = Color(0xFFD6E6FF);

  static const background = Color(0xFF0F0F0F);
  static const surface = Color(0xFF1A1A1A);
  static const onSurface = Color(0xFFFFFFFF);
  static const surfaceVariant = Color(0xFF2D3748);
  static const onSurfaceVariant = Color(0xFFA0AEC0);

  static const success = Color(0xFF22C55E);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);
  static const info = Color(0xFF3B82F6);

  static const outline = Color(0xFF4A5568);
}

/// Font size constants
class FontSizes {
  static const double displayLarge = 57.0;
  static const double displayMedium = 45.0;
  static const double displaySmall = 36.0;
  static const double headlineLarge = 32.0;
  static const double headlineMedium = 28.0;
  static const double headlineSmall = 24.0;
  static const double titleLarge = 22.0;
  static const double titleMedium = 16.0;
  static const double titleSmall = 14.0;
  static const double labelLarge = 14.0;
  static const double labelMedium = 12.0;
  static const double labelSmall = 11.0;
  static const double bodyLarge = 16.0;
  static const double bodyMedium = 14.0;
  static const double bodySmall = 12.0;
}

// =============================================================================
// THEMES
// =============================================================================

/// Light theme with modern, neutral aesthetic
ThemeData get lightTheme => ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.light(
    primary: TrainexaColorsLight.primary,
    onPrimary: TrainexaColorsLight.onPrimary,
    primaryContainer: TrainexaColorsLight.primaryContainer,
    onPrimaryContainer: TrainexaColorsLight.onPrimaryContainer,
    secondary: TrainexaColorsLight.primary, // keep palette tight
    onSecondary: TrainexaColorsLight.onPrimary,
    tertiary: TrainexaColorsLight.info,
    onTertiary: TrainexaColorsLight.onPrimary,
    error: TrainexaColorsLight.error,
    onError: Colors.white,
    surface: TrainexaColorsLight.surface,
    onSurface: TrainexaColorsLight.onSurface,
    surfaceContainerHighest: TrainexaColorsLight.surfaceVariant,
    onSurfaceVariant: TrainexaColorsLight.onSurfaceVariant,
    outline: TrainexaColorsLight.outline,
  ),
  brightness: Brightness.light,
  scaffoldBackgroundColor: TrainexaColorsLight.surface,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    foregroundColor: TrainexaColorsLight.onSurface,
    elevation: 0,
    scrolledUnderElevation: 0,
  ),
  cardTheme: CardThemeData(
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: BorderSide(
        color: TrainexaColorsLight.outline.withValues(alpha: 0.2),
        width: 1,
      ),
    ),
  ),
  textTheme: _buildTextTheme(Brightness.light),
);

/// Dark theme with good contrast and readability
ThemeData get darkTheme => ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.dark(
    primary: TrainexaColorsDark.primary,
    onPrimary: TrainexaColorsDark.onPrimary,
    primaryContainer: TrainexaColorsDark.primaryContainer,
    onPrimaryContainer: TrainexaColorsDark.onPrimaryContainer,
    secondary: TrainexaColorsDark.primary,
    onSecondary: TrainexaColorsDark.onPrimary,
    tertiary: TrainexaColorsDark.info,
    onTertiary: TrainexaColorsDark.onPrimary,
    error: TrainexaColorsDark.error,
    onError: Colors.white,
    surface: TrainexaColorsDark.surface,
    onSurface: TrainexaColorsDark.onSurface,
    surfaceContainerHighest: TrainexaColorsDark.surfaceVariant,
    onSurfaceVariant: TrainexaColorsDark.onSurfaceVariant,
    outline: TrainexaColorsDark.outline,
  ),
  brightness: Brightness.dark,
  scaffoldBackgroundColor: TrainexaColorsDark.background,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    foregroundColor: TrainexaColorsDark.onSurface,
    elevation: 0,
    scrolledUnderElevation: 0,
  ),
  cardTheme: CardThemeData(
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: BorderSide(
        color: TrainexaColorsDark.outline.withValues(alpha: 0.2),
        width: 1,
      ),
    ),
  ),
  textTheme: _buildTextTheme(Brightness.dark),
);

/// Build text theme using Inter font family
TextTheme _buildTextTheme(Brightness brightness) {
  return TextTheme(
    displayLarge: GoogleFonts.inter(
      fontSize: FontSizes.displayLarge,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.25,
    ),
    displayMedium: GoogleFonts.inter(
      fontSize: FontSizes.displayMedium,
      fontWeight: FontWeight.w400,
    ),
    displaySmall: GoogleFonts.inter(
      fontSize: FontSizes.displaySmall,
      fontWeight: FontWeight.w400,
    ),
    headlineLarge: GoogleFonts.inter(
      fontSize: FontSizes.headlineLarge,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.5,
    ),
    headlineMedium: GoogleFonts.inter(
      fontSize: FontSizes.headlineMedium,
      fontWeight: FontWeight.w600,
    ),
    headlineSmall: GoogleFonts.inter(
      fontSize: FontSizes.headlineSmall,
      fontWeight: FontWeight.w600,
    ),
    titleLarge: GoogleFonts.inter(
      fontSize: FontSizes.titleLarge,
      fontWeight: FontWeight.w600,
    ),
    titleMedium: GoogleFonts.inter(
      fontSize: FontSizes.titleMedium,
      fontWeight: FontWeight.w500,
    ),
    titleSmall: GoogleFonts.inter(
      fontSize: FontSizes.titleSmall,
      fontWeight: FontWeight.w500,
    ),
    labelLarge: GoogleFonts.inter(
      fontSize: FontSizes.labelLarge,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
    ),
    labelMedium: GoogleFonts.inter(
      fontSize: FontSizes.labelMedium,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
    ),
    labelSmall: GoogleFonts.inter(
      fontSize: FontSizes.labelSmall,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
    ),
    bodyLarge: GoogleFonts.inter(
      fontSize: FontSizes.bodyLarge,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.15,
    ),
    bodyMedium: GoogleFonts.inter(
      fontSize: FontSizes.bodyMedium,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
    ),
    bodySmall: GoogleFonts.inter(
      fontSize: FontSizes.bodySmall,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.4,
    ),
  );
}
