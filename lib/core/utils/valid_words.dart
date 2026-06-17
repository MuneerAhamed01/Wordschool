import 'package:flutter/services.dart';

class ValidWords {
  final List<String> _validWords = [];
  final List<String> _answerWords = [];

  List<String> get validWords => _validWords;
  List<String> get answerWords => _answerWords;

  Future<void> loadWords() async {
    if (_validWords.isNotEmpty) return;

    final guessData = await rootBundle.loadString('assets/words/words.txt');
    _validWords.addAll(
      guessData.split('\n').map((e) => e.trim().toLowerCase()).where((e) => e.length == 5),
    );

    final answerData = await rootBundle.loadString('assets/words/answers.txt');
    _answerWords.addAll(
      answerData.split('\n').map((e) => e.trim().toLowerCase()).where((e) => e.length == 5),
    );
  }

  bool checkIsValidWord(String word) {
    return _validWords.contains(word.toLowerCase());
  }
}
