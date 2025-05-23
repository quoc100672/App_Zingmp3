import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/song.dart';
import '../providers/music_provider.dart';
import 'package:share_plus/share_plus.dart';

class PlayerScreen extends StatefulWidget {
  final Song song;

  const PlayerScreen({Key? key, required this.song}) : super(key: key);

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final musicProvider = Provider.of<MusicProvider>(context, listen: false);
      musicProvider.playSong(widget.song);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đang phát'),
        centerTitle: true,
      ),
      body: Consumer<MusicProvider>(
        builder: (context, musicProvider, child) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Album art
              Container(
                width: 300,
                height: 300,
                margin: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 5,
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                  image: DecorationImage(
                    image: widget.song.coverUrl != null
                      ? NetworkImage(widget.song.coverUrl!)
                      : const AssetImage('assets/images/song_1.jpg') as ImageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              // Song info
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Text(
                      widget.song.title,
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.song.artist,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // Progress bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Slider(
                      value: musicProvider.position.inSeconds.toDouble(),
                      min: 0,
                      max: musicProvider.duration?.inSeconds.toDouble() ?? 0.0,
                      onChanged: (value) {
                        musicProvider.seek(Duration(seconds: value.toInt()));
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_formatDuration(musicProvider.position)),
                        Text(_formatDuration(musicProvider.duration ?? Duration.zero)),
                      ],
                    ),
                  ],
                ),
              ),

              // Control buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: Icon(
                      musicProvider.isShuffle ? Icons.shuffle : Icons.shuffle_outlined,
                      size: 30,
                    ),
                    onPressed: musicProvider.toggleShuffle,
                  ),
                  IconButton(
                    icon: const Icon(Icons.skip_previous, size: 45),
                    onPressed: musicProvider.previousSong,
                  ),
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).primaryColor,
                    ),
                    child: IconButton(
                      icon: Icon(
                        musicProvider.isPlaying ? Icons.pause : Icons.play_arrow,
                        size: 45,
                        color: Colors.white,
                      ),
                      onPressed: musicProvider.togglePlay,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.skip_next, size: 45),
                    onPressed: musicProvider.nextSong,
                  ),
                  IconButton(
                    icon: Icon(
                      musicProvider.isLooping ? Icons.repeat_one : Icons.repeat,
                      size: 30,
                    ),
                    onPressed: musicProvider.toggleLoop,
                  ),
                ],
              ),

              // Additional controls
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: Icon(
                      musicProvider.isFavorite(widget.song)
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: musicProvider.isFavorite(widget.song)
                          ? Colors.red
                          : null,
                    ),
                    onPressed: () => musicProvider.toggleFavorite(widget.song),
                  ),
                  IconButton(
                    icon: const Icon(Icons.playlist_add),
                    onPressed: () => _showAddToPlaylistDialog(context),
                  ),
                  IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: () {
                      Share.share(
                        'Đang nghe ${widget.song.title} - ${widget.song.artist}',
                      );
                    },
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  void _showAddToPlaylistDialog(BuildContext context) {
    // TODO: Implement add to playlist dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm vào playlist'),
        content: const Text('Tính năng đang được phát triển'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }
}
