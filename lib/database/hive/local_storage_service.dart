import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

final favoritesProvider = StateNotifierProvider<FavoritesNotifier, Set<String>>(
  (ref) {
    return FavoritesNotifier();
  },
);

class FavoritesNotifier extends StateNotifier<Set<String>> {
  final Box _favoritesBox = Hive.box('favorites');

  FavoritesNotifier() : super({}) {
    _loadFavorites();
  }

  void _loadFavorites() {
    final stored = _favoritesBox.get('items', defaultValue: <String>[]);
    state = Set<String>.from(stored);
  }

  void toggleFavorite(String itemId) {
    final current = Set<String>.from(state);
    if (current.contains(itemId)) {
      current.remove(itemId);
    } else {
      current.add(itemId);
    }
    state = current;
    _favoritesBox.put('items', state.toList());
  }

  bool isFavorite(String itemId) {
    return state.contains(itemId);
  }
}
