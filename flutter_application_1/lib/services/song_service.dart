import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/song.dart';

class SongService {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:3000/api';
    } else {
      return 'http://10.0.2.2:3000/api';
    }
  }

  final http.Client _client = http.Client();

  // Get all songs
  Future<List<Song>> getAllSongs() async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/songs'),
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Song.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load songs: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load songs: $e');
    }
  }

  // Get song by ID
  Future<Song> getSongById(String id) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/songs/$id'),
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return Song.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load song: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load song: $e');
    }
  }

  // Search songs
  Future<List<Song>> searchSongs(String query) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/songs/search').replace(
          queryParameters: {'q': query},
        ),
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Song.fromJson(json)).toList();
      } else {
        throw Exception('Failed to search songs: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to search songs: $e');
    }
  }

  // Get songs by genre
  Future<List<Song>> getSongsByGenre(String genre) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/songs/genre/$genre'),
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Song.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load songs by genre: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load songs by genre: $e');
    }
  }

  void dispose() {
    _client.close();
  }
} 