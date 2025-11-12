import 'package:flutter/material.dart';

String _appTheme = "lightCode";
LightCodeColors get appTheme => ThemeHelper().themeColor();
ThemeData get theme => ThemeHelper().themeData();

/// Helper class for managing themes and colors.

// ignore_for_file: must_be_immutable
class ThemeHelper {
  // A map of custom color themes supported by the app
  Map<String, LightCodeColors> _supportedCustomColor = {
    'lightCode': LightCodeColors()
  };

  // A map of color schemes supported by the app
  Map<String, ColorScheme> _supportedColorScheme = {
    'lightCode': ColorSchemes.lightCodeColorScheme
  };

  /// Changes the app theme to [_newTheme].
  void changeTheme(String _newTheme) {
    _appTheme = _newTheme;
  }

  /// Returns the lightCode colors for the current theme.
  LightCodeColors _getThemeColors() {
    return _supportedCustomColor[_appTheme] ?? LightCodeColors();
  }

  /// Returns the current theme data.
  ThemeData _getThemeData() {
    var colorScheme =
        _supportedColorScheme[_appTheme] ?? ColorSchemes.lightCodeColorScheme;
    return ThemeData(
      visualDensity: VisualDensity.standard,
      colorScheme: colorScheme,
    );
  }

  /// Returns the lightCode colors for the current theme.
  LightCodeColors themeColor() => _getThemeColors();

  /// Returns the current theme data.
  ThemeData themeData() => _getThemeData();
}

class ColorSchemes {
  static final lightCodeColorScheme = ColorScheme.light();
}

class LightCodeColors {
  // App Colors
  Color get green_200 => Color(0xFFA0ECB1);
  Color get teal_400 => Color(0xFF32C697);
  Color get blue_gray_700 => Color(0xFF37705E);
  Color get blue_gray_100 => Color(0xFFD3D3D3);
  Color get white_A700 => Color(0xFFFDFEFB);
  Color get gray_800 => Color(0xFF3B3B3B);
  Color get black_900 => Color(0xFF000000);
  Color get yellow_A400 => Color(0xFFFFE812);
  Color get blue_A200 => Color(0xFF4285F4);
  Color get green_600 => Color(0xFF34A853);
  Color get amber_500 => Color(0xFFFBBC05);
  Color get red_500 => Color(0xFFEB4335);
  Color get green_50 => Color(0xFFE3FAE8);

  // Additional Colors
  Color get transparentCustom => Colors.transparent;
  Color get whiteCustom => Colors.white;
  Color get greyCustom => Colors.grey;
  Color get redCustom => Colors.red;
  Color get color66D3D3 => Color(0x66D3D3D3);
  Color get colorFF66D3 => Color(0xFF66D3D3);

  // Color Shades - Each shade has its own dedicated constant
  Color get grey200 => Colors.grey.shade200;
  Color get grey100 => Colors.grey.shade100;
}
