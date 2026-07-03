class XlsxTable {
  const XlsxTable({
    required this.sheetName,
    required this.headers,
    required this.records,
  });

  final String sheetName;
  final List<String> headers;
  final List<XlsxRecord> records;

  bool get hasHeader => headers.isNotEmpty;
}

class XlsxRecord {
  const XlsxRecord({
    required this.rowIndex,
    required this.values,
  });

  final int rowIndex;
  final Map<String, String> values;

  String operator [](String key) => values[key] ?? '';
}

