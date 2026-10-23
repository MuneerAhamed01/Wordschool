import 'dart:convert';

/// Answer encoding shared with the server (CW-014, DEC-003).
///
/// `answerEnc = base64(utf8(answer) XOR utf8(puzzleId + ":" + wordId))`, key
/// repeated over the answer. **Obfuscation, not security** — lets Check and
/// Reveal work offline; `submitCrossword` re-scores against the private key.
/// Python twin: `functions/crossword/answer_encoding.py`; both are tested
/// against `test/fixtures/answer_encoding.json`.
String encodeAnswer(String answer, String puzzleId, String wordId) {
  return base64.encode(_xor(utf8.encode(answer), puzzleId, wordId));
}

/// Reverses [encodeAnswer].
String decodeAnswer(String answerEnc, String puzzleId, String wordId) {
  return utf8.decode(_xor(base64.decode(answerEnc), puzzleId, wordId));
}

List<int> _xor(List<int> data, String puzzleId, String wordId) {
  final key = utf8.encode('$puzzleId:$wordId');
  return [
    for (var i = 0; i < data.length; i++) data[i] ^ key[i % key.length],
  ];
}
