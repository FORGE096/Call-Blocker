import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return AppBar(
      elevation: 4,
      shadowColor: isDark ? Colors.black54 : Colors.black26,
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      surfaceTintColor: Colors.transparent,
      toolbarHeight: 72,
      title: Row(
        children: [
          Icon(
            Icons.block_flipped,
            color: isDark ? Colors.white : const Color(0xFF1E1E1E),
            size: 32,
          ),
          const SizedBox(width: 12),
          Text(
            'Call Blocker',
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF1E1E1E),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2C2C2C) : Colors.grey[100],
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black38 : Colors.black12,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(
              isDark ? Icons.light_mode : Icons.dark_mode,
              color: isDark ? Colors.amber : const Color(0xFF1E1E1E),
              size: 28,
            ),
            onPressed: () {
              themeProvider.toggleTheme();
            },
            style: IconButton.styleFrom(
              padding: const EdgeInsets.all(12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(72);
}
