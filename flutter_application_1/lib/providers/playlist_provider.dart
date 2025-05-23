import 'package:flutter/material.dart';
import '../models/song.dart';

class PlaylistProvider extends ChangeNotifier {
  Map<String, List<Song>> _playlists = {};
  
  Map<String, List<Song>> get playlists => _playlists;

  // Create a new playlist
  void createPlaylist(String name) {
    if (!_playlists.containsKey(name)) {
      _playlists[name] = [];
      notifyListeners();
    }
  }

  // Add song to playlist
  void addSongToPlaylist(String playlistName, Song song) {
    if (_playlists.containsKey(playlistName) && 
        !_playlists[playlistName]!.contains(song)) {
      _playlists[playlistName]!.add(song);
      notifyListeners();
    }
  }

  // Remove song from playlist
  void removeSongFromPlaylist(String playlistName, Song song) {
    if (_playlists.containsKey(playlistName)) {
      _playlists[playlistName]!.removeWhere((s) => s.id == song.id);
      notifyListeners();
    }
  }

  // Delete playlist
  void deletePlaylist(String name) {
    _playlists.remove(name);
    notifyListeners();
  }

  // Get songs in playlist
  List<Song> getPlaylistSongs(String name) {
    return _playlists[name] ?? [];
  }

  // Clear playlist
  void clearPlaylist(String name) {
    if (_playlists.containsKey(name)) {
      _playlists[name]!.clear();
      notifyListeners();
    }
  }
}
