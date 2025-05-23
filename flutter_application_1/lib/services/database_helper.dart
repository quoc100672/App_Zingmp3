import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/song.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('music_app.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE favorites(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        artist TEXT NOT NULL,
        album TEXT,
        duration INTEGER NOT NULL,
        url TEXT NOT NULL,
        coverImage TEXT,
        genre TEXT,
        createdAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE playlists(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE playlist_songs(
        playlistId INTEGER,
        songId TEXT,
        addedAt TEXT NOT NULL,
        FOREIGN KEY (playlistId) REFERENCES playlists (id) ON DELETE CASCADE,
        FOREIGN KEY (songId) REFERENCES favorites (id) ON DELETE CASCADE,
        PRIMARY KEY (playlistId, songId)
      )
    ''');
  }

  // Favorites operations
  Future<bool> addToFavorites(Song song) async {
    try {
      final db = await database;
      await db.insert('favorites', song.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace);
      return true;
    } catch (e) {
      print('Error adding to favorites: $e');
      return false;
    }
  }

  Future<bool> removeFromFavorites(String songId) async {
    try {
      final db = await database;
      await db.delete(
        'favorites',
        where: 'id = ?',
        whereArgs: [songId],
      );
      return true;
    } catch (e) {
      print('Error removing from favorites: $e');
      return false;
    }
  }

  Future<List<Song>> getFavorites() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query('favorites');
      return List.generate(maps.length, (i) => Song.fromJson(maps[i]));
    } catch (e) {
      print('Error getting favorites: $e');
      return [];
    }
  }

  Future<bool> isFavorite(String songId) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'favorites',
        where: 'id = ?',
        whereArgs: [songId],
      );
      return maps.isNotEmpty;
    } catch (e) {
      print('Error checking favorite status: $e');
      return false;
    }
  }

  // Playlist operations
  Future<int> createPlaylist(String name) async {
    try {
      final db = await database;
      final Map<String, dynamic> playlist = {
        'name': name,
        'createdAt': DateTime.now().toIso8601String(),
      };
      return await db.insert('playlists', playlist);
    } catch (e) {
      print('Error creating playlist: $e');
      return -1;
    }
  }

  Future<bool> addSongToPlaylist(int playlistId, Song song) async {
    try {
      final db = await database;
      // First ensure the song is in favorites
      await addToFavorites(song);
      // Then add to playlist
      await db.insert(
        'playlist_songs',
        {
          'playlistId': playlistId,
          'songId': song.id,
          'addedAt': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return true;
    } catch (e) {
      print('Error adding song to playlist: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getPlaylists() async {
    try {
      final db = await database;
      return await db.query('playlists');
    } catch (e) {
      print('Error getting playlists: $e');
      return [];
    }
  }

  Future<List<Song>> getPlaylistSongs(int playlistId) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT f.* FROM favorites f
        INNER JOIN playlist_songs ps ON f.id = ps.songId
        WHERE ps.playlistId = ?
        ORDER BY ps.addedAt DESC
      ''', [playlistId]);
      return List.generate(maps.length, (i) => Song.fromJson(maps[i]));
    } catch (e) {
      print('Error getting playlist songs: $e');
      return [];
    }
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
} 