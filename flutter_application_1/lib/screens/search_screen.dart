import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/song.dart';
import '../providers/music_provider.dart';
import '../widgets/song_tile.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Tìm kiếm bài hát, nghệ sĩ...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.grey[400]),
          ),
          style: const TextStyle(color: Colors.white),
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<MusicProvider>(
              builder: (context, musicProvider, child) {
                final filteredSongs = musicProvider.songs
                    .where((song) =>
                        song.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                        song.artist.toLowerCase().contains(_searchQuery.toLowerCase()))
                    .toList();

                if (_searchQuery.isEmpty) {
                  return const Center(
                    child: Text('Nhập từ khóa để tìm kiếm'),
                  );
                }

                if (filteredSongs.isEmpty) {
                  return const Center(
                    child: Text('Không tìm thấy kết quả'),
                  );
                }

                return ListView.builder(
                  itemCount: filteredSongs.length,
                  itemBuilder: (context, index) {
                    final song = filteredSongs[index];
                    return SongTile(song: song);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
