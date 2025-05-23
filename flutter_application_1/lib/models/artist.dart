class Artist {
  final String id;
  final String name;
  final String avatarUrl;     // Ảnh đại diện ca sĩ
  final String bio;           // Mô tả, giới thiệu
  final List<String> genres;  // Thể loại nhạc nghệ sĩ chơi (Pop, EDM, Ballad,...)
  final String? country;      // Quốc gia, có thể null

  Artist({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.bio,
    required this.genres,
    this.country,
  });

  factory Artist.fromJson(Map<String, dynamic> json) {
    return Artist(
      id: json['id'],
      name: json['name'],
      avatarUrl: json['avatarUrl'] ?? '',
      bio: json['bio'] ?? '',
      genres: json['genres'] != null
          ? List<String>.from(json['genres'])
          : [],
      country: json['country'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatarUrl': avatarUrl,
      'bio': bio,
      'genres': genres,
      'country': country,
    };
  }
}
