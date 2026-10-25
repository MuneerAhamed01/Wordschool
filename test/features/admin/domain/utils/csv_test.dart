import 'package:flutter_test/flutter_test.dart';
import 'package:wordshool/features/admin/domain/utils/csv.dart';

void main() {
  test('quoted cells with commas, quotes and line breaks', () {
    const text = 'a,b,c\r\n"x, y","say ""hi""","two\nlines"\r\n';
    expect(parseCsv(text), [
      ['a', 'b', 'c'],
      ['x, y', 'say "hi"', 'two\nlines'],
    ]);
  });

  test('byte-order mark, blank lines and empty cells', () {
    expect(parseCsv('﻿a,b\n\n1,\n'), [
      ['a', 'b'],
      ['1', ''],
    ]);
  });

  test('cells pasted from Google Sheets are tab-separated', () {
    expect(parseCsv('answer\tfact_en\nVaikom\tA fact, with a comma'), [
      ['answer', 'fact_en'],
      ['Vaikom', 'A fact, with a comma'],
    ]);
  });

  test('toCsvLine round-trips', () {
    final cells = ['plain', 'with, comma', 'with "quote"', 'multi\nline'];
    expect(parseCsv(toCsvLine(cells)).single, cells);
  });
}
