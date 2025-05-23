import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'providers/player_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/music_provider.dart';
import 'providers/favorite_provider.dart';
import 'providers/playlist_provider.dart';
import 'app.dart';
import 'services/storage_service.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    print('Flutter binding initialized');
    
    await StorageService.instance.init();
    print('Storage service initialized');
    
    runApp(const MyApp());
    print('App started');
  } catch (e) {
    print('Error starting app: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => PlayerProvider()),
        ChangeNotifierProvider(create: (_) => MusicProvider()),
        ChangeNotifierProvider(create: (_) => FavoriteProvider()),
        ChangeNotifierProvider(create: (_) => PlaylistProvider()),
      ],
      child: const App(),
    );
  }
}
