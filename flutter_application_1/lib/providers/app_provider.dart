import 'package:flutter/material.dart';
import '../models/song.dart';
import '../services/song_service.dart';
import '../services/storage_service.dart';

class AppProvider with ChangeNotifier {
  final SongService _songService = SongService();
  final StorageService _storageService = StorageService.instance;
  
  List<Song> _allSongs = [];
  List<Song> _filteredSongs = [];
  List<Song> _favorites = [];
  bool _isLoading = false;
  String? _error;
  String _currentGenre = 'All';

  // Getters
  List<Song> get allSongs => _allSongs;
  List<Song> get filteredSongs => _filteredSongs;
  List<Song> get favorites => _favorites;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get currentGenre => _currentGenre;

  AppProvider() {
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      await _storageService.init();
      await loadSongs();
      await loadFavorites();
    } catch (e) {
      print('Error initializing data: $e');
      _error = 'Failed to initialize app: $e';
      notifyListeners();
    }
  }

  Future<void> loadSongs() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      print('Loading songs from service...');
      _allSongs = await _songService.getAllSongs();
      print('Loaded ${_allSongs.length} songs');
      _filteredSongs = _allSongs;
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error loading songs: $e');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadFavorites() async {
    try {
      _favorites = await _storageService.getFavorites();
      notifyListeners();
    } catch (e) {
      print('Error loading favorites: $e');
    }
  }

  void filterSongs(String query) {
    if (query.isEmpty) {
      _filteredSongs = _allSongs;
    } else {
      _filteredSongs = _allSongs.where((song) {
        return song.title.toLowerCase().contains(query.toLowerCase()) ||
            song.artist.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
    notifyListeners();
  }

  Future<void> filterByGenre(String genre) async {
    try {
      _isLoading = true;
      _currentGenre = genre;
      notifyListeners();

      if (genre == 'All') {
        _filteredSongs = _allSongs;
      } else {
        _filteredSongs = await _songService.getSongsByGenre(genre);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(Song song) async {
    try {
      final isFavorite = await _storageService.isFavorite(song.id);
      if (isFavorite) {
        await _storageService.removeFromFavorites(song.id);
        _favorites.removeWhere((s) => s.id == song.id);
      } else {
        await _storageService.addToFavorites(song);
        _favorites.add(song);
      }
      notifyListeners();
    } catch (e) {
      print('Error toggling favorite: $e');
    }
  }

  Future<bool> isFavorite(String songId) async {
    return await _storageService.isFavorite(songId);
  }

  @override
  void dispose() {
    _songService.dispose();
    super.dispose();
  }
} 