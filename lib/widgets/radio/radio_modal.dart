import 'package:flutter/material.dart';
import 'package:la_nacion/config/constants.dart';
import 'package:la_nacion/dashboard/models/radio_model.dart';
import 'package:la_nacion/widgets/radio/podcast_player.dart'; // ajusta la ruta si es otra

void showRadioProgramDetailModal(BuildContext context, RadioModel program) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder:
        (context) => DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.6,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: const BoxDecoration(
                color: AppConstants.backgroundColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                child: PodcastPlayer(podcast: program),
              ),
            );
          },
        ),
  );
}
