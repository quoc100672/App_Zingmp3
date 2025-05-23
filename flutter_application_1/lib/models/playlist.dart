import 'song.dart';

class Playlist {
  final String id;
  final String name;
  final String description;
  final String coverUrl;
  final List<Song> songs;  // Danh sách bài hát

  Playlist({
    required this.id,
    required this.name,
    required this.description,
    required this.coverUrl,
    required this.songs,
  });

  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      id: json['id'],
      name: json['name'],
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
      'description': description,
      'coverUrl': coverUrl,
      'songs': songs.map((x) => x.toJson()).toList(),
    };
  }
}
