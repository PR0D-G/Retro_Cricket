import 'package:flutter/material.dart';
import 'dart:math';
import 'package:retro_cricket/widget/align.dart';

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
  bool playerBatting = true; // true = you are batting
  bool ballInProgress = false; // ⏳ Prevents spam + shows timeout clock
  String? lastBallResult; // stores score or OUT

  Future<void> playTurn(int choice) async {
    if (ballInProgress) return;
    setState(() => ballInProgress = true);

    String? result; // temporary result holder
    bool triggerInningsChange = false;
    bool triggerGameOver = false;

    setState(() {
      playerChoice = choice;
      opponentChoice = random.nextInt(6) + 1;

      if (playerBatting) {
        if (playerChoice == opponentChoice) {
          result = "OUT";
          wickets++;
          if (wickets >= 1) {
            target = runs + 1;
            playerBatting = false;
            runs = 0;
            wickets = 0;
            triggerInningsChange = true;
          }
        } else {
          runs += playerChoice;
          result = "$playerChoice";
        }
      } else {
        if (playerChoice == opponentChoice) {
          result = "OUT";
          wickets++;
          triggerGameOver = true;
        } else {
          runs += opponentChoice;
          result = "$opponentChoice";
          if (runs >= target) triggerGameOver = true;
        }
      }

      lastBallResult = result;
    });

    // show popup for 1 sec
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return; // ✅ safety check

    setState(() {
      lastBallResult = null; // hide popup
      ballInProgress = false;
    });

    // ✅ trigger dialogs only after popup is hidden
    if (triggerInningsChange && mounted) {
      GameAlignments.showInningsChange(context, target);
    } else if (triggerGameOver && mounted) {
      GameAlignments.showResult(context, runs, wickets, target);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double buttonBottomPadding = GameAlignments.isDesktopOrWeb ? 55 : 10;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ✅ Background
          GameAlignments.background(playerBatting),

          // ✅ Scorecard
          if (GameAlignments.isDesktopOrWeb)
            GameAlignments.scoreCard(
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
                child: GameAlignments.scoreCard(
                  playerBatting: playerBatting,
                  runs: runs,
                  wickets: wickets,
                  playerChoice: playerChoice,
                  opponentChoice: opponentChoice,
                  target: target,
                ),
              ),
            ),

          // ✅ Score Popup in center while waiting
          // ✅ Show circular popup for last ball
          // ✅ Score Popup in center while waiting
          if (lastBallResult != null)
            Center(
              child: RunVfxPopup(
                result: lastBallResult!,
              ),
            ),

          // ✅ Buttons at bottom
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: buttonBottomPadding),
              child: GameAlignments.actionButtons(
                playTurn: playTurn,
                disabled: ballInProgress, // 🔹 Disable while waiting
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 🔹 Retro Timeout Clock Widget
class _SandClock extends StatefulWidget {
  @override
  State<_SandClock> createState() => _SandClockState();
}

class _SandClockState extends State<_SandClock>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true); // flip every 0.5 sec
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: Tween<double>(begin: 0, end: 1).animate(_controller),
      child: Image.asset(
        "assets/timeout.png",
        width: 40,
        height: 40,
        filterQuality: FilterQuality.none,
      ),
    );
  }
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
