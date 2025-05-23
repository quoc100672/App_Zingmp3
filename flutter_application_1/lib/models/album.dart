import 'song.dart';

class Album {
  final String id;
  final String name;
  final String artist;         // Tên nghệ sĩ/ban nhạc/ca sĩ
  final String description;
  final String coverUrl;
  final List<Song> songs;

  Album({
    required this.id,
    required this.name,
    required this.artist,
    required this.description,
    required this.coverUrl,
    required this.songs,
  });

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      id: json['id'],
      name: json['name'],
      artist: json['artist'],
      description: json['description'] ?? '',
      coverUrl: json['coverUrl'] ?? '',
      songs: json['songs'] != null
          ? List<Song>.from(
              (json['songs'] as List).map((x) => Song.fromJson(x)),
            )
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'artist': artist,
      'description': description,
      'coverUrl': coverUrl,
      'songs': songs.map((x) => x.toJson()).toList(),
    };
  }
}
