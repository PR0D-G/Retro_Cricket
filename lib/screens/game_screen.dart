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

  Future<void> playTurn(int choice) async {
    if (ballInProgress) return; // 🚫 Prevent spam
    setState(() => ballInProgress = true);

    setState(() {
      playerChoice = choice;
      opponentChoice = random.nextInt(6) + 1;

      if (playerBatting) {
        // ✅ First Innings - Player batting
        if (playerChoice == opponentChoice) {
          wickets++;
          if (wickets >= 1) {
            target = runs + 1;
            playerBatting = false;
            runs = 0;
            wickets = 0;
            GameAlignments.showInningsChange(context, target);
          }
        } else {
          runs += playerChoice;
        }
      } else {
        // ✅ Second Innings - Player bowling
        if (playerChoice == opponentChoice) {
          wickets++;
          GameAlignments.showResult(context, runs, wickets, target);
        } else {
          runs += opponentChoice;
          if (runs >= target) {
            GameAlignments.showResult(context, runs, wickets, target);
          }
        }
      }
    });

    // ⏳ Wait 1 sec before enabling next ball
    await Future.delayed(const Duration(seconds: 1));
    setState(() => ballInProgress = false);
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

          // ✅ Timeout SandClock in center while waiting
          if (ballInProgress)
            const Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.only(top: 80, right: 20),
                child: SandClock(visible: true),
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
        filterQuality: FilterQuality.none, // retro pixel look
      ),
    );
  }
}
