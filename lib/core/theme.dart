import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/models/theme_settings.dart';
import 'weight.dart';

const Color kPrimaryBlue = Color(0xFF4285F4);
const Color kWarmYellow = Color(0xFFF5A623);
const Color kDangerRed = Color(0xFFE53E3E);
const Color kLightBackground = Color(0xFFF7FAFF);
const Color kLightCard = Color(0xFFFFFFFF);
const Color kDarkBackground = Color(0xFF0F141E);
const Color kDarkCard = Color(0xFF1B2230);

ThemeData buildDefaultLightTheme() {
  return _buildTheme(
    background: kLightBackground,
    card: kLightCard,
    pageBrightness: Brightness.light,
    cardBrightness: Brightness.light,
    transparentScaffold: false,
  );
}

ThemeData buildDefaultDarkTheme() {
  return _buildTheme(
    background: kDarkBackground,
    card: kDarkCard,
    pageBrightness: Brightness.dark,
    cardBrightness: Brightness.dark,
    transparentScaffold: false,
  );
}

ThemeData buildCustomTheme(ThemeSettings settings) {
  final card = Color(settings.cardColorValue);
  final background = Color(settings.backgroundColorValue);
  final cardBrightness = ThemeData.estimateBrightnessForColor(card);
  final hasImage = settings.useBackgroundImage;
  // 图片背景优先于纯色背景：页面文字固定使用深色遮罩上的白色，
  // 不再根据卡片颜色决定页面文字/遮罩。
  final pageReference = hasImage ? Colors.black : background;
  final pageBrightness = ThemeData.estimateBrightnessForColor(pageReference);
  return _buildTheme(
    background: pageReference,
    card: card,
    pageBrightness: pageBrightness,
    cardBrightness: cardBrightness,
    transparentScaffold: hasImage,
  );
}

ThemeData _buildTheme({
  required Color background,
  required Color card,
  required Brightness pageBrightness,
  required Brightness cardBrightness,
  required bool transparentScaffold,
}) {
  final pageText = contrastColor(background);
  final cardText = contrastColor(card);
  final cardSecondary = secondaryTextColor(card);
  final seedScheme = ColorScheme.fromSeed(
    seedColor: kPrimaryBlue,
    brightness: cardBrightness,
  );
  final scheme = seedScheme.copyWith(
    primary: cardBrightness == Brightness.dark
        ? const Color(0xFF9CC4FF)
        : kPrimaryBlue,
    secondary: kWarmYellow,
    error: kDangerRed,
    surface: card,
    onSurface: cardText,
    onSurfaceVariant: cardSecondary,
    outlineVariant: cardText.withAlpha(42),
    outline: cardText.withAlpha(90),
  );

  final base = ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    brightness: cardBrightness,
    scaffoldBackgroundColor: transparentScaffold
        ? Colors.transparent
        : background,
    cardColor: card,
    canvasColor: card,
    extensions: <ThemeExtension<dynamic>>[PageScrimTheme(color: background)],
    dividerColor: cardText.withAlpha(32),
    textTheme: Typography.material2021(
      platform: TargetPlatform.android,
    ).black.apply(bodyColor: pageText, displayColor: pageText),
    iconTheme: IconThemeData(color: pageText),
    appBarTheme: AppBarTheme(
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: pageText,
      systemOverlayStyle: pageBrightness == Brightness.dark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        color: pageText,
        fontSize: 22,
        fontWeight: FontWeight.w700,
      ),
      iconTheme: IconThemeData(color: pageText),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: card,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        color: cardText,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
      contentTextStyle: TextStyle(color: cardText, fontSize: 14, height: 1.5),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: card,
      modalBackgroundColor: card,
      surfaceTintColor: Colors.transparent,
      modalBarrierColor: Colors.black.withAlpha(80),
    ),
    inputDecorationTheme: InputDecorationTheme(
      isDense: true,
      filled: true,
      fillColor: _tint(card, cardText, 8),
      labelStyle: TextStyle(color: cardSecondary),
      hintStyle: TextStyle(color: cardSecondary.withAlpha(150)),
      prefixIconColor: cardSecondary,
      suffixIconColor: cardSecondary,
      counterStyle: TextStyle(color: cardSecondary),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: cardText.withAlpha(45)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: cardText.withAlpha(45)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: scheme.primary, width: 1.5),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: 68,
      backgroundColor: card,
      surfaceTintColor: Colors.transparent,
      indicatorColor: scheme.primary.withAlpha(36),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        return IconThemeData(
          color: states.contains(WidgetState.selected)
              ? scheme.primary
              : cardText,
        );
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        return TextStyle(
          color: states.contains(WidgetState.selected)
              ? scheme.primary
              : cardSecondary,
          fontSize: 12,
          fontWeight: states.contains(WidgetState.selected)
              ? FontWeight.w600
              : FontWeight.w400,
        );
      }),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: scheme.primary,
      foregroundColor: contrastColor(scheme.primary),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: cardBrightness == Brightness.dark
          ? const Color(0xFFEDF2FF)
          : const Color(0xFF222A36),
      contentTextStyle: TextStyle(
        color: cardBrightness == Brightness.dark ? Colors.black : Colors.white,
      ),
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: scheme.primary,
      selectionColor: scheme.primary.withAlpha(60),
      selectionHandleColor: scheme.primary,
    ),
    dividerTheme: DividerThemeData(
      color: cardText.withAlpha(32),
      thickness: 1,
      space: 1,
    ),
  );

  return base.copyWith(
    textTheme: base.textTheme.apply(
      bodyColor: pageText,
      displayColor: pageText,
    ),
  );
}

Color _tint(Color base, Color text, int alpha) {
  return Color.alphaBlend(text.withAlpha(alpha), base);
}

/// 自定义图片/纯色全局背景。只在自定义主题下使用。
class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.settings, required this.child});

  final ThemeSettings settings;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final background = Color(settings.backgroundColorValue);
    final imageFile = File(settings.backgroundImagePath);
    final hasImage =
        settings.useBackgroundImage &&
        settings.backgroundImagePath.isNotEmpty &&
        imageFile.existsSync();

    if (!settings.useBackgroundImage) {
      return ColoredBox(color: background, child: child);
    }
    if (!hasImage) {
      // 图片模式已开启但文件暂时不可用：仍保持深色底，避免白色页面文字
      // 落在浅色纯色背景上而看不清。
      return ColoredBox(color: Colors.black, child: child);
    }

    Widget image = Image.file(
      imageFile,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (_, __, ___) => const ColoredBox(color: Colors.black),
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
        // 图片模式使用独立的深色底，不读取卡片背景色。
        const ColoredBox(color: Colors.black),
        image,
        // 中性的深色遮罩，只服务于文字可读性，不参与卡片配色。
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withAlpha(120),
                Colors.black.withAlpha(70),
                Colors.black.withAlpha(145),
              ],
            ),
          ),
        ),
        child,
      ],
    );
  }
}

/// 页面顶部/底部渐变蒙层使用的基准色。
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

Color pageScrimColor(BuildContext context) {
  final theme = Theme.of(context);
  return theme.extension<PageScrimTheme>()?.color ??
      theme.scaffoldBackgroundColor;
}

/// 卡片内部主题：按卡片底色自动选择文字深浅。
ThemeData cardTheme(BuildContext context) {
  final theme = Theme.of(context);
  final card = theme.cardColor;
  final text = contrastColor(card);
  final secondary = secondaryTextColor(card);
  final brightness = ThemeData.estimateBrightnessForColor(card);
  final scheme =
      ColorScheme.fromSeed(
        seedColor: kPrimaryBlue,
        brightness: brightness,
      ).copyWith(
        primary: brightness == Brightness.dark
            ? const Color(0xFF9CC4FF)
            : kPrimaryBlue,
        secondary: kWarmYellow,
        error: kDangerRed,
        surface: card,
        onSurface: text,
        onSurfaceVariant: secondary,
        outlineVariant: text.withAlpha(42),
        outline: text.withAlpha(90),
      );
  return theme.copyWith(
    colorScheme: scheme,
    textTheme: theme.textTheme.apply(bodyColor: text, displayColor: text),
    iconTheme: theme.iconTheme.copyWith(color: text),
    dividerColor: text.withAlpha(32),
  );
}
