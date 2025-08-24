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
        title: const Text("Innings Over!",
            style: TextStyle(color: Colors.yellow, fontFamily: "monospace")),
        content: Text("Target for opponent: $target",
            style: const TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK", style: TextStyle(color: Colors.cyanAccent)),
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
        title: const Text("Game Over",
            style: TextStyle(color: Colors.redAccent, fontFamily: "monospace")),
        content: Text(
          "Final Score: $runs/${wickets}\n\n$result",
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("Back to Menu",
                style: TextStyle(color: Colors.greenAccent)),
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
              color: Colors.cyanAccent),
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
                  fontFamily: "monospace"),
            ),
            Text(
              "Runs: $runs | Wickets: $wickets",
              style: const TextStyle(
                  fontSize: 18,
                  color: Colors.greenAccent,
                  fontFamily: "monospace"),
            ),
            Text(
              "You: $playerChoice   Opponent: $opponentChoice",
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
            Wrap(
              spacing: 10,
              children: List.generate(6, (i) {
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purpleAccent,
                    foregroundColor: Colors.black,
                    shadowColor: Colors.cyanAccent,
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => playTurn(i + 1),
                  child: Text(
                    "${i + 1}",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      fontFamily: "monospace",
                    ),
                  ),
                );
              }),
            )
          ],
        ),
      ),
    );
  }
}
