import 'package:flutter/material.dart';
import 'package:la_nacion/config/env_constants.dart';
import 'package:la_nacion/widgets/loading_icon.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:xml/xml.dart' as xml;
import 'package:http/http.dart' as http;
import 'package:la_nacion/utils/responsive_values.dart';
import 'package:la_nacion/config/constants.dart';

class Youtube extends StatefulWidget {
  const Youtube({super.key});

  @override
  State<Youtube> createState() => _YoutubeState();
}

class _YoutubeState extends State<Youtube> {
  bool _loading = true;
  String? _videoId;
  String? _title;
  String? _thumbnail;
  String? _error;
  YoutubePlayerController? _controller;
  bool _playerVisible = false;

  @override
  void initState() {
    super.initState();
    _fetchLatestVideo();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _fetchLatestVideo() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final url = Uri.parse(
      'https://www.youtube.com/feeds/videos.xml?channel_id=${EnvConstants.youtubeChannelId}',
    );

    try {
      final resp = await http.get(url);
      if (resp.statusCode != 200) {
        setState(() {
          _error = 'HTTP ${resp.statusCode}';
          _loading = false;
        });
        return;
      }

      final doc = xml.XmlDocument.parse(resp.body);
      final entry = doc.findAllElements('entry').firstOrNull;

      if (entry == null) {
        setState(() {
          _error = 'No entries in feed';
          _loading = false;
        });
        return;
      }

      final videoIdElem =
          entry.findElements('videoId', namespace: '*').firstOrNull ??
          entry.findAllElements('videoId').firstOrNull;
      final vid =
          videoIdElem?.text ??
          entry.findElements('id').first.text.split(':').last;
      final t = entry.findElements('title').first.text;
      final thumbElem =
          entry.findAllElements('thumbnail').firstOrNull ??
          entry.findAllElements('thumbnail', namespace: '*').firstOrNull;
      final thumb =
          thumbElem?.getAttribute('url') ??
          'https://img.youtube.com/vi/$vid/hqdefault.jpg';

      setState(() {
        _videoId = vid;
        _title = t;
        _thumbnail = thumb;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Exception: $e';
        _loading = false;
      });
    }
  }

  void _openPlayer() {
    if (_videoId == null) return;
    _controller ??= YoutubePlayerController(
      initialVideoId: _videoId!,
      flags: const YoutubePlayerFlags(
        showLiveFullscreenButton: false,
        hideThumbnail: true,
      ),
    );
    setState(() {
      _playerVisible = true;
    });
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      await launchUrl(uri, mode: LaunchMode.inAppWebView);
    }
  }

  @override
  Widget build(BuildContext context) {
    final margin = responsiveValue<EdgeInsets>(
      context,
      mobile: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      tablet: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
    );

    if (_loading) {
      return const Center(
        child: LoadingIcon(
          padding: EdgeInsets.symmetric(vertical: 40),
          size: 40,
        ),
      );
    }

    // Error o sin video
    if (_error != null || _videoId == null) {
      return Container(
        width: 600,
        margin: margin,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 12),
            Text(
              'No pudimos cargar el último video',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Pero puedes visitar nuestro canal en YouTube para ver el contenido más reciente.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => _openUrl(AppConstants.youtubeChannel),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppConstants.primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.play_circle_fill,
                      color: AppConstants.textLight,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'IR AL CANAL',
                      style: TextStyle(
                        color: AppConstants.textLight,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Video cargado
    return Container(
      margin: margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'CANAL DE YOUTUBE',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              GestureDetector(
                onTap: () => _openUrl(AppConstants.youtubeChannel),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppConstants.primaryColor.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'VER CANAL',
                        style: TextStyle(
                          color: AppConstants.textLight,
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.open_in_new,
                        color: AppConstants.textLight,
                        size: 13,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Player
          LayoutBuilder(
            builder: (context, constraints) {
              const maxHeight = 450.0;
              final maxWidth = constraints.maxWidth;
              final calculatedHeight = maxWidth * 9 / 16;
              final height =
                  calculatedHeight > maxHeight ? maxHeight : calculatedHeight;
              final width = height * 16 / 9;

              return Center(
                child: GestureDetector(
                  onTap: _playerVisible ? null : _openPlayer,
                  child: Container(
                    width: width,
                    height: height,
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.black12,
                    ),
                    child:
                        _playerVisible && _controller != null
                            ? YoutubePlayer(controller: _controller!)
                            : Stack(
                              alignment: Alignment.center,
                              children: [
                                Image.network(
                                  _thumbnail!,
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.black54,
                                  ),
                                  child: const Icon(Icons.play_arrow, size: 48),
                                ),
                              ],
                            ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 12),
          Text(
            _title ?? 'Sin título',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

// helper extension
extension FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull => isEmpty ? null : first;
}
