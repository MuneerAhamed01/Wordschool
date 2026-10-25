// Minimal CSV/TSV reader and writer (RFC 4180 quoting) for bulk upload.

/// Rows of cells. Handles quoted cells with commas, quotes ("") and line
/// breaks, CRLF line ends and a UTF-8 byte-order mark. When the first line has
/// tabs but no commas (cells copied from Google Sheets), tabs separate cells.
List<List<String>> parseCsv(String text) {
  var input = text.startsWith('\uFEFF') ? text.substring(1) : text;
  input = input.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
  final firstLine = input.split('\n').first;
  final separator =
      firstLine.contains('\t') && !firstLine.contains(',') ? '\t' : ',';

  final rows = <List<String>>[];
  var row = <String>[];
  final cell = StringBuffer();
  var inQuotes = false;
  var cellStarted = false;

  void endCell() {
    row.add(cell.toString());
    cell.clear();
    cellStarted = false;
  }

  void endRow() {
    endCell();
    if (!(row.length == 1 && row.first.trim().isEmpty)) rows.add(row);
    row = <String>[];
  }

  for (var i = 0; i < input.length; i++) {
    final ch = input[i];
    if (inQuotes) {
      if (ch == '"') {
        if (i + 1 < input.length && input[i + 1] == '"') {
          cell.write('"');
          i++;
        } else {
          inQuotes = false;
        }
      } else {
        cell.write(ch);
      }
    } else if (ch == '"' && !cellStarted) {
      inQuotes = true;
      cellStarted = true;
    } else if (ch == separator) {
      endCell();
    } else if (ch == '\n') {
      endRow();
    } else {
      cell.write(ch);
      cellStarted = true;
    }
  }
  if (cell.isNotEmpty || row.isNotEmpty) endRow();
  return rows;
}

/// One CSV line, quoting cells that need it.
String toCsvLine(List<String> cells) => cells.map((cell) {
      final needsQuotes =
          cell.contains(',') || cell.contains('"') || cell.contains('\n');
      return needsQuotes ? '"${cell.replaceAll('"', '""')}"' : cell;
    }).join(',');
