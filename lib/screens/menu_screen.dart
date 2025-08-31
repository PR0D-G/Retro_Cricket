import 'package:flutter/material.dart';
import 'game_screen.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 🔹 Retro Neon Background (static PNG)
          Positioned.fill(
            child: Image.asset(
              "assets/bg.png", // <-- use your PNG here
              fit: BoxFit.fill,
            ),
          ),

          // 🔹 Overlay with slight gradient tint for readability
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withValues(alpha: 0.7),
                  Colors.transparent,
                  Colors.black..withValues(alpha: 0.8),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // 🔹 Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Title
                Text(
                  'RETRO HAND CRICKET',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    color: Colors.yellowAccent,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.greenAccent.shade400,
                        blurRadius: 12,
                        offset: const Offset(2, 2),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 60),

                // Player vs AI button
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

                // Player vs Player button
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

                // Footer text
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
