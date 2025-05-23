import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../models/song.dart';

class PlayerProvider with ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  Song? _currentSong;
  List<Song> _playlist = [];
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  // Getters
  Song? get currentSong => _currentSong;
  List<Song> get playlist => _playlist;
  bool get isPlaying => _isPlaying;
  Duration get position => _position;
  Duration get duration => _duration;
  double get progress => duration.inSeconds > 0 
    ? position.inSeconds / duration.inSeconds 
    : 0;

  PlayerProvider() {
    _initAudioPlayer();
  }

  void _initAudioPlayer() {
    // Listen to player state changes
    _audioPlayer.playerStateStream.listen((state) {
      _isPlaying = state.playing;
      notifyListeners();
    });

    // Listen to position changes
    _audioPlayer.positionStream.listen((pos) {
      _position = pos;
      notifyListeners();
    });

    // Listen to duration changes
    _audioPlayer.durationStream.listen((dur) {
      _duration = dur ?? Duration.zero;
      notifyListeners();
    });
  }

  // Set playlist
  void setPlaylist(List<Song> songs) {
    _playlist = songs;
    notifyListeners();
  }

  // Play a specific song
  Future<void> playSong(Song song) async {
    if (_currentSong?.id != song.id) {
      _currentSong = song;
      await _audioPlayer.setUrl(song.url);
    }
    await _audioPlayer.play();
    notifyListeners();
  }

  // Play next song
  Future<void> playNext() async {
    if (_playlist.isEmpty || _currentSong == null) return;
    
    final currentIndex = _playlist.indexWhere((s) => s.id == _currentSong!.id);
    if (currentIndex < _playlist.length - 1) {
      await playSong(_playlist[currentIndex + 1]);
    }
  }

  // Play previous song
  Future<void> playPrevious() async {
    if (_playlist.isEmpty || _currentSong == null) return;
    
    final currentIndex = _playlist.indexWhere((s) => s.id == _currentSong!.id);
    if (currentIndex > 0) {
      await playSong(_playlist[currentIndex - 1]);
    }
  }

  // Pause playback
  Future<void> pause() async {
    await _audioPlayer.pause();
    notifyListeners();
  }

  // Resume playback
  Future<void> resume() async {
    await _audioPlayer.play();
    notifyListeners();
  }

  // Seek to position
  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
    notifyListeners();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
} 