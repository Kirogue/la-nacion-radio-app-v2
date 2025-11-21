/// Controlador de estado con ChangeNotifier
/// - Fetch desde Graph API
/// - Filtra solo videos
/// - Expuesta como Provider global
library;

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Config
import '../../config/env_constants.dart';

// Model
import '../models/reels_model.dart';

class ReelsController extends ChangeNotifier {
  List<Reel> _reels = [];
  bool _isLoading = false;
  String? _error;

  List<Reel> get reels => _reels;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void updateReels(List<Reel> newReels) {
    _reels = newReels;
    notifyListeners();
  }

  Future<void> fetchReels() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final base = 'https://graph.facebook.com/v23.0/${EnvConstants.instagramUserId}/media';
    final params =
        '?fields=id,media_type,media_url,thumbnail_url,caption,permalink,timestamp,owner{username,profile_picture_url}';
    final token = '&access_token=${EnvConstants.instagramAccessToken}';
    final url = Uri.parse(base + params + token);

    try {
      final resp = await http.get(url);

      if (resp.statusCode == 200) {
        final body = jsonDecode(resp.body);

        // Validar que haya 'data' y que sea lista
        if (body['data'] is List) {
          final List data = body['data'];

          _reels =
              data
                  .where((m) => m['media_type'] == 'VIDEO')
                  .map((json) => Reel.fromJson(json))
                  .toList();
        } else {
          _error = 'Respuesta inesperada: no se encontró lista "data".';
        }
      } else {
        final errorBody = jsonDecode(resp.body);
        _error =
            'Error HTTP ${resp.statusCode}: ${errorBody['error']?['message'] ?? 'Desconocido'}';
      }
    } catch (e) {
      _error = 'Excepción al obtener Reels: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
