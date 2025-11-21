import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/wp_api_model.dart';
import 'ad_manager.dart';

class AdsController extends ChangeNotifier {
  static const String baseUrl = 'https://maroon-ibis-412710.hostingersite.com/wp-json/api/';
  final String endpoint = 'ads';
  static const String params = '?per_page=100';

  List<WpItem> _items = [];
  bool _isLoading = false;

  late final String fullUrl = '$baseUrl$endpoint$params';
  AdManager? _adManager;

  List<WpItem> get items => _items;
  bool get isLoading => _isLoading;

  Future<void> fetchItems() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse(fullUrl));
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        _items = jsonData.map((json) => WpItem.fromJson(json)).toList();
        _adManager = AdManager(_items);
      } else {}
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<WpItem> getUniqueAds([int count = 3]) {
    return _adManager?.getUniqueAds(count) ?? [];
  }

  void resetAdSelection() {
    _adManager?.reset();
  }
}
