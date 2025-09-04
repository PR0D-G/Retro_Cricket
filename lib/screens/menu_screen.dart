import 'package:flutter/foundation.dart'; // for kIsWeb
import 'package:flutter/material.dart';
import 'game_screen.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  bool get isDesktopOrWeb =>
      kIsWeb ||
      [TargetPlatform.macOS, TargetPlatform.linux, TargetPlatform.windows]
          .contains(defaultTargetPlatform);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 🔹 Retro Neon Background (adaptive for devices)
          Positioned.fill(
            child: Image.asset(
              "assets/menu_screen_bg.png",
              fit: isDesktopOrWeb ? BoxFit.fitHeight : BoxFit.fill,
              alignment: Alignment.center,
              filterQuality: FilterQuality.none,
            ),
          ),

          // 🔹 Overlay with slight gradient tint for readability
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withValues(alpha: 0.7),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.8),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // 🔹 Main content
          Center(
            child: Padding(
              padding: EdgeInsets.only(
                top: isDesktopOrWeb ? 400 : 520, // ⬅️ different offsets
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _menuButton(
                    label: "🤖 vs AI",
                    color: Colors.greenAccent,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const GameScreen(vsAI: true),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  _menuButton(
                    label: "👥 Online",
                    color: Colors.cyanAccent,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const GameScreen(vsAI: false),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 40),
                  Text(
                    "© Retro Cricket 2025",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade400,
                      fontFamily: "monospace",
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 Custom neon-styled button
  Widget _menuButton({
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 220,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: color,
          side: BorderSide(color: color, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          shadowColor: color,
          elevation: 10,
        ),
        onPressed: onTap,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 18,
            fontFamily: "monospace",
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }
}
