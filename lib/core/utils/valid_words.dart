import 'package:flutter/services.dart';

class ValidWords {
  final List<String> _validWords = [];

  List<String> get validWords => _validWords;

  Future<void> loadWords() async {
    final data = await rootBundle.loadString('assets/words/words.txt');
    _validWords.addAll(data.split('\n').map((e) => e.trim().toLowerCase()));
  }

  bool checkIsValidWord(String word) {
    return _validWords.contains(word.toLowerCase());
  }
}
