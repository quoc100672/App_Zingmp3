import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';
import 'screens/bottom_nav_screen.dart';
import 'theme/app_theme.dart';

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music App',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      home: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          print('Auth state changed - isLoading: ${authProvider.isLoading}, isAuthenticated: ${authProvider.isAuthenticated}');
          
          if (authProvider.isLoading) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (authProvider.isAuthenticated) {
            print('User is authenticated, showing BottomNavScreen');
            return const BottomNavScreen();
          }

          print('User is not authenticated, showing LoginScreen');
          return const LoginScreen();
        },
      ),
    );
  }
}
