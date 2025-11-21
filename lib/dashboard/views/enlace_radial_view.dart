import 'package:flutter/material.dart';
import 'package:la_nacion/widgets/custom_wrapper.dart';
import 'package:la_nacion/widgets/loading_icon.dart';
import 'package:la_nacion/widgets/media_card.dart';
import 'package:provider/provider.dart';
import '../controllers/radio_controller.dart';
import '../../config/constants.dart';

class EnlaceRadialView extends StatefulWidget {
  const EnlaceRadialView({super.key});
  @override
  State<EnlaceRadialView> createState() => _EnlaceRadialViewState();
}

class _EnlaceRadialViewState extends State<EnlaceRadialView> with AutomaticKeepAliveClientMixin {
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

    return Consumer<RadioController>(
      builder: (context, controller, _) {
        final top = MediaQuery.of(context).padding.top;

        if (controller.isLoading) {
          return Center(child: LoadingIcon(padding: EdgeInsets.only(top: top), size: 40));
        }
        if (controller.enlaceRadialStations.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.only(top: top),
              child: Text('No hay estaciones disponibles'),
            ),
          );
        }

        final enlaceStations = controller.enlaceRadialStations;

        return SingleChildScrollView(
          child: ContentWrapper(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: const Icon(Icons.keyboard_arrow_down),
                    iconSize: 32,
                    color: AppConstants.textLight,
                    onPressed: () => Navigator.pop(context),
                  ),
                ),

                ...enlaceStations.map(
                  (station) => HorizontalMediaCard(
                    imageUrl: station.artworkUrl,
                    title: station.title,
                    author: station.description,
                    countIcon:
                        controller.isPlaying && controller.currentPodcastId == station.id
                            ? Icons.pause
                            : Icons.play_arrow,
                    height: 140,
                    onTap: () {
                      if (station.streamUrl.isNotEmpty) {
                        controller.playPodcast(station.streamUrl, station.id);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
