class BalanceMappingReport {
  const BalanceMappingReport({
    required this.sections,
  });

  final List<BalanceMappingSection> sections;
}

class BalanceMappingSection {
  const BalanceMappingSection({
    required this.fileName,
    required this.sheets,
    required this.directMappings,
    required this.missingFields,
    required this.supplementFields,
  });

  final String fileName;
  final List<BalanceSheetReport> sheets;
  final List<String> directMappings;
  final List<String> missingFields;
  final List<String> supplementFields;
}

class BalanceSheetReport {
  const BalanceSheetReport({
    required this.sheetName,
    required this.fields,
  });

  final String sheetName;
  final List<String> fields;
}

