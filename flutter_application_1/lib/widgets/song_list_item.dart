import 'package:flutter/material.dart';
import '../models/song.dart';

class SongListItem extends StatelessWidget {
  final Song song;
  final bool isPlaying;
  final VoidCallback onTap;

  const SongListItem({
    Key? key,
    required this.song,
    this.isPlaying = false,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 50,
        height: 50,
       decoration: BoxDecoration(
  image: DecorationImage(
    image: song.coverUrl != null
      ? NetworkImage(song.coverUrl!)
      : const AssetImage('assets/images/song_1.jpg') as ImageProvider,
    fit: BoxFit.cover,
  ),
),
      ),
      title: Text(
        song.title,
        style: TextStyle(
          fontWeight: isPlaying ? FontWeight.bold : FontWeight.normal,
          color: isPlaying ? Theme.of(context).primaryColor : null,
        ),
      ),
      subtitle: Text(song.artist),
      trailing: isPlaying
          ? Icon(
              Icons.equalizer,
              color: Theme.of(context).primaryColor,
            )
          : null,
      onTap: onTap,
    );
  }
}
