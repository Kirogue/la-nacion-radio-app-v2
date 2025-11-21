import 'package:flutter/material.dart';
import 'package:la_nacion/widgets/custom_expansion_tile.dart';
import '../gradient_decorations.dart';
import 'package:la_nacion/config/constants.dart';

class CategorySelect extends StatelessWidget {
  final List<String> generalCategories;
  final String? selectedGeneral;
  final String? selectedEspecificaValue;
  final Map<String, List<Map<String, String>>> groupedCategories;
  final bool expanded;
  final VoidCallback onTap;
  final void Function(String? general, String? especificaValue) onSelect;

  const CategorySelect({
    super.key,
    required this.generalCategories,
    required this.selectedGeneral,
    required this.selectedEspecificaValue,
    required this.groupedCategories,
    required this.expanded,
    required this.onTap,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: gradientDecoration(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  (() {
                    if (selectedEspecificaValue != null && selectedGeneral != null) {
                      final especifica = groupedCategories[selectedGeneral!]?.firstWhere(
                        (e) => e['value'] == selectedEspecificaValue,
                        orElse: () => {},
                      );
                      return (especifica?['especifica'] ?? especifica?['label'] ?? '')
                          .toUpperCase();
                    } else if (selectedGeneral != null) {
                      return selectedGeneral!.toUpperCase();
                    }
                    return 'TODAS';
                  })(),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                AnimatedRotation(
                  turns: expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(Icons.expand_more),
                ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          child:
              expanded
                  ? Container(
                    clipBehavior: Clip.hardEdge,
                    margin: const EdgeInsets.only(top: 8),
                    decoration: gradientDecoration(),
                    child: Scrollbar(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // TODAS
                            Container(
                              color:
                                  (selectedGeneral == null && selectedEspecificaValue == null)
                                      ? AppConstants.blueGradient
                                      : null,
                              child: ListTile(
                                title: const Text(
                                  'TODAS',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                onTap: () => onSelect(null, null),
                              ),
                            ),

                            // Categorías generales
                            for (final general in generalCategories)
                              CustomExpansionTile(
                                title: general,
                                initiallyExpanded: selectedGeneral == general,
                                backgroundColor:
                                    (selectedGeneral == general && selectedEspecificaValue == null)
                                        ? AppConstants.blueGradient
                                        : null,
                                onSelectParent: () => onSelect(general, null),
                                children: [
                                  for (final especifica in groupedCategories[general]!)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 15,
                                        vertical: 2.5,
                                      ),
                                      color:
                                          (selectedGeneral == general &&
                                                  selectedEspecificaValue == especifica['value'])
                                              ? AppConstants.blueGradient
                                              : null,
                                      child: ListTile(
                                        title: Text(
                                          especifica['especifica'] ?? especifica['label'] ?? '',
                                          style: const TextStyle(color: Colors.white),
                                        ),
                                        onTap: () => onSelect(general, especifica['value']),
                                      ),
                                    ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  )
                  : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
