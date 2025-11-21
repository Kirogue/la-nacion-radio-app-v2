import '../models/wp_api_model.dart';

class AdManager {
  final List<WpItem> allAds;
  final Set<int> _shownAdIds = {};

  AdManager(this.allAds);

  List<WpItem> getUniqueAds(int count) {
    if (allAds.isEmpty) return [];

    final unused = allAds.where((ad) => !_shownAdIds.contains(ad.id)).toList()..shuffle();
    final selected = <WpItem>[];

    // Tomar los que no han sido mostrados
    selected.addAll(unused.take(count));

    // Si aún faltan, tomar de los usados (sin repetir dentro del mismo lote)
    if (selected.length < count) {
      final used = allAds.where((ad) => !_idsMatchAny(ad.id, selected)).toList()..shuffle();

      selected.addAll(used.take(count - selected.length));
    }

    _shownAdIds.addAll(selected.map((e) => e.id));
    return selected;
  }

  bool _idsMatchAny(int id, List<WpItem> items) {
    return items.any((e) => e.id == id);
  }

  void reset() => _shownAdIds.clear();
}
