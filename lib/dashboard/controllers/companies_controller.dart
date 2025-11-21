import 'wp_api_controller.dart';
import '../models/wp_api_model.dart';

class CompaniesController extends WpApiController {
  CompaniesController() : super('companies');

  String? _selectedCategory;
  String? get selectedCategory => _selectedCategory;

  List<String> get categories {
    final allFields = items
        .map((e) => e.acf['company_field'] ?? '')
        .where((f) => f.toString().isNotEmpty);
    return allFields.toSet().cast<String>().toList()..sort();
  }

  List<WpItem> get filteredItems {
    if (_selectedCategory == null) return items;
    return items.where((item) => item.acf['company_field'] == _selectedCategory).toList();
  }

  void selectCategory(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }
}

extension CompaniesPriorityExtension on CompaniesController {
  List<WpItem> get priorityCompanies {
    final filtered = items.where((item) => item.acf['company_priority'] == true).toList();
    filtered.shuffle();
    return filtered.take(6).toList();
  }
}

extension CompaniesCategoryExtension on CompaniesController {
  // Devuelve un Map<general, List<especifica>>
  Map<String, List<Map<String, String>>> get groupedCategories {
    final Map<String, List<Map<String, String>>> result = {};
    for (final item in items) {
      final field = item.acf['company_field'];
      if (field is Map && field['value'] != null && field['label'] != null) {
        final value = field['value'] as String;
        final label = field['label'] as String;
        final parts = value.split('/');
        if (parts.length == 2) {
          final general = parts[0].replaceAll('_', ' ').toUpperCase();
          final especifica = parts[1].replaceAll('_', ' ').toUpperCase();
          result.putIfAbsent(general, () => []);
          result[general]!.add({'value': value, 'label': label, 'especifica': especifica});
        }
      }
    }
    // Elimina duplicados en especificas
    result.updateAll((key, list) {
      final seen = <String>{};
      return list.where((e) => seen.add(e['value']!)).toList();
    });
    return result;
  }

  // Devuelve la lista de generales
  List<String> get generalCategories => groupedCategories.keys.toList()..sort();

  // Devuelve la lista de especificas para una general
  List<Map<String, String>> especificasForGeneral(String general) =>
      groupedCategories[general] ?? [];

  // Devuelve los items de una categoria especifica (por value)
  List<WpItem> itemsForEspecifica(String value) =>
      items.where((item) => item.acf['company_field']?['value'] == value).toList();
}

extension CompaniesSearchExtension on CompaniesController {
  List<WpItem> searchByName(String query) {
    final lowerQuery = query.toLowerCase();
    return items.where((item) {
      final title = item.title.toLowerCase();
      return title.contains(lowerQuery);
    }).toList();
  }
}
