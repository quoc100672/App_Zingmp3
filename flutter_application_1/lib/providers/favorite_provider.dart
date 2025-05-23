import 'package:flutter/material.dart';
import '../models/song.dart';

class FavoriteProvider extends ChangeNotifier {
  List<Song> _favorites = [];

  List<Song> get favorites => _favorites;

  void addToFavorites(Song song) {
    if (!_favorites.any((s) => s.id == song.id)) {
      _favorites.add(song);
      notifyListeners();
    }
  }

  void removeFromFavorites(Song song) {
    _favorites.removeWhere((s) => s.id == song.id);
    notifyListeners();
  }

  bool isFavorite(Song song) {
    return _favorites.any((s) => s.id == song.id);
  }
}
