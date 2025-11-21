import 'package:flutter/material.dart';
import 'package:la_nacion/utils/responsive_values.dart';
import 'package:provider/provider.dart';
import '../../dashboard/controllers/radio_controller.dart';
import '../../config/constants.dart';
import '../../dashboard/controllers/mini_player_controller.dart';

class GlobalMiniPlayer extends StatefulWidget {
  const GlobalMiniPlayer({super.key});

  @override
  State<GlobalMiniPlayer> createState() => _GlobalMiniPlayerState();
}

class _GlobalMiniPlayerState extends State<GlobalMiniPlayer> {
  @override
  Widget build(BuildContext context) {
    final radioController = Provider.of<RadioController>(context);
    final miniPlayerController = Provider.of<MiniPlayerController>(context);

    if (radioController.currentPodcastId.isEmpty) {
      return const SizedBox.shrink();
    }

    final allStations = [
      ...radioController.radioPodcasts,
      ...radioController.enlaceRadialStations,
    ];

    if (allStations.isEmpty) {
      return const SizedBox.shrink();
    }

    final podcast = allStations.firstWhere(
      (p) => p.id == radioController.currentPodcastId,
      orElse: () => allStations.first,
    );

    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 8), // Margen para separar del navbar
      height: 72,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppConstants.primaryColor.withOpacity(0.15),
            AppConstants.surfaceColor.withOpacity(0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppConstants.primaryColor.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppConstants.primaryColor.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: _buildMiniView(
        context,
        podcast,
        radioController,
        miniPlayerController,
      ),
    );
  }

  bool _isLiveStation(dynamic podcast, RadioController controller) {
    if (controller.radioPodcasts.isNotEmpty &&
        podcast.id == controller.radioPodcasts.first.id) {
      return true;
    }

    return controller.enlaceRadialStations.any(
      (station) => station.id == podcast.id,
    );
  }

  Widget _buildMiniView(
    BuildContext context,
    dynamic podcast,
    RadioController controller,
    MiniPlayerController miniController,
  ) {
    final isLive = _isLiveStation(podcast, controller);
    final isPlayable = podcast.isPlayable;

    return Row(
      children: [
        // Botón play/pause moderno
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppConstants.primaryColor,
                AppConstants.primaryColor.withOpacity(0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppConstants.primaryColor.withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IconButton(
            icon: controller.isTransitioning
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Icon(
                    controller.isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 24,
                  ),
            onPressed: controller.isTransitioning
                ? null
                : () {
                    if (!isPlayable) return;
                    if (controller.isPlaying) {
                      controller.pausePodcast();
                    } else {
                      controller.playPodcast(podcast.streamUrl, podcast.id);
                    }
                  },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      podcast.title.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isLive) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.circle, color: Colors.white, size: 6),
                          SizedBox(width: 4),
                          Text(
                            'En Vivo',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              Text(
                podcast.description,
                style: const TextStyle(color: Colors.white70, fontSize: 11),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
