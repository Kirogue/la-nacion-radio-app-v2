import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:url_launcher/url_launcher.dart';

class ReelCard extends StatefulWidget {
  final dynamic reel; // tu modelo Reel
  final bool isPlaying;
  final bool isMuted;
  final double? height;
  final double? width;
  final VoidCallback? onCompleted;
  final VoidCallback? onMuteToggle;

  const ReelCard({
    super.key,
    required this.reel,
    required this.isPlaying,
    required this.isMuted,
    this.height,
    this.onCompleted,
    this.onMuteToggle,
    this.width,
  });

  @override
  State<ReelCard> createState() => _ReelCardState();
}

class _ReelCardState extends State<ReelCard> {
  VideoPlayerController? _controller;
  bool _isVisible = false;
  bool _isManuallyPlaying = true; // estado de play/pause manual

  @override
  void didUpdateWidget(covariant ReelCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Cambia entre play/pause cuando cambia isPlaying
    if (widget.isPlaying != oldWidget.isPlaying || widget.isMuted != oldWidget.isMuted) {
      _handlePlayback();
    }
  }

  @override
  void dispose() {
    _controller?.removeListener(_videoListener);
    _controller?.dispose();
    _controller = null;
    super.dispose();
  }

  void _handlePlayback() async {
    if (widget.isPlaying && _isVisible) {
      if (_controller == null || !_controller!.value.isInitialized) {
        await _initVideo();
      }
      if (_isManuallyPlaying) _controller?.play();
      _controller?.setVolume(widget.isMuted ? 0 : 1);
    } else {
      _controller?.pause();
    }
  }

  void _videoListener() {
    if (!mounted) return;
    if (_controller != null && _controller!.value.isInitialized && widget.isPlaying && _isVisible) {
      if (_controller!.value.position >= _controller!.value.duration) {
        if (!mounted) return;
        widget.onCompleted?.call();
      }
    }
  }

  Future<void> _initVideo() async {
    try {
      if (_controller != null && _controller!.value.isInitialized) {
        return;
      }

      _controller?.removeListener(_videoListener);
      _controller?.dispose();

      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.reel.mediaUrl));
      await _controller!.initialize();
      if (!mounted) return;

      _controller!.setLooping(false);
      _controller!.setVolume(widget.isMuted ? 0 : 1);
      _controller!.addListener(_videoListener);

      if (_isManuallyPlaying) {
        _controller!.play();
      }
      if (!mounted) return;
      if (mounted) setState(() {});
    } catch (e) {}
  }

  void _togglePlayPause() {
    if (_controller == null) return;
    setState(() {
      _isManuallyPlaying = !_isManuallyPlaying;
    });
    if (_isManuallyPlaying) {
      _controller!.play();
    } else {
      _controller!.pause();
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = widget.width ?? MediaQuery.of(context).size.width * 0.85;
    final height = widget.height ?? MediaQuery.of(context).size.height;

    Widget content;
    if (widget.isPlaying && _isVisible && _controller != null && _controller!.value.isInitialized) {
      content = VideoPlayer(_controller!);
    } else {
      // OPTIMIZACIÓN: Usar CachedNetworkImage y memCacheHeight para reducir uso de RAM
      // Si la URL es nula o vacía, mostrar placeholder
      final imageUrl = widget.reel.thumbnailUrl ?? widget.reel.mediaUrl;
      
      content = CachedNetworkImage(
        imageUrl: imageUrl ?? '',
        fit: BoxFit.cover,
        // Limitar tamaño en memoria para evitar Jank en scroll
        memCacheWidth: (width * 2).toInt(), // Retina display x2
        placeholder: (context, url) => Container(color: Colors.black12),
        errorWidget: (context, url, error) => Container(color: Colors.grey),
      );
    }

    return VisibilityDetector(
      key: Key(widget.reel.id),
      onVisibilityChanged: (info) {
        final visible = info.visibleFraction > 0.5;
        if (visible != _isVisible && mounted) {
          setState(() => _isVisible = visible);
          _handlePlayback();
        }
      },
      child: GestureDetector(
        onTap: () async {
          final url = Uri.parse(widget.reel.permalink);

          try {
            final ok = await launchUrl(url, mode: LaunchMode.externalApplication);
            if (!ok) {
              // fallback forzado al navegador
              await launchUrl(url, mode: LaunchMode.inAppBrowserView);
            }
          } catch (_) {
            await launchUrl(url, mode: LaunchMode.inAppBrowserView);
          }
        },

        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: Colors.black),
          clipBehavior: Clip.hardEdge,
          child: Stack(
            fit: StackFit.expand,
            children: [
              content,
              // Controles overlay
              Positioned(
                bottom: 16,
                right: 16,
                child: Column(
                  children: [
                    IconButton(
                      icon: Icon(
                        _isManuallyPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                        color: Colors.white,
                        size: 40,
                      ),
                      onPressed: _togglePlayPause,
                    ),
                    IconButton(
                      icon: Icon(
                        widget.isMuted ? Icons.volume_off : Icons.volume_up,
                        color: Colors.white,
                        size: 30,
                      ),
                      onPressed: widget.onMuteToggle,
                    ),
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
