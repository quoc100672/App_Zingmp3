import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/music_provider.dart';
import '../widgets/song_tile.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({Key? key}) : super(key: key);

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thư viện'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Playlist'),
            Tab(text: 'Yêu thích'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPlaylistTab(),
          _buildFavoritesTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCreatePlaylistDialog();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildPlaylistTab() {
    return ListView(
      children: [
        ListTile(
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.favorite, color: Colors.white),
          ),
          title: const Text('Bài hát yêu thích'),
          subtitle: Text(
            '${context.watch<MusicProvider>().favorites.length} bài hát',
          ),
          onTap: () {
            // TODO: Navigate to favorites playlist
          },
        ),
        const Divider(),
        // TODO: Add list of user-created playlists
      ],
    );
  }

  Widget _buildFavoritesTab() {
    return Consumer<MusicProvider>(
      builder: (context, musicProvider, child) {
        final favorites = musicProvider.favorites;

        if (favorites.isEmpty) {
          return const Center(
            child: Text('Chưa có bài hát yêu thích'),
          );
        }

        return ListView.builder(
          itemCount: favorites.length,
          itemBuilder: (context, index) {
            final song = favorites[index];
            return SongTile(
              song: song,
              isPlaying: song == musicProvider.currentSong,
              onTap: () {
                musicProvider.playSong(song);
              },
            );
          },
        );
      },
    );
  }

  void _showCreatePlaylistDialog() {
    final TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tạo playlist mới'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Tên playlist',
            hintText: 'Nhập tên playlist',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Create new playlist
              Navigator.pop(context);
            },
            child: const Text('Tạo'),
          ),
        ],
      ),
    );
  }
} 