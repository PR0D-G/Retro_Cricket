import 'dart:math';
import 'package:flutter/material.dart';
import '../widget/align.dart';

class GameScreen extends StatefulWidget {
  final bool vsAI;
  final bool battingFirst;
  final int wickets;
  final int overs; // -1 means Unlimited

  const GameScreen({
    super.key,
    this.vsAI = false,
    this.battingFirst = true,
    this.wickets = 1,
    this.overs = 1,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final Random random = Random();
  late final bool initialPlayerBatting;

  int runs = 0;
  int wickets = 0;
  int playerChoice = 0;
  int opponentChoice = 0;
  int target = -1;

  late bool playerBatting;
  bool isFirstInnings = true;
  int ballsInInnings = 0;

  bool ballInProgress = false;
  String? lastBallResult;

  @override
  void initState() {
    super.initState();
    initialPlayerBatting = widget.battingFirst; // save role
    playerBatting = initialPlayerBatting;
  }

  /// 🔹 Reset match but keep same settings
  void resetGame() {
    setState(() {
      runs = 0;
      wickets = 0;
      playerChoice = 0;
      opponentChoice = 0;
      target = -1;
      playerBatting = initialPlayerBatting; // reset role correctly
      isFirstInnings = true;
      ballsInInnings = 0;
      ballInProgress = false;
      lastBallResult = null;
    });
  }

  Future<void> playTurn(int choice) async {
    if (ballInProgress) return;
    setState(() => ballInProgress = true);

    String? result;
    bool triggerInningsChange = false;
    bool triggerGameOver = false;
    final maxBalls = widget.overs == -1 ? -1 : widget.overs * 6;

    setState(() {
      playerChoice = choice;
      opponentChoice = random.nextInt(6) + 1;

      if (isFirstInnings) {
        // First innings
        if (playerBatting) {
          if (playerChoice == opponentChoice) {
            result = "OUT";
            wickets++;
          } else {
            runs += playerChoice;
            result = "$playerChoice";
          }
        } else {
          if (playerChoice == opponentChoice) {
            result = "OUT";
            wickets++;
          } else {
            runs += opponentChoice;
            result = "$opponentChoice";
          }
        }

        ballsInInnings++;
        if (wickets >= widget.wickets ||
            (maxBalls != -1 && ballsInInnings >= maxBalls)) {
          target = runs + 1;
          isFirstInnings = false;
          playerBatting = !playerBatting;
          runs = 0;
          wickets = 0;
          ballsInInnings = 0;
          triggerInningsChange = true;
        }
      } else {
        // Second innings
        if (playerBatting) {
          if (playerChoice == opponentChoice) {
            result = "OUT";
            wickets++;
            if (wickets >= widget.wickets && runs < target) {
              triggerGameOver = true;
            }
          } else {
            runs += playerChoice;
            result = "$playerChoice";
            if (target != -1 && runs >= target) {
              triggerGameOver = true;
            }
          }
        } else {
          if (playerChoice == opponentChoice) {
            result = "OUT";
            wickets++;
            if (wickets >= widget.wickets && runs < target) {
              triggerGameOver = true;
            }
          } else {
            runs += opponentChoice;
            result = "$opponentChoice";
            if (target != -1 && runs >= target) {
              triggerGameOver = true;
            }
          }
        }

        ballsInInnings++;
        if (!triggerGameOver && maxBalls != -1 && ballsInInnings >= maxBalls) {
          triggerGameOver = true;
        }
      }

      lastBallResult = result;
    });

    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    setState(() {
      lastBallResult = null;
      ballInProgress = false;
    });

    if (triggerInningsChange && mounted) {
      GameAlignments.showInningsChange(context, target);
    } else if (triggerGameOver && mounted) {
      GameAlignments.showResult(
        context,
        runs,
        wickets,
        target,
        playerBatting: playerBatting,
        onRetry: resetGame, // ✅ pass resetGame for retry button
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GameAlignments.buildGameUI(
        context: context,
        playerBatting: playerBatting,
        runs: runs,
        wickets: wickets,
        playerChoice: playerChoice,
        opponentChoice: opponentChoice,
        target: target,
        lastBallResult: lastBallResult,
        ballInProgress: ballInProgress,
        playTurn: playTurn,
      ),
    );
  }
}
