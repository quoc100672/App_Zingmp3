import 'package:mongo_dart/mongo_dart.dart';

class Song {
  final String id;
  final String title;
  final String artist;
  final String url;
  final String? imageUrl;
  final String? duration;

  Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.url,
    this.imageUrl,
    this.duration,
  });

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      artist: json['artist'] ?? '',
      url: json['url'] ?? '',
      imageUrl: json['imageUrl'],
      duration: json['duration']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'artist': artist,
      'url': url,
      'imageUrl': imageUrl,
      'duration': duration,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': ObjectId.parse(id),
      'title': title,
      'artist': artist,
      'url': url,
      'imageUrl': imageUrl,
      'duration': duration,
    };
  }

  factory Song.fromMap(Map<String, dynamic> map) {
    return Song(
      id: (map['_id'] as ObjectId).toHexString(),
      title: map['title'] as String,
      artist: map['artist'] as String,
      url: map['url'] as String,
      imageUrl: map['imageUrl'] as String?,
      duration: map['duration']?.toString(),
    );
  }

  Song copyWith({
    String? id,
    String? title,
    String? artist,
    String? url,
    String? imageUrl,
    String? duration,
  }) {
    return Song(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      url: url ?? this.url,
      imageUrl: imageUrl ?? this.imageUrl,
      duration: duration ?? this.duration,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Song &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  // Backward compatibility getters
  String? get coverUrl => imageUrl;
  String get coverImage => imageUrl ?? '';
  String? get album => null;
  String? get genre => null;
  DateTime get createdAt => DateTime.now();
}
