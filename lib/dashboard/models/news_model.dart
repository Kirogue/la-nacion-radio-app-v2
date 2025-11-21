class NewsModel {
  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  final String category;
  final DateTime publishDate;
  final String articleUrl;
  final String? author;
  final String? postId;

  const NewsModel({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.category,
    required this.publishDate,
    required this.articleUrl,
    this.author,
    this.postId,
  });

  factory NewsModel.fromXml(Map<String, dynamic> xmlData) {
    // Prioridad: primero enclosure, luego imagen del contenido
    String? enclosureImage = xmlData['enclosure'] as String?;
    String? imageFromContent = extractImageFromContent(xmlData['description'] ?? '');
    final initialImage = enclosureImage ?? imageFromContent;

    return NewsModel(
      id: xmlData['guid'] ?? '',
      title: cleanHtml(xmlData['title'] ?? 'Sin título'),
      description: cleanHtml(xmlData['description'] ?? 'Sin descripción'),
      imageUrl: initialImage,
      postId: xmlData['post_id']?.toString(),
      category: xmlData['category'] ?? 'General',
      publishDate: parseDate(xmlData['pubDate']),
      articleUrl: xmlData['link'] ?? '',
      author: xmlData['creator'] ?? xmlData['author'],
    );
  }

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'],
      category: json['category'] ?? 'General',
      postId: json['post_id']?.toString(),
      publishDate: DateTime.parse(json['publishDate']),
      articleUrl: json['articleUrl'] ?? '',
      author: json['author'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'postId': postId,
      'category': category,
      'publishDate': publishDate.toIso8601String(),
      'articleUrl': articleUrl,
      'author': author,
    };
  }

  NewsModel copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    String? postId,
    String? category,
    DateTime? publishDate,
    String? articleUrl,
    String? author,
  }) {
    return NewsModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      postId: postId ?? this.postId,
      category: category ?? this.category,
      publishDate: publishDate ?? this.publishDate,
      articleUrl: articleUrl ?? this.articleUrl,
      author: author ?? this.author,
    );
  }

  String get shortDescription {
    if (description.length <= 100) return description;
    return '${description.substring(0, 100)}...';
  }

  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(publishDate);

    if (difference.inDays > 0) {
      return 'Hace ${difference.inDays} día${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'Hace ${difference.inHours} hora${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'Hace ${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'Hace un momento';
    }
  }

  @override
  String toString() {
    return 'NewsModel(id: $id, title: $title, category: $category)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NewsModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  static String cleanHtml(String htmlString) {
    return htmlString
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#039;', "'")
        .trim();
  }

  static String? extractImageFromContent(String content) {
    if (content.isEmpty) return null;

    final patterns = [
      RegExp(
        r'data-orig-file=["'
        "'"
        r']([^"'
        "'"
        r']+)["'
        "'"
        r']',
        caseSensitive: false,
      ),
      RegExp(
        r'data-large-file=["'
        "'"
        r']([^"'
        "'"
        r']+)["'
        "'"
        r']',
        caseSensitive: false,
      ),
      RegExp(
        r'<img[^>]+src=["'
        "'"
        r']([^"'
        "'"
        r']+)["'
        "'"
        r'][^>]*>',
        caseSensitive: false,
      ),
      RegExp(
        r'https?://i\d+\.wp\.com/[^\s<>"'
        "'"
        r']*\.(?:jpg|jpeg|png|gif|webp)',
        caseSensitive: false,
      ),
      RegExp(
        r'https?://[^\s<>"'
        "'"
        r']*lanacionweb\.com[^\s<>"'
        "'"
        r']*\.(?:jpg|jpeg|png|gif|webp)',
        caseSensitive: false,
      ),
      RegExp(
        r'https?://[^\s<>"'
        "'"
        r']+\.(?:jpg|jpeg|png|gif|webp)(?:\?[^\s<>"'
        "'"
        r']*)?',
        caseSensitive: false,
      ),
    ];

    String? bestUrl;

    for (final pattern in patterns) {
      final match = pattern.firstMatch(content);
      if (match != null) {
        String url = match.groupCount > 0 ? (match.group(1) ?? match.group(0)!) : match.group(0)!;
        url = cleanImageUrl(url);

        if (isQualityImage(url)) {
          return url;
        }
        bestUrl ??= url;
      }
    }

    return bestUrl;
  }

  static bool isQualityImage(String url) {
    final lower = url.toLowerCase();
    return lower.contains('1024') ||
        lower.contains('768') ||
        lower.contains('large') ||
        (lower.contains('resize=') && !lower.contains('150'));
  }

  static String cleanImageUrl(String url) {
    return url
        .replaceAll('&#038;', '&')
        .replaceAll('&amp;', '&')
        .trim()
        .replaceFirst('http://', 'https://');
  }

  static const Map<String, int> _monthMap = {
    'jan': 1,
    'feb': 2,
    'mar': 3,
    'apr': 4,
    'may': 5,
    'jun': 6,
    'jul': 7,
    'aug': 8,
    'sep': 9,
    'oct': 10,
    'nov': 11,
    'dec': 12,
    'enero': 1,
    'febrero': 2,
    'marzo': 3,
    'abril': 4,
    'mayo': 5,
    'junio': 6,
    'julio': 7,
    'agosto': 8,
    'septiembre': 9,
    'octubre': 10,
    'noviembre': 11,
    'diciembre': 12,
  };

  static DateTime parseDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return DateTime(1970, 1, 1);
    }

    try {
      return DateTime.parse(dateString);
    } catch (e) {
      try {
        final cleaned = dateString.trim().replaceFirst(RegExp(r'^[a-zA-Z]+,\s*'), '');

        final parts = cleaned.split(RegExp(r'\s+'));
        if (parts.length >= 4) {
          final day = int.parse(parts[0]);
          final monthStr = parts[1].toLowerCase();
          final year = int.parse(parts[2]);

          final month = _monthMap[monthStr];
          if (month != null) {
            if (parts.length > 3 && parts[3].contains(':')) {
              final timeParts = parts[3].split(':');
              final hour = int.parse(timeParts[0]);
              final minute = int.parse(timeParts[1]);
              final second = timeParts.length > 2 ? int.parse(timeParts[2]) : 0;
              return DateTime(year, month, day, hour, minute, second);
            }
            return DateTime(year, month, day);
          }
        }

        final fallbackDate = cleaned
            .replaceAll(RegExp(r'\s+[+-]\d{4}$'), '')
            .replaceAll(RegExp(r'\s+[A-Z]{3}$'), '');
        return DateTime.parse(fallbackDate);
      } catch (e2) {
        return DateTime(1970, 1, 1);
      }
    }
  }
}
