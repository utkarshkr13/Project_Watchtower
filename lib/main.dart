import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/app_data_store.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const ProjectWatchtowerApp());
}

class ProjectWatchtowerApp extends StatelessWidget {
  const ProjectWatchtowerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppDataStore(),
      child: Consumer<AppDataStore>(
        builder: (context, store, child) {
          return MaterialApp(
            title: 'Project Watchtower',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: store.themeMode,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}