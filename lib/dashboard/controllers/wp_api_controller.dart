import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/wp_api_model.dart';

// Función aislada para decodificar JSON en segundo plano
List<WpItem> _parseWpItems(String responseBody) {
  final List<dynamic> jsonData = json.decode(responseBody);
  return jsonData.map((json) => WpItem.fromJson(json)).toList();
}

class WpApiController extends ChangeNotifier {
  static const String baseUrl =
      'https://maroon-ibis-412710.hostingersite.com/wp-json/api/';

  final String endpoint;
  static const params = '?per_page=100';

  List<WpItem> _items = [];
  bool _isLoading = false;

  WpApiController(this.endpoint);

  List<WpItem> get items => _items;
  bool get isLoading => _isLoading;

  String get fullUrl => '$baseUrl$endpoint$params';

  Future<void> fetchItems() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse(fullUrl));
      if (response.statusCode == 200) {
        // OPTIMIZACIÓN: Usar compute para parsear JSON en un Isolate separado
        // Esto evita que la UI se congele mientras se procesan los datos.
        _items = await compute(_parseWpItems, response.body);
      } else {
        debugPrint('Error fetching items: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error in fetchItems: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
