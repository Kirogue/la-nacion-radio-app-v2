import 'dart:ui'; // Importar dart:ui para ImageFilter
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animations/animations.dart'; // Importar paquete de animaciones
import 'package:la_nacion/dashboard/controllers/mini_player_controller.dart';
import 'package:la_nacion/dashboard/controllers/news_controller.dart';
import 'package:provider/provider.dart';

// Constants
import 'package:la_nacion/config/constants.dart';

// Controllers
import '../controllers/navigation_controller.dart';
import '../controllers/radio_controller.dart';

// Views
import 'home_view.dart';
import 'radio_view.dart';
import 'companies_view.dart';
import 'news_view.dart';

// Widgets
import 'package:la_nacion/widgets/custom_app_bar.dart';
import 'package:la_nacion/widgets/custom_bottom_navigation_bar.dart';
import '../../widgets/radio/global_mini_player.dart';

class MainScreenView extends StatefulWidget {
  const MainScreenView({super.key});

  @override
  State<MainScreenView> createState() => _MainScreenViewState();
}

class _MainScreenViewState extends State<MainScreenView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final radioController = Provider.of<RadioController>(context, listen: false);
      await radioController.fetchPodcasts();

      if (radioController.radioPodcasts.isNotEmpty) {
        final firstPodcast = radioController.radioPodcasts.first;
        radioController.setCurrentPodcast(firstPodcast.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final newsController = context.watch<NewsController>();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        systemNavigationBarColor: AppConstants.surfaceColor,
        systemNavigationBarContrastEnforced: true,
      ),
      child: WillPopScope(
        onWillPop: () async {
          final newsCtrl = Provider.of<NewsController>(context, listen: false);
          final miniPlayer = Provider.of<MiniPlayerController>(context, listen: false);

          if (newsCtrl.isArticleWebViewOpen) {
            newsCtrl.setArticleWebViewOpen(false);
            return false;
          }

          if (miniPlayer.isExpanded) {
            miniPlayer.collapse();
            return false;
          }

          return true; // permite salir si no hay overlays activos
        },
        child: Scaffold(
          extendBodyBehindAppBar: true, // Restaurar para que el AppBar sea transparente
          backgroundColor: AppConstants.backgroundColor, // Negro profundo
          appBar: !newsController.isArticleWebViewOpen ? CustomAppBar() : null,
          body: Stack(
            children: [
              // Luces ambientales de fondo
              Positioned(
                top: -100,
                left: -100,
                child: Container(
                  width: 500,
                  height: 500,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 0.5,
                      colors: [
                        AppConstants.primaryColor.withAlpha(150),
                        AppConstants.primaryColor.withAlpha(50),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -100,
                right: -100,
                child: Container(
                  width: 400,
                  height: 400,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 0.5,
                      colors: [
                        Colors.blueAccent.withAlpha(80),
                        Colors.purple.withAlpha(30),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ),
              
              // Contenido con navegación
              Consumer<NavigationController>(
                builder: (context, nav, _) {
                  Widget child;
                  switch (nav.currentIndex) {
                    case 0:
                      child = const HomeView();
                      break;
                    case 1:
                      child = const RadioView();
                      break;
                    case 2:
                      child = const NewsView();
                      break;
                    case 3:
                      child = const CompaniesView();
                      break;
                    default:
                      child = const HomeView();
                  }

                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: KeyedSubtree(
                      key: ValueKey<int>(nav.currentIndex),
                      child: child,
                    ),
                  );
                },
              ),
              
              // Mini Player flotante arriba del navbar
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                bottom: newsController.isArticleWebViewOpen ? -100 : 80, // Posicionado arriba del navbar (80px desde abajo)
                left: 0,
                right: 0,
                child: GlobalMiniPlayer(),
              ),
              
              // Navbar flotante arriba del contenido
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: const CustomBottomNavigationBar(),
              ),
            ],
          ),
          bottomNavigationBar: null, // Ya está en el Stack como flotante
        ),
      ),
    );
  }
}
