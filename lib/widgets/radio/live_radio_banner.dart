import 'package:flutter/material.dart';
import 'package:la_nacion/widgets/skeleton_pulse.dart';
import 'package:provider/provider.dart';
import 'package:la_nacion/dashboard/controllers/radio_controller.dart';
import 'package:la_nacion/utils/responsive_values.dart';

class LiveRadioBanner extends StatefulWidget {
  const LiveRadioBanner({super.key});
  @override
  State<LiveRadioBanner> createState() => _LiveRadioBannerState();
}

class _LiveRadioBannerState extends State<LiveRadioBanner> with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final radioController = Provider.of<RadioController>(context);

    if (radioController.radioPodcasts.isEmpty) {
      // Mostrar un placeholder o skeleton
      return Container(
        margin: responsiveValue<EdgeInsets>(
          context,
          mobile: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          tablet: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
        ),
        child: SkeletonPulse(
          width: double.infinity,
          height: responsiveValue<double>(context, mobile: 200, tablet: 300),
        ),
      );
    }

    final podcast = radioController.radioPodcasts.first;

    // Determina si este podcast está sonando (fuente única de verdad)
    final isPlayingForThisPodcast =
        radioController.currentPodcastId == podcast.id && radioController.isPlaying;

    // Si el controller tiene una acción pendiente, puedes mostrar el estado objetivo inmediatamente:
    final isPendingPlayForThis =
        radioController.pendingPodcastId == podcast.id &&
        radioController.podcastAction == PodcastAction.play;
    final isPendingPauseForThis =
        radioController.pendingPodcastId == podcast.id &&
        radioController.podcastAction == PodcastAction.pause;

    // Resultado visible: si hay una acción pendiente la mostramos (optimista),
    // en otro caso usamos el valor real.
    final showPlaying = isPendingPlayForThis || (!isPendingPauseForThis && isPlayingForThisPodcast);

    // Evita taps mientras haya transicion en curso (previene doble taps)
    final isTransitioning = radioController.isTransitioning;

    void onTapBanner() {
      if (isTransitioning) return; // ignore taps while transitioning
      if (!podcast.isPlayable) return;
      if (showPlaying) {
        radioController.pausePodcast();
      } else {
        radioController.playPodcast(podcast.streamUrl, podcast.id);
      }
    }

    if (radioController.radioPodcasts.isEmpty) {
      return Container(
        margin: responsiveValue<EdgeInsets>(
          context,
          mobile: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          tablet: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
        ),

        child: SkeletonPulse(
          width: double.infinity,
          height: responsiveValue<double>(context, mobile: 200, tablet: 300),
        ),
      );
    }

    return GestureDetector(
      onTap: onTapBanner,
      child: Container(
        constraints: BoxConstraints(maxWidth: 600),
        height: responsiveValue<double>(context, mobile: 200, tablet: 300),
        margin: responsiveValue<EdgeInsets>(
          context,
          mobile: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          tablet: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
        ),

        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
        child: Stack(
          children: [
            // Fondo imagen
            Positioned.fill(child: Image.asset('assets/images/banner-home.png', fit: BoxFit.cover)),

            // Ícono alineado a la izquierda con padding
            Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                child: Container(
                  key: ValueKey(showPlaying ? 'pause' : 'play'),
                  margin: responsiveValue<EdgeInsets>(
                    context,
                    mobile: const EdgeInsets.only(top: 80, right: 10),
                    tablet: const EdgeInsets.only(top: 130, right: 20),
                  ),
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    border: BoxBorder.all(color: Colors.white, width: 2),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Icon(
                    showPlaying ? Icons.pause_outlined : Icons.play_arrow,
                    size: 40,
                    color: Colors.white,
                    key: ValueKey(showPlaying ? 'pause' : 'play'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
