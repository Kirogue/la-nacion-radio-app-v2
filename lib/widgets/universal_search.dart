import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:la_nacion/dashboard/controllers/companies_controller.dart';
import 'package:la_nacion/dashboard/controllers/news_controller.dart';
import 'package:la_nacion/utils/responsive_values.dart';
import 'package:provider/provider.dart';

enum SearchType { news, companies, podcasts }

class UniversalSearchWidget extends StatefulWidget {
  final SearchType searchType;
  final String hint;
  final Function(dynamic results, String query)? onItemTap; // <-- dos parámetros

  const UniversalSearchWidget({
    super.key,
    required this.searchType,
    this.hint = '',
    this.onItemTap,
  });

  @override
  State<UniversalSearchWidget> createState() => _UniversalSearchWidgetState();
}

class _UniversalSearchWidgetState extends State<UniversalSearchWidget> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      constraints: BoxConstraints(maxWidth: 600),
      margin: responsiveValue<EdgeInsets>(
        context,
        mobile: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        tablet: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFD9D9D9),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.black, width: 1),
      ),
      child: TextField(
        controller: _controller,
        style: const TextStyle(color: Color(0xFF334369)),
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(14),
            child: SvgPicture.asset(
              'assets/icons/search.svg',
              colorFilter: ColorFilter.mode(Color(0xFF334369), BlendMode.srcIn),
            ),
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          fillColor: Colors.transparent,
          filled: false,
        ),
        onChanged: (value) {
          _performSearch(value);
        },
      ),
    );
  }

  void _performSearch(String query) {
    switch (widget.searchType) {
      case SearchType.news:
        _searchNews(query);
        break;
      case SearchType.companies:
        _searchCompanies(query);
        break;
      case SearchType.podcasts:
        _searchPodcasts(query);
        break;
    }

    if (widget.searchType == SearchType.companies && widget.onItemTap != null) {
      final controller = Provider.of<CompaniesController>(context, listen: false);
      final results = query.isEmpty ? null : controller.searchByName(query);
      widget.onItemTap!(results, query);
    }
  }

  void _searchNews(String query) {
    final controller = Provider.of<NewsController>(context, listen: false);
    final results = controller.searchByTitle(query);
    debugPrint('🔎 Query $query');
    for (final result in results) {
      debugPrint(result.title);
    }
    if (widget.onItemTap != null) {
      widget.onItemTap!(results, query);
    }
  }

  void _searchCompanies(String query) {
    final controller = Provider.of<CompaniesController>(context, listen: false);
    final results = controller.searchByName(query); // tu función de búsqueda
    if (widget.onItemTap != null) {
      widget.onItemTap!(results, query); // <-- pasar ambos
    }
  }

  void _searchPodcasts(String query) {
    // Implementar búsqueda en podcasts
    // final podcastController = Provider.of<PodcastController>(context, listen: false);
    // podcastController.searchPodcasts(query);
  }
}
