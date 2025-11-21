import 'package:flutter/material.dart';
import 'package:la_nacion/dashboard/controllers/ads_controller.dart';
import 'package:la_nacion/utils/responsive_values.dart';
import 'package:la_nacion/widgets/ad_banner.dart';
import 'package:la_nacion/widgets/custom_wrapper.dart';
import 'package:la_nacion/widgets/loading_icon.dart';
import 'package:la_nacion/widgets/media_card.dart';
import 'package:la_nacion/widgets/radio/radio_modal.dart';
import 'package:la_nacion/widgets/skeleton_network_image.dart';
import 'package:provider/provider.dart';
import '../controllers/radio_controller.dart';
import '../../config/constants.dart';

class RadioView extends StatefulWidget {
  const RadioView({super.key});
  @override
  State<RadioView> createState() => _RadioViewState();
}

class _RadioViewState extends State<RadioView> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.microtask(() {
        if (!mounted) {
          return;
        }
        Provider.of<RadioController>(context, listen: false).fetchPodcasts();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final adsController = Provider.of<AdsController>(context);

    return Consumer<RadioController>(
      builder: (context, controller, _) {
        final top = MediaQuery.of(context).padding.top;

        if (controller.isLoading) {
          return Center(child: LoadingIcon(padding: EdgeInsets.only(top: top), size: 40));
        }
        if (controller.radioPodcasts.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsetsGeometry.only(top: top),
              child: Text('No hay podcasts disponibles'),
            ),
          );
        }

        final currentPodcast = controller.radioPodcasts.first;

        // Obtener todos los episodios destacados
        final allEpisodes = controller.getFeaturedEpisodes();

        // Omitir solo el primer elemento si existe
        final otherPodcasts = allEpisodes.length > 1 ? allEpisodes.sublist(1) : [];

        final horizontalPadding = responsiveValue(context, mobile: 16.0, tablet: 48.0);
        final spacing = 20.0;
        final rowSpacing = responsiveValue(context, mobile: 20.0, tablet: 40.0);
        final numberCards = responsiveValue(context, mobile: 2.0, tablet: 4.0);

        final radioController = Provider.of<RadioController>(context);

        final isPlayingForThisPodcast =
            radioController.currentPodcastId == currentPodcast.id && radioController.isPlaying;

        final isPendingPlayForThis =
            radioController.pendingPodcastId == currentPodcast.id &&
            radioController.podcastAction == PodcastAction.play;

        final isPendingPauseForThis =
            radioController.pendingPodcastId == currentPodcast.id &&
            radioController.podcastAction == PodcastAction.pause;

        final showPlaying =
            isPendingPlayForThis || (!isPendingPauseForThis && isPlayingForThisPodcast);

        final isTransitioning = radioController.isTransitioning;

        void onTapBanner() {
          if (isTransitioning) return;
          if (!currentPodcast.isPlayable) return;

          if (showPlaying) {
            radioController.pausePodcast();
          } else {
            radioController.playPodcast(currentPodcast.streamUrl, currentPodcast.id);
          }
        }

        return SingleChildScrollView(
          child: ContentWrapper(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 20.0,
              children: [
                BannerPodcast(
                  countIcon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return ScaleTransition(scale: animation, child: child);
                    },
                    child: radioController.isBuffering
                        ? SizedBox(
                            width: responsiveValue(context, mobile: 25, tablet: 35),
                            height: responsiveValue(context, mobile: 25, tablet: 35),
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          )
                        : Icon(
                      showPlaying ? Icons.pause_outlined : Icons.play_arrow,
                      key: ValueKey(showPlaying ? 'pause' : 'play'),
                      color: Colors.white,
                      size: responsiveValue(context, mobile: 25, tablet: 35),
                    ),
                  ),
                  onTap: onTapBanner,
                ),

                Container(
                  margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'PROGRAMACION RADIAL',
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        fontSize: 16,
                        color: AppConstants.lightGrey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                Container(
                  margin: responsiveValue<EdgeInsets>(
                    context,
                    mobile: const EdgeInsets.symmetric(horizontal: 16),
                    tablet: const EdgeInsets.symmetric(horizontal: 48),
                  ),

                  child: Wrap(
                    spacing: spacing,
                    runSpacing: rowSpacing,
                    children: List.generate(
                      otherPodcasts.length +
                          (otherPodcasts.length ~/ responsiveValue(context, mobile: 6, tablet: 4)),
                      (index) {
                        final interval = responsiveValue(context, mobile: 7, tablet: 5);
                        if ((index + 1) % interval == 0) {
                          final ads = adsController.getUniqueAds(3);
                          return Center(child: AdBanner(ads: ads, xMargin: 0));
                        }

                        final realIndex = index - (index ~/ interval);

                        final podcast = otherPodcasts[realIndex];

                        return GestureDetector(
                          onTap: () {
                            if (podcast.isPlayable) {
                              controller.playPodcast(podcast.streamUrl, podcast.id);
                            } else {
                              showRadioProgramDetailModal(context, podcast);
                            }
                          },
                          child: Container(
                            width:
                                (MediaQuery.of(context).size.width -
                                    horizontalPadding * 2 -
                                    (spacing * (numberCards - 1))) /
                                numberCards,
                            height: 200,
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: SkeletonNetworkImage(
                                imageUrl: podcast.artworkUrl,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                InfoCard(
                  imageUrl: 'assets/images/enlace-r.png',
                  title: 'ENLACE RADIAL',
                  icon: Icons.arrow_forward_ios,
                  isLocalImage: true,
                  height: responsiveValue<double>(context, mobile: 120, tablet: 200),
                ),

                SizedBox(height: responsiveValue(context, mobile: 8, tablet: 32)),
              ],
            ),
          ),
        );
      },
    );
  }
}
