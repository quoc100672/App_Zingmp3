import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/song.dart';

class StorageService {
  static final StorageService instance = StorageService._init();
  static const String favoritesKey = 'favorites';
  static const String playlistsKey = 'playlists';

  StorageService._init();

  Future<void> init() async {
    // Initialize any required setup
    await SharedPreferences.getInstance();
  }

  // Favorites operations
  Future<bool> addToFavorites(Song song) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favorites = await getFavorites();
      favorites.add(song);
      
      final List<String> encodedSongs = favorites.map((s) => _encodeSong(s)).toList();
      await prefs.setStringList(favoritesKey, encodedSongs);
      return true;
    } catch (e) {
      print('Error adding to favorites: $e');
      return false;
    }
  }

  Future<bool> removeFromFavorites(String songId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favorites = await getFavorites();
      favorites.removeWhere((s) => s.id == songId);
      
      final List<String> encodedSongs = favorites.map((s) => _encodeSong(s)).toList();
      await prefs.setStringList(favoritesKey, encodedSongs);
      return true;
    } catch (e) {
      print('Error removing from favorites: $e');
      return false;
    }
  }

  Future<List<Song>> getFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> encodedSongs = prefs.getStringList(favoritesKey) ?? [];
      return encodedSongs.map((s) => _decodeSong(s)).toList();
    } catch (e) {
      print('Error getting favorites: $e');
      return [];
    }
  }

  Future<bool> isFavorite(String songId) async {
    try {
      final favorites = await getFavorites();
      return favorites.any((s) => s.id == songId);
    } catch (e) {
      print('Error checking favorite status: $e');
      return false;
    }
  }

  // Playlist operations
  Future<int> createPlaylist(String name) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> playlists = await getPlaylists();
      final newId = playlists.isEmpty ? 1 : playlists.last['id'] + 1;
      
      playlists.add({
        'id': newId,
        'name': name,
        'createdAt': DateTime.now().toIso8601String(),
      });
      
      await prefs.setString(playlistsKey, _encodeList(playlists));
      return newId;
    } catch (e) {
      print('Error creating playlist: $e');
      return -1;
    }
  }

  Future<bool> addSongToPlaylist(int playlistId, Song song) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String key = 'playlist_$playlistId';
      final List<Song> songs = await getPlaylistSongs(playlistId);
      
      if (!songs.any((s) => s.id == song.id)) {
        songs.add(song);
        final List<String> encodedSongs = songs.map((s) => _encodeSong(s)).toList();
        await prefs.setStringList(key, encodedSongs);
      }
      
      return true;
    } catch (e) {
      print('Error adding song to playlist: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getPlaylists() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? encoded = prefs.getString(playlistsKey);
      if (encoded == null) return [];
      return _decodeList(encoded);
    } catch (e) {
      print('Error getting playlists: $e');
      return [];
    }
  }

  Future<List<Song>> getPlaylistSongs(int playlistId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String key = 'playlist_$playlistId';
      final List<String> encodedSongs = prefs.getStringList(key) ?? [];
      return encodedSongs.map((s) => _decodeSong(s)).toList();
    } catch (e) {
      print('Error getting playlist songs: $e');
      return [];
    }
  }

  // Helper methods for encoding/decoding
  String _encodeSong(Song song) {
    return '${song.id}|${song.title}|${song.artist}|${song.url}|${song.duration ?? ""}|${song.imageUrl ?? ""}';
  }

  Song _decodeSong(String encoded) {
    final parts = encoded.split('|');
    return Song(
      id: parts[0],
      title: parts[1],
      artist: parts[2],
      url: parts[3],
      duration: parts[4].isEmpty ? null : parts[4],
      imageUrl: parts[5].isEmpty ? null : parts[5],
    );
  }

  String _encodeList(List<Map<String, dynamic>> list) {
    return list.map((item) => '${item['id']}|${item['name']}|${item['createdAt']}').join(';');
  }

  List<Map<String, dynamic>> _decodeList(String encoded) {
    if (encoded.isEmpty) return [];
    return encoded.split(';').map((item) {
      final parts = item.split('|');
      return {
        'id': int.parse(parts[0]),
        'name': parts[1],
        'createdAt': parts[2],
      };
    }).toList();
  }
}
