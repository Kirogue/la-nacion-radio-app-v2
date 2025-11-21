import 'package:flutter/material.dart';
import 'package:la_nacion/dashboard/views/splash_screen_view.dart';
import 'package:la_nacion/dashboard/views/main_screen_view.dart';
import 'package:la_nacion/config/constants.dart';

class SplashWrapper extends StatefulWidget {
  const SplashWrapper({super.key});

  @override
  State<SplashWrapper> createState() => _SplashWrapperState();
}

class _SplashWrapperState extends State<SplashWrapper> with TickerProviderStateMixin {
  bool _showMain = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.5,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
  }

  void _handleLoaded() async {
    await _animationController.forward(); 
    if (mounted) setState(() => _showMain = true); 
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedOpacity(
          opacity: _showMain ? 1 : 0.5,
          duration: const Duration(milliseconds: 500),
          child: const MainScreenView(),
        ),
        if (!_showMain)
          SplashScreenView(
            onLoaded: _handleLoaded,
            scaleAnimation: _scaleAnimation,
            fadeAnimation: _fadeAnimation,
            useAlternativeVersion: AppConstants.useAlternativeVersion,
          ),
      ],
    );
  }
}
