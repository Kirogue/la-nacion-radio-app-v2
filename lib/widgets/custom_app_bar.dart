import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:la_nacion/config/constants.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final appBarHeight = 80 + topPadding;

    return SizedBox(
      height: appBarHeight + topPadding,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0), // Blur más fuerte (estilo iOS)
              child: Container(
                color: AppConstants.surfaceColor.withAlpha((0.6 * 255).toInt()), // Más translúcido
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: topPadding, left: 20, right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Image.asset('assets/images/logo.png', width: 93)],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80.0);
}
