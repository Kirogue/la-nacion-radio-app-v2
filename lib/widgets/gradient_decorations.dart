import 'package:flutter/material.dart';
import 'package:la_nacion/config/constants.dart';

enum GradientVariant { normal, alternative, banner }

BoxDecoration gradientDecoration([
  GradientVariant variant = GradientVariant.normal,
]) {
  switch (variant) {
    case GradientVariant.normal:
      return BoxDecoration(
        gradient: LinearGradient(
          colors: [AppConstants.lightGradient, AppConstants.darkGradient],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      );
    case GradientVariant.alternative:
      return BoxDecoration(
        gradient: LinearGradient(
          colors: [AppConstants.lightGrey, AppConstants.secondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      );
    case GradientVariant.banner:
      return BoxDecoration(
        gradient: LinearGradient(
          colors: [AppConstants.blueGradient, AppConstants.secondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      );
  }
}
