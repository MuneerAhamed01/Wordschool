import 'package:flutter/material.dart';

class GamePage extends StatelessWidget {
  static const String routeName = '/game';
  const GamePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Game Page')),
    );
  }
}
