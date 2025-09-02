class Operation {
  final int operationsId;
  DateTime operationsDate;
  String operationsName;
  double operationsAmount;
  String operationsSource;
  String operationsDestination;
  double operationsCosts;
  String operationsCategory;
  bool operationsValidated;
  String operationsRedundancy;
  DateTime operationsCreatedAt;

  Operation({
    required this.operationsId,
    required this.operationsDate,
    required this.operationsName,
    required this.operationsAmount,
    required this.operationsSource,
    required this.operationsDestination,
    required this.operationsCosts,
    required this.operationsCategory,
    required this.operationsValidated,
    required this.operationsRedundancy,
    required this.operationsCreatedAt,
  });

  factory Operation.fromJson(Map<String, dynamic> j) {
    // robust parsing helpers
    int parseId(dynamic v) {
      if (v is int) return v;
      return int.tryParse(v?.toString() ?? '') ?? 0;
    }

    double parseDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    DateTime parseDate(dynamic v, [DateTime? fallback]) {
      if (v == null) return fallback ?? DateTime.now();
      if (v is DateTime) return v;
      return DateTime.tryParse(v.toString()) ?? (fallback ?? DateTime.now());
    }

    bool parseBool(dynamic v) {
      if (v is bool) return v;
      if (v is num) return v != 0;
      final s = v?.toString().toLowerCase();
      return s == 'true' || s == '1';
    }

    final dateStr = j['operations_date'] ?? j['date'];
    final createdAtStr = j['operations_createdat'] ?? j['operations_created_at'] ?? j['operations_date'];

    return Operation(
      operationsId: parseId(j['operations_id'] ?? 0),
      operationsDate: parseDate(dateStr),
      operationsName: j['operations_name'] ?? '',
      operationsAmount: parseDouble(j['operations_amount'] ?? j['amount'] ?? 0),
      operationsSource: j['operations_source'] ?? '',
      operationsDestination: j['operations_destination'] ?? '',
      operationsCosts: parseDouble(j['operations_costs'] ?? j['costs'] ?? 0),
      operationsCategory: j['operations_category'] ?? '',
      operationsValidated: parseBool(j['operations_validated'] ?? j['validated'] ?? false),
      operationsRedundancy: j['operations_redundancy'] ?? '',
      operationsCreatedAt: parseDate(createdAtStr, DateTime.now()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'operations_date': operationsDate.toUtc().toIso8601String(),
      'operations_name': operationsName,
      'operations_amount': operationsAmount,
      'operations_source': operationsSource,
      'operations_destination': operationsDestination,
      'operations_costs': operationsCosts,
      'operations_category': operationsCategory,
      'operations_validated': operationsValidated,
    };
  }

  // convenience getters for charts/ui
  double get amount => operationsAmount;
  DateTime get date => operationsDate;
  String get name => operationsName;
  String get category => operationsCategory;
}