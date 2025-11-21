import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'skeleton_pulse.dart';

class SkeletonNetworkImage extends StatelessWidget {
  final String? imageUrl;
  final double width;
  final double height;
  final BoxFit fit;

  const SkeletonNetworkImage({
    super.key,
    required this.imageUrl,
    required this.width,
    required this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    // OPTIMIZACIÓN: Si el ancho es finito, limitar el cache de memoria
    // para evitar decodificar imágenes gigantes innecesariamente.
    int? memCacheWidth;
    if (width != double.infinity && width > 0) {
      memCacheWidth = (width * 2.5).toInt(); // x2.5 para retina y margen
    }

    return CachedNetworkImage(
      imageUrl: imageUrl ?? '',
      width: width,
      height: height,
      fit: fit,
      memCacheWidth: memCacheWidth, // Ahorra mucha RAM
      placeholder: (_, __) => SkeletonPulse(width: width, height: height, showErrorIcon: false),
      errorWidget: (_, __, ___) => SkeletonPulse(width: width, height: height, showErrorIcon: true),
    );
  }
}
