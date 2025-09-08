import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'dart:ui';
import 'dart:math';

class GameAlignments {
  static bool get isDesktopOrWeb {
    if (kIsWeb) return true;
    try {
      return Platform.isWindows || Platform.isLinux || Platform.isMacOS;
    } catch (_) {
      return false;
    }
  }

  static Widget buildGameUI({
    required BuildContext context,
    required bool playerBatting,
    required int runs,
    required int wickets,
    required int playerChoice,
    required int opponentChoice,
    required int target,
    required String? lastBallResult,
    required bool ballInProgress,
    required Function(int) playTurn,
  }) {
    final double buttonBottomPadding = isDesktopOrWeb ? 55 : 10;

    return Stack(
      fit: StackFit.expand,
      children: [
        background(playerBatting),
        if (isDesktopOrWeb)
          scoreCard(
            playerBatting: playerBatting,
            runs: runs,
            wickets: wickets,
            playerChoice: playerChoice,
            opponentChoice: opponentChoice,
            target: target,
          )
        else
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 25),
              child: scoreCard(
                playerBatting: playerBatting,
                runs: runs,
                wickets: wickets,
                playerChoice: playerChoice,
                opponentChoice: opponentChoice,
                target: target,
              ),
            ),
          ),
        if (lastBallResult != null)
          Center(child: RunVfxPopup(result: lastBallResult)),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.only(bottom: buttonBottomPadding),
            child: Opacity(
              opacity: ballInProgress ? 0.4 : 1.0,
              child: IgnorePointer(
                ignoring: ballInProgress,
                child: actionButtons(
                  playTurn: playTurn,
                  disabled: ballInProgress,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  static Widget background(bool playerBatting) {
    return Image.asset(
      playerBatting ? "assets/batsman_end.png" : "assets/bowler_end.png",
      key: ValueKey(playerBatting),
      fit: isDesktopOrWeb ? BoxFit.fitHeight : BoxFit.fill,
      alignment: Alignment.center,
      filterQuality: FilterQuality.none,
    );
  }

  static Widget scoreCard({
    required bool playerBatting,
    required int runs,
    required int wickets,
    required int playerChoice,
    required int opponentChoice,
    required int target,
  }) {
    final card = Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.7),
            blurRadius: 10,
            offset: const Offset(3, 3),
          ),
        ],
      ),
      child: topTexts(
        playerBatting: playerBatting,
        runs: runs,
        wickets: wickets,
        playerChoice: playerChoice,
        opponentChoice: opponentChoice,
        target: target,
      ),
    );

    if (isDesktopOrWeb) {
      return Positioned(
        top: 20,
        right: 20,
        child: card,
      );
    } else {
      return Align(
        alignment: isDesktopOrWeb ? Alignment.topLeft : Alignment.topCenter,
        child: Container(
          margin: const EdgeInsets.only(top: 16, left: 16, right: 16),
          constraints: const BoxConstraints(
            maxWidth: 300,
            maxHeight: 200,
          ),
          child: card,
        ),
      );
    }
  }

  static Widget topTexts({
    required bool playerBatting,
    required int runs,
    required int wickets,
    required int playerChoice,
    required int opponentChoice,
    required int target,
  }) {
    List<Widget> children = [];

    children.add(
      Text(
        "Runs: $runs | Wickets: $wickets",
        style: const TextStyle(
          fontSize: 18,
          color: Colors.greenAccent,
          fontFamily: "monospace",
        ),
      ),
    );

    if (target != -1) {
      children.add(const SizedBox(height: 6));
      children.add(
        Text(
          "Target: $target",
          style: const TextStyle(
            fontSize: 16,
            color: Colors.yellow,
            fontFamily: "monospace",
          ),
        ),
      );
    }

    children.add(const SizedBox(height: 12));

    // ✅ Choices row
    children.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _glassBox("You", playerChoice, Colors.cyanAccent),
          const SizedBox(width: 20),
          _glassBox("Opponent", opponentChoice, Colors.pinkAccent),
        ],
      ),
    );

    return Column(children: children);
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
                  color: borderColor,
                  fontWeight: FontWeight.bold,
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
    bool disabled = false,
  }) {
    if (isDesktopOrWeb) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(6, (i) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Opacity(
              opacity: disabled ? 0.5 : 1, // fade when disabled
              child: IgnorePointer(
                // block taps + animations
                ignoring: disabled,
                child: SpriteButton(
                  index: i + 1,
                  onTap: () => playTurn(i + 1),
                  buttonSize: 80,
                ),
              ),
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
            child: Opacity(
              opacity: disabled ? 0.5 : 1,
              child: IgnorePointer(
                ignoring: disabled,
                child: SpriteButton(
                  index: i + 1,
                  onTap: () => playTurn(i + 1),
                  buttonSize: 90,
                ),
              ),
            ),
          );
        }),
      );
    }
  }

  static void showInningsChange(BuildContext context, int target) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF00BFA5), // teal retro bg
            border: Border.all(color: Colors.black, width: 4),
            boxShadow: const [
              BoxShadow(
                color: Colors.black,
                offset: Offset(4, 4), // blocky shadow
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.black,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Text(
                  "INNINGS CHANGE",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontFamily: "monospace", // use pixel font if available
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Target for opponent: $target",
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                  fontFamily: "monospace",
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _retroButton("OK", () => Navigator.pop(context)),
                  const SizedBox(width: 12),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  static Widget _retroButton(String text, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.yellow,
          border: Border.all(color: Colors.black, width: 3),
          boxShadow: const [
            BoxShadow(
              color: Colors.black,
              offset: Offset(3, 3), // block shadow
            ),
          ],
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            fontFamily: "monospace",
            color: Colors.black,
          ),
        ),
      ),
    );
  }

// ✅ Retro Game Over Dialog
  static void showResult(
    BuildContext context,
    int runs,
    int wickets,
    int target, {
    required VoidCallback onRetry,
    required bool playerBatting,
  }) {
    String result;
    Color bgColor;

    if (runs >= target) {
      if (playerBatting) {
        result = "You Win!";
        bgColor = const Color(0xFFFFD700); // gold
      } else {
        result = "Opponent Wins!";
        bgColor = const Color(0xFFFF3838); // red
      }
    } else if (runs == target - 1) {
      result = "Match Tied!";
      bgColor = Colors.cyanAccent;
    } else {
      if (playerBatting) {
        result = "Opponent Wins!";
        bgColor = const Color(0xFFFF3838);
      } else {
        result = "You Win!";
        bgColor = const Color(0xFFFFD700);
      }
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: bgColor,
            border: Border.all(color: Colors.black, width: 4),
            boxShadow: const [
              BoxShadow(
                color: Colors.black,
                offset: Offset(4, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.black,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Text(
                  "GAME OVER",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontFamily: "monospace",
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Final Score: $runs/$wickets\n\n$result",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                  fontFamily: "monospace",
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _retroButton("RETRY", () {
                    Navigator.pop(context);
                    onRetry(); // resets current GameScreen state, keeps widget settings
                  }),
                  const SizedBox(width: 12),
                  _retroButton("MENU", () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  }),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class SandClock extends StatefulWidget {
  final bool visible;
  const SandClock({super.key, required this.visible});

  @override
  State<SandClock> createState() => _SandClockState();
}

class _SandClockState extends State<SandClock>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true); // flip every 0.5s
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.visible) return const SizedBox.shrink();

    return RotationTransition(
      turns: Tween<double>(begin: 0, end: 1).animate(_controller),
      child: Image.asset(
        "assets/timeout.png", // ✅ use your retro timeout image
        width: 100,
        height: 100,
        filterQuality: FilterQuality.none, // keep pixel look
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

class RunVfxPopup extends StatefulWidget {
  final String result;
  const RunVfxPopup({super.key, required this.result});

  @override
  State<RunVfxPopup> createState() => _RunVfxPopupState();
}

class _RunVfxPopupState extends State<RunVfxPopup>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _floatAnim;
  late Animation<Color?> _colorAnim;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();

    _scaleAnim = Tween<double>(begin: 0.5, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _fadeAnim = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _floatAnim = Tween<Offset>(begin: Offset.zero, end: const Offset(0, -50))
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _colorAnim = ColorTween(begin: Colors.yellow, end: Colors.orange)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        // hide popup automatically after animation
        setState(() {
          // Optional: you can call a callback here to hide `lastBallResult`
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: _floatAnim.value,
          child: Transform.scale(
            scale: _scaleAnim.value,
            child: Opacity(
              opacity: _fadeAnim.value,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  for (int i = 0; i < 8; i++)
                    Positioned(
                      left: (Random().nextDouble() - 0.5) * 60,
                      top: (Random().nextDouble() - 0.5) * 60,
                      child: Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.primaries[i % Colors.primaries.length],
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  // ✨ Floating glowing text
                  Text(
                    widget.result,
                    style: TextStyle(
                      fontSize: 80,
                      fontWeight: FontWeight.bold,
                      color: _colorAnim.value,
                      shadows: [
                        Shadow(
                          blurRadius: 10,
                          color: Colors.white,
                          offset: const Offset(0, 0),
                        ),
                        Shadow(
                          blurRadius: 20,
                          color: Colors.orange,
                          offset: const Offset(0, 0),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
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
