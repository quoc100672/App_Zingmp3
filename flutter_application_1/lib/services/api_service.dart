import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/song.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiService {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:3000/api';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000/api';
    } else {
      return 'http://localhost:3000/api';
    }
  }
  
  static const Duration timeoutDuration = Duration(seconds: 10);

  // Get all songs
  static Future<List<Song>> getAllSongs() async {
    try {
      print('Fetching songs from: $baseUrl/songs');
      final response = await http.get(
        Uri.parse('$baseUrl/songs'),
      ).timeout(timeoutDuration);
      
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Song.fromJson(json)).toList();
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting songs: $e');
      if (e.toString().contains('TimeoutException')) {
        throw Exception('Connection timeout. Please check your internet connection and try again.');
      } else if (e.toString().contains('SocketException')) {
        throw Exception('Cannot connect to server. Please make sure the server is running.');
      }
      rethrow;
    }
  }

  // Get song by id
  static Future<Song> getSong(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/songs/$id'),
      ).timeout(timeoutDuration);
      
      if (response.statusCode == 200) {
        return Song.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load song: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting song: $e');
      if (e.toString().contains('TimeoutException')) {
        throw Exception('Connection timeout. Please check your internet connection and try again.');
      } else if (e.toString().contains('SocketException')) {
        throw Exception('Cannot connect to server. Please make sure the server is running.');
      }
      rethrow;
    }
  }

  // Add new song
  Future<bool> addSong(Song song) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/songs'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(song.toJson()),
      ).timeout(timeoutDuration);
      
      return response.statusCode == 201;
    } catch (e) {
      print('Error adding song: $e');
      return false;
    }
  }

  // Delete song
  Future<bool> deleteSong(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/songs/$id'),
      ).timeout(timeoutDuration);
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error deleting song: $e');
      return false;
    }
  }

  // Search songs
  Future<List<Song>> searchSongs(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/songs/search/$query'),
      ).timeout(timeoutDuration);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Song.fromJson(json)).toList();
      } else {
        throw Exception('Failed to search songs: ${response.statusCode}');
      }
    } catch (e) {
      print('Error searching songs: $e');
      if (e.toString().contains('TimeoutException')) {
        throw Exception('Connection timeout. Please check your internet connection and try again.');
      } else if (e.toString().contains('SocketException')) {
        throw Exception('Cannot connect to server. Please make sure the server is running.');
      }
      rethrow;
    }
  }

  Future<List<Song>> fetchSongs() async {
    try {
      print('Fetching songs from: $baseUrl/songs');
      final response = await http.get(
        Uri.parse('$baseUrl/songs'),
      ).timeout(timeoutDuration);
      
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        final songs = jsonData.map((json) => Song.fromJson(json)).toList();
        print('Successfully parsed ${songs.length} songs');
        return songs;
      } else {
        print('Error status code: ${response.statusCode}');
        throw Exception('Failed to load songs: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching songs: $e');
      if (e.toString().contains('SocketException')) {
        print('Network error - make sure backend is running and accessible');
      }
      throw Exception('Failed to connect to the server: $e');
    }
  }

  Future<Song> getSongById(String id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/songs/$id'));
      
      if (response.statusCode == 200) {
        return Song.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load song: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server: $e');
    }
  }

  Future<dynamic> get(String endpoint) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl$endpoint'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in ApiService.get: $e');
      throw Exception('Network error: $e');
    }
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to post data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in ApiService.post: $e');
      throw Exception('Network error: $e');
    }
  }
}