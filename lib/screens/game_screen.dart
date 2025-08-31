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
            GameAlignments.showInningsChange(context, target);
          }
        } else {
          runs += playerChoice;
        }
      } else {
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
  }

  @override
  Widget build(BuildContext context) {
    final double buttonBottomPadding = GameAlignments.isDesktopOrWeb ? 55 : 10;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          GameAlignments.background(playerBatting),
          Padding(
            padding: EdgeInsets.only(
              left: 18,
              right: 18,
              top: 18,
              bottom: buttonBottomPadding,
            ),
            child: Column(
              children: [
                GameAlignments.topTexts(
                  playerBatting: playerBatting,
                  runs: runs,
                  wickets: wickets,
                  playerChoice: playerChoice,
                  opponentChoice: opponentChoice,
                ),
                const Spacer(),
                GameAlignments.actionButtons(
                  playTurn: playTurn,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
