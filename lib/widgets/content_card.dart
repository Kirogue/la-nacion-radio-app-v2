import 'package:flutter/material.dart';
import 'package:la_nacion/utils/responsive_values.dart';
import 'package:la_nacion/widgets/skeleton_network_image.dart';
import 'package:provider/provider.dart';
import 'package:la_nacion/dashboard/controllers/news_controller.dart';
import 'package:la_nacion/dashboard/models/news_model.dart';
import 'package:la_nacion/dashboard/models/radio_model.dart';
import 'package:la_nacion/dashboard/controllers/radio_controller.dart';
import 'package:la_nacion/widgets/radio/radio_modal.dart';
import 'package:la_nacion/widgets/companies/company_modal.dart';
import 'package:la_nacion/config/constants.dart';
import 'package:la_nacion/widgets/animations/bounce_button.dart'; // Importar BounceButton

class ContentCard extends StatefulWidget {
  final String title;
  final String imageUrl;
  final String routeName;
  final dynamic item;
  final bool showTitle;

  const ContentCard({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.routeName,
    required this.item,
    this.showTitle = true,
  });

  @override
  State<ContentCard> createState() => _ContentCardState();
}

class _ContentCardState extends State<ContentCard> {
  void _handleTap(BuildContext context) {
    switch (widget.routeName) {
      case 'news':
        final newsController = Provider.of<NewsController>(context, listen: false);
        if (widget.item is NewsModel) {
          newsController.selectNews(widget.item);
          newsController.setArticleWebViewOpen(true);
        }
        break; // Faltaba break aquí

      case 'radio':
        final radioController = Provider.of<RadioController>(context, listen: false);
        if (widget.item is RadioModel) {
          final podcast = widget.item as RadioModel;
          if (podcast.isPlayable) {
            radioController.playPodcast(podcast.streamUrl, podcast.id);
          } else {
            showRadioProgramDetailModal(context, podcast);
          }
        }
        break;

      case 'companies':
        if (widget.item != null) {
          showCompanyDetailModal(context, widget.item);
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = 16.0;
    final separatorWidth = responsiveValue<double>(context, mobile: 12.0, tablet: 36.0);

    final cardWidth = responsiveValue<double>(
      context,
      mobile:
          (screenWidth - (horizontalPadding * 2) - separatorWidth * 1) /
          2.5, // muestra 2.5 tarjetas
      tablet:
          (screenWidth - (horizontalPadding * 2) - separatorWidth * (5 - 1)) /
          4.5, // máximo 5 tarjetas
    );

    // Diseño Premium Enigma: Tarjeta "Glass" con borde sutil y sombra profunda
    return BounceButton(
      onTap: () => _handleTap(context),
      child: Container(
        width: cardWidth,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24), // Muy redondeado
          border: Border.all(color: Colors.white.withAlpha(20), width: 1), // Borde sutil
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(100),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
            // Sombra de acento muy sutil (azul La Nación)
            BoxShadow(
              color: AppConstants.primaryColor.withAlpha(20),
              blurRadius: 30,
              offset: const Offset(0, 5),
              spreadRadius: -5,
            ),
          ],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Capa 1: Imagen de fondo
            SkeletonNetworkImage(
              imageUrl: widget.imageUrl,
              width: double.infinity,
              height: double.infinity,
            ),
            
            // Capa 2: Gradiente de legibilidad estilo Enigma (más limpio)
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.5, 1.0],
                  colors: [
                    Colors.transparent,
                    Colors.black.withAlpha(50),
                    Colors.black.withAlpha(240), // Fondo casi sólido para texto
                  ],
                ),
              ),
            ),

            // Capa 3: Texto y Metadata
            if (widget.showTitle)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Etiqueta de Categoría Premium (Borde + Transparencia)
                    if (widget.item is NewsModel)
                      Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppConstants.primaryColor.withAlpha(40), // Fondo muy suave
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppConstants.primaryColor.withAlpha(100)),
                        ),
                        child: Text(
                          (widget.item as NewsModel).category.toUpperCase(),
                          style: const TextStyle(
                            color: AppConstants.textLight,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Montserrat',
                            letterSpacing: 1.2, // Tracking amplio
                          ),
                        ),
                      ),

                    Text(
                      widget.title, 
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700, 
                        fontFamily: 'Montserrat',
                        fontSize: 15,
                        height: 1.25,
                      ),
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
