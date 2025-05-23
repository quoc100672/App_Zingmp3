import 'api_service.dart';
import '../models/song.dart';

class MusicService {
  static Future<List<Song>> fetchSongs() async {
    final data = await ApiService.get('songs');
    return (data as List).map((json) => Song.fromJson(json)).toList();
  }

  static Future<List<Song>> searchSongs(String keyword) async {
    final data = await ApiService.get('songs/search?query=$keyword');
    return (data as List).map((json) => Song.fromJson(json)).toList();
  }
}
