import 'package:audio_service/audio_service.dart'; // Necesario para AudioProcessingState
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/radio_model.dart';
import '../../main.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

enum PodcastAction { play, pause }

class RadioController with ChangeNotifier {
  List<RadioModel> _radioPodcasts = [];
  List<RadioModel> _enlaceRadialStations = [];
  bool _isLoading = false;
  String _currentPodcastId = '';
  bool _callbacksConfigured = false;

  bool _hasError = false;
  String _errorMessage = '';
  String _lastAttemptedPodcastId = '';

  final bool _isTransitioning = false;
  String? _pendingPodcastId;
  PodcastAction? _podcastAction;

  // Lógica Pre-Roll
  bool _isPreRollPlaying = false;
  String? _originalStreamUrl; // Para reanudar después del anuncio
  String? _originalPodcastId; // Para reanudar después del anuncio

  bool get isTransitioning => _isTransitioning;
  String? get pendingPodcastId => _pendingPodcastId;
  PodcastAction? get podcastAction => _podcastAction;

  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;
  String get lastAttemptedPodcastId => _lastAttemptedPodcastId;

  List<RadioModel> get radioPodcasts => _radioPodcasts;
  List<RadioModel> get enlaceRadialStations => _enlaceRadialStations;
  bool get isLoading => _isLoading;
  bool get isPlaying => audioHandler.isPlaying;
  bool get isBuffering => audioHandler.isBuffering;
  String get currentPodcastId => _currentPodcastId;
  bool get isPreRollPlaying => _isPreRollPlaying;

  RadioController() {
    audioHandler.playbackState.listen((state) {
      // Si termina el Pre-Roll, reproducir el contenido original
      if (state.processingState == AudioProcessingState.completed && _isPreRollPlaying) {
        _onPreRollFinished();
      }
      notifyListeners();
    });
  }

  void _setupSkipCallbacks() {
    if (!_callbacksConfigured) {
      audioHandler.setSkipCallbacks(
        skipToNext: () => playNextPodcast(),
        skipToPrevious: () => playPreviousPodcast(),
      );
      _callbacksConfigured = true;
    }
  }

  // Simulador de obtención de anuncio de audio
  Future<String?> _fetchAudioAd() async {
    // Aquí podrías llamar a AdsController para obtener una URL real de un anuncio de audio
    // Por ahora devolvemos null o una URL de prueba fija si se quisiera implementar
    return null; // Deshabilitado por defecto hasta tener URLs reales
  }

  Future<void> playPodcast(String url, String podcastId, {bool playPreRoll = true}) async {
    try {
      _hasError = false;
      _errorMessage = '';

      // Si ya está sonando lo mismo, pausar (toggle)
      if (_currentPodcastId == podcastId && isPlaying && !_isPreRollPlaying) {
        await pausePodcast();
        return;
      }

      // Lógica de Pre-Roll Ad
      if (playPreRoll) {
        final adUrl = await _fetchAudioAd();
        if (adUrl != null) {
          _isPreRollPlaying = true;
          _originalStreamUrl = url;
          _originalPodcastId = podcastId;
          
          // Reproducir anuncio
          await _playStream(adUrl, 'Publicidad', 'La Nación Radio', 'ad_preroll');
          return;
        }
      }

      // Reproducción normal (o post-anuncio)
      _isPreRollPlaying = false;
      await _playStream(url, _getPodcastTitle(podcastId), _getPodcastDesc(podcastId), podcastId);

    } on PlatformException catch (e) {
      _handleError(podcastId, 'Error de plataforma: ${e.message}');
    } catch (e) {
      _handleError(podcastId, 'Error inesperado al reproducir');
    }
  }

  String _getPodcastTitle(String id) => findStationById(id)?.title ?? 'La Nación Radio';
  String _getPodcastDesc(String id) => findStationById(id)?.description ?? 'En Vivo';

  Future<void> _playStream(String url, String title, String desc, String id) async {
    try {
      await audioHandler.stop();
    } catch (e) {}

    _currentPodcastId = id;
    _lastAttemptedPodcastId = id;

    final artworkUrl = findStationById(id)?.artworkUrl ?? '';

    try {
      await audioHandler.setUrl(
        url,
        title,
        desc,
        imageUrl: artworkUrl.isNotEmpty ? artworkUrl : null,
      );
    } catch (e) {
      _handleError(id, 'Error al cargar audio');
      return;
    }

    try {
      await audioHandler.play();
    } catch (e) {
      _handleError(id, 'Error al iniciar reproducción');
    }
  }

  void _onPreRollFinished() {
    _isPreRollPlaying = false;
    if (_originalStreamUrl != null && _originalPodcastId != null) {
      playPodcast(_originalStreamUrl!, _originalPodcastId!, playPreRoll: false);
      _originalStreamUrl = null;
      _originalPodcastId = null;
    }
  }

  void _handleError(String podcastId, String msg) {
    _lastAttemptedPodcastId = podcastId;
    _hasError = true;
    _errorMessage = msg;
    try {
      audioHandler.stop();
    } catch (_) {}
    notifyListeners();
  }

  Future<void> pausePodcast() async {
    try {
      await audioHandler.pause();
      notifyListeners();
    } on PlatformException catch (e) {
      debugPrint('Platform error pausing podcast: ${e.code} - ${e.message}');
    }
  }

  Future<void> resumePodcast() async {
    try {
      await audioHandler.play();
      notifyListeners();
    } on PlatformException catch (e) {
      debugPrint('Platform error resuming podcast: ${e.code} - ${e.message}');
    }
  }

  Future<void> stopPodcast() async {
    try {
      await audioHandler.stop();
      _lastAttemptedPodcastId = _currentPodcastId;
      _currentPodcastId = '';
      _hasError = false;
      _errorMessage = '';
      _isPreRollPlaying = false; // Reset flag
      notifyListeners();
    } on PlatformException {
      _handleError(_currentPodcastId, 'Error al detener la reproducción');
    } catch (e) {
      _handleError(_currentPodcastId, 'Error inesperado al detener');
    }
  }

  void playPreviousPodcast() {
    final allStations = [..._radioPodcasts, ..._enlaceRadialStations];
    if (allStations.isEmpty || _currentPodcastId.isEmpty) return;

    int currentIndex = allStations.indexWhere((p) => p.id == _currentPodcastId);

    if (currentIndex > 0) {
      var previousPodcast = allStations[currentIndex - 1];
      playPodcast(previousPodcast.streamUrl, previousPodcast.id);
    }
  }

  void playNextPodcast() {
    final allStations = [..._radioPodcasts, ..._enlaceRadialStations];
    if (allStations.isEmpty || _currentPodcastId.isEmpty) return;

    int currentIndex = allStations.indexWhere((p) => p.id == _currentPodcastId);

    if (currentIndex < allStations.length - 1) {
      var nextPodcast = allStations[currentIndex + 1];
      playPodcast(nextPodcast.streamUrl, nextPodcast.id);
    }
  }

  bool shouldShowMiniPlayer() {
    return _currentPodcastId.isNotEmpty ||
        (_hasError && _lastAttemptedPodcastId.isNotEmpty);
  }

  RadioModel? getCurrentDisplayStation() {
    if (_currentPodcastId.isNotEmpty) {
      return findStationById(_currentPodcastId);
    }

    if (_hasError && _lastAttemptedPodcastId.isNotEmpty) {
      return findStationById(_lastAttemptedPodcastId);
    }

    return null;
  }

  String getPlayerStatus() {
    if (_hasError) {
      return 'error';
    } else if (isBuffering) {
      return 'buffering';
    } else if (isPlaying) {
      return 'playing';
    } else {
      return 'paused';
    }
  }

  Future<void> fetchPodcasts([int limit = 100]) async {
    _isLoading = true;
    notifyListeners();

    try {
      List<RadioModel> allStations = [];

      // Mantener la estación en vivo principal al inicio (Siempre disponible)
      final laNacionRadio = RadioModel(
        id: 'nacion_radio_main',
        title: 'La Nación Radio',
        description: 'San Cristóbal - En Vivo 24/7',
        streamUrl: 'https://guri.tepuyserver.net/8044/stream',
        artworkUrl:
            'https://yt3.googleusercontent.com/XICUubqTSojDItH6CYd4l0VLRGqRDCGcOyf04byOhN_QBS8ukHCye7bX9GRoHMWYjhj8CR-NMQ=s900-c-k-c0x00ffffff-no-rj',
      );
      allStations.add(laNacionRadio);
      
      // Asignar INMEDIATAMENTE para que la UI tenga algo que mostrar mientras carga el resto
      _radioPodcasts = List.from(allStations); 
      notifyListeners();

      // Intentar traer los programas desde la API de WP
      const String base =
          'https://maroon-ibis-412710.hostingersite.com/wp-json/api/programas';
      final uri = Uri.parse('$base?per_page=$limit');

      final resp = await http.get(uri).timeout(const Duration(seconds: 30));
      if (resp.statusCode == 200) {
        final data = json.decode(resp.body);
        if (data is List) {
          final programs =
              data.map<RadioModel>((item) {
                try {
                  return RadioModel.fromWpProgramJson(
                    item as Map<String, dynamic>,
                  );
                } catch (e) {
                  // Si algo falla mapeando un item, lo ignoramos
                  return RadioModel(
                    id:
                        (item['id']?.toString() ??
                            DateTime.now().millisecondsSinceEpoch.toString()),
                    title: item['title']?['rendered'] ?? 'Programa sin título',
                    description: item['acf']?['podcast_description'] ?? '',
                    streamUrl: '',
                    artworkUrl: item['acf']?['podcast_image']?['url'] ?? '',
                  );
                }
              }).toList();

          // Filtramos para excluir cualquier programa cuyo título sea "Sin Programa"
          final filteredPrograms =
              programs
                  .where((p) => p.title.trim().toLowerCase() != 'sin programa')
                  .toList();

          allStations.addAll(filteredPrograms);
        }
      } else {
        debugPrint('WP API Radio error: ${resp.statusCode}');
      }

      // Actualizar lista final con todo lo encontrado
      _radioPodcasts = allStations;
      _enlaceRadialStations = _getManualStations();
      _setupSkipCallbacks();
      
    } catch (e) {
      debugPrint('Error fetching radio programs: $e');
      // Si falla, al menos aseguramos que las manuales y la principal estén
       _enlaceRadialStations = _getManualStations();
       // _radioPodcasts ya tiene la principal agregada al inicio
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setCurrentPodcast(String podcastId) {
    _currentPodcastId = podcastId;
    notifyListeners();
  }

  List<RadioModel> getEpisodesBySeries(String seriesPrefix) {
    final allStations = [..._radioPodcasts, ..._enlaceRadialStations];
    return allStations
        .where((podcast) => podcast.id.startsWith(seriesPrefix))
        .toList();
  }

  List<RadioModel> getRelatedEpisodes(String seriesName) {
    final allStations = [..._radioPodcasts, ..._enlaceRadialStations];
    return allStations.where((podcast) {
      return podcast.title.toLowerCase().contains(seriesName.toLowerCase());
    }).toList();
  }

  static const Map<String, Map<String, String>> programInfo = {
    'leyendas_': {
      'locutor': 'Reporteritos de Córdoba',
      'schedule': 'lunes, miércoles y viernes\n2:00 pm',
      'description':
          'Todos los lunes, miércoles y viernes escucha Una leyenda de espanto, un espacio para la promoción de la lectura, creado por los Reporteritos Córdoba, de San Cristóbal, donde viajarás al pasado a descubrir historias que guardan las memorias del estado Táchira, llenas de misterio y suspenso.',
    },
    'raices_': {
      'locutor': 'Equipo La Nación Radio',
      'schedule': 'dias 1:00 pm',
      'description':
          'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry’s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged.',
    },
    'radio_talento_': {
      'locutor': 'Radio talento',
      'schedule': 'dias 1:00 pm',
      'description':
          'Espacio radial que promueve cuentos, poesías, leyendas, mitos y fábulas; acercando a estudiantes y la comunidad al mágico mundo de los libros y la radio. En esta producción participan estudiantes de Venezuela, España, Colombia, México, Argentina, Bolivia y Ecuador.',
    },
    'fake_news_': {
      'locutor': 'Analistas La Nación',
      'schedule': 'dias 1:00 pm',
      'description':
          'No te dejes engañar por todo lo que ves y oyes en redes sociales. Nuestro equipo periodístico trabaja constantemente para filtrar las noticias falsas y de dudosa procedencia que viajan por la autopista de la información. Consume siempre contenido verificado.',
    },
    'llanera_': {
      'locutor': 'Yuliana Ruiz',
      'schedule': 'dias 1:00 pm',
      'description':
          'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry’s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged.',
    },
    'nacion_radio': {
      'locutor': 'Ana Becerra',
      'schedule': 'dias 24/7',
      'description':
          'La primera radio nativa digital del Táchira que conecta con tu día a día. Como brazo radial del prestigioso Diario La Nación, llevamos más de 52 años informando con credibilidad y cercanía a toda la región andina.\n\nTe acompañamos 24/7 con noticias de última hora, análisis profundo, entretenimiento y la mejor programación local. Desde San Cristóbal para todo el Táchira, Colombia y el mundo.\n\nCon las voces de José Velandia, Ana Becerra, María Teresa Amaya, Alexander Contreras, David Bernal, Mayra Sánchez, Porfirio Parada y Yuliana Ruiz, que hacen de cada programa una experiencia única y auténticamente tachirense.',
    },
  };

  Map<String, String>? getProgramInfo(String podcastId) {
    // Primero intentar obtener la estación/programa desde los datos cargados
    final station = findStationById(podcastId);
    if (station != null) {
      // Si es un programa traído desde WP (isProgram) o tiene announcers / schedule, úsalo
      if (station.isProgram ||
          (station.announcers != null && station.announcers!.isNotEmpty) ||
          (station.programSchedule != null &&
              station.programSchedule!.isNotEmpty)) {
        final locutor =
            (station.announcers != null && station.announcers!.isNotEmpty)
                ? station.announcers!.join(', ')
                : 'Sin Locutor';
        final schedule = station.programSchedule ?? '';
        final desc =
            (station.description.isNotEmpty) ? station.description : '';

        return {'locutor': locutor, 'schedule': schedule, 'description': desc};
      }
    }

    return null;
  }

  List<RadioModel> getFeaturedEpisodes() {
    Map<String, RadioModel> featuredMap = {};

    for (var podcast in _radioPodcasts) {
      String seriesKey = '';

      if (podcast.id.startsWith('llanera_')) {
        seriesKey = 'llanera';
      } else if (podcast.id.startsWith('radio_talento_')) {
        seriesKey = 'radio_talento';
      } else if (podcast.id.startsWith('fake_news_')) {
        seriesKey = 'fake_news';
      } else if (podcast.id.startsWith('raices_')) {
        seriesKey = 'raices';
      } else if (podcast.id.startsWith('leyendas_')) {
        seriesKey = 'leyendas';
      } else if (podcast.id.startsWith('nacion_radio')) {
        seriesKey = 'nacion_radio';
      } else {
        seriesKey = podcast.id;
      }

      if (!featuredMap.containsKey(seriesKey)) {
        featuredMap[seriesKey] = podcast;
      }
    }

    return featuredMap.values.toList();
  }

  List<RadioModel> _getManualStations() {
    return [
      RadioModel(
        id: 'radio_fe_alegria_guasdualito',
        title: 'Radio Fe y Alegría',
        description: 'Guasdualito, Apure - 101.1 FM',
        streamUrl: 'http://aler.org:8000/guasdualitofm.aac',
        artworkUrl: 'https://cdn.onlineradiobox.com/img/l/3/60183.v23.png',
      ),
      RadioModel(
        id: 'buena_compania_radio',
        title: 'Buena Compañía Radio',
        description: 'San Cristóbal, Táchira - 94.1 FM',
        streamUrl: 'https://stream.zeno.fm/0zd4m5vtmchvv',
        artworkUrl: 'https://cdn.onlineradiobox.com/img/l/1/110891.v5.png',
      ),
      RadioModel(
        id: 'superior_929_fm',
        title: 'Superior 92.9 FM',
        description: 'El Nula, Apure - 92.9 FM',
        streamUrl: 'https://laradiossl.online:6290/stream',
        artworkUrl: 'https://cdn.onlineradiobox.com/img/l/4/48754.v12.png',
      ),
      RadioModel(
        id: 'digital_1007_fm',
        title: 'Cadena Digital FM',
        description: 'San Cristóbal, Táchira - 100.7 FM',
        streamUrl: 'https://server6.globalhostla.com:9284/stream',
        artworkUrl:
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTPWpTauUNpORr8hfObBjWQsJXQQhE3afZ4tw&s',
      ),
      RadioModel(
        id: 'radio_impacto_2_1055',
        title: 'Radio Impacto 2',
        description: 'Elmhurst, Estados Unidos - 105.5 FM',
        streamUrl:
            'https://panel.streamingtv-mediacp.online:2020/stream/impacto2',
        artworkUrl: 'https://cdn.onlineradiobox.com/img/l/5/80765.v6.png',
      ),
      RadioModel(
        id: 'onda_merida',
        title: 'Onda',
        description: 'Mérida',
        streamUrl: '',
        artworkUrl:
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSIJefry9dlL4NwgznRoUmB6fK_JJrJbf8zhg&s',
      ),
      RadioModel(
        id: 'conectados_radio',
        title: 'Conectados Radio',
        description: 'San Cristóbal',
        streamUrl: '',
        artworkUrl:
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSzUOROIssQBnJ1Vox7gaVXjZuAYb8EYFJz4A&s',
      ),
      RadioModel(
        id: 'impacto_la_fria',
        title: 'Impacto',
        description: 'La Fría',
        streamUrl: '',
        artworkUrl:
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQqcakmoQYghfI_BLodADo4w-iZ6xZvHf5M9w&s',
      ),
      RadioModel(
        id: 'a_lo_latino',
        title: 'A lo Latino',
        description: 'Mallorca España',
        streamUrl: '',
        artworkUrl:
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSIProo5Mr5053mH3M4saNC_jiMUJO7WCMZvQ&s',
      ),
      RadioModel(
        id: 'dinamica_pregonero',
        title: 'Dinámica',
        description: 'Pregonero',
        streamUrl: '',
        artworkUrl:
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSOp-JxLFnffbhMcEMmBrKj-qqr1gWq8VmdHQ&s',
      ),
      RadioModel(
        id: 'radio_chacaro',
        title: 'Radio Chacaro',
        description: 'Pregonero',
        streamUrl: '',
        artworkUrl: 'https://cdn.onlineradiobox.com/img/l/3/136333.v2.png',
      ),
    ];
  }

  // Método para encontrar una estación por ID
  RadioModel? findStationById(String stationId) {
    final allStations = [..._radioPodcasts, ..._enlaceRadialStations];
    try {
      return allStations.firstWhere((station) => station.id == stationId);
    } catch (e) {
      return null;
    }
  }

  // Método para limpiar el estado de error
  void clearError() {
    _hasError = false;
    _errorMessage = '';
    notifyListeners();
  }
}
