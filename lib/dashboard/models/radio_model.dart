class RadioModel {
  final String id;
  final String title;
  final String description;
  final String streamUrl;
  final String artworkUrl;
  final List<String>? announcers;
  final String? programSchedule;
  final bool isProgram;

  RadioModel({
    required this.id,
    required this.title,
    required this.description,
    required this.streamUrl,
    required this.artworkUrl,
    this.announcers,
    this.programSchedule,
    this.isProgram = false,
  });

  factory RadioModel.fromJson(Map<String, dynamic> json) {
    return RadioModel(
      id: json['id'].toString(),
      title: json['title'],
      description: json['description'] ?? 'La Nacion Radio',
      streamUrl: json['stream_url'],
      artworkUrl: json['thumb'] ?? '',
    );
  }

  // Añadir este nuevo factory para mapear la respuesta de la API de 'programas'
  factory RadioModel.fromWpProgramJson(Map<String, dynamic> json) {
    final acf = json['acf'] ?? {};
    final image = acf['podcast_image'];
    // Construir lista de locutores si vienen
    List<String> announcersList = [];
    if (acf['podcast_announcers'] != null && acf['podcast_announcers'] is List) {
      try {
        announcersList =
            (acf['podcast_announcers'] as List)
                .map<String>((a) {
                  if (a is Map && (a['post_title'] ?? a['title']) != null) {
                    return (a['post_title'] ?? a['title']).toString();
                  }
                  if (a is String) return a;
                  return '';
                })
                .where((s) => s.isNotEmpty)
                .toList();
      } catch (e) {
        announcersList = [];
      }
    }

    // Construir string de schedule (si viene como array)
    String scheduleText = '';
    if (acf['podcast_schedule'] != null && acf['podcast_schedule'] is List) {
      try {
        final List sc = acf['podcast_schedule'] as List;
        scheduleText = sc
            .map((entry) {
              if (entry is Map) {
                final days =
                    (entry['podcast_schedule_days'] is List)
                        ? (entry['podcast_schedule_days'] as List).join(', ')
                        : (entry['podcast_schedule_days']?.toString() ?? '');
                final start = entry['podcast_schedule_time_start'] ?? '';
                final end = entry['podcast_schedule_time_end'] ?? '';
                if (days.isNotEmpty && start.toString().isNotEmpty) {
                  if (end.toString().isNotEmpty) {
                    return '$days • $start - $end';
                  }
                  return '$days • $start';
                }
                return start.toString().isNotEmpty ? start.toString() : '';
              }
              return '';
            })
            .where((s) => s.isNotEmpty)
            .join('\n');
      } catch (e) {
        scheduleText = '';
      }
    }

    return RadioModel(
      id: json['id'].toString(),
      title:
          (json['title'] != null && json['title']['rendered'] != null)
              ? json['title']['rendered']
              : (json['slug']?.toString() ?? 'Programa sin título'),
      description: acf['podcast_description']?.toString() ?? '',
      streamUrl: '', // programas informativos no reproducen audio desde aquí
      artworkUrl:
          image != null ? (image['url']?.toString() ?? '') : (json['thumb']?.toString() ?? ''),
      announcers: announcersList.isNotEmpty ? announcersList : null,
      programSchedule: scheduleText.isNotEmpty ? scheduleText : null,
      isProgram: true,
    );
  }

  factory RadioModel.fromRadioBrowserJson(Map<String, dynamic> json) {
    String streamUrl = '';
    if (json['url_resolved'] != null && json['url_resolved'].toString().isNotEmpty) {
      streamUrl = json['url_resolved'];
    } else if (json['url'] != null && json['url'].toString().isNotEmpty) {
      streamUrl = json['url'];
    }

    String description = 'Venezuela';
    if (json['state'] != null && json['state'].toString().isNotEmpty) {
      description = '${json['state']}, Venezuela';
    }

    if (json['tags'] != null && json['tags'].toString().isNotEmpty) {
      final tags = json['tags'].toString();
      if (tags.contains('news')) description += ' • Noticias';
      if (tags.contains('music')) description += ' • Música';
      if (tags.contains('talk')) description += ' • Conversación';
    }

    return RadioModel(
      id:
          json['stationuuid'] ??
          json['changeuuid'] ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      title: json['name'] ?? 'Emisora sin nombre',
      description: description,
      streamUrl: streamUrl,
      artworkUrl: json['favicon'] ?? '',
    );
  }

  bool get isValid {
    return streamUrl.isNotEmpty &&
        title.isNotEmpty &&
        id.isNotEmpty &&
        (streamUrl.startsWith('http://') || streamUrl.startsWith('https://'));
  }

  bool get isPlayable => streamUrl.isNotEmpty;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'streamUrl': streamUrl,
      'artworkUrl': artworkUrl,
      'announcers': announcers,
      'programSchedule': programSchedule,
      'isProgram': isProgram,
      'isValid': isValid,
    };
  }
}
