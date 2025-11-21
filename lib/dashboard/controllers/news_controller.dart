import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import 'dart:async';
import '../models/news_model.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class NewsController extends ChangeNotifier {
  List<NewsModel> _newsList = [];
  List<NewsModel> _allNews = [];
  final List<NewsModel> _mainNews = [];

  static const String _newsCacheKey = 'cached_news_list';
  static const String _imageCacheKey = 'cached_image_urls';

  final Map<String, int> _categoryPages = {};
  final Map<String, bool> _categoryHasMore = {};

  final Map<String, String> _imageUrlCache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  final Set<String> _loadingImages = {};
  static const Duration _cacheExpiry = Duration(hours: 24);

  String _currentActiveCategory = 'Todas';
  String get currentActiveCategory => _currentActiveCategory;

  List<NewsModel> get mainNews => _mainNews;

  bool _isLoading = false;
  bool _isLoadingMore = false;
  NewsModel? _selectedNews;
  String? _errorMessage;
  int _currentPage = 0;
  final int _itemsPerPage = 8;
  bool _hasMoreNews = true;

  bool _isArticleWebViewOpen = false;

  bool get isArticleWebViewOpen => _isArticleWebViewOpen;

  void setArticleWebViewOpen(bool isOpen) {
    _isArticleWebViewOpen = isOpen;
    notifyListeners();
  }

  // ... (mantengo las urls y listas estáticas igual) ...
  static const List<String> rssUrls = [
    'https://lanacionweb.com/feed/',
    'https://lanacionweb.com/deportes/feed/',
    'https://lanacionweb.com/sucesos/feed/',
    'https://lanacionweb.com/obituarios/feed',
    'https://lanacionweb.com/legales/feed',
    'https://lanacionweb.com/opinion/feed/',
    'https://lanacionweb.com/internacional/feed',
    'https://lanacionweb.com/nacional/feed',
    'https://lanacionweb.com/frontera/feed/',
    'https://lanacionweb.com/regional/feed/',
    'https://lanacionweb.com/politica/feed/',
  ];

  static const List<String> _categoryOrder = [
    'Sucesos',
    'Política',
    'Frontera',
    'Regional',
    'Deportes',
    'Opinión',
    'Nacional',
    'Internacional',
    'Legales',
    'Obituarios',
  ];

  List<NewsModel> get newsList => _newsList;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMoreNews => _hasMoreNews;
  NewsModel? get selectedNews => _selectedNews;
  String? get errorMessage => _errorMessage;

  Future<void> loadNews() async {
    _setLoading(true);
    _clearError();
    
    // 1. Cargar caché local primero para mostrar contenido inmediato
    await _loadFromCache();
    if (_allNews.isNotEmpty) {
      _isLoading = false; // Ya tenemos datos, dejamos de girar (o seguimos en background)
      notifyListeners();
    }

    // Limpieza
    clearImageCache();
    // No borramos _allNews todavía para no parpadear
    _categoryPages.clear();
    _categoryHasMore.clear();
    _cleanExpiredCache();

    try {
      List<Future<http.Response?>> futures =
          rssUrls.map((url) async {
            try {
              return await http
                  .get(
                    Uri.parse(url),
                    headers: {
                      'User-Agent': 'Mozilla/5.0 (iPhone; CPU iPhone OS 14_0 like Mac OS X)',
                      'Accept': 'application/rss+xml, application/xml, text/xml',
                    },
                  )
                  .timeout(const Duration(seconds: 15));
            } catch (e) {
              return null;
            }
          }).toList();

      List<http.Response?> responses = await Future.wait(futures);
      List<NewsModel> fetchedNews = [];
      List<NewsModel> newMainNews = [];

      for (int i = 0; i < responses.length; i++) {
        final response = responses[i];
        if (response != null && response.statusCode == 200) {
          try {
            final xmlDocument = XmlDocument.parse(response.body);
            List<NewsModel> newsFromFeed = await _parseRssToNewsQuick(xmlDocument);

            for (var news in newsFromFeed) {
              _categoryPages[news.category] = 1;
              _categoryHasMore[news.category] = true;
            }

            if (rssUrls[i] == 'https://lanacionweb.com/feed/') {
              newMainNews.addAll(newsFromFeed);
            }

            fetchedNews.addAll(newsFromFeed);
          } catch (e) {}
        }
      }

      Set<String> seenTitles = <String>{};
      Set<String> seenUrls = <String>{};
      List<NewsModel> uniqueNews = [];

      for (final news in fetchedNews) {
        String normalizedTitle = news.title.toLowerCase().trim();
        String cleanUrl = news.articleUrl.split('?')[0].toLowerCase();
        if (!seenTitles.contains(normalizedTitle) && !seenUrls.contains(cleanUrl)) {
          seenTitles.add(normalizedTitle);
          seenUrls.add(cleanUrl);
          uniqueNews.add(news);
        }
      }

      uniqueNews.sort((a, b) => b.publishDate.compareTo(a.publishDate));
      newMainNews.sort((a, b) => b.publishDate.compareTo(a.publishDate));

      // Actualizar listas principales
      _mainNews.clear();
      _mainNews.addAll(newMainNews);

      _allNews = uniqueNews;
      _currentPage = 0;
      _hasMoreNews = _allNews.length > _itemsPerPage;
      _newsList = _getPaginatedNews();
      
      // Guardar en caché los nuevos datos
      _saveToCache();
      
      // Si después de todo no tenemos noticias (API vacía o filtrada), usar fallback para demo
      if (_allNews.isEmpty) {
        debugPrint('API devolvió lista vacía. Usando Fallback Premium.');
        _allNews = _getFallbackNews();
        _mainNews.clear();
        _mainNews.addAll(_allNews); // Fallback también para main
        _newsList = _getPaginatedNews();
      }
      
    } catch (e) {
      _errorMessage = 'Error al cargar las noticias: $e';
      debugPrint(_errorMessage); // Log para debug
      
      // Si falló internet y no teníamos caché, mostrar fallback
      if (_newsList.isEmpty) {
        _allNews = _getFallbackNews();
        _mainNews.clear();
        _mainNews.addAll(_allNews);
        _newsList = _getPaginatedNews();
      }
    } finally {
      _setLoading(false);

      if (_currentActiveCategory == 'Todas') {
        unawaited(_processImagesForAllCategoriesSequential());
      } else {
        _processImagesByPriority();
      }

      final currentCategoryNews = getNewsByCategory(_currentActiveCategory);
      final withImage = currentCategoryNews.where((news) => news.hasImage).length;
    }
  }

  Future<void> _loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString(_newsCacheKey);
      
      if (jsonString != null && jsonString.isNotEmpty) {
        final List<dynamic> jsonList = json.decode(jsonString);
        final cachedNews = jsonList.map((e) => NewsModel.fromJson(e)).toList();
        
        if (cachedNews.isNotEmpty) {
          _allNews = cachedNews;
          // Reconstruir _mainNews (asumimos que las primeras son las principales o por fecha)
          _mainNews.clear();
          _mainNews.addAll(cachedNews.take(20).toList()); // Aproximación
          
          _currentPage = 0;
          _hasMoreNews = _allNews.length > _itemsPerPage;
          _newsList = _getPaginatedNews();
          
          // Cargar caché de imágenes también
          final String? imageCacheJson = prefs.getString(_imageCacheKey);
          if (imageCacheJson != null) {
             final Map<String, dynamic> decoded = json.decode(imageCacheJson);
             decoded.forEach((key, value) {
               if (value is String) _imageUrlCache[key] = value;
             });
          }
          
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error loading cache: $e');
    }
  }

  Future<void> _saveToCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Guardar solo las primeras 50-100 noticias para no saturar
      final newsToSave = _allNews.take(100).map((e) => e.toJson()).toList();
      await prefs.setString(_newsCacheKey, json.encode(newsToSave));
      
      // Guardar caché de imágenes también
      await prefs.setString(_imageCacheKey, json.encode(_imageUrlCache));
    } catch (e) {
      debugPrint('Error saving cache: $e');
    }
  }

  void setActiveCategory(String category) {
    if (_currentActiveCategory != category) {
      _currentActiveCategory = category;
      notifyListeners();

      if (category == 'Todas') {
        _processImagesForAllCategoriesSequential();
      } else {
        final categoryNews = getNewsByCategory(category);
        final withImage = categoryNews.where((news) => news.hasImage).length;
        _processImagesByPriority();
      }
    }
  }

  Future<void> _processImagesForAllCategoriesSequential() async {
    final activeCategories = getActiveCategories();

    for (String category in activeCategories) {
      final categoryNews = getNewsByCategory(category);
      final topSixNews = categoryNews.take(6).toList();

      final urlsToLoad =
          topSixNews
              .where(
                (news) =>
                    !news.hasImage &&
                    news.articleUrl.isNotEmpty &&
                    !_isImageCached(news.articleUrl) &&
                    !_loadingImages.contains(news.articleUrl),
              )
              .map((news) => news.articleUrl)
              .toList();

      if (urlsToLoad.isNotEmpty) {
        final futures = urlsToLoad.map((url) => _loadSingleImageParallel(url));
        await Future.wait(futures);
      }

      await Future.delayed(const Duration(milliseconds: 200));
    }
  }

  Future<void> _processImagesByPriority() async {
    final mainNewsWithoutImage =
        _mainNews
            .where(
              (news) =>
                  !news.hasImage &&
                  news.articleUrl.isNotEmpty &&
                  !_isImageCached(news.articleUrl) &&
                  !_loadingImages.contains(news.articleUrl),
            )
            .toList();

    final categoryNews =
        getNewsByCategory(_currentActiveCategory)
            .where(
              (news) =>
                  !news.hasImage &&
                  news.articleUrl.isNotEmpty &&
                  !_isImageCached(news.articleUrl) &&
                  !_loadingImages.contains(news.articleUrl),
            )
            .toList();

    final Set<String> seenUrls = <String>{};
    final List<String> criticalUrls = [];
    final List<String> highPriorityUrls = [];

    for (String url in mainNewsWithoutImage.take(5).map((news) => news.articleUrl)) {
      if (!seenUrls.contains(url)) {
        seenUrls.add(url);
        criticalUrls.add(url);
      }
    }

    for (String url in categoryNews.take(8).map((news) => news.articleUrl)) {
      if (!seenUrls.contains(url)) {
        seenUrls.add(url);
        highPriorityUrls.add(url);
      }
    }

    if (criticalUrls.isNotEmpty) {
      final criticalFutures = criticalUrls.map((url) => _loadSingleImageParallel(url));
      await Future.wait(criticalFutures);
    }

    if (highPriorityUrls.isNotEmpty) {
      await _processImagesInBatches(highPriorityUrls, batchSize: 3);
    }
  }

  Future<void> _loadSingleImageParallel(String articleUrl) async {
    try {
      _loadingImages.add(articleUrl);

      String? cachedUrl = _getCachedImageUrl(articleUrl);
      if (cachedUrl != null) {
        _updateNewsWithImage(articleUrl, cachedUrl);
        return;
      }

      NewsModel? findNewsByUrl(String articleUrl) {
        for (final n in _allNews) {
          if (n.articleUrl == articleUrl) return n;
        }
        return null;
      }

      final news = findNewsByUrl(articleUrl);
      String? postId = news?.postId;

      String? imageUrl = await _getOptimizedFeaturedImage(articleUrl, postId: postId);

      if (imageUrl != null && imageUrl.isNotEmpty) {
        _cacheImageUrl(articleUrl, imageUrl);
        _updateNewsWithImage(articleUrl, imageUrl);
      }
    } finally {
      _loadingImages.remove(articleUrl);
    }
  }

  Future<void> _processImagesInBatches(List<String> urls, {int batchSize = 3}) async {
    for (int i = 0; i < urls.length; i += batchSize) {
      final batch = urls.skip(i).take(batchSize).toList();

      final batchFutures = batch.map((url) => _loadSingleImageParallel(url));
      await Future.wait(batchFutures);

      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  Future<String?> _getFeaturedImageFromWpRest(String articleUrl, {String? postId}) async {
    try {
      final uri = Uri.parse(articleUrl);
      final origin = '${uri.scheme}://${uri.host}';

      Future<String?> tryFetch(String url) async {
        final resp = await http
            .get(
              Uri.parse(url),
              headers: {'User-Agent': 'Mozilla/5.0', 'Accept': 'application/json'},
            )
            .timeout(const Duration(seconds: 10));
        if (resp.statusCode == 200) {
          final data = json.decode(resp.body);
          if (data is Map<String, dynamic>) {
            final embedded = data['_embedded'] as Map<String, dynamic>?;
            if (embedded != null && embedded.containsKey('wp:featuredmedia')) {
              final fm = embedded['wp:featuredmedia'];
              if (fm is List && fm.isNotEmpty) {
                final media = fm[0] as Map<String, dynamic>;
                final src =
                    media['source_url'] as String? ??
                    media['media_details']?['sizes']?['full']?['source_url'] as String?;
                if (src != null && src.isNotEmpty) return src;
              }
            }
          } else if (data is List && data.isNotEmpty) {
            final post = data[0] as Map<String, dynamic>;
            final embedded = post['_embedded'] as Map<String, dynamic>?;
            if (embedded != null && embedded.containsKey('wp:featuredmedia')) {
              final fm = embedded['wp:featuredmedia'];
              if (fm is List && fm.isNotEmpty) {
                final media = fm[0] as Map<String, dynamic>;
                final src =
                    media['source_url'] as String? ??
                    media['media_details']?['sizes']?['full']?['source_url'] as String?;
                if (src != null && src.isNotEmpty) return src;
              }
            }
          }
        }
        return null;
      }

      // 1) Si tenemos postId -> posts/<id>?_embed
      if (postId != null && postId.isNotEmpty) {
        final urlById = '$origin/wp-json/wp/v2/posts/$postId?_embed';
        final maybe = await tryFetch(urlById);
        if (maybe != null) return maybe;
      }

      // 2) fallback: slug based
      final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
      if (segments.isEmpty) return null;
      String slug = segments.last.replaceAll(RegExp(r'\.html$'), '');
      final restUrl = '$origin/wp-json/wp/v2/posts?slug=$slug&_embed';
      return await tryFetch(restUrl);
    } catch (e) {
      return null;
    }
  }

  Future<String?> _getOptimizedFeaturedImage(String articleUrl, {String? postId}) async {
    try {
      final response = await http
          .get(
            Uri.parse(articleUrl),
            headers: {
              'User-Agent':
                  'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
              'Accept':
                  'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
              'Accept-Language': 'es-ES,es;q=0.9',
            },
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        String body = response.body;

        final metaPatterns = [
          RegExp(
            r"""<meta[^>]+(?:property|name)\s*=\s*["\'](?:og:image|twitter:image)["\'][^>]*content\s*=\s*["\']([^"\']+)["\']""",
            caseSensitive: false,
          ),
          RegExp(
            r"""<meta[^>]+content\s*=\s*["\']([^"\']+)["\'][^>]+(?:property|name)\s*=\s*["\'](?:og:image|twitter:image)["\']""",
            caseSensitive: false,
          ),
          RegExp(
            r"""<link[^>]+rel\s*=\s*["\']image_src["\'][^>]+href\s*=\s*["\']([^"\']+)["\']""",
            caseSensitive: false,
          ),
        ];

        for (final p in metaPatterns) {
          final m = p.firstMatch(body);
          if (m != null) {
            final imageUrl = _cleanImageUrl(m.group(1)!);
            if (_isValidImageUrl(imageUrl)) return imageUrl;
          }
        }

        List<RegExp> imagePatterns = [
          RegExp(
            r"""<img[^>]+class\s*=\s*["\'][^"']*size-large[^"\']*["\'][^>]+(?:data-src|src)\s*=\s*["\']([^"\']+)["\']""",
            caseSensitive: false,
          ),
          RegExp(
            r"""<figure[^>]*>.*?<img[^>]+(?:data-src|src)\s*=\s*["\']([^"']+)["\']""",
            caseSensitive: false,
            dotAll: true,
          ),
          RegExp(r"""<img[^>]+(?:data-src|src)\s*=\s*["\']([^"']+)["\']""", caseSensitive: false),
        ];

        for (RegExp pattern in imagePatterns) {
          final match = pattern.firstMatch(body);
          if (match != null) {
            String imageUrl = _cleanImageUrl(match.group(1)!);
            if (_isValidImageUrl(imageUrl)) {
              return imageUrl;
            }
          }
        }

        // 3) Si no encontramos nada útil en el HTML, intento la REST API de WordPress (featured image)
        final restImage = await _getFeaturedImageFromWpRest(articleUrl, postId: postId);
        if (restImage != null && restImage.isNotEmpty && _isValidImageUrl(restImage)) {
          return restImage;
        }

        return null;
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  String _cleanImageUrl(String rawUrl) {
    return rawUrl
        .replaceAll('&#038;', '&')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .trim();
  }

  bool _isValidImageUrl(String url) {
    if (url.isEmpty || url.startsWith('data:') || url.contains('logo') || url.contains('favicon')) {
      return false;
    }
    try {
      Uri.parse(url);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _urlExists(String url) async {
    try {
      final response = await http.head(Uri.parse(url));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<void> _updateNewsWithImage(String articleUrl, String imageUrl) async {
    if (await _urlExists(imageUrl)) {
      for (int i = 0; i < _allNews.length; i++) {
        if (_allNews[i].articleUrl == articleUrl && !_allNews[i].hasImage) {
          _allNews[i] = _allNews[i].copyWith(imageUrl: imageUrl);
          _newsList = _getPaginatedNews();
          notifyListeners();
          break;
        }
      }
    }
  }

  bool _isImageCached(String articleUrl) {
    if (!_imageUrlCache.containsKey(articleUrl)) return false;

    final timestamp = _cacheTimestamps[articleUrl];
    if (timestamp == null) return false;

    return DateTime.now().difference(timestamp) < _cacheExpiry;
  }

  String? _getCachedImageUrl(String articleUrl) {
    if (_isImageCached(articleUrl)) {
      return _imageUrlCache[articleUrl];
    }
    return null;
  }

  void _cacheImageUrl(String articleUrl, String imageUrl) {
    if (imageUrl.isNotEmpty && !imageUrl.startsWith('data:')) {
      _imageUrlCache[articleUrl] = imageUrl;
      _cacheTimestamps[articleUrl] = DateTime.now();
    }
  }

  void _cleanExpiredCache() {
    final now = DateTime.now();
    final expiredKeys =
        _cacheTimestamps.entries
            .where((entry) => now.difference(entry.value) >= _cacheExpiry)
            .map((entry) => entry.key)
            .toList();

    for (String key in expiredKeys) {
      _imageUrlCache.remove(key);
      _cacheTimestamps.remove(key);
    }
  }

  Future<void> loadMoreCategoryNews(String category) async {
    if (_isLoadingMore || !(_categoryHasMore[category] ?? false)) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      int nextPage = (_categoryPages[category] ?? 1) + 1;
      String feedUrl = _getCategoryFeedUrl(category, nextPage);

      final response = await http
          .get(
            Uri.parse(feedUrl),
            headers: {
              'User-Agent': 'Mozilla/5.0 (iPhone; CPU iPhone OS 14_0 like Mac OS X)',
              'Accept': 'application/rss+xml, application/xml, text/xml',
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final xmlDocument = XmlDocument.parse(response.body);
        List<NewsModel> newNews = await _parseRssToNewsQuick(xmlDocument);

        if (newNews.isNotEmpty) {
          _addUniqueNews(newNews);
          _categoryPages[category] = nextPage;

          final newUrls =
              newNews
                  .where(
                    (news) =>
                        !news.hasImage &&
                        news.articleUrl.isNotEmpty &&
                        !_isImageCached(news.articleUrl),
                  )
                  .map((news) => news.articleUrl)
                  .toList();

          if (newUrls.isNotEmpty) {
            unawaited(_processImagesInBatches(newUrls, batchSize: 3));
          }
        } else {
          _categoryHasMore[category] = false;
        }
      }
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  String _getCategoryFeedUrl(String category, int page) {
    Map<String, String> categoryUrls = {
      'Política': 'https://lanacionweb.com/politica/feed/',
      'Deportes': 'https://lanacionweb.com/deportes/feed/',
      'Sucesos': 'https://lanacionweb.com/sucesos/feed/',
      'Obituarios': 'https://lanacionweb.com/obituarios/feed/',
      'Legales': 'https://lanacionweb.com/legales/feed/',
      'Opinión': 'https://lanacionweb.com/opinion/feed/',
      'Internacional': 'https://lanacionweb.com/internacional/feed/',
      'Nacional': 'https://lanacionweb.com/nacional/feed/',
      'Frontera': 'https://lanacionweb.com/frontera/feed/',
      'Regional': 'https://lanacionweb.com/regional/feed/',
    };

    String baseUrl = categoryUrls[category] ?? 'https://lanacionweb.com/feed/';
    return '$baseUrl?paged=$page';
  }

  Future<List<NewsModel>> _parseRssToNewsQuick(XmlDocument xmlDocument) async {
    String? getEnclosureOrMediaImage(XmlElement item) {
      try {
        // enclosure (rss)
        final enclosures = item.findElements('enclosure');
        if (enclosures.isNotEmpty) {
          final url = enclosures.first.getAttribute('url');
          if (url != null && url.isNotEmpty) return url;
        }

        // media:content (namespaced) -> buscamos por local name 'content' y prefix 'media'
        for (final el in item.findElements('content')) {
          if (el.name.prefix == 'media') {
            final url = el.getAttribute('url') ?? el.innerText;
            if (url.isNotEmpty) return url;
          }
        }

        // fallback: buscar cualquier child con atributo url (ej: media:thumbnail url="...")
        for (final child in item.children.whereType<XmlElement>()) {
          final url = child.getAttribute('url');
          if (url != null &&
              url.isNotEmpty &&
              (child.name.local.toLowerCase().contains('media') ||
                  child.name.local.toLowerCase().contains('thumbnail'))) {
            return url;
          }
        }
      } catch (e) {
        // ignore
      }
      return null;
    }

    try {
      final items = xmlDocument.findAllElements('item');
      final List<NewsModel> news = [];

      for (final item in items) {
        try {
          final xmlData = <String, dynamic>{};

          String extractPostId(XmlElement item) {
            try {
              final wpId = _getElementText(item, 'wp:post_id');
              if (wpId.isNotEmpty) return wpId;

              final link = _getElementText(item, 'link');
              final q = RegExp(r'[?&]p=(\d+)').firstMatch(link);
              if (q != null) return q.group(1)!;

              final guid = _getElementText(item, 'guid');
              final q2 = RegExp(r'[?&]p=(\d+)').firstMatch(guid);
              if (q2 != null) return q2.group(1)!;
            } catch (e) {}
            return '';
          }

          xmlData['post_id'] = extractPostId(item);

          xmlData['title'] = _getElementText(item, 'title');
          xmlData['link'] = _getElementText(item, 'link');
          xmlData['description'] = _getElementText(item, 'content:encoded');
          xmlData['pubDate'] = _getElementText(item, 'pubDate');
          xmlData['category'] = _getElementText(item, 'category');
          xmlData['guid'] = _getElementText(item, 'guid');
          xmlData['creator'] = _getElementText(item, 'dc:creator');
          xmlData['author'] = _getElementText(item, 'author');
          xmlData['enclosure'] = getEnclosureOrMediaImage(item);

          final newsItem = _createNewsModelQuick(xmlData);
          news.add(newsItem);
        } catch (e) {
          continue;
        }
      }

      return news;
    } catch (e) {
      return [];
    }
  }

  NewsModel _createNewsModelQuick(Map<String, dynamic> xmlData) {
    // Cambia el orden de prioridad: primero enclosure, luego imagen del contenido
    String? enclosureImage = xmlData['enclosure'] as String?;
    String? imageFromContent = NewsModel.extractImageFromContent(xmlData['description'] ?? '');
    final initialImage = enclosureImage ?? imageFromContent;

    return NewsModel(
      id: xmlData['guid'] ?? '',
      title: NewsModel.cleanHtml(xmlData['title'] ?? 'Sin título'),
      description: NewsModel.cleanHtml(xmlData['description'] ?? 'Sin descripción'),
      imageUrl: initialImage,
      category: xmlData['category'] ?? 'General',
      publishDate: NewsModel.parseDate(xmlData['pubDate']),
      articleUrl: xmlData['link'] ?? '',
      author: xmlData['creator'] ?? xmlData['author'],
      postId: xmlData['post_id'],
    );
  }

  List<NewsModel> _getPaginatedNews() {
    final endIndex = (_currentPage + 1) * _itemsPerPage;
    if (endIndex >= _allNews.length) {
      _hasMoreNews = false;
      return _allNews;
    }
    return _allNews.take(endIndex).toList();
  }

  Future<void> loadMoreNews() async {
    if (_isLoadingMore || !_hasMoreNews) return;

    _isLoadingMore = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    _currentPage++;
    _newsList = _getPaginatedNews();
    _isLoadingMore = false;
    notifyListeners();
  }

  String _getElementText(XmlElement parent, String tagName) {
    try {
      return parent.findElements(tagName).first.innerText.trim();
    } catch (e) {
      return '';
    }
  }

  List<NewsModel> _getFallbackNews() {
    // DATOS DE PRUEBA VISUAL (FALLBACK PREMIUM)
    // Si no carga la API, mostramos esto para verificar el diseño.
    return [
      NewsModel(
        id: 'mock_1',
        title: 'La Nación Radio estrena nueva interfaz digital con tecnología de punta',
        description: 'La emisora líder del Táchira se renueva con una experiencia de usuario moderna, rápida y elegante, diseñada para el futuro de la información.',
        category: 'Tecnología',
        publishDate: DateTime.now(),
        articleUrl: 'https://lanacionweb.com',
        imageUrl: 'https://images.unsplash.com/photo-1504711434969-e33886168f5c?q=80&w=1000&auto=format&fit=crop', // Imagen genérica de noticias
        author: 'Redacción Digital',
      ),
      NewsModel(
        id: 'mock_2',
        title: 'Deportivo Táchira se prepara para la gran final de la temporada',
        description: 'El aurinegro ajusta los últimos detalles tácticos antes del encuentro decisivo en el Templo Sagrado del fútbol nacional.',
        category: 'Deportes',
        publishDate: DateTime.now().subtract(const Duration(hours: 2)),
        articleUrl: 'https://lanacionweb.com',
        imageUrl: 'https://images.unsplash.com/photo-1579952363873-27f3bade9f55?q=80&w=1000&auto=format&fit=crop', // Fútbol
        author: 'Deportes LN',
      ),
      NewsModel(
        id: 'mock_3',
        title: 'Nuevas medidas económicas impactan el comercio fronterizo',
        description: 'Autoridades de ambos países acuerdan flexibilizar el paso de mercancías, impulsando el intercambio comercial en la región.',
        category: 'Frontera',
        publishDate: DateTime.now().subtract(const Duration(hours: 5)),
        articleUrl: 'https://lanacionweb.com',
        imageUrl: 'https://images.unsplash.com/photo-1559526324-4b87b5e36e44?q=80&w=1000&auto=format&fit=crop', // Comercio/Frontera
        author: 'Economía',
      ),
       NewsModel(
        id: 'mock_4',
        title: 'Festival cultural binacional reúne a miles en San Antonio',
        description: 'Artistas de Colombia y Venezuela celebran la hermandad a través de la música y la gastronomía típica.',
        category: 'Cultura',
        publishDate: DateTime.now().subtract(const Duration(hours: 8)),
        articleUrl: 'https://lanacionweb.com',
        imageUrl: 'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?q=80&w=1000&auto=format&fit=crop', // Cultura/Evento
        author: 'Cultura',
      ),
    ];
  }

  void selectNews(NewsModel news) {
    _selectedNews = news;
    notifyListeners();
  }

  List<NewsModel> searchNews(String query) {
    if (query.isEmpty) return _newsList;

    final searchQuery = query.toLowerCase();
    return _allNews.where((news) {
      return news.title.toLowerCase().contains(searchQuery) ||
          news.description.toLowerCase().contains(searchQuery) ||
          news.category.toLowerCase().contains(searchQuery);
    }).toList();
  }

  List<NewsModel> searchByTitle(String query) {
    if (query.trim().isEmpty) return [];
    final lower = query.toLowerCase();
    return _allNews.where((n) => n.title.toLowerCase().contains(lower)).toList();
  }

  List<NewsModel> getNewsByCategory(String category) {
    if (category == 'Todas') {
      return [];
    }
    return _allNews.where((news) => news.category.toLowerCase() == category.toLowerCase()).toList();
  }

  List<String> getActiveCategories() {
    return getCategories().where((cat) => cat != 'Todas').toList();
  }

  List<String> getCategories() {
    final availableCategories = _allNews.map((news) => news.category).toSet();

    List<String> orderedCategories = ['Todas'];

    for (String category in _categoryOrder) {
      if (availableCategories.contains(category)) {
        orderedCategories.add(category);
      }
    }

    for (String category in availableCategories) {
      if (!orderedCategories.contains(category)) {
        orderedCategories.add(category);
      }
    }

    return orderedCategories;
  }

  Future<void> refreshNews() async {
    _currentPage = 0;
    _hasMoreNews = true;
    await loadNews();
  }

  void cancelImageLoading() {
    _loadingImages.clear();
  }

  void clearImageCache() {
    _imageUrlCache.clear();
    _cacheTimestamps.clear();
  }

  Map<String, dynamic> getCacheStats() {
    return {
      'cached_images': _imageUrlCache.length,
      'loading_images': _loadingImages.length,
      'expired_entries':
          _cacheTimestamps.entries
              .where((entry) => DateTime.now().difference(entry.value) >= _cacheExpiry)
              .length,
    };
  }

  void _addUniqueNews(List<NewsModel> newNews) {
    for (final news in newNews) {
      final normalizedTitle = news.title.toLowerCase().trim();
      final cleanUrl = news.articleUrl.split('?')[0].toLowerCase();

      final isDuplicate = _allNews.any(
        (existing) =>
            existing.title.toLowerCase().trim() == normalizedTitle ||
            existing.articleUrl.split('?')[0].toLowerCase() == cleanUrl,
      );

      if (!isDuplicate) {
        _allNews.add(news);
      }
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
