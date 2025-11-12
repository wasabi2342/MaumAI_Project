import 'package:flutter/material.dart';
import '../core/app_export.dart';

/// A helper class for managing text styles in the application
class TextStyleHelper {
  static TextStyleHelper? _instance;

  TextStyleHelper._();

  static TextStyleHelper get instance {
    _instance ??= TextStyleHelper._();
    return _instance!;
  }

  // Headline Styles
  // Medium-large text styles for section headers

  TextStyle get headline29BoldCafe24SsurroundOTF => TextStyle(
    fontSize: 29.fSize,
    fontWeight: FontWeight.w700,
    fontFamily: 'Cafe24 Ssurround OTF',
    color: appTheme.whiteCustom,
  );

  // Title Styles
  // Medium text styles for titles and subtitles

  TextStyle get title20RegularRoboto => TextStyle(
    fontSize: 20.fSize,
    fontWeight: FontWeight.w400,
    fontFamily: 'Roboto',
  );

  // Body Styles
  // Standard text styles for body content

  TextStyle get body14RegularPretendard => TextStyle(
    fontSize: 14.fSize,
    fontWeight: FontWeight.w400,
    fontFamily: 'Pretendard',
    color: appTheme.black_900,
  );

  TextStyle get body12MediumPretendard => TextStyle(
    fontSize: 12.fSize,
    fontWeight: FontWeight.w500,
    fontFamily: 'Pretendard',
    color: appTheme.teal_400,
  );

  // Other Styles
  // Miscellaneous text styles without specified font size

  TextStyle get bodyTextPretendard => TextStyle(
    fontFamily: 'Pretendard',
  );
}
