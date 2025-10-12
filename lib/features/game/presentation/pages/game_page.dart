import 'package:flutter/material.dart';

class GamePage extends StatelessWidget {
  static const String routeName = '/game';
  const GamePage({super.key});

  void onPressed() {
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: ElevatedButton(onPressed: onPressed, child: const Text('Sign Out'))),
    );
  }
}
