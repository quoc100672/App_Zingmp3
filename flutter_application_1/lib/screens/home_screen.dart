import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../providers/player_provider.dart';
import '../theme/app_theme.dart';
import '../models/song.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final AuthService _authService = AuthService();
  String _username = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadUsername();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsername() async {
    final user = await _authService.getCurrentUser();
    if (user != null && mounted) {
      setState(() {
        _username = user.name;
      });
    }
  }

  void _onSearchChanged() {
    Provider.of<AppProvider>(context, listen: false)
        .filterSongs(_searchController.text);
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Consumer<AppProvider>(
          builder: (context, appProvider, child) {
            if (appProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (appProvider.error != null) {
              return _buildErrorWidget(appProvider);
            }

            return Column(
              children: [
                _buildHeader(),
                _buildSearchBar(),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => appProvider.loadSongs(),
                    child: ListView(
                      children: [
                        _buildCategories(appProvider),
                        _buildFeaturedSection(appProvider),
                        _buildAllSongs(appProvider),
                      ],
                    ),
                  ),
                ),
                _buildMiniPlayer(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hi $_username',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Text(
                'Beat that touch your heart',
                style: TextStyle(
                  color: AppTheme.textColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: AppTheme.textColor),
            onPressed: _logout,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: AppTheme.textColor),
        decoration: InputDecoration(
          hintText: "Let's find your song...",
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
          filled: true,
          fillColor: AppTheme.surfaceColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget(AppProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Error: ${provider.error}',
            style: const TextStyle(color: AppTheme.textColor),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: provider.loadSongs,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories(AppProvider provider) {
    final genres = ['All', 'Pop', 'Rock', 'Jazz', 'Classical', 'Hip Hop'];
    final colors = [
      Colors.blue,
      Colors.pink,
      Colors.purple,
      Colors.orange,
      Colors.teal,
      Colors.green,
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Row(
        children: List.generate(
          genres.length,
          (index) => _buildCategoryButton(
            genres[index],
            colors[index],
            provider.currentGenre == genres[index],
            () => provider.filterByGenre(genres[index]),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryButton(
    String label,
    Color color,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedSection(AppProvider provider) {
    final featuredSongs = provider.filteredSongs.take(5).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Featured Songs',
            style: TextStyle(
              color: AppTheme.textColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: featuredSongs.length,
            itemBuilder: (context, index) {
              return _buildFeaturedSongCard(featuredSongs[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedSongCard(Song song) {
    return GestureDetector(
      onTap: () => _playSong(song),
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl: song.imageUrl ?? 'https://via.placeholder.com/140',
                height: 140,
                width: 140,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: AppTheme.surfaceColor,
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  color: AppTheme.surfaceColor,
                  child: const Icon(Icons.music_note, color: AppTheme.textColor),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              song.title,
              style: const TextStyle(
                color: AppTheme.textColor,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllSongs(AppProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'All Songs',
            style: TextStyle(
              color: AppTheme.textColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: provider.filteredSongs.length,
          itemBuilder: (context, index) {
            return _buildSongListTile(provider.filteredSongs[index]);
          },
        ),
      ],
    );
  }

  Widget _buildSongListTile(Song song) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        return FutureBuilder<bool>(
          future: appProvider.isFavorite(song.id),
          builder: (context, snapshot) {
            final isFavorite = snapshot.data ?? false;
            
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: song.imageUrl ?? 'https://via.placeholder.com/50',
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: AppTheme.surfaceColor,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: AppTheme.surfaceColor,
                    child: const Icon(Icons.music_note, color: AppTheme.textColor),
                  ),
                ),
              ),
              title: Text(
                song.title,
                style: const TextStyle(
                  color: AppTheme.textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                song.artist,
                style: const TextStyle(color: AppTheme.secondaryTextColor),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? AppTheme.accentColor : AppTheme.textColor,
                    ),
                    onPressed: () => appProvider.toggleFavorite(song),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.play_circle_outline,
                      color: AppTheme.primaryColor,
                    ),
                    onPressed: () => _playSong(song),
                  ),
                ],
              ),
              onTap: () => _playSong(song),
            );
          },
        );
      },
    );
  }

  Widget _buildMiniPlayer() {
    return Consumer<PlayerProvider>(
      builder: (context, playerProvider, child) {
        final currentSong = playerProvider.currentSong;
        if (currentSong == null) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            border: Border(
              top: BorderSide(
                color: Colors.grey[800]!,
                width: 0.5,
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ProgressBar(
                progress: playerProvider.position,
                total: playerProvider.duration,
                onSeek: playerProvider.seek,
                barHeight: 3,
                baseBarColor: Colors.grey[600],
                progressBarColor: AppTheme.primaryColor,
                thumbColor: AppTheme.primaryColor,
                timeLabelTextStyle: const TextStyle(
                  color: AppTheme.textColor,
                  fontSize: 12,
                ),
              ),
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: CachedNetworkImage(
                      imageUrl: currentSong.imageUrl ?? 'https://via.placeholder.com/40',
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: AppTheme.surfaceColor,
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: AppTheme.surfaceColor,
                        child: const Icon(Icons.music_note, color: AppTheme.textColor),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentSong.title,
                          style: const TextStyle(
                            color: AppTheme.textColor,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          currentSong.artist,
                          style: const TextStyle(
                            color: AppTheme.secondaryTextColor,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.skip_previous,
                      color: AppTheme.textColor,
                    ),
                    onPressed: playerProvider.playPrevious,
                  ),
                  IconButton(
                    icon: Icon(
                      playerProvider.isPlaying ? Icons.pause : Icons.play_arrow,
                      color: AppTheme.textColor,
                    ),
                    onPressed: () {
                      if (playerProvider.isPlaying) {
                        playerProvider.pause();
                      } else {
                        playerProvider.resume();
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.skip_next,
                      color: AppTheme.textColor,
                    ),
                    onPressed: playerProvider.playNext,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _playSong(Song song) {
    final playerProvider = Provider.of<PlayerProvider>(context, listen: false);
    playerProvider.playSong(song);
  }
}
