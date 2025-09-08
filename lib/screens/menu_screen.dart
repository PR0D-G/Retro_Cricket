import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'offline_game_screen.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  bool get isDesktopOrWeb =>
      kIsWeb ||
      [TargetPlatform.macOS, TargetPlatform.linux, TargetPlatform.windows]
          .contains(defaultTargetPlatform);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 🔹 Retro Neon Background
          Positioned.fill(
            child: Image.asset(
              "assets/menu_screen_bg.png",
              fit: isDesktopOrWeb ? BoxFit.fitHeight : BoxFit.fill,
              alignment: Alignment.center,
              filterQuality: FilterQuality.none,
            ),
          ),

          // 🔹 Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withValues(alpha: 0.7),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.8),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // 🔹 Content
          Center(
            child: Column(
              children: [
                const Spacer(flex: 7),
                FractionallySizedBox(
                  widthFactor: isDesktopOrWeb ? 0.25 : 0.6,
                  child: _menuButton(
                    label: "🤖 vs AI",
                    color: Colors.greenAccent,
                    onTap: () async {
                      // Step 1: Choose Batting/Bowling
                      final choice = await _showBatBowlDialog(context);
                      if (choice == null) return;
                      if (!context.mounted) return;

                      // Step 2 & 3: Choose Wickets + Overs together
                      final settings = await _showWicketsOversDialog(context);
                      if (settings == null) return;
                      if (!context.mounted) return;

                      final wickets = settings["wickets"]!;
                      final overs = settings["overs"]!;

                      // Navigate with selections
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GameScreen(
                            vsAI: true,
                            battingFirst: choice == "bat",
                            wickets: wickets,
                            overs: overs,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                FractionallySizedBox(
                  widthFactor: isDesktopOrWeb ? 0.25 : 0.6,
                  child: _menuButton(
                    label: "👥 Online",
                    color: Colors.cyanAccent,
                    onTap: () {
                      showRetroSnackBar(
                          context, "Online mode will be added soon!");
                    },
                  ),
                ),
                const Spacer(flex: 3),
                Text(
                  "© Retro Cricket 2025",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade400,
                    fontFamily: "monospace",
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 🔹 Step 1: Batting/Bowling dialog
  Future<String?> _showBatBowlDialog(BuildContext context) {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: const [
              BoxShadow(
                color: Colors.white24,
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Choose Batting or Bowling",
                style: TextStyle(
                  color: Colors.yellowAccent,
                  fontFamily: "monospace",
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _batBowlButton(
                    context,
                    "bat",
                    "assets/batting_icon.png",
                    glowColor: Colors.blueAccent,
                  ),
                  _batBowlButton(
                    context,
                    "bowl",
                    "assets/bowling_icon.png",
                    glowColor: Colors.redAccent,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _batBowlButton(
    BuildContext context,
    String value,
    String asset, {
    required Color glowColor,
  }) {
    return InkWell(
      onTap: () => Navigator.pop(context, value),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              border: Border.all(color: glowColor, width: 2),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: glowColor,
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Image.asset(asset, width: 60, height: 60),
          ),
          const SizedBox(height: 8),
          Text(
            value == "bat" ? "Batting" : "Bowling",
            style: const TextStyle(
              color: Colors.white,
              fontFamily: "monospace",
            ),
          )
        ],
      ),
    );
  }

  Future<Map<String, int>?> _showWicketsOversDialog(BuildContext context) {
    int? selectedWickets;
    int? selectedOvers;

    return showDialog<Map<String, int>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          backgroundColor: Colors.transparent,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: const [
                BoxShadow(
                  color: Colors.white,
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Match Settings",
                  style: TextStyle(
                    color: Colors.yellowAccent,
                    fontFamily: "monospace",
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                // Wickets
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "No. of Wickets:",
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: "monospace",
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [1, 3, 5].map((w) {
                    final isSelected = selectedWickets == w;
                    return _retroOptionButton(
                      label: "$w",
                      isSelected: isSelected,
                      onTap: () => setState(() => selectedWickets = w),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // Overs
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "No. of Overs:",
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: "monospace",
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 12,
                  runSpacing: 8,
                  children: [1, 5, 10, -1].map((o) {
                    final isSelected = selectedOvers == o;
                    return _retroOptionButton(
                      label: o == -1 ? "Test" : "$o",
                      isSelected: isSelected,
                      onTap: () => setState(() => selectedOvers = o),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.cyanAccent,
                    side: const BorderSide(color: Colors.cyanAccent, width: 2),
                  ),
                  onPressed: (selectedWickets != null && selectedOvers != null)
                      ? () => Navigator.pop(context, {
                            "wickets": selectedWickets!,
                            "overs": selectedOvers!,
                          })
                      : null,
                  child: const Text(
                    "Start Match",
                    style: TextStyle(fontFamily: "monospace"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _retroOptionButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.cyanAccent : Colors.black,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.cyanAccent, width: 2),
          boxShadow: isSelected
              ? [
                  const BoxShadow(
                    color: Colors.cyanAccent,
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.cyanAccent,
            fontFamily: "monospace",
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void showRetroSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.yellowAccent,
          border: Border.all(color: Colors.black, width: 3),
          boxShadow: const [
            BoxShadow(color: Colors.black, offset: Offset(3, 3)),
          ],
        ),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            fontFamily: "monospace",
            color: Colors.black,
          ),
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 1),
      margin: const EdgeInsets.only(bottom: 30, left: 30, right: 30),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Widget _menuButton({
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: color,
          side: BorderSide(color: color, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          shadowColor: color,
          elevation: 10,
        ),
        onPressed: onTap,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 18,
              fontFamily: "monospace",
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}
