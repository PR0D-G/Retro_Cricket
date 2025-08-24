import 'package:flutter/material.dart';
import 'screens/menu_screen.dart';

void main() {
  runApp(const RetroHandCricket());
}

class RetroHandCricket extends StatelessWidget {
  const RetroHandCricket({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Retro Hand Cricket',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const MenuScreen(),
    );
  }
}
