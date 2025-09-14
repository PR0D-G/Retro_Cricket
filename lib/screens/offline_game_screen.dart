import 'dart:math';
import 'package:flutter/services.dart'; // for rootBundle
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
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

  // 🎵 Preloaded sound bytes
  late Uint8List _outBytes;
  late Uint8List _batBytes;

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

    _preloadSounds(); // ✅ preload sounds into memory
  }

  /// 🔹 Preload sound assets into memory for instant playback
  Future<void> _preloadSounds() async {
    _outBytes = await rootBundle
        .load("assets/sounds/out.mp3")
        .then((b) => b.buffer.asUint8List());

    _batBytes = await rootBundle
        .load("assets/sounds/bat_hit.mp3")
        .then((b) => b.buffer.asUint8List());

    // 🔥 Warm up both sounds silently
    final warmUp1 = AudioPlayer();
    await warmUp1.play(BytesSource(_outBytes), volume: 0);
    await warmUp1.stop();
    await warmUp1.dispose();

    final warmUp2 = AudioPlayer();
    await warmUp2.play(BytesSource(_batBytes), volume: 0);
    await warmUp2.stop();
    await warmUp2.dispose();
  }

  /// 🔹 Fire-and-forget sound player (allows overlapping spam)
  Future<void> _playSound(Uint8List bytes) async {
    final player = AudioPlayer();
    await player.play(BytesSource(bytes));
  }

  /// 🔹 Reset match but keep same settings
  void resetGame() {
    setState(() {
      runs = 0;
      wickets = 0;
      playerChoice = 0;
      opponentChoice = 0;
      target = -1;
      playerBatting = initialPlayerBatting;
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
            _playSound(_outBytes); // 🔊 OUT
          } else {
            runs += playerChoice;
            result = "$playerChoice";
            _playSound(_batBytes); // 🔊 Bat hit
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
            _playSound(_outBytes); // 🔊 OUT
            if (wickets >= widget.wickets && runs < target) {
              triggerGameOver = true;
            }
          } else {
            runs += playerChoice;
            result = "$playerChoice";
            _playSound(_batBytes); // 🔊 Bat hit
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
        onRetry: resetGame,
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
