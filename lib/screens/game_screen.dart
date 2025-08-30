import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

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
  int target = -1;
  bool playerBatting = true;

  void playTurn(int choice) {
    setState(() {
      playerChoice = choice;
      opponentChoice = random.nextInt(6) + 1;

      if (playerBatting) {
        if (playerChoice == opponentChoice) {
          wickets++;
          if (wickets >= 1) {
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
        if (playerChoice == opponentChoice) {
          wickets++;
          _showResult();
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
    } else if (runs == target - 1) {
      result = "Match Tied!";
    } else {
      result = "You Win!";
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
          backgroundColor: Colors.green.shade900,
          elevation: 6,
          centerTitle: true,
          title: Text(
            playerBatting ? "🏏 Batting End" : "☄️ Bowling End",
            style: const TextStyle(
              fontFamily: "monospace",
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.yellowAccent,
              shadows: [
                Shadow(
                  blurRadius: 4,
                  color: Colors.black,
                  offset: Offset(2, 2),
                )
              ],
            ),
          ),
        ),
        body: Stack(
          fit: StackFit.expand,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                // detect if running on web or desktop
                final isDesktopOrWeb = kIsWeb ||
                    Platform.isWindows ||
                    Platform.isLinux ||
                    Platform.isMacOS;

                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 600),
                  child: Image.asset(
                    playerBatting
                        ? "assets/batsman_end.png"
                        : "assets/bowler_end.png",
                    key: ValueKey(playerBatting),
                    fit: isDesktopOrWeb
                        ? BoxFit.contain // ✅ keep original ratio (desktop/web)
                        : BoxFit.cover, // ✅ fill screen (mobile/tablet)
                    alignment: Alignment.center,
                    filterQuality: FilterQuality.none,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                );
              },
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 600),
              child: Image.asset(
                playerBatting
                    ? "assets/batsman_end.png"
                    : "assets/bowler_end.png",
                key: ValueKey(playerBatting),
                fit: BoxFit.cover, // ✅ fullscreen, crops excess
                alignment: Alignment.center,
                filterQuality: FilterQuality.none,
                width: double.infinity,
                height: double.infinity,
              ),
            ),

            // Foreground UI
            Padding(
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
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
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
          ],
        ));
  }
}

class SpriteButton extends StatefulWidget {
  final int index;
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
        duration: const Duration(milliseconds: 100),
        transform: Matrix4.translationValues(0, _pressed ? 4 : 0, 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: _pressed
              ? [
                  const BoxShadow(
                    color: Colors.black87,
                    offset: Offset(2, 2),
                    blurRadius: 0,
                  )
                ]
              : [
                  const BoxShadow(
                    color: Colors.tealAccent,
                    offset: Offset(0, 0),
                    blurRadius: 6,
                  ),
                  const BoxShadow(
                    color: Colors.black,
                    offset: Offset(6, 6),
                    blurRadius: 0,
                  ),
                ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            "assets/btn${widget.index}.png",
            width: 80,
            height: 80,
            filterQuality: FilterQuality.none,
          ),
        ),
      ),
    );
  }
}
