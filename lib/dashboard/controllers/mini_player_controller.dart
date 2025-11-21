import 'package:flutter/material.dart';
import '../models/radio_model.dart';

class MiniPlayerController with ChangeNotifier {
  bool _isExpanded = false;
  RadioModel? _selectedPodcast;

  bool get isExpanded => _isExpanded;
  RadioModel? get selectedPodcast => _selectedPodcast;

  void expand({RadioModel? podcast}) {
    _isExpanded = true;
    if (podcast != null) {
      _selectedPodcast = podcast;
    }
    notifyListeners();
  }

  void collapse() {
    _isExpanded = false;
    _selectedPodcast = null;
    notifyListeners();
  }

  void toggle({RadioModel? podcast}) {
    if (_isExpanded) {
      collapse();
    } else {
      expand(podcast: podcast);
    }
  }
}