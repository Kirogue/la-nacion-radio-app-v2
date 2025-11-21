import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:la_nacion/dashboard/controllers/radio_controller.dart';
import 'package:la_nacion/utils/responsive_values.dart';
import 'package:provider/provider.dart';
import '../../config/constants.dart';
import 'package:flutter/services.dart';
import 'package:la_nacion/dashboard/controllers/ads_controller.dart';
import 'package:la_nacion/dashboard/controllers/news_controller.dart';
import 'package:la_nacion/widgets/connection_error_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:la_nacion/dashboard/controllers/reels_controller.dart';

class SplashScreenView extends StatefulWidget {
  final VoidCallback onLoaded;
  final bool useAlternativeVersion;
  final Animation<double>? scaleAnimation;
  final Animation<double>? fadeAnimation;

  const SplashScreenView({
    super.key,
    required this.onLoaded,
    this.useAlternativeVersion = false,
    this.scaleAnimation,
    this.fadeAnimation,
  });

  @override
  State<SplashScreenView> createState() => _SplashScreenViewState();
}

class _SplashScreenViewState extends State<SplashScreenView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _rotationController;
  bool _navigated = false;
  Timer? _timeoutTimer;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _startTimeout();

    final adsController = Provider.of<AdsController>(context, listen: false);
    final newsController = Provider.of<NewsController>(context, listen: false);
    final radioController = Provider.of<RadioController>(
      context,
      listen: false,
    );
    final reelsController = Provider.of<ReelsController>(
      context,
      listen: false,
    );

    Future.microtask(() async {
      await _initializeApp(
        adsController,
        newsController,
        radioController,
        reelsController,
      );
    });
  }

  void _startTimeout() {
    _timeoutTimer = Timer(const Duration(seconds: 60), () {
      if (!_navigated && mounted) {
        _showTimeoutDialog();
      }
    });
  }

  void _cancelTimeout() {
    _timeoutTimer?.cancel();
  }

  void _retryInitialization() {
    _cancelTimeout();
    _startTimeout();

    final adsController = Provider.of<AdsController>(context, listen: false);
    final newsController = Provider.of<NewsController>(context, listen: false);
    final radioController = Provider.of<RadioController>(
      context,
      listen: false,
    );
    final reelsController = Provider.of<ReelsController>(
      context,
      listen: false,
    );

    Future.microtask(() async {
      await _initializeApp(
        adsController,
        newsController,
        radioController,
        reelsController,
      );
    });
  }

  void _showTimeoutDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (ctx) => ConnectionErrorDialog(
            onRetry: () {
              if (!mounted || _navigated) return;
              _retryInitialization();
            },
          ),
    );
  }

  @override
  void dispose() {
    _cancelTimeout();
    _rotationController.dispose();
    super.dispose();
  }

  Future<void> _initializeApp(
    AdsController adsController,
    NewsController newsController,
    RadioController radioController,
    ReelsController reelsController,
  ) async {
    // OPTIMIZACIÓN: Iniciar descargas PERO NO ESPERARLAS (Fire and Forget)
    // Esto permite entrar a la app inmediatamente mientras los datos cargan en segundo plano.

    // Lanzamos las peticiones en paralelo sin await
    if (adsController.items.isEmpty && !adsController.isLoading)
      adsController.fetchItems();
    if (newsController.newsList.isEmpty && !newsController.isLoading)
      newsController.loadNews();
    if (!radioController.isBuffering && radioController.radioPodcasts.isEmpty)
      radioController.fetchPodcasts();
    if (reelsController.reels.isEmpty && !reelsController.isLoading)
      reelsController.fetchReels();

    // Pequeña pausa estética para mostrar el logo (3 segundos)
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    _cancelTimeout();
    _navigated = true;
    widget.onLoaded();

    // El precache ya no es crítico aquí, puede correr tranquilo después
    Future.microtask(
      () =>
          _precacheImagesAsync(adsController, newsController, reelsController),
    );
  }

  Future<void> _precacheImagesAsync(
    AdsController ads,
    NewsController news,
    ReelsController reels,
  ) async {
    // OPTIMIZACIÓN: Solo precargar las imágenes más importantes (Primeros items visibles)
    // Esto libera ancho de banda para el streaming de audio y carga inicial.
    final essentialImages = [
      ...ads.items
          .take(3)
          .map(
            (ad) =>
                ad.acf['ad_image']?['sizes']?['medium_large'] ??
                ad.acf['ad_image']?['url'],
          )
          .whereType<String>(),

      ...news.newsList
          .take(5)
          .where((n) => n.hasImage)
          .map((n) => n.imageUrl!)
          .whereType<String>(),

      ...reels.reels
          .take(5)
          .map((r) => r.thumbnailUrl ?? r.mediaUrl)
          .whereType<String>(),
    ];

    // Cargar en serie o con límite bajo de concurrencia para no saturar la red
    for (final url in essentialImages) {
      if (!mounted) return;
      try {
        await precacheImage(CachedNetworkImageProvider(url), context);
      } catch (_) {
        debugPrint('Error precaching image: $url');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = responsiveValue(context, mobile: false, tablet: true);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        systemNavigationBarColor: AppConstants.secondaryColor,
        systemNavigationBarContrastEnforced: true,
      ),
      child: Scaffold(
        backgroundColor: AppConstants.secondaryColor,
        body: FadeTransition(
          opacity: widget.fadeAnimation ?? const AlwaysStoppedAnimation(1.0),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (!widget.useAlternativeVersion) ...[
                Positioned(
                  bottom: -50,
                  left: -50,
                  child: SvgPicture.asset(
                    'assets/icons/elipse.svg',
                    width: 200,
                    height: 200,
                  ),
                ),
                Positioned(
                  top: -50,
                  right: -50,
                  child: Transform.rotate(
                    angle: 3.1416,
                    child: SvgPicture.asset(
                      'assets/icons/elipse.svg',
                      width: 200,
                      height: 200,
                    ),
                  ),
                ),
              ] else ...[
                if (!isTablet)
                  Image.asset('assets/images/loading.jpg', fit: BoxFit.cover),
                Container(
                  color: AppConstants.secondaryColor.withAlpha(
                    (0.75 * 255).round(),
                  ),
                ),
              ],
              Center(
                child: ScaleTransition(
                  scale:
                      widget.scaleAnimation ??
                      const AlwaysStoppedAnimation(1.0),
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 250,
                    height: 123,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 80),
                  child: SizedBox(
                    width: 60,
                    height: 60,
                    child: RotationTransition(
                      turns: _rotationController,
                      child: SvgPicture.asset('assets/icons/loading.svg'),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
