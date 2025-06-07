import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/blocker_settings_service.dart';
import '../services/theme_service.dart';
import 'block_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<BlockerSettingsService>();
    final themeService = context.watch<ThemeService>();
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        actions: [
          GestureDetector(
            onTap: () => themeService.toggleTheme(),
            child: Container(
              width: width * 0.22,
              height: width * 0.11,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: themeService.isDarkMode
                    ? const Color(0xFF4CAF50)
                    : Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[700]
                        : const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(50),
                    blurRadius: 8,
                    spreadRadius: 1,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    left: themeService.isDarkMode
                        ? (width * 0.12)
                        : (width * 0.01),
                    top: width * 0.01,
                    child: Container(
                      width: width * 0.09,
                      height: width * 0.09,
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[800]
                            : Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            spreadRadius: 1,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          themeService.isDarkMode
                              ? Icons.light_mode
                              : Icons.dark_mode,
                          color: themeService.isDarkMode
                              ? const Color(0xFF4CAF50)
                              : Theme.of(context).brightness == Brightness.dark
                                  ? Colors.grey[400]
                                  : const Color(0xFF9E9E9E),
                          size: height * 0.018,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.settings,
              size: 28,
              color: themeService.isDarkMode
                  ? const Color(0xFF4CAF50)
                  : Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[400]
                      : const Color(0xFF9E9E9E),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BlockScreen()),
              );
            },
          ),
          SizedBox(width: width * 0.02),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: height * 0.02),
            Image.asset(
              settings.isBlockerEnabled
                  ? 'assets/imgs/enabled-vector.png'
                  : 'assets/imgs/disabled-vector.png',
              width: width * 0.7,
              height: height * 0.35,
              fit: BoxFit.contain,
            ),
            SizedBox(height: height * 0.06),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.06),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    settings.isBlockerEnabled
                        ? 'Blocking\nis ON'
                        : 'Blocking\nis OFF',
                    style: TextStyle(
                      fontSize: height * 0.032,
                      fontWeight: FontWeight.w800,
                      height: 1.3,
                      color: settings.isBlockerEnabled
                          ? const Color(0xFF388E3C)
                          : Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  GestureDetector(
                    onTap: () =>
                        settings.setBlockerEnabled(!settings.isBlockerEnabled),
                    child: Container(
                      width: width * 0.32,
                      height: width * 0.16,
                      decoration: BoxDecoration(
                        color: settings.isBlockerEnabled
                            ? const Color(0xFF4CAF50)
                            : Theme.of(context).brightness == Brightness.dark
                                ? Colors.grey[700]
                                : const Color(0xFFE0E0E0),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(50),
                            blurRadius: 8,
                            spreadRadius: 1,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          AnimatedPositioned(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            left: settings.isBlockerEnabled
                                ? (width * 0.17)
                                : (width * 0.01),
                            top: width * 0.01,
                            child: Container(
                              width: width * 0.14,
                              height: width * 0.14,
                              decoration: BoxDecoration(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.grey[800]
                                    : Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 4,
                                    spreadRadius: 1,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Icon(
                                  settings.isBlockerEnabled
                                      ? Icons.check
                                      : Icons.close,
                                  color: settings.isBlockerEnabled
                                      ? const Color(0xFF4CAF50)
                                      : Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.grey[400]
                                          : const Color(0xFF9E9E9E),
                                  size: height * 0.022,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: height * 0.08),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.08),
              child: Text(
                settings.isBlockerEnabled
                    ? 'Call blocking is currently active. All calls matching your blocking rules will be blocked.'
                    : 'Call blocking is disabled. Tap the switch to enable protection.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: height * 0.016,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const BlockScreen()),
          );
        },
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 4,
        child: const Icon(Icons.block, color: Colors.white, size: 28),
      ),
    );
  }
}
