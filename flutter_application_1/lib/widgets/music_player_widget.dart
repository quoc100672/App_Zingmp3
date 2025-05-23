import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/music_provider.dart';
import '../models/song.dart';
import '../screens/player_screen.dart';

class MusicPlayerWidget extends StatelessWidget {
  const MusicPlayerWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final musicProvider = context.watch<MusicProvider>();
    final Song? song = musicProvider.currentSong;
    final bool isPlaying = musicProvider.isPlaying;

    if (song == null) return SizedBox.shrink();

    return GestureDetector(
      onTap: () {
        // Mở màn hình Player chi tiết
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PlayerScreen()),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.deepPurple.shade50,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.deepPurple.withOpacity(0.08),
              blurRadius: 10,
              offset: Offset(0, 2),
            )
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                song.coverUrl,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Icon(Icons.music_note, size: 32, color: Colors.deepPurple),
              ),
            ),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(song.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 2),
                  Text(song.artist,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                color: Colors.deepPurple,
                size: 36,
              ),
              onPressed: () {
                if (isPlaying) {
                  musicProvider.pause();
                } else {
                  musicProvider.resume();
                }
              },
            ),
            SizedBox(width: 2),
            IconButton(
              icon: Icon(Icons.close, color: Colors.deepPurple),
              onPressed: () {
                musicProvider.stop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
