import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:device_preview/device_preview.dart';
import 'package:provider/provider.dart';
import 'providers/file_provider.dart';
import 'theme/app_theme.dart';
import 'screens/file_list_screen.dart';
import 'screens/shared_files_screen.dart';
import 'screens/search_filter_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => FileProvider()..init(),
      child: DevicePreview(
        enabled: kIsWeb, // Enable only on web
        builder: (context) => const SmartFileShareApp(),
      ),
    ),
  );
}

class SmartFileShareApp extends StatelessWidget {
  const SmartFileShareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart File Share',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const HomeScreen(),
      locale: DevicePreview.locale(context), // Add for device preview
      builder: DevicePreview.appBuilder, // Add for device preview
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final _screens = const [
    FileListScreen(),
    SharedFilesScreen(),
    SearchFilterScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _screens[_currentIndex]),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.secondaryDark,
          border: Border(
            top: BorderSide(color: AppTheme.surfaceLight.withOpacity(0.5)),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.folder_rounded),
              activeIcon: Icon(Icons.folder_rounded),
              label: 'My Files',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.group_rounded),
              activeIcon: Icon(Icons.group_rounded),
              label: 'Shared',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search_rounded),
              activeIcon: Icon(Icons.search_rounded),
              label: 'Search',
            ),
          ],
        ),
      ),
    );
  }
}
