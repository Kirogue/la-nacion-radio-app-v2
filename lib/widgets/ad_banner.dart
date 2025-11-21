import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:la_nacion/dashboard/models/wp_api_model.dart';
import 'package:la_nacion/widgets/skeleton_network_image.dart';
import 'package:la_nacion/widgets/skeleton_pulse.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:la_nacion/utils/responsive_values.dart';

class AdBanner extends StatefulWidget {
  final List<WpItem> ads;
  final double xMargin;
  const AdBanner({super.key, required this.ads, this.xMargin = 16});

  @override
  State<AdBanner> createState() => _AdBannerState();
}

class _AdBannerState extends State<AdBanner> {
  PageController? _pageController;
  List<WpItem> _displayAds = [];
  Timer? _autoSlideTimer;
  bool imagesReady = false;

  static const _autoScrollDuration = Duration(seconds: 5);
  static const int _visibleAdsCount = 3;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_displayAds.isEmpty && widget.ads.isNotEmpty) {
      _prepareDisplayAds();
    }
  }

  void _prepareDisplayAds() {
    if (_displayAds.isNotEmpty) return; // Ya preparados

    final original = widget.ads.take(_visibleAdsCount).toList();
    _displayAds = [...original, ...original]; // duplicar para scroll infinito

    _pageController = PageController(initialPage: _visibleAdsCount);
    _precacheImages();
    _startAutoScroll();
  }

  void _precacheImages() async {
    for (final ad in _displayAds) {
      if (!mounted) return;
      final url = responsiveValue<String?>(
        context,
        mobile: ad.acf['ad_image']?['sizes']?['medium_large'] ?? ad.acf['ad_image']?['url'],
        tablet: ad.acf['ad_image']?['sizes']?['large'] ?? ad.acf['ad_image']?['url'],
      );
      if (url != null) {
        await precacheImage(CachedNetworkImageProvider(url), context);
      }
    }
    if (mounted) setState(() => imagesReady = true);
  }

  void _startAutoScroll() {
    _autoSlideTimer = Timer.periodic(_autoScrollDuration, (_) {
      if (!mounted || !_pageController!.hasClients) return;
      final next = _pageController!.page!.toInt() + 1;
      _pageController?.animateToPage(
        next,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  void _resetAutoScroll() {
    _autoSlideTimer?.cancel();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _pageController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.ads.isEmpty || _displayAds.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _prepareDisplayAds());

      return Container(
        constraints: BoxConstraints(maxWidth: 1000),
        margin: EdgeInsets.symmetric(horizontal: widget.xMargin, vertical: 8),
        child: SkeletonPulse(
          width: double.infinity,
          height: responsiveValue<double>(context, mobile: 200, tablet: 300),
        ),
      );
    }

    return Container(
      constraints: BoxConstraints(maxWidth: 600),
      height: responsiveValue<double>(context, mobile: 200, tablet: 300),
      child: PageView.builder(
        controller: _pageController!,
        onPageChanged: (_) => _resetAutoScroll(),
        itemBuilder: (_, i) {
          final ad = _displayAds[i % _visibleAdsCount]; // loop cleanly
          final acf = ad.acf;
          final imageUrl = acf['ad_image']?['sizes']?['medium_large'] ?? acf['ad_image']?['url'];
          final link = acf['ad_link'] ?? '';

          return GestureDetector(
            onTap: () async {
              final uri = Uri.parse(link);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: widget.xMargin, vertical: 8),
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  SkeletonNetworkImage(
                    imageUrl: imageUrl,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, Colors.black.withAlpha((0.85 * 255).round())],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
