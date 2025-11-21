import 'package:flutter/material.dart';
import 'package:la_nacion/config/constants.dart';
import 'package:la_nacion/dashboard/controllers/companies_controller.dart';
import 'package:la_nacion/dashboard/models/radio_model.dart';
import 'package:la_nacion/dashboard/models/wp_api_model.dart';
import 'package:la_nacion/utils/responsive_values.dart';
import 'package:provider/provider.dart';

import 'content_card.dart';
import 'package:la_nacion/dashboard/models/news_model.dart';
import 'package:la_nacion/dashboard/controllers/news_controller.dart';
import 'package:la_nacion/dashboard/controllers/radio_controller.dart';
import 'package:la_nacion/dashboard/controllers/navigation_controller.dart';
import 'package:la_nacion/widgets/animations/fade_in_up.dart'; // Importar animación

class HomeNewsSection extends StatelessWidget {
  final String title;
  final int itemCount;

  const HomeNewsSection({super.key, required this.title, this.itemCount = 6});

  @override
  Widget build(BuildContext context) {
    final nav = Provider.of<NavigationController>(context, listen: false);

    return Padding(
      padding: responsiveValue<EdgeInsets>(
        context,
        mobile: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        tablet: const EdgeInsets.symmetric(vertical: 48, horizontal: 48),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header minimalista
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title.toUpperCase(),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900, // Ultra bold
                  letterSpacing: 1.2,
                  color: Colors.white.withAlpha(230),
                  fontSize: 14,
                ),
              ),
              GestureDetector(
                onTap: () => nav.changeTab(2),
                child: Text(
                  'Ver más',
                        style: TextStyle(
                    color: AppConstants.primaryColor, // Azul Nación
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // BENTO GRID LAYOUT (Asimétrico)
          SizedBox(
            height: responsiveValue(context, mobile: 380.0, tablet: 450.0),
            child: Consumer<NewsController>(
              builder: (context, newsController, child) {
                if (newsController.isLoading && newsController.newsList.isEmpty) {
                  return Center(child: CircularProgressIndicator(color: AppConstants.primaryColor));
                }

                final newsList = newsController.newsList
                    .where((n) => n.imageUrl != null && n.imageUrl!.isNotEmpty)
                    .take(3) // Tomamos solo las 3 principales para el grid
                    .toList();

                if (newsList.isEmpty) {
                  // Mostrar estado vacío elegante en lugar de nada
                  return Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(10),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withAlpha(20)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.newspaper_rounded, size: 48, color: Colors.white.withAlpha(100)),
                        const SizedBox(height: 16),
                        Text(
                          'Cargando noticias...',
                          style: TextStyle(
                            color: Colors.white.withAlpha(150),
                            fontFamily: 'Montserrat',
                            fontSize: 14,
                          ),
                        ),
                        // Botón de reintentar oculto pero útil si falla
                         TextButton(
                          onPressed: () => newsController.loadNews(),
                          child: const Text('Actualizar', style: TextStyle(color: AppConstants.primaryColor)),
                        )
                      ],
                    ),
                  );
                }

                // Si hay menos de 3, fallback a lista simple
                if (newsList.length < 3) {
                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                    itemCount: newsList.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (ctx, idx) => ContentCard(
                      title: newsList[idx].title,
                      imageUrl: newsList[idx].imageUrl!,
                      routeName: 'news',
                      item: newsList[idx],
                    ),
                    );
                }

                // Layout Bento: 1 Grande a la izq, 2 Pequeñas a la der
                return Row(
                  children: [
                    // Noticia Principal (Hero)
                    Expanded(
                      flex: 5,
                      child: FadeInUp(
                        delay: const Duration(milliseconds: 100),
                        child: ContentCard(
                          title: newsList[0].title,
                          imageUrl: newsList[0].imageUrl!,
                          routeName: 'news',
                          item: newsList[0],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Columna Derecha (2 noticias apiladas)
                    Expanded(
                      flex: 4,
                      child: Column(
                        children: [
                          Expanded(
                            child: FadeInUp(
                              delay: const Duration(milliseconds: 200), // Retraso escalonado
                              child: ContentCard(
                                title: newsList[1].title,
                                imageUrl: newsList[1].imageUrl!,
                                routeName: 'news',
                                item: newsList[1],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: FadeInUp(
                              delay: const Duration(milliseconds: 300), // Retraso escalonado
                              child: ContentCard(
                                title: newsList[2].title,
                                imageUrl: newsList[2].imageUrl!,
                                routeName: 'news',
                                item: newsList[2],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ContentSection extends StatelessWidget {
  final String title;
  final String routeName;
  final bool showOnlyPriority;
  final String? categoryValue;
  final bool showSeeMoreButton;
  final List<dynamic>? items;
  final String? category;
  final int itemCount;

  const ContentSection({
    super.key,
    required this.title,
    required this.routeName,
    this.showOnlyPriority = false,
    this.categoryValue = '',
    this.showSeeMoreButton = true,
    this.items,
    this.category,
    this.itemCount = 6,
  });

  @override
  Widget build(BuildContext context) {
    final nav = Provider.of<NavigationController>(context, listen: false);

    List<Widget> cards = [];
    bool isLoading = false;

    if (routeName == 'news') {
      final newsController = Provider.of<NewsController>(context);
      isLoading = newsController.isLoading;
      if (isLoading) {
        cards = List.generate(
          6,
          (_) => const ContentCard(title: '', imageUrl: '', routeName: 'news', item: null),
        );
      } else {
        List<NewsModel> newsToShow;
        if (category != null) {
          newsToShow = newsController.getNewsByCategory(category!);
        } else {
          newsToShow = newsController.newsList;
        }

        cards =
            newsToShow.take(itemCount).map((news) {
              return ContentCard(
                title: news.title,
                imageUrl: news.imageUrl ?? '',
                routeName: routeName,
                item: news,
              );
            }).toList();
      }
    } else if (routeName == 'radio') {
      final radioController = Provider.of<RadioController>(context);
      isLoading = radioController.isLoading;
      if (isLoading) {
        cards = List.generate(
          itemCount,
          (_) => const ContentCard(title: '', imageUrl: '', routeName: 'radio', item: null),
        );
      } else {
        final visiblePodcasts =
            radioController.radioPodcasts.length > 1
                ? radioController.radioPodcasts.skip(1).take(6).toList()
                : <RadioModel>[];

        cards =
            visiblePodcasts.map((podcast) {
              return ContentCard(
                title: podcast.title,
                imageUrl: podcast.artworkUrl,
                routeName: routeName,
                item: podcast,
                showTitle: true,
              );
            }).toList();
      }
    } else if (routeName == 'companies') {
      final companiesController = Provider.of<CompaniesController>(context);
      isLoading = companiesController.isLoading;
      List<WpItem> companies = [];
      if (isLoading) {
        cards = List.generate(
          6,
          (_) => const ContentCard(title: '', imageUrl: '', routeName: 'companies', item: null),
        );
      } else {
        if (items != null) {
          companies = items!.cast<WpItem>();
        } else if (showOnlyPriority) {
          companies = companiesController.priorityCompanies;
        } else if (categoryValue != null && categoryValue!.isNotEmpty) {
          companies = companiesController.itemsForEspecifica(categoryValue!);
        } else {
          companies = companiesController.items;
        }
        cards =
            companies.map((company) {
              return ContentCard(
                title: '',
                imageUrl: company.acf['company_image']?['url'] ?? '',
                routeName: routeName,
                item: company,
              );
            }).toList();
      }
    }

    return Padding(
      padding: responsiveValue<EdgeInsets>(
        context,
        mobile: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        tablet: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              if (showSeeMoreButton &&
                  routeName == 'news' &&
                  categoryValue != null &&
                  categoryValue!.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    final newsController = Provider.of<NewsController>(context, listen: false);
                    newsController.setActiveCategory(categoryValue ?? '');

                    nav.changeTab(2);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppConstants.primaryColor,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'VER MAS',
                          style: TextStyle(
                            color: AppConstants.textLight,
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.arrow_forward_ios, color: AppConstants.textLight, size: 13),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          if (cards.isEmpty)
            Container(
              height: 150,
              width: double.infinity,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'No hay contenido disponible',
                style: TextStyle(color: Colors.white.withAlpha(100)),
              ),
            )
          else
            SizedBox(
              height: 200,
              child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: cards.length,
              separatorBuilder: (_, __) => SizedBox(width: 12),
              itemBuilder: (context, index) {
                return cards[index];
              },
            ),
          ),
        ],
      ),
    );
  }
}