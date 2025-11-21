import 'package:flutter/material.dart';
import 'package:la_nacion/utils/responsive_values.dart';
import 'package:la_nacion/widgets/skeleton_network_image.dart';
import 'package:la_nacion/widgets/skeleton_pulse.dart';
import '../config/constants.dart';
import '../config/text_styles.dart';

import '../dashboard/views/enlace_radial_view.dart';

class MediaCard extends StatelessWidget {
  final String imageUrl;
  final String? title;
  final String? description;
  final VoidCallback? onTap;
  final double xMargin;

  const MediaCard({
    super.key,
    required this.imageUrl,
    this.title,
    this.description,
    this.onTap,
    this.xMargin = 16,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: EdgeInsets.symmetric(horizontal: xMargin, vertical: 8),
        decoration: BoxDecoration(
          color: AppConstants.lightGradient,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.3 * 255).round()),
              offset: const Offset(0, 4),
              blurRadius: 8,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder:
                        (context, error, stackTrace) => Container(
                          color: AppConstants.lightGrey,
                          child: const Icon(
                            Icons.image_not_supported,
                            color: AppConstants.darkGrey,
                            size: 40,
                          ),
                        ),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: AppConstants.lightGrey,
                        child: Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(AppConstants.primaryColor),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            if (title != null || description != null)
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (title != null)
                        Text(
                          title!,
                          style: AppTextStyles.musicTitle.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      if (title != null && description != null) const SizedBox(height: 4),
                      if (description != null)
                        Text(
                          description!,
                          style: AppTextStyles.musicSubtitle.copyWith(
                            fontSize: 12,
                            color: AppConstants.textLight.withAlpha((0.8 * 255).round()),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class HorizontalMediaCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String author;
  final IconData? countIcon;
  final double? width;
  final double? height;
  final VoidCallback? onTap;

  const HorizontalMediaCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.author,
    this.width,
    this.height,
    this.countIcon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        constraints: BoxConstraints(maxWidth: 600),
        margin: const EdgeInsets.symmetric(vertical: 6), // Menos margen vertical
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E), // Color sólido oscuro (Dark Grey)
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 1. Artwork (Cuadrado perfecto con borde redondeado)
            SizedBox(
              width: responsiveValue(context, mobile: 70, tablet: 90),
              height: responsiveValue(context, mobile: 70, tablet: 90),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SkeletonNetworkImage(
                  imageUrl: imageUrl,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            
            const SizedBox(width: 16),

            // 2. Info Text
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700, // Bold
                      fontFamily: 'Montserrat',
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    author.toUpperCase(),
                    style: TextStyle(
                      color: Colors.white.withAlpha(150), // Gris claro
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // 3. Play Button (Sutil)
            if (countIcon != null)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppConstants.primaryColor.withAlpha(20),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  countIcon, 
                  size: 20, 
                  color: AppConstants.primaryColor
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class BannerPodcast extends StatelessWidget {
  final VoidCallback? onTap;
  final Widget? countIcon;

  const BannerPodcast({super.key, this.onTap, this.countIcon});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: BoxConstraints(maxWidth: 600),
        height: responsiveValue(context, mobile: 150, tablet: 200),
        margin: responsiveValue<EdgeInsets>(
          context,
          mobile: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          tablet: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
        ),

        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
        child: Stack(
          children: [
            // Fondo imagen
            Positioned.fill(
              child: Image.asset('assets/images/banner-podcast.png', fit: BoxFit.cover),
            ),

            // Ícono alineado a la izquierda con padding
            Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                child: Container(
                  margin: responsiveValue<EdgeInsets>(
                    context,
                    mobile: const EdgeInsets.only(top: 55, right: 20),
                    tablet: const EdgeInsets.only(top: 80, right: 30),
                  ),
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    border: BoxBorder.all(color: Colors.white, width: 2),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: countIcon,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final IconData icon;
  final VoidCallback? onTap;
  final double? width;
  final double? height;
  final double borderRadius;
  final double opacity;
  final bool isLocalImage;

  const InfoCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.icon,
    this.onTap,
    this.width,
    this.height,
    this.borderRadius = 14,
    this.opacity = 0.9,
    this.isLocalImage = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder:
              (context) => DraggableScrollableSheet(
                initialChildSize: 0.9,
                minChildSize: 0.6,
                maxChildSize: 0.95,
                expand: false,
                builder: (context, scrollController) {
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: const BoxDecoration(
                      color: AppConstants.backgroundColor,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: EnlaceRadialView(),
                    ),
                  );
                },
              ),
        );
      },
      child: Container(
        constraints: BoxConstraints(maxWidth: 600),
        width: width ?? double.infinity,
        height: height ?? 180,
        margin: responsiveValue<EdgeInsets>(
          context,
          mobile: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          tablet: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          color: AppConstants.lightGrey,
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Opacity(
                opacity: opacity,
                child:
                    isLocalImage
                        ? Image.asset(
                          imageUrl,
                          fit: BoxFit.contain,
                          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                            // Mostrar skeleton mientras la imagen se carga
                            if (frame == null) {
                              return SkeletonPulse(height: double.infinity, width: double.infinity);
                            }
                            // Cuando la imagen está cargada, mostrar la imagen con animación de fade
                            return AnimatedOpacity(
                              opacity: 1,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOut,
                              child: child,
                            );
                          },
                          errorBuilder:
                              (context, error, stackTrace) => SkeletonPulse(
                                height: double.infinity,
                                width: double.infinity,
                                showErrorIcon: true,
                              ),
                        )
                        : Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) => SkeletonPulse(
                                height: double.infinity,
                                width: double.infinity,
                                showErrorIcon: true,
                              ),
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return SkeletonPulse(height: double.infinity, width: double.infinity);
                          },
                        ),
              ),

              // Capa de color negra con transparencia para mejorar legibilidad
              Container(color: Colors.black.withAlpha((0.4 * 255).round())),

              // Contenido (icono + texto)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(color: Colors.black54, blurRadius: 4, offset: Offset(1, 1)),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Icon(icon, color: Colors.white, size: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CategoryLabel extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;

  const CategoryLabel({super.key, required this.text, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1D63FF), Color(0xFF363E51)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          text,
          style: AppTextStyles.categoryLabel.copyWith(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }
}

class ScheduleCard extends StatelessWidget {
  final dynamic scheduleData; // puede ser List (repeater) o String (multiline) o Map

  const ScheduleCard({super.key, required this.scheduleData});

  @override
  Widget build(BuildContext context) {
    final List<Widget> rows = [];

    if (scheduleData is List) {
      // cada item: { "company_schedule_days": ["Lunes","Martes"], "company_schedule_time_start": "7:00 am", "company_schedule_time_end": "10:00 pm" }
      for (var item in scheduleData) {
        final daysList = (item['company_schedule_days'] as List?)?.cast<String>() ?? [];
        final daysText = daysList.join(', ');
        final start = (item['company_schedule_time_start'] ?? '') as String;
        final end = (item['company_schedule_time_end'] ?? '') as String;
        final hours =
            (start.isNotEmpty && end.isNotEmpty)
                ? '$start - $end'
                : (start.isNotEmpty ? start : end);
        rows.add(_buildScheduleRow(daysText, hours));
      }
    } else if (scheduleData is Map) {
      // posible caso si ACF devuelve un solo grupo como Map
      final daysList = (scheduleData['company_schedule_days'] as List?)?.cast<String>() ?? [];
      final daysText = daysList.join(', ');
      final start = (scheduleData['company_schedule_time_start'] ?? '') as String;
      final end = (scheduleData['company_schedule_time_end'] ?? '') as String;
      final hours =
          (start.isNotEmpty && end.isNotEmpty) ? '$start - $end' : (start.isNotEmpty ? start : end);
      rows.add(_buildScheduleRow(daysText, hours));
    } else if (scheduleData is String) {
      // fallback antiguo: multiline string
      final lines = scheduleData.split('\n').where((line) => line.trim().isNotEmpty).toList();
      for (var line in lines) {
        // intentar extraer con regex anterior
        final regex = RegExp(r'^(.*?)(\d+:\d+\s*[apmAPM]*\s*-\s*\d+:\d+\s*[apmAPM]*)');
        final match = regex.firstMatch(line.trim());
        if (match != null) {
          final days = match.group(1)?.trim() ?? '';
          final hours = match.group(2)?.trim() ?? '';
          rows.add(_buildScheduleRow(days, hours));
        } else {
          rows.add(_buildScheduleRow(line.trim(), ''));
        }
      }
    } else {
      rows.add(_buildScheduleRow('Horario no disponible', ''));
    }

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: responsiveValue(context, mobile: 40.0, tablet: 20.0)),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
      child: Column(
        children: [
          Text(
            'HORARIO DEL NEGOCIO',
            style: AppTextStyles.navLabel.copyWith(
              fontWeight: FontWeight.bold,
              color: AppConstants.primaryColor,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 12),
          ...rows,
        ],
      ),
    );
  }

  Widget _buildScheduleRow(String daysText, String hoursText) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        children: [
          if (daysText.isNotEmpty)
            Text(
              daysText.toUpperCase(),
              style: AppTextStyles.navLabel.copyWith(
                color: AppConstants.primaryColor,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
          if (hoursText.isNotEmpty)
            Text(
              hoursText,
              style: AppTextStyles.navLabel.copyWith(
                color: AppConstants.primaryColor,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
          if (daysText.isEmpty && hoursText.isEmpty)
            Text(
              'Horario no disponible',
              style: AppTextStyles.navLabel.copyWith(color: AppConstants.primaryColor),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }
}

class ScheduleCardRadio extends StatelessWidget {
  final String schedule;

  const ScheduleCardRadio({super.key, required this.schedule});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: [
                Text(
                  'Todos los ',
                  style: AppTextStyles.navLabel.copyWith(
                    color: AppConstants.primaryColor,
                    fontSize: 20,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  schedule,
                  style: AppTextStyles.navLabel.copyWith(
                    color: AppConstants.primaryColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
