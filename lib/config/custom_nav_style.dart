import 'package:flutter/material.dart';

@immutable
class CustomNavStyle extends ThemeExtension<CustomNavStyle> {
  final Color backgroundColor;
  final Color selectedColor;
  final Color unselectedColor;
  final TextStyle labelStyle;

  const CustomNavStyle({
    required this.backgroundColor,
    required this.selectedColor,
    required this.unselectedColor,
    required this.labelStyle,
  });

  @override
  CustomNavStyle copyWith({
    Color? backgroundColor,
    Color? selectedColor,
    Color? unselectedColor,
    TextStyle? labelStyle,
  }) {
    return CustomNavStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      selectedColor: selectedColor ?? this.selectedColor,
      unselectedColor: unselectedColor ?? this.unselectedColor,
      labelStyle: labelStyle ?? this.labelStyle,
    );
  }

  @override
  CustomNavStyle lerp(ThemeExtension<CustomNavStyle>? other, double t) {
    if (other is! CustomNavStyle) return this;
    return CustomNavStyle(
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t)!,
      selectedColor: Color.lerp(selectedColor, other.selectedColor, t)!,
      unselectedColor: Color.lerp(unselectedColor, other.unselectedColor, t)!,
      labelStyle: TextStyle.lerp(labelStyle, other.labelStyle, t)!,
    );
  }
}
