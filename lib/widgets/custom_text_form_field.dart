import 'package:flutter/material.dart';

import '../core/app_export.dart';

/**
 * CustomTextFormField - A reusable text input field component with comprehensive styling and validation support
 *
 * Supports various input types, validation, styling customization, and responsive design.
 * Handles email, password, and general text input with proper keyboard types and validation.
 *
 * @param controller - TextEditingController for managing text input
 * @param placeholder - Hint text displayed when field is empty
 * @param validator - Function to validate input text
 * @param keyboardType - Type of keyboard to display
 * @param obscureText - Whether to hide text input (for passwords)
 * @param onTap - Callback function when field is tapped
 * @param readOnly - Whether the field is read-only
 * @param maxLines - Maximum number of lines for text input
 * @param textStyle - Custom text style for input text
 * @param fillColor - Background color of the input field
 * @param borderColor - Border color of the input field
 * @param focusedBorderColor - Border color when field is focused
 * @param borderRadius - Border radius of the input field
 * @param contentPadding - Internal padding of the input field
 * @param margin - External margin around the input field
 * @param suffixIcon - Widget to display at the end of the field
 * @param prefixIcon - Widget to display at the beginning of the field
 */
class CustomTextFormField extends StatelessWidget {
  CustomTextFormField({
    Key? key,
    this.controller,
    this.placeholder,
    this.validator,
    this.keyboardType,
    this.obscureText,
    this.onTap,
    this.readOnly,
    this.maxLines,
    this.textStyle,
    this.fillColor,
    this.borderColor,
    this.focusedBorderColor,
    this.borderRadius,
    this.contentPadding,
    this.margin,
    this.suffixIcon,
    this.prefixIcon,
  }) : super(key: key);

  final TextEditingController? controller;
  final String? placeholder;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool? obscureText;
  final VoidCallback? onTap;
  final bool? readOnly;
  final int? maxLines;
  final TextStyle? textStyle;
  final Color? fillColor;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final double? borderRadius;
  final EdgeInsetsGeometry? contentPadding;
  final EdgeInsetsGeometry? margin;
  final Widget? suffixIcon;
  final Widget? prefixIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? EdgeInsets.only(top: 2.h),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType ?? TextInputType.text,
        obscureText: obscureText ?? false,
        onTap: onTap,
        readOnly: readOnly ?? false,
        maxLines: maxLines ?? 1,
        style: textStyle ?? TextStyleHelper.instance.body14RegularPretendard,
        decoration: InputDecoration(
          hintText: placeholder,
          hintStyle: TextStyleHelper.instance.body14RegularPretendard
              .copyWith(color: appTheme.blue_gray_100),
          filled: true,
          fillColor: fillColor ?? Color(0xFFFDFEFB),
          contentPadding: contentPadding ??
              EdgeInsets.symmetric(
                horizontal: 10.h,
                vertical: 8.h,
              ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 16.h),
            borderSide: BorderSide(
              color: borderColor ?? Color(0x66D3D3D3),
              width: 1.h,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 16.h),
            borderSide: BorderSide(
              color: borderColor ?? Color(0x66D3D3D3),
              width: 1.h,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 16.h),
            borderSide: BorderSide(
              color: focusedBorderColor ?? Color(0xFF66D3D3),
              width: 1.h,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 16.h),
            borderSide: BorderSide(
              color: appTheme.redCustom,
              width: 1.h,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 16.h),
            borderSide: BorderSide(
              color: appTheme.redCustom,
              width: 1.h,
            ),
          ),
          suffixIcon: suffixIcon,
          prefixIcon: prefixIcon,
        ),
      ),
    );
  }
}
