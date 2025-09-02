import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'dart:ui';

class GameAlignments {
  static bool get isDesktopOrWeb {
    if (kIsWeb) return true;
    try {
      return Platform.isWindows || Platform.isLinux || Platform.isMacOS;
    } catch (_) {
      return false;
    }
  }

  static Widget background(bool playerBatting) {
    return Image.asset(
      playerBatting ? "assets/batsman_end.png" : "assets/bowler_end.png",
      key: ValueKey(playerBatting),
      fit: isDesktopOrWeb ? BoxFit.fitHeight : BoxFit.cover,
      alignment: Alignment.center,
      filterQuality: FilterQuality.none,
    );
  }

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
        const SizedBox(height: 12),

        // 🔹 Glassmorphic squares
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _glassBox("You", playerChoice, Colors.cyanAccent),
            const SizedBox(width: 20),
            _glassBox("Opponent", opponentChoice, Colors.pinkAccent),
          ],
        ),
      ],
    );
  }

  static Widget _glassBox(String title, int choice, Color borderColor) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: 120,
          height: 90,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: borderColor.withValues(alpha: 0.7),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 8,
                offset: const Offset(2, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: borderColor, // ✅ same as box color
                  fontWeight: FontWeight.bold, // ✅ bold text
                  fontFamily: "monospace",
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "$choice",
                style: TextStyle(
                  fontSize: 26,
                  color: borderColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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

class _SpriteButtonState extends State<SpriteButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
      reverseDuration: const Duration(milliseconds: 120),
    );

    _offsetAnimation = Tween<double>(begin: 0, end: 4).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  void _handleTap() {
    if (mounted) {
      _controller.forward(from: 0).then((_) {
        if (mounted) _controller.reverse();
      });
    }
    widget.onTap();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _offsetAnimation.value),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                boxShadow: _controller.isAnimating
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
        },
      ),
    );
  }
}
