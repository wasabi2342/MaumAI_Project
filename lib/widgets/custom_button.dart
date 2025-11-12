import 'package:flutter/material.dart';

import '../core/app_export.dart';
import './custom_image_view.dart';

/**
 * CustomButton - A flexible button widget supporting various styles, icons, and layouts
 *
 * Features:
 * - Customizable background colors and text colors
 * - Optional left icon support
 * - Configurable padding, margin, and dimensions
 * - Built-in shadow effects and border radius
 * - Responsive design with SizeUtils integration
 *
 * @param text - Button text content (required)
 * @param onPressed - Tap callback function
 * @param backgroundColor - Button background color
 * @param textColor - Text color
 * @param leftIcon - Optional left icon path
 * @param width - Button width
 * @param height - Button height
 * @param padding - Internal padding
 * @param margin - External margin
 * @param fontSize - Text font size
 * @param fontWeight - Text font weight
 * @param borderRadius - Border radius
 * @param isEnabled - Button enabled state
 */
class CustomButton extends StatelessWidget {
  CustomButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.leftIcon,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.fontSize,
    this.fontWeight,
    this.borderRadius,
    this.isEnabled = true,
  }) : super(key: key);

  /// Button text content
  final String text;

  /// Callback function when button is pressed
  final VoidCallback? onPressed;

  /// Background color of the button
  final Color? backgroundColor;

  /// Text color
  final Color? textColor;

  /// Left icon image path
  final String? leftIcon;

  /// Button width
  final double? width;

  /// Button height
  final double? height;

  /// Button padding
  final EdgeInsets? padding;

  /// Button margin
  final EdgeInsets? margin;

  /// Text font size
  final double? fontSize;

  /// Text font weight
  final FontWeight? fontWeight;

  /// Border radius
  final double? borderRadius;

  /// Whether button is enabled
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    final double effectiveBorderRadius = borderRadius ?? 18.h;

    return Container(
      width: width,
      height: height ?? 48.h,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(effectiveBorderRadius),
        boxShadow: [
          BoxShadow(
            color: appTheme.color66D3D3,
            offset: Offset(0, 4.h),
            blurRadius: 8.h,
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? Color(0xFF32C697),
          foregroundColor: textColor ?? Color(0xFFFDFEFB),
          elevation: 0,
          padding: padding ??
              EdgeInsets.symmetric(
                horizontal: 30.h,
                vertical: 10.h,
              ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(effectiveBorderRadius),
          ),
          shadowColor: appTheme.transparentCustom,
        ).copyWith(
          overlayColor: WidgetStateProperty.all(appTheme.transparentCustom),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (leftIcon != null) ...[
              CustomImageView(
                imagePath: leftIcon!,
                height: 24.h,
                width: 24.h,
              ),
              SizedBox(width: 8.h),
            ],
            Flexible(
              child: Text(
                text,
                style: TextStyleHelper.instance.bodyTextPretendard.copyWith(
                  color: textColor ?? Color(0xFFFDFEFB),
                  fontSize: fontSize ?? 14.fSize,
                  fontWeight: fontWeight ?? FontWeight.w400,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}