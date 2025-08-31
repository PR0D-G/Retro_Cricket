import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'dart:math' as math;

class GameAlignments {
  // ✅ Check platform
  static bool get isDesktopOrWeb {
    if (kIsWeb) return true;
    try {
      return Platform.isWindows || Platform.isLinux || Platform.isMacOS;
    } catch (_) {
      return false;
    }
  }

  // ✅ Background (with proper BoxFit logic)
  static Widget background(bool playerBatting) {
    return Image.asset(
      playerBatting ? "assets/batsman_end.png" : "assets/bowler_end.png",
      key: ValueKey(playerBatting),
      fit: isDesktopOrWeb ? BoxFit.fitHeight : BoxFit.cover,
      alignment: Alignment.center,
      filterQuality: FilterQuality.none,
    );
  }

  // ✅ Player sprite overlay

  // ✅ Top status texts
  static Widget topTexts({
    required bool playerBatting,
    required int runs,
    required int wickets,
    required int playerChoice,
    required int opponentChoice,
  }) {
    return Column(
      children: [
        Text(
          "Runs: $runs | Wickets: $wickets",
          style: const TextStyle(
            fontSize: 18,
            color: Colors.greenAccent,
            fontFamily: "monospace",
          ),
        ),
        Text(
          "You: $playerChoice Opponent: $opponentChoice",
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ),
      ],
    );
  }

  // ✅ Action buttons (desktop vs mobile layout preserved)
  static Widget actionButtons({
    required Function(int) playTurn,
  }) {
    if (isDesktopOrWeb) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(6, (i) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: SpriteButton(
              index: i + 1,
              onTap: () => playTurn(i + 1),
              buttonSize: 80,
            ),
          );
        }),
      );
    } else {
      return GridView.count(
        shrinkWrap: true,
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 0,
        children: List.generate(6, (i) {
          return Center(
            child: SpriteButton(
              index: i + 1,
              onTap: () => playTurn(i + 1),
              buttonSize: 90,
            ),
          );
        }),
      );
    }
  }

  // ✅ Innings change dialog
  static void showInningsChange(BuildContext context, int target) {
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

  // ✅ Result dialog
  static void showResult(
      BuildContext context, int runs, int wickets, int target) {
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
          style: TextStyle(
            color: Colors.redAccent,
            fontFamily: "monospace",
          ),
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
}

// ✅ SpriteButton moved here
class SpriteButton extends StatefulWidget {
  final int index;
  final VoidCallback onTap;
  final double buttonSize;

  const SpriteButton({
    super.key,
    required this.index,
    required this.onTap,
    required this.buttonSize,
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
            width: widget.buttonSize,
            height: widget.buttonSize,
            filterQuality: FilterQuality.none,
          ),
        ),
      ),
    );
  }
}
