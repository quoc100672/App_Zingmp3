import 'package:flutter/material.dart';
import '../models/song.dart';
import '../screens/player_screen.dart';

class SongTile extends StatelessWidget {
  final Song song;
  final bool isPlaying;
  final VoidCallback? onTap;

  const SongTile({
    Key? key,
    required this.song,
    this.isPlaying = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: song.coverUrl != null
          ? NetworkImage(song.coverUrl!)
          : const AssetImage('assets/images/song_1.jpg') as ImageProvider,
      ),
      title: Text(
        song.title,
        style: TextStyle(
          fontWeight: isPlaying ? FontWeight.bold : FontWeight.normal,
          color: isPlaying ? Theme.of(context).primaryColor : null,
        ),
      ),
      subtitle: Text(song.artist),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isPlaying)
            Icon(
              Icons.equalizer,
              color: Theme.of(context).primaryColor,
            ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              _handleMenuSelection(context, value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'play',
                child: Row(
                  children: [
                    Icon(Icons.play_arrow),
                    SizedBox(width: 8),
                    Text('Phát'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'playlist',
                child: Row(
                  children: [
                    Icon(Icons.playlist_add),
                    SizedBox(width: 8),
                    Text('Thêm vào playlist'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'favorite',
                child: Row(
                  children: [
                    Icon(Icons.favorite_border),
                    SizedBox(width: 8),
                    Text('Thêm vào yêu thích'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'share',
                child: Row(
                  children: [
                    Icon(Icons.share),
                    SizedBox(width: 8),
                    Text('Chia sẻ'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      onTap: () {
        if (onTap != null) {
          onTap!();
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PlayerScreen(song: song),
            ),
          );
        }
      },
    );
  }

  void _handleMenuSelection(BuildContext context, String value) {
    switch (value) {
      case 'play':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlayerScreen(song: song),
          ),
        );
        break;
      case 'playlist':
        // TODO: Implement add to playlist
        break;
      case 'favorite':
        // TODO: Implement add to favorites
        break;
      case 'share':
        // TODO: Implement share functionality
        break;
    }
  }
} 