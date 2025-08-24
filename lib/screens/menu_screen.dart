import 'package:flutter/material.dart';
import 'game_screen.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'RETRO HAND CRICKET',
              style: TextStyle(
                fontSize: 24,
                color: Colors.greenAccent,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const GameScreen(vsAI: true),
                  ),
                );
              },
              child: const Text('Player vs AI'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const GameScreen(vsAI: false),
                  ),
                );
              },
              child: const Text('Player vs Player'),
            ),
          ],
        ),
      ),
    );
  }
}
