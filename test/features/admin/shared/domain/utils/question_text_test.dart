import 'package:flutter_test/flutter_test.dart';
import 'package:wordshool/features/admin/shared/domain/utils/question_text.dart';

void main() {
  test('normalizeAnswer matches the server', () {
    expect(normalizeAnswer('Vasco da-Gama.'), 'VASCODAGAMA');
    expect(normalizeAnswer(' e. m. s '), 'EMS');
  });

  test('answerProblem', () {
    expect(answerProblem('Vaikom'), isNull);
    expect(answerProblem(''), 'Enter the answer');
    expect(answerProblem('A'), contains('at least 2'));
    expect(answerProblem('വൈക്കം'), contains('A–Z'));
    expect(answerProblem('1924'), contains('A–Z'));
    expect(answerProblem('A' * 16), contains('15 letters'));
  });

  test('toSnake and parseTags', () {
    expect(toSnake(' Kerala History '), 'kerala_history');
    expect(toSnake('Degree-level (2024)'), 'degree_level_2024');
    expect(parseTags('LDC, lgs; Degree level | ldc'),
        ['ldc', 'lgs', 'degree_level']);
    expect(parseTags(''), isEmpty);
  });

  test('humanize', () {
    expect(humanize('kerala_history'), 'Kerala history');
    expect(humanize(''), '');
  });
}
