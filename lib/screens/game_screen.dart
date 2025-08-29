import 'package:flutter/material.dart';
import 'dart:math';

class GameScreen extends StatefulWidget {
  final bool vsAI;

  const GameScreen({super.key, this.vsAI = false});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final Random random = Random();

  int runs = 0;
  int wickets = 0;
  int playerChoice = 0;
  int opponentChoice = 0;

  int target = -1; // used for 2nd innings
  bool playerBatting = true; // true = player batting first

  void playTurn(int choice) {
    setState(() {
      playerChoice = choice;

      // Opponent move
      opponentChoice = random.nextInt(6) + 1;

      if (playerBatting) {
        // Batting phase
        if (playerChoice == opponentChoice) {
          wickets++;
          if (wickets >= 1) {
            // End of innings
            target = runs + 1;
            playerBatting = false;
            runs = 0;
            wickets = 0;
            _showInningsChange();
          }
        } else {
          runs += playerChoice;
        }
      } else {
        // Bowling phase (opponent batting)
        if (playerChoice == opponentChoice) {
          wickets++;
          if (wickets >= 1 || runs >= target) {
            _showResult();
          }
        } else {
          runs += opponentChoice;
          if (runs >= target) {
            _showResult();
          }
        }
      }
    });
  }

  void _showInningsChange() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.black,
        title: const Text(
          "Innings Over!",
          style: TextStyle(color: Colors.yellow, fontFamily: "monospace"),
        ),
        content: Text(
          "Target for opponent: $target",
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "OK",
              style: TextStyle(color: Colors.cyanAccent),
            ),
          )
        ],
      ),
    );
  }

  void _showResult() {
    String result;
    if (runs >= target) {
      result = "Opponent Wins!";
    } else {
      result = "You Win!";
    }

    if (runs == target - 1) {
      result = "Match Tied!";
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.black,
        title: const Text(
          "Game Over",
          style: TextStyle(color: Colors.redAccent, fontFamily: "monospace"),
        ),
        content: Text(
          "Final Score: $runs/$wickets\n\n$result",
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text(
              "Back to Menu",
              style: TextStyle(color: Colors.greenAccent),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text(
          'Retro Hand Cricket',
          style: TextStyle(
            fontFamily: "monospace",
            fontWeight: FontWeight.bold,
            color: Colors.cyanAccent,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              playerBatting ? "You are Batting" : "You are Bowling",
              style: const TextStyle(
                fontSize: 20,
                color: Colors.yellowAccent,
                fontFamily: "monospace",
              ),
            ),
            Text(
              "Runs: $runs | Wickets: $wickets",
              style: const TextStyle(
                fontSize: 18,
                color: Colors.greenAccent,
                fontFamily: "monospace",
              ),
            ),
            Text(
              "You: $playerChoice   Opponent: $opponentChoice",
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),

            // Retro Buttons (6)
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: List.generate(6, (i) {
                return SpriteButton(
                  index: i + 1,
                  onTap: () => playTurn(i + 1),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

/// A button using your cropped retro images
class SpriteButton extends StatefulWidget {
  final int index; // 1–6
  final VoidCallback onTap;

  const SpriteButton({
    super.key,
    required this.index,
    required this.onTap,
  });

  @override
  State<SpriteButton> createState() => _SpriteButtonState();
}

class _SpriteButtonState extends State<SpriteButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        transform: Matrix4.translationValues(0, _pressed ? 4 : 0, 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: _pressed
              ? [
                  const BoxShadow(
                    color: Colors.black87,
                    offset: Offset(2, 2),
                    blurRadius: 0,
                  ),
                ]
              : [
                  const BoxShadow(
                    color: Colors.tealAccent,
                    offset: Offset(0, 0),
                    blurRadius: 8,
                  ),
                  const BoxShadow(
                    color: Colors.black,
                    offset: Offset(6, 6),
                    blurRadius: 0,
                  ),
                ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            "assets/btn${widget.index}.png", // your retro cropped buttons
            width: 80,
            height: 80,
            filterQuality: FilterQuality.none, // keep retro crispness
          ),
        ),
      ),
    );
  }
}
