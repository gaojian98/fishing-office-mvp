import 'dart:io';
import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:flutter/services.dart';
import 'package:xml/xml.dart';

import 'xlsx_table.dart';

class XlsxWorkbookReader {
  const XlsxWorkbookReader();

  Future<Map<String, XlsxTable>> readAsset(String assetPath) async {
    final data = await rootBundle.load(assetPath);
    return readBytes(data.buffer.asUint8List());
  }

  Future<Map<String, XlsxTable>> readFile(String filePath) async {
    final bytes = await File(filePath).readAsBytes();
    return readBytes(bytes);
  }

  Map<String, XlsxTable> readBytes(Uint8List bytes) {
    final archive = ZipDecoder().decodeBytes(bytes);
    String? readText(String path) {
      for (final file in archive) {
        if (file.name == path) {
          final content = file.content;
          if (content is List<int>) return utf8.decode(content);
          if (content is Uint8List) return utf8.decode(content);
        }
      }
      return null;
    }

    final workbookXml = readText('xl/workbook.xml');
    final relsXml = readText('xl/_rels/workbook.xml.rels');
    if (workbookXml == null || relsXml == null) {
      return const {};
    }

    final workbook = XmlDocument.parse(workbookXml);
    final rels = XmlDocument.parse(relsXml);

    final relMap = <String, String>{};
    for (final rel in rels.findAllElements('Relationship')) {
      final id = rel.getAttribute('Id');
      final target = rel.getAttribute('Target');
      if (id != null && target != null) {
        relMap[id] = _normalizePath(target);
      }
    }

    final sharedStrings = _parseSharedStrings(readText('xl/sharedStrings.xml'));

    final result = <String, XlsxTable>{};
    for (final sheet in workbook.findAllElements('sheet')) {
      final name = sheet.getAttribute('name') ?? '';
      final relId = sheet.getAttribute('r:id');
      if (name.isEmpty || relId == null) continue;
      final target = relMap[relId];
      if (target == null) continue;

      final sheetXml = readText(target);
      if (sheetXml == null) continue;
      result[name] = _parseSheet(name, sheetXml, sharedStrings);
    }
    return result;
  }

  XlsxTable _parseSheet(
    String sheetName,
    String xml,
    List<String> sharedStrings,
  ) {
    final document = XmlDocument.parse(xml);
    final rows = <_RawRow>[];
    for (final row in document.findAllElements('row')) {
      final rowIndex = int.tryParse(row.getAttribute('r') ?? '') ?? rows.length + 1;
      final cells = <int, String>{};
      for (final cell in row.findElements('c')) {
        final ref = cell.getAttribute('r') ?? '';
        final colIndex = _columnIndex(_columnName(ref));
        final type = cell.getAttribute('t');
        final value = _readCellValue(cell, type, sharedStrings);
        cells[colIndex] = value;
      }
      rows.add(_RawRow(rowIndex: rowIndex, cells: cells));
    }

    final headerRowIndex = _detectHeaderRowIndex(rows);
    if (headerRowIndex == -1) {
      return XlsxTable(sheetName: sheetName, headers: const [], records: const []);
    }

    final headerRow = rows[headerRowIndex];
    final headers = _orderedValues(headerRow.cells)
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList(growable: false);

    final records = <XlsxRecord>[];
    for (var i = headerRowIndex + 1; i < rows.length; i++) {
      final row = rows[i];
      if (row.cells.isEmpty) continue;
      final ordered = _orderedValues(row.cells);
      final values = <String, String>{};
      for (var j = 0; j < headers.length; j++) {
        values[headers[j]] = j < ordered.length ? ordered[j] : '';
      }
      if (values.values.every((value) => value.trim().isEmpty)) continue;
      records.add(XlsxRecord(rowIndex: row.rowIndex, values: values));
    }

    return XlsxTable(sheetName: sheetName, headers: headers, records: records);
  }

  int _detectHeaderRowIndex(List<_RawRow> rows) {
    for (var i = 0; i < rows.length; i++) {
      final row = rows[i];
      final values = _orderedValues(row.cells);
      final nonEmpty = values.where((value) => value.trim().isNotEmpty).toList();
      if (nonEmpty.length < 2) continue;
      final textCells = nonEmpty.where((value) => !_looksLikeNumber(value)).length;
      if (textCells >= 2) return i;
    }
    return -1;
  }

  List<String> _parseSharedStrings(String? xml) {
    if (xml == null || xml.isEmpty) return const [];
    final document = XmlDocument.parse(xml);
    return document
        .findAllElements('si')
        .map((si) => si.findAllElements('t').map((t) => t.innerText).join())
        .toList(growable: false);
  }

  String _readCellValue(
    XmlElement cell,
    String? type,
    List<String> sharedStrings,
  ) {
    if (type == 'inlineStr') {
      return cell.findAllElements('t').map((t) => t.innerText).join();
    }
    final valueElement = cell.findElements('v').isNotEmpty
        ? cell.findElements('v').first
        : null;
    final raw = valueElement?.innerText ?? '';
    if (type == 's') {
      final index = int.tryParse(raw) ?? -1;
      if (index >= 0 && index < sharedStrings.length) {
        return sharedStrings[index];
      }
    }
    return raw;
  }

  String _normalizePath(String target) {
    var normalized = target.replaceAll('\\', '/');
    while (normalized.startsWith('../')) {
      normalized = normalized.substring(3);
    }
    if (!normalized.startsWith('xl/')) {
      normalized = 'xl/$normalized';
    }
    return normalized;
  }

  String _columnName(String ref) {
    final match = RegExp(r'[A-Z]+').firstMatch(ref);
    return match?.group(0) ?? '';
  }

  int _columnIndex(String col) {
    var value = 0;
    for (final rune in col.runes) {
      value = value * 26 + (rune - 64);
    }
    return value;
  }

  List<String> _orderedValues(Map<int, String> cells) {
    final entries = cells.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return entries.map((entry) => entry.value).toList(growable: false);
  }

  bool _looksLikeNumber(String value) {
    return double.tryParse(value.replaceAll('%', '').replaceAll(',', '')) != null;
  }
}

class _RawRow {
  const _RawRow({
    required this.rowIndex,
    required this.cells,
  });

  final int rowIndex;
  final Map<int, String> cells;
}
