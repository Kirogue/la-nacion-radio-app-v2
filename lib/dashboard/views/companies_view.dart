import 'package:flutter/material.dart';
import 'package:la_nacion/dashboard/models/wp_api_model.dart';
import 'package:la_nacion/utils/responsive_values.dart';
import 'package:la_nacion/widgets/companies/company_ad_banner.dart';
import 'package:la_nacion/widgets/content_section.dart';
import 'package:la_nacion/widgets/custom_wrapper.dart';
import 'package:la_nacion/widgets/loading_icon.dart';
import 'package:provider/provider.dart';
import '../controllers/companies_controller.dart';
import 'package:la_nacion/widgets/companies/companies_category_select.dart';
import 'package:la_nacion/dashboard/controllers/navigation_controller.dart';
import '../../widgets/universal_search.dart';

class CompaniesView extends StatefulWidget {
  const CompaniesView({super.key});
  @override
  State<CompaniesView> createState() => _CompaniesViewState();
}

class _CompaniesViewState extends State<CompaniesView> with AutomaticKeepAliveClientMixin {
  String? selectedGeneral;
  String? selectedEspecificaValue;
  bool showCategoryList = false;
  int previousTabIndex = -1;
  late NavigationController navController;
  List<WpItem>? searchResults;
  String searchQuery = '';

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    navController = Provider.of<NavigationController>(context, listen: false);
    previousTabIndex = navController.currentIndex;
    navController.addListener(_handleTabChange);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.microtask(() {
        if (!mounted) {
          return;
        }
        Provider.of<CompaniesController>(context, listen: false).fetchItems();
      });
    });
  }

  void _handleTabChange() {
    final newIndex = navController.currentIndex;
    if (mounted && showCategoryList && newIndex != previousTabIndex) {
      setState(() => showCategoryList = false);
    }
    previousTabIndex = newIndex;
  }

  @override
  void dispose() {
    navController.removeListener(_handleTabChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final controller = Provider.of<CompaniesController>(context);
    final isLoading = controller.isLoading;
    final grouped = controller.groupedCategories;
    final generalCategories = controller.generalCategories;

    final top = MediaQuery.of(context).padding.top;

    if (isLoading) {
      return Center(child: LoadingIcon(padding: EdgeInsets.only(top: top), size: 40));
    }

    // --- Generar las secciones de companies según la selección ---
    List<Widget> companySections = [];

    if (searchResults != null) {
      if (searchResults!.isEmpty) {
        companySections.add(
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'No se encontraron empresas con "$searchQuery"',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        );
      } else {
        companySections.add(
          ContentSection(
            title: 'Empresas encontradas por "$searchQuery"',
            routeName: 'companies',
            items: searchResults,
            showSeeMoreButton: false,
          ),
        );
      }
    } else {
      if (selectedEspecificaValue != null && selectedGeneral != null) {
        // Solo una sección para la específica seleccionada
        final especifica = grouped[selectedGeneral!]?.firstWhere(
          (e) => e['value'] == selectedEspecificaValue,
          orElse: () => {},
        );
        final title = especifica?['especifica'] ?? especifica?['label'] ?? '';
        final items = controller.itemsForEspecifica(selectedEspecificaValue!);
        companySections.add(
          ContentSection(
            title: title,
            routeName: 'companies',
            items: items,
            showSeeMoreButton: false,
          ),
        );
      } else if (selectedGeneral != null) {
        // Una sección por cada específica de la general seleccionada
        final especificas = controller.especificasForGeneral(selectedGeneral!);
        for (final especifica in especificas) {
          final items = controller.itemsForEspecifica(especifica['value']!);
          companySections.add(
            ContentSection(
              title: especifica['especifica'] ?? especifica['label'] ?? '',
              routeName: 'companies',
              items: items,
              showSeeMoreButton: false,
            ),
          );
        }
      } else {
        // Mostrar todas las companies prioritarias y todas las categorías específicas
        companySections.add(
          ContentSection(
            title: 'EMPRESAS DESTACADAS',
            routeName: 'companies',
            showOnlyPriority: true,
            showSeeMoreButton: false,
          ),
        );
        final allEspecificas = controller.groupedCategories.values.expand((list) => list).toList();
        for (final especifica in allEspecificas) {
          final items = controller.itemsForEspecifica(especifica['value']!);
          companySections.add(
            ContentSection(
              title: especifica['especifica'] ?? especifica['label'] ?? '',
              routeName: 'companies',
              items: items,
              showSeeMoreButton: false,
            ),
          );
        }
      }
    }

    return Scaffold(
      body: GestureDetector(
        onTap: () {
          if (showCategoryList) {
            setState(() => showCategoryList = false);
          }
          FocusScope.of(context).unfocus();
        },
        behavior: HitTestBehavior.translucent,
        child: SingleChildScrollView(
          child: ContentWrapper(
            child: Column(
              children: [
                CompanyAdBanner(),
                UniversalSearchWidget(
                  searchType: SearchType.companies,
                  onItemTap: (results, query) {
                    setState(() {
                      searchQuery = query;
                      selectedGeneral = null;
                      selectedEspecificaValue = null;

                      if (query.isEmpty) {
                        searchResults = null; // <-- vuelve a mostrar las categorías normales
                      } else {
                        searchResults = results?.cast<WpItem>();
                      }
                    });
                  },
                ),

                Container(
                  margin: responsiveValue<EdgeInsets>(
                    context,
                    mobile: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    tablet: const EdgeInsets.symmetric(horizontal: 48, vertical: 8),
                  ),
                  child: CategorySelect(
                    generalCategories: generalCategories,
                    selectedGeneral: selectedGeneral,
                    selectedEspecificaValue: selectedEspecificaValue,
                    groupedCategories: grouped,
                    expanded: showCategoryList,
                    onTap: () => setState(() => showCategoryList = !showCategoryList),
                    onSelect: (general, especificaValue) {
                      setState(() {
                        selectedGeneral = general;
                        selectedEspecificaValue = especificaValue;
                        showCategoryList = false;
                      });
                    },
                  ),
                ),
                ...companySections,

                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
