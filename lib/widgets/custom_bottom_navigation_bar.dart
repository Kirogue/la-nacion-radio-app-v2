import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Para HapticFeedback
import 'package:flutter_svg/flutter_svg.dart';
import 'package:la_nacion/dashboard/controllers/mini_player_controller.dart';
import 'package:la_nacion/dashboard/controllers/news_controller.dart';
import 'package:provider/provider.dart';

import 'package:la_nacion/dashboard/controllers/navigation_controller.dart';
import 'package:la_nacion/config/constants.dart';
import 'package:la_nacion/config/custom_nav_style.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  const CustomBottomNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    final nav = Provider.of<NavigationController>(context);
    // Ignoramos CustomNavStyle por ahora para forzar el diseño dark/premium
    // final navStyle = Theme.of(context).extension<CustomNavStyle>()!;

    // Diseño Flotante Premium tipo Cápsula (Ultra-Premium Glassmorphism)
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 24.0, left: 30.0, right: 30.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32.0), // Bordes muy redondeados
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
            child: Container(
              height: 70.0,
              constraints: const BoxConstraints(maxWidth: 400), // No estirarse demasiado en tablets
              decoration: BoxDecoration(
                // Fondo semi-transparente oscuro para contraste máximo (estilo React App)
                color: const Color(0xFF050505).withAlpha((0.85 * 255).toInt()),
                borderRadius: BorderRadius.circular(32.0),
                border: Border.all(
                  color: Colors.white.withAlpha((0.1 * 255).toInt()),
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha((0.5 * 255).toInt()),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                    spreadRadius: 0,
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavItem(
                    context: context,
                    index: 0,
                    currentIndex: nav.currentIndex,
                    iconData: Icons.home_rounded,
                    label: 'Inicio',
                    onTap: nav.changeTab,
                  ),
                  _buildNavItem(
                    context: context,
                    index: 1,
                    currentIndex: nav.currentIndex,
                    iconData: Icons.radio_rounded,
                    label: 'Radio',
                    onTap: nav.changeTab,
                  ),
                  _buildNavItem(
                    context: context,
                    index: 2,
                    currentIndex: nav.currentIndex,
                    iconData: Icons.article_rounded,
                    label: 'Noticias',
                    onTap: nav.changeTab,
                  ),
                  _buildNavItem(
                    context: context,
                    index: 3,
                    currentIndex: nav.currentIndex,
                    iconData: Icons.store_mall_directory_rounded,
                    label: 'Directorio', // Renombrado de Menú a Directorio
                    onTap: nav.changeTab,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required int currentIndex,
    required IconData iconData,
    required String label,
    required void Function(int) onTap,
  }) {
    final isSelected = index == currentIndex;

    return GestureDetector(
      onTap: () {
        // Haptic Feedback para sensación táctil premium
        HapticFeedback.selectionClick();
        
        Provider.of<MiniPlayerController>(context, listen: false).collapse();
        Provider.of<NewsController>(context, listen: false).setArticleWebViewOpen(false);
        onTap(index);
      },
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        height: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icono animado
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 1.0, end: isSelected ? 1.2 : 1.0), // Escala sutil al seleccionar
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutBack,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Icon(
                    iconData,
                    size: 26.0,
                    color: isSelected ? AppConstants.primaryColor : Colors.grey[600],
                  ),
                );
              },
            ),
            
            const SizedBox(height: 4),

            // Punto brillante indicador (Estilo Enigma)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutQuint,
              width: isSelected ? 4 : 0,
              height: isSelected ? 4 : 0,
              decoration: BoxDecoration(
                color: AppConstants.primaryColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppConstants.primaryColor.withAlpha(150),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
