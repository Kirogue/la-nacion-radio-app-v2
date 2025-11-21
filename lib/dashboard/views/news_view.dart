import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // Para kIsWeb
import 'package:la_nacion/utils/responsive_values.dart';
import 'package:la_nacion/widgets/custom_wrapper.dart';
import 'package:la_nacion/widgets/loading_icon.dart';
import 'package:la_nacion/widgets/skeleton_network_image.dart';
import 'package:la_nacion/widgets/skeleton_pulse.dart';
import 'package:la_nacion/widgets/universal_search.dart';
import 'package:provider/provider.dart';
import '../controllers/news_controller.dart';
import '../models/news_model.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../config/constants.dart';
import '../../config/text_styles.dart';

import 'package:la_nacion/widgets/content_section.dart';
import 'package:la_nacion/widgets/ad_banner.dart';
import 'package:la_nacion/dashboard/controllers/ads_controller.dart';

class NewsView extends StatefulWidget {
  const NewsView({super.key});
  @override
  State<NewsView> createState() => _NewsViewState();
}

class _NewsViewState extends State<NewsView> with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();
  String _selectedCategory = 'Todas';
  NewsController? _newsController;
  String _searchQuery = '';
  List<NewsModel> _searchResults = [];

  int _batchesToShow = 1;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.microtask(() {
        if (!mounted) return;
        _newsController = Provider.of<NewsController>(context, listen: false);
        _newsController!.addListener(_onNewsControllerChanged); 
        _newsController!.loadNews();
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _newsController?.removeListener(_onNewsControllerChanged);
    super.dispose();
  }

  void _onNewsControllerChanged() {
    if (mounted && _selectedCategory != _newsController!.currentActiveCategory) {
      setState(() {
        _selectedCategory = _newsController!.currentActiveCategory ?? 'Todas';
      });
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      final newsController = Provider.of<NewsController>(context, listen: false);
      newsController.loadMoreCategoryNews(_selectedCategory);
    }
  }

  void _onCategoryChanged(String category) {
    setState(() {
      _selectedCategory = category;
      _searchQuery = '';
      _searchResults = [];
    });
    final newsController = Provider.of<NewsController>(context, listen: false);

    newsController.setActiveCategory(category);

    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Consumer<NewsController>(
      builder: (context, newsController, _) {
        final top = MediaQuery.of(context).padding.top;

        if (newsController.isLoading) {
          return Center(child: LoadingIcon(padding: EdgeInsets.only(top: top), size: 40));
        }

        if (newsController.errorMessage != null) {
          return Center(
            child: Padding(
              padding: EdgeInsets.only(top: top),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: AppConstants.errorColor),
                  const SizedBox(height: 16),
                  Text(
                    'Error al cargar las noticias',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(newsController.errorMessage!, style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => newsController.loadNews(),
                    label: const Text('Reintentar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.errorColor,
                      foregroundColor: AppConstants.textLight,
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 28),
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final newsToShow = newsController.getNewsByCategory(_selectedCategory);

        if (newsToShow.isEmpty && _selectedCategory != 'Todas') {
          return Center(
            child: Padding(
              padding: EdgeInsets.only(top: top),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.article_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No se encontraron noticias',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No hay noticias en esta categoría',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          );
        }

        return SingleChildScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          child: ContentWrapper(
            child: Column(
              spacing: 12,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildCategoryFilter(newsController),
                UniversalSearchWidget(
                  searchType: SearchType.news,
                  hint: 'Buscar noticias...',
                  onItemTap: (results, query) {
                    setState(() {
                      _searchQuery = query;
                      _searchResults = results ?? [];
                    });
                  },
                ),

                if (_searchQuery.isNotEmpty)
                  ..._buildNewsStructure(_searchResults)
                else if (_selectedCategory == 'Todas')
                  ...newsController.getActiveCategories().map(
                    (category) => ContentSection(
                      title: 'LO ÚLTIMO EN ${category.toUpperCase()}',
                      routeName: 'news',
                      category: category,
                      itemCount: 6,
                      showSeeMoreButton: true,
                      categoryValue: category,
                    ),
                  )
                else
                  ContentSection(
                    title: 'LO ÚLTIMO EN ${_selectedCategory.toUpperCase()}',
                    routeName: 'news',
                    category: _selectedCategory,
                    itemCount: 6,
                    showSeeMoreButton: false,
                  ),

                if (_searchQuery.isNotEmpty && _searchResults.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: Column(
                      children: [
                        Icon(Icons.search_off, size: 60, color: Colors.grey[400]),
                        const SizedBox(height: 12),
                        Text(
                          'No se encontraron noticias para “$_searchQuery”',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  )
                else if (_searchQuery.isEmpty)
                  ..._buildNewsStructure(newsToShow),

                if (newsController.isLoadingMore) Center(child: LoadingIcon(size: 40)),

                SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildNewsStructure(List<NewsModel> newsToShow) {
    List<Widget> widgets = [];
    final adsController = Provider.of<AdsController>(context);

    final isSearch = _searchQuery.isNotEmpty;
    final newsForStructure = isSearch ? newsToShow : newsToShow.skip(6).toList();

    int articlesSinceLastAd = 0;
    int adsShown = 0;
    int maxAdsAllowed = _batchesToShow * 3;

    final articlesPerAd = responsiveValue<int>(context, mobile: 6, tablet: 4);
    final columns = responsiveValue<int>(context, mobile: 2, tablet: 4);

    List<NewsModel> batch = [];
    for (var news in newsForStructure) {
      batch.add(news);
      articlesSinceLastAd++;

      if (articlesSinceLastAd >= articlesPerAd) {
        for (int i = 0; i < batch.length; i += columns) {
          final rowItems = batch.skip(i).take(columns).toList();
          widgets.add(_buildArticlesRow(rowItems));
        }

        batch = [];
        articlesSinceLastAd = 0;

        if (adsShown < maxAdsAllowed) {
          final ads = adsController.getUniqueAds(3);
          widgets.add(
            Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: AdBanner(ads: ads)),
          );
          adsShown++;
        } else {
          widgets.add(
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Center(
                child: ElevatedButton(
                  onPressed: () => setState(() => _batchesToShow++),
                  child: const Text(
                    'CARGAR MÁS',
                    style: TextStyle(
                      color: AppConstants.textLight,
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
          );
          break;
        }
      }
    }

    if (batch.isNotEmpty) {
      for (int i = 0; i < batch.length; i += columns) {
        final rowItems = batch.skip(i).take(columns).toList();
        widgets.add(_buildArticlesRow(rowItems));
      }
    }

    return widgets;
  }

  Widget _buildArticlesRow(List<NewsModel> articles) {
    final newsController = Provider.of<NewsController>(context, listen: false);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children:
            articles.map((news) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: _buildNewsCard(news, newsController),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildCategoryFilter(NewsController newsController) {
    List<String> categories = newsController.getCategories();
    final horizontalPadding = responsiveValue<double>(context, mobile: 16, tablet: 48);

    return Container(
      decoration: BoxDecoration(color: AppConstants.surfaceColor.withAlpha((0.75 * 255).toInt())),
      child: SizedBox(
        height: responsiveValue(context, mobile: 55, tablet: 75),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final totalChipsWidth = categories.length * 100;
            final useSpaceEvenly = totalChipsWidth < constraints.maxWidth;

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Row(
                mainAxisAlignment:
                    useSpaceEvenly ? MainAxisAlignment.spaceEvenly : MainAxisAlignment.start,
                children:
                    categories.map((category) {
                      final isSelected = category == _selectedCategory;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ChoiceChip(
                          label: Text(
                            category,
                            style: AppTextStyles.categoryLabel.copyWith(
                              fontSize: 14,
                              color: Colors.white,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              shadows: [
                                Shadow(
                                  offset: Offset(0, 4),
                                  blurRadius: 4,
                                  color: Colors.black.withAlpha((0.4 * 255).round()),
                                ),
                              ],
                            ),
                          ),
                          selected: isSelected,
                          onSelected: (_) => _onCategoryChanged(category),
                          selectedColor: AppConstants.primaryColor,
                          backgroundColor: Colors.transparent,
                          side: BorderSide.none,
                          showCheckmark: false,
                          elevation: isSelected ? 4 : 0,
                          shadowColor: Colors.black.withAlpha((0.4 * 255).round()),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        ),
                      );
                    }).toList(),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildNewsCard(NewsModel news, NewsController newsController) {
    return SizedBox(
      height: 260,
      child: Card(
        elevation: Theme.of(context).cardTheme.elevation,
        shape: Theme.of(context).cardTheme.shape,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _openArticle(news),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child:
                    news.hasImage
                        ? SkeletonNetworkImage(
                          imageUrl: news.imageUrl,
                          width: double.infinity,
                          height: double.infinity,
                        )
                        : SkeletonPulse(width: double.infinity, height: 180),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 6),
                      Text(
                        news.title.toUpperCase(),
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(fontSize: 16, height: 1),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 4),

                      Text(
                        news.shortDescription,
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(fontSize: 10, height: 1.2),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openArticle(NewsModel news) async {
    final ctrl = Provider.of<NewsController>(context, listen: false);
    ctrl.selectNews(news);

    ctrl.setArticleWebViewOpen(true);
  }
}

class ArticleWebView extends StatefulWidget {
  final NewsModel news;

  const ArticleWebView({super.key, required this.news});

  @override
  State<ArticleWebView> createState() => _ArticleWebViewState();
}

class _ArticleWebViewState extends State<ArticleWebView> {
  late final WebViewController controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.news.articleUrl));

    if (!kIsWeb) {
      controller.setNavigationDelegate(
            NavigationDelegate(
              onPageStarted: (String url) {
            if (mounted) setState(() => isLoading = true);
              },
              onPageFinished: (String url) {
            if (mounted) setState(() => isLoading = false);
          },
        ),
      );
    } else {
                  isLoading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            padding: EdgeInsets.only(top: topPadding),
            child: WebViewWidget(controller: controller),
          ),
          if (isLoading)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 16,
                children: [
                  LoadingIcon(size: 40, color: AppConstants.surfaceColor),
                  Text(
                    'Cargando artículo...',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: AppConstants.surfaceColor),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}