import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/models/theme_settings.dart';

// IRON LEDGER / 铁册 — v2.0.0 design tokens.
const Color kInk = Color(0xFF0A0B0C);
const Color kCarbon = Color(0xFF121315);
const Color kGraphite = Color(0xFF1A1C1E);
const Color kChalk = Color(0xFFEDE8DC);
const Color kSteel = Color(0xFF8B8F8C);
const Color kSafetyOrange = Color(0xFFFF4E12);
const Color kSafetyDeep = Color(0xFF8F2A0C);
const Color kDangerRed = Color(0xFFFF5C4D);
const Color kSuccess = Color(0xFF9BBF8A);
const Color kLine = Color(0xFF303334);
const Color kLineSoft = Color(0xFF222527);

// Old names are kept only so untouched secondary screens still compile.
// They intentionally resolve to the new palette; do not use them in new UI.
const Color kPrimaryBlue = kSafetyOrange;
const Color kWarmYellow = kChalk;
const Color kLightBackground = kInk;
const Color kLightCard = kCarbon;
const Color kDarkBackground = kInk;
const Color kDarkCard = kCarbon;

const String kDisplayFont = 'NotoSerifSC';

ThemeData buildLedgerTheme() {
  final scheme =
      const ColorScheme.dark(
        brightness: Brightness.dark,
        primary: kSafetyOrange,
        onPrimary: kInk,
        primaryContainer: kSafetyDeep,
        onPrimaryContainer: kChalk,
        secondary: kChalk,
        onSecondary: kInk,
        secondaryContainer: kGraphite,
        onSecondaryContainer: kChalk,
        error: kDangerRed,
        onError: kInk,
        surface: kCarbon,
        onSurface: kChalk,
      ).copyWith(
        surfaceContainerHighest: kGraphite,
        onSurfaceVariant: kSteel,
        outline: kSteel,
        outlineVariant: kLine,
        surfaceTint: Colors.transparent,
      );

  final textTheme = _ledgerTextTheme();

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: scheme,
    scaffoldBackgroundColor: kInk,
    canvasColor: kInk,
    cardColor: kCarbon,
    dividerColor: kLine,
    disabledColor: kSteel.withAlpha(110),
    extensions: const <ThemeExtension<dynamic>>[PageScrimTheme(color: kInk)],
    splashFactory: NoSplash.splashFactory,
    visualDensity: VisualDensity.standard,
    materialTapTargetSize: MaterialTapTargetSize.padded,
    textTheme: textTheme,
    primaryTextTheme: textTheme,
    iconTheme: const IconThemeData(color: kChalk, size: 22),
    appBarTheme: AppBarTheme(
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: 64,
      backgroundColor: Colors.transparent,
      foregroundColor: kChalk,
      surfaceTintColor: Colors.transparent,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      iconTheme: const IconThemeData(color: kChalk, size: 20),
      actionsIconTheme: const IconThemeData(color: kChalk, size: 20),
      titleTextStyle: const TextStyle(
        fontFamily: kDisplayFont,
        color: kChalk,
        fontSize: 26,
        fontWeight: FontWeight.w700,
        height: 1.1,
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: kCarbon,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(2)),
        side: BorderSide(color: kLine),
      ),
      titleTextStyle: const TextStyle(
        fontFamily: kDisplayFont,
        color: kChalk,
        fontSize: 23,
        fontWeight: FontWeight.w700,
        height: 1.2,
      ),
      contentTextStyle: const TextStyle(
        color: kChalk,
        fontSize: 14.5,
        height: 1.65,
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: kCarbon,
      modalBackgroundColor: kCarbon,
      surfaceTintColor: Colors.transparent,
      modalBarrierColor: Color(0xB8000000),
      shape: RoundedRectangleBorder(),
      dragHandleColor: kSteel,
      showDragHandle: false,
    ),
    inputDecorationTheme: InputDecorationTheme(
      isDense: true,
      filled: true,
      fillColor: kInk,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
      labelStyle: const TextStyle(color: kSteel, fontSize: 13),
      floatingLabelStyle: const TextStyle(color: kSteel, fontSize: 12),
      hintStyle: TextStyle(color: kSteel.withAlpha(150), fontSize: 14),
      prefixIconColor: kSteel,
      suffixIconColor: kSteel,
      counterStyle: const TextStyle(color: kSteel, fontSize: 11),
      helperStyle: const TextStyle(color: kSteel, fontSize: 11.5),
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: kLine),
      ),
      enabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: kLine),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: kSafetyOrange, width: 1.5),
      ),
      errorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: kDangerRed),
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: kDangerRed, width: 1.5),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: ButtonStyle(
        minimumSize: const WidgetStatePropertyAll(Size(48, 48)),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
        shape: const WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(1)),
          ),
        ),
        backgroundColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.disabled) ? kGraphite : kSafetyOrange,
        ),
        foregroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.disabled) ? kSteel : kInk,
        ),
        overlayColor: WidgetStatePropertyAll(kChalk.withAlpha(20)),
        textStyle: const WidgetStatePropertyAll(
          TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
        elevation: const WidgetStatePropertyAll(0),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        minimumSize: const WidgetStatePropertyAll(Size(48, 48)),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        ),
        shape: const WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(1)),
          ),
        ),
        foregroundColor: const WidgetStatePropertyAll(kChalk),
        side: const WidgetStatePropertyAll(BorderSide(color: kLine)),
        overlayColor: WidgetStatePropertyAll(kSafetyOrange.withAlpha(22)),
        textStyle: const WidgetStatePropertyAll(
          TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        minimumSize: const WidgetStatePropertyAll(Size(44, 40)),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        ),
        shape: const WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(1)),
          ),
        ),
        foregroundColor: const WidgetStatePropertyAll(kSafetyOrange),
        overlayColor: WidgetStatePropertyAll(kSafetyOrange.withAlpha(20)),
        textStyle: const WidgetStatePropertyAll(
          TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: ButtonStyle(
        minimumSize: const WidgetStatePropertyAll(Size(44, 44)),
        shape: const WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(1)),
          ),
        ),
        foregroundColor: const WidgetStatePropertyAll(kChalk),
        overlayColor: WidgetStatePropertyAll(kSafetyOrange.withAlpha(20)),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: kGraphite,
      contentTextStyle: const TextStyle(
        color: kChalk,
        fontSize: 13,
        height: 1.4,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(1)),
        side: BorderSide(color: kLine),
      ),
      insetPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      elevation: 0,
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: kSafetyOrange,
      selectionColor: kSafetyOrange.withAlpha(55),
      selectionHandleColor: kSafetyOrange,
    ),
    dividerTheme: const DividerThemeData(color: kLine, thickness: 1, space: 1),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        return states.contains(WidgetState.selected)
            ? kSafetyOrange
            : Colors.transparent;
      }),
      checkColor: const WidgetStatePropertyAll(kInk),
      side: const BorderSide(color: kSteel, width: 1.2),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(1)),
      ),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Colors.transparent,
      selectedColor: kSafetyOrange.withAlpha(28),
      disabledColor: Colors.transparent,
      side: const BorderSide(color: kLine),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(1)),
      ),
      labelStyle: const TextStyle(color: kChalk, fontSize: 12.5),
      secondaryLabelStyle: const TextStyle(color: kChalk, fontSize: 12.5),
      checkmarkColor: kSafetyOrange,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      showCheckmark: false,
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        minimumSize: const WidgetStatePropertyAll(Size(44, 44)),
        shape: const WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(1)),
          ),
        ),
        side: const WidgetStatePropertyAll(BorderSide(color: kLine)),
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? kGraphite
              : Colors.transparent;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected) ? kChalk : kSteel;
        }),
        overlayColor: WidgetStatePropertyAll(kSafetyOrange.withAlpha(18)),
        textStyle: const WidgetStatePropertyAll(
          TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: kGraphite,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(1)),
        side: BorderSide(color: kLine),
      ),
      textStyle: const TextStyle(color: kChalk, fontSize: 14),
    ),
    listTileTheme: const ListTileThemeData(
      iconColor: kSteel,
      textColor: kChalk,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      minVerticalPadding: 12,
    ),
    tooltipTheme: TooltipThemeData(
      decoration: const BoxDecoration(
        color: kGraphite,
        border: Border.fromBorderSide(BorderSide(color: kLine)),
      ),
      textStyle: const TextStyle(color: kChalk, fontSize: 12),
      waitDuration: const Duration(milliseconds: 300),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: kSafetyOrange,
      linearTrackColor: kLine,
      circularTrackColor: kLineSoft,
    ),
    datePickerTheme: const DatePickerThemeData(
      backgroundColor: kCarbon,
      surfaceTintColor: Colors.transparent,
      headerBackgroundColor: kInk,
      headerForegroundColor: kChalk,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(2)),
        side: BorderSide(color: kLine),
      ),
    ),
    scrollbarTheme: ScrollbarThemeData(
      thumbColor: const WidgetStatePropertyAll(kSteel),
      radius: Radius.zero,
      thickness: const WidgetStatePropertyAll(2),
    ),
    navigationBarTheme: const NavigationBarThemeData(
      height: 56,
      backgroundColor: kInk,
      surfaceTintColor: Colors.transparent,
      indicatorColor: Colors.transparent,
      elevation: 0,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: kSafetyOrange,
      foregroundColor: kInk,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(1)),
      ),
    ),
  );
}

TextTheme _ledgerTextTheme() {
  final base = Typography.material2021(platform: TargetPlatform.android).white;
  const tabular = [ui.FontFeature.tabularFigures()];
  return base
      .copyWith(
        displayLarge: base.displayLarge?.copyWith(
          fontFamily: kDisplayFont,
          fontSize: 54,
          fontWeight: FontWeight.w700,
          height: 0.98,
          letterSpacing: -1.8,
          fontFeatures: tabular,
          color: kChalk,
        ),
        displayMedium: base.displayMedium?.copyWith(
          fontFamily: kDisplayFont,
          fontSize: 42,
          fontWeight: FontWeight.w700,
          height: 1.0,
          letterSpacing: -1.2,
          fontFeatures: tabular,
          color: kChalk,
        ),
        displaySmall: base.displaySmall?.copyWith(
          fontFamily: kDisplayFont,
          fontSize: 34,
          fontWeight: FontWeight.w700,
          height: 1.05,
          letterSpacing: -0.8,
          fontFeatures: tabular,
          color: kChalk,
        ),
        headlineLarge: base.headlineLarge?.copyWith(
          fontFamily: kDisplayFont,
          fontSize: 30,
          fontWeight: FontWeight.w700,
          height: 1.1,
          color: kChalk,
        ),
        headlineMedium: base.headlineMedium?.copyWith(
          fontFamily: kDisplayFont,
          fontSize: 26,
          fontWeight: FontWeight.w700,
          height: 1.15,
          color: kChalk,
        ),
        headlineSmall: base.headlineSmall?.copyWith(
          fontFamily: kDisplayFont,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          height: 1.2,
          color: kChalk,
        ),
        titleLarge: base.titleLarge?.copyWith(
          fontSize: 19,
          fontWeight: FontWeight.w700,
          height: 1.3,
          color: kChalk,
        ),
        titleMedium: base.titleMedium?.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          height: 1.35,
          color: kChalk,
        ),
        titleSmall: base.titleSmall?.copyWith(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          height: 1.35,
          color: kChalk,
        ),
        bodyLarge: base.bodyLarge?.copyWith(
          fontSize: 16,
          height: 1.6,
          color: kChalk,
        ),
        bodyMedium: base.bodyMedium?.copyWith(
          fontSize: 14.5,
          height: 1.6,
          color: kChalk,
        ),
        bodySmall: base.bodySmall?.copyWith(
          fontSize: 12.5,
          height: 1.55,
          color: kSteel,
        ),
        labelLarge: base.labelLarge?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          height: 1.2,
          color: kChalk,
        ),
        labelMedium: base.labelMedium?.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          height: 1.2,
          color: kSteel,
        ),
        labelSmall: base.labelSmall?.copyWith(
          fontSize: 10.5,
          fontWeight: FontWeight.w500,
          height: 1.2,
          letterSpacing: 0.4,
          color: kSteel,
        ),
      )
      .apply(bodyColor: kChalk, displayColor: kChalk);
}

// Compatibility wrappers: the app is dark-only from v2.0.0.
ThemeData buildDefaultLightTheme() => buildLedgerTheme();
ThemeData buildDefaultDarkTheme() => buildLedgerTheme();
ThemeData buildCustomTheme(ThemeSettings settings) => buildLedgerTheme();

Color pageScrimColor(BuildContext context) {
  return Theme.of(context).extension<PageScrimTheme>()?.color ?? kInk;
}

ThemeData cardTheme(BuildContext context) {
  return Theme.of(context).copyWith(cardColor: kGraphite);
}

/// Optional custom photo background retained for old settings data.
class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.settings, required this.child});

  final ThemeSettings settings;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final imageFile = File(settings.backgroundImagePath);
    final hasImage =
        settings.useBackgroundImage &&
        settings.backgroundImagePath.isNotEmpty &&
        imageFile.existsSync();
    if (!hasImage) {
      return ColoredBox(color: kInk, child: child);
    }

    Widget image = Image.file(
      imageFile,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (_, __, ___) => const ColoredBox(color: kInk),
    );
    if (settings.backgroundImageBlur > 0) {
      image = ImageFiltered(
        imageFilter: ui.ImageFilter.blur(
          sigmaX: settings.backgroundImageBlur,
          sigmaY: settings.backgroundImageBlur,
        ),
        child: image,
      );
    }
    image = Opacity(
      opacity: settings.backgroundImageOpacity.clamp(0.05, 1.0),
      child: image,
    );

    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: kInk),
        image,
        const ColoredBox(color: Color(0xCC0A0B0C)),
        child,
      ],
    );
  }
}

class PageScrimTheme extends ThemeExtension<PageScrimTheme> {
  const PageScrimTheme({required this.color});

  final Color color;

  @override
  PageScrimTheme copyWith({Color? color}) {
    return PageScrimTheme(color: color ?? this.color);
  }

  @override
  PageScrimTheme lerp(
    covariant ThemeExtension<PageScrimTheme>? other,
    double t,
  ) {
    if (other is! PageScrimTheme) return this;
    return PageScrimTheme(color: Color.lerp(color, other.color, t) ?? color);
  }
}
