import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import '../services/api_service.dart';
import '../models/song.dart';

class MusicProvider with ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final ApiService _apiService = ApiService();
  
  List<Song> _songs = [];
  List<Song> get songs => _songs;
  
  Song? _currentSong;
  Song? get currentSong => _currentSong;

  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;

  bool _isShuffle = false;
  bool get isShuffle => _isShuffle;

  bool _isLooping = false;
  bool get isLooping => _isLooping;

  List<Song> _favorites = [];
  List<Song> get favorites => _favorites;

  Duration get position => _audioPlayer.position;
  Duration? get duration => _audioPlayer.duration;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  final Random _random = Random();

  MusicProvider() {
    _audioPlayer.playerStateStream.listen((state) {
      _isPlaying = state.playing;
      notifyListeners();
    });

    _audioPlayer.positionStream.listen((_) {
      notifyListeners();
    });

    _audioPlayer.durationStream.listen((_) {
      notifyListeners();
    });

    loadSongs();
  }

  Future<void> loadSongs() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _songs = await _apiService.fetchSongs();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  // Play control methods
  Future<void> togglePlay() async {
    if (_currentSong == null) return;
    
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
        _isPlaying = false;
      } else {
        await _audioPlayer.play();
        _isPlaying = true;
      }
      notifyListeners();
    } catch (e) {
      print('Error toggling play: $e');
      _error = e.toString();
      notifyListeners();
    }
  }

  void toggleShuffle() {
    _isShuffle = !_isShuffle;
    _audioPlayer.setShuffleModeEnabled(_isShuffle);
    notifyListeners();
  }

  void toggleLoop() {
    _isLooping = !_isLooping;
    _audioPlayer.setLoopMode(_isLooping ? LoopMode.one : LoopMode.off);
    notifyListeners();
  }

  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  Future<void> nextSong() async {
    if (_currentSong == null || _songs.isEmpty) return;

    try {
      int currentIndex = _songs.indexOf(_currentSong!);
      if (_isShuffle) {
        int nextIndex;
        do {
          nextIndex = _random.nextInt(_songs.length);
        } while (nextIndex == currentIndex && _songs.length > 1);
        await playSong(_songs[nextIndex]);
      } else {
        int nextIndex = (currentIndex + 1) % _songs.length;
        await playSong(_songs[nextIndex]);
      }
    } catch (e) {
      print('Error playing next song: $e');
    }
  }

  Future<void> previousSong() async {
    if (_currentSong == null || _songs.isEmpty) return;

    try {
      int currentIndex = _songs.indexOf(_currentSong!);
      if (_isShuffle) {
        int prevIndex;
        do {
          prevIndex = _random.nextInt(_songs.length);
        } while (prevIndex == currentIndex && _songs.length > 1);
        await playSong(_songs[prevIndex]);
      } else {
        int prevIndex = (currentIndex - 1 + _songs.length) % _songs.length;
        await playSong(_songs[prevIndex]);
      }
    } catch (e) {
      print('Error playing previous song: $e');
    }
  }

  Future<void> playSong(Song song) async {
    try {
      _currentSong = song;
      print('Playing song: ${song.title} - URL: ${song.url}');
      
      // Reset position when playing new song
      _audioPlayer.stop();
      
      await _audioPlayer.setUrl(song.url);
      await _audioPlayer.play();
      _isPlaying = true;
      notifyListeners();
    } catch (e) {
      print('Error playing song: $e');
      _error = e.toString();
      notifyListeners();
    }
  }

  void pauseSong() {
    _isPlaying = false;
    notifyListeners();
  }

  void resumeSong() {
    if (_currentSong != null) {
      _isPlaying = true;
      notifyListeners();
    }
  }

  void stopSong() {
    _currentSong = null;
    _isPlaying = false;
    notifyListeners();
  }

  // Favorite methods
  bool isFavorite(Song song) {
    return _favorites.any((s) => s.id == song.id);
  }

  void toggleFavorite(Song song) {
    if (isFavorite(song)) {
      _favorites.removeWhere((s) => s.id == song.id);
    } else {
      _favorites.add(song);
    }
    notifyListeners();
  }

  // CRUD operations
  Future<bool> addSong(Song song) async {
    try {
      final success = await _apiService.addSong(song);
      if (success) {
        _songs.add(song);
        notifyListeners();
      }
      return success;
    } catch (e) {
      print('Error adding song: $e');
      return false;
    }
  }

  Future<bool> deleteSong(String id) async {
    try {
      final success = await _apiService.deleteSong(id);
      if (success) {
        _songs.removeWhere((song) => song.id == id);
        if (_currentSong?.id == id) {
          _currentSong = null;
          await _audioPlayer.stop();
        }
        notifyListeners();
      }
      return success;
    } catch (e) {
      print('Error deleting song: $e');
      return false;
    }
  }

  Future<void> searchSongs(String query) async {
    try {
      _isLoading = true;
      notifyListeners();

      if (query.isEmpty) {
        await loadSongs();
      } else {
        _songs = await _apiService.searchSongs(query);
        notifyListeners();
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error searching songs: $e');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshSongs() async {
    await loadSongs();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void setCurrentSong(Song song) {
    _currentSong = song;
    _isPlaying = true;
    notifyListeners();
  }

  void togglePlayPause() {
    if (_currentSong != null) {
      _isPlaying = !_isPlaying;
      notifyListeners();
    }
  }

  void stopPlaying() {
    _isPlaying = false;
    notifyListeners();
  }
} 