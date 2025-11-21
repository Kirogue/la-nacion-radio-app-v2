import 'package:flutter/material.dart';
import 'package:la_nacion/dashboard/controllers/mini_player_controller.dart';
import 'package:la_nacion/utils/responsive_values.dart';
import 'package:la_nacion/widgets/custom_wrapper.dart';
import '../../widgets/media_card.dart';
import 'package:provider/provider.dart';
import 'package:la_nacion/dashboard/models/radio_model.dart';
import 'package:la_nacion/dashboard/controllers/radio_controller.dart';

class PodcastPlayer extends StatelessWidget {
  final RadioModel podcast;

  const PodcastPlayer({super.key, required this.podcast});

  @override
  Widget build(BuildContext context) {
    return Consumer<RadioController>(
      builder: (context, controller, child) {
        final miniPlayerController = Provider.of<MiniPlayerController>(context);
        // Si el mini player tiene seleccionado algo usa eso, sino el que llegó por props
        RadioModel currentPodcast = miniPlayerController.selectedPodcast ?? podcast;

        final programData = controller.getProgramInfo(currentPodcast.id);
        final topPadding = MediaQuery.of(context).padding.top + 56;
        final bottomPadding = MediaQuery.of(context).viewPadding.bottom;

        return SingleChildScrollView(
          child: ContentWrapper(
            child: Container(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - topPadding - bottomPadding - 56,
              ),
              padding: EdgeInsets.only(top: responsiveValue(context, mobile: 60, tablet: 20)),
              child: Column(
                spacing: 30,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 32),
                      onPressed: () {
                        miniPlayerController.collapse();
                      },
                    ),
                  ),
                  _buildAlbumArt(currentPodcast),
                  _buildPodcastInfo(context, currentPodcast, controller, programData),
                  if ((currentPodcast.isProgram || (programData != null))) ...[
                    _buildProgramInfo(context, currentPodcast, programData),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAlbumArt(RadioModel currentPodcast) {
    return Hero(
      tag: currentPodcast.id,
      child: Container(
        width: 280,
        height: 280,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.1 * 255).round()),
              blurRadius: 20,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: MediaCard(imageUrl: currentPodcast.artworkUrl),
      ),
    );
  }

  Widget _buildPodcastInfo(
    BuildContext context,
    RadioModel podcast,
    RadioController controller,
    Map<String, String>? programData,
  ) {
    return Text(
      podcast.title,
      style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white),
      textAlign: TextAlign.center,
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildProgramInfo(
    BuildContext context,
    RadioModel currentPodcast,
    Map<String, String>? programData,
  ) {
    // Priorizar lista en el modelo
    final announcersFromModel = currentPodcast.announcers ?? [];

    // Construir la lista final de locutores a mostrar
    List<String> announcersDisplay;
    if (announcersFromModel.isNotEmpty) {
      announcersDisplay = announcersFromModel;
    } else if (programData != null && (programData['locutor'] ?? '').trim().isNotEmpty) {
      announcersDisplay =
          (programData['locutor'] ?? '')
              .split(',')
              .map((s) => s.trim())
              .where((s) => s.isNotEmpty)
              .toList();
    } else {
      announcersDisplay = [];
    }

    // Si no hay ninguno, mostramos texto por defecto
    if (announcersDisplay.isEmpty) {
      announcersDisplay = ['Sin Locutor'];
    }

    final locutorLabel = announcersDisplay.length > 1 ? 'Locutores' : 'Locutor';

    final scheduleText =
        currentPodcast.programSchedule ??
        (programData != null ? (programData['schedule'] ?? '') : '');

    String descriptionText =
        (currentPodcast.description.isNotEmpty)
            ? currentPodcast.description
            : (programData != null ? (programData['description'] ?? '') : '');

    // Si la descripción contiene &nbsp; (HTML entity) no la mostramos
    if (descriptionText.contains('&nbsp;')) {
      descriptionText = '';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Label centrado
        Center(child: CategoryLabel(text: locutorLabel)),

        const SizedBox(height: 12),

        // Layout adaptable: hasta 3 por fila si cabe, sino 2, sino 1
        LayoutBuilder(
          builder: (context, constraints) {
            final available = constraints.maxWidth;
            const double minItemWidth = 120.0; // ancho mínimo razonable por item
            int columns = 3;

            if (announcersDisplay.length == 1) {
              columns = 1;
            } else {
              if (available >= minItemWidth * 3) {
                columns = 3;
              } else if (available >= minItemWidth * 2) {
                columns = 2;
              } else {
                columns = 1;
              }
              // evita columnas mayores a la cantidad de elementos
              if (columns > announcersDisplay.length) columns = announcersDisplay.length;
            }

            final List<Widget> rows = [];
            for (int i = 0; i < announcersDisplay.length; i += columns) {
              final end =
                  (i + columns < announcersDisplay.length) ? i + columns : announcersDisplay.length;
              final chunk = announcersDisplay.sublist(i, end);

              rows.add(
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      for (int j = 0; j < chunk.length; j++) ...[
                        Expanded(
                          child: Text(
                            chunk[j],
                            style: Theme.of(
                              context,
                            ).textTheme.bodyLarge?.copyWith(color: Colors.white, fontSize: 14),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (j != chunk.length - 1) const SizedBox(width: 12),
                      ],
                    ],
                  ),
                ),
              );
            }

            return Column(mainAxisSize: MainAxisSize.min, children: rows);
          },
        ),

        const SizedBox(height: 20),

        if (scheduleText.isNotEmpty) ScheduleCardRadio(schedule: scheduleText),

        const SizedBox(height: 20),

        if (descriptionText.isNotEmpty)
          Text(
            descriptionText,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.white, fontSize: 16),
            textAlign: TextAlign.center,
          ),
      ],
    );
  }
}
