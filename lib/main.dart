import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/block_screen.dart';
import 'services/theme_service.dart';
import 'services/blocker_settings_service.dart';
import 'package:flutter/services.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // Set preferred orientations
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Initialize SharedPreferences
    final prefs = await SharedPreferences.getInstance();

    // Run the app with error handling
    runApp(MyApp(prefs: prefs));
  } catch (e) {
    // If initialization fails, show error screen
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'خطا در راه‌اندازی برنامه',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'لطفاً برنامه را بسته و دوباره اجرا کنید',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;

  const MyApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeService(prefs)),
        ChangeNotifierProvider(create: (_) => BlockerSettingsService(prefs)),
      ],
      child: Consumer<ThemeService>(
        builder: (context, themeService, _) {
          return MaterialApp(
            title: 'Call Blocker',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF4CAF50),
                brightness: Brightness.light,
              ),
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF4CAF50),
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
            ),
            themeMode: themeService.themeMode,
            home: const SplashScreen(),
            routes: {
              '/home': (context) => const HomeScreen(),
              '/block': (context) => const BlockScreen(),
            },
          );
        },
      ),
    );
  }
}
