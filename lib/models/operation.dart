class Operation {
  final int id;
  DateTime levyDate;
  String label;
  double amount;
  String category;

  String? source;
  String? destination;
  double costs;
  bool isValidate;

  final int userId;
  int? subscriptionId;
  DateTime createdAt;
  DateTime updatedAt;

  Operation({
    required this.id,
    required this.levyDate,
    required this.label,
    required this.amount,
    required this.category,

    this.source,
    this.destination,
    required this.costs,
    required this.isValidate,

    required this.userId,
    this.subscriptionId,
    required this.createdAt,
    required this.updatedAt,
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

    final dateStr = j['levy_date'];
    final createdAtStr = j['created_at'];
    final updatedAtStr = j['updated_at'];

    return Operation(
      id: parseId(j['id']),
      levyDate: parseDate(dateStr),
      label: j['label'],
      amount: parseDouble(j['amount']),
      category: j['category'],

      source: j['source'],
      destination: j['destination'],
      costs: parseDouble(j['costs']),
      isValidate: parseBool(j['is_validate']),

      userId: parseId(j['user_id']),
      subscriptionId: j['subscription_id'] == null ? null : parseId(j['subscription_id']),
      createdAt: parseDate(createdAtStr, DateTime.now()),
      updatedAt: parseDate(updatedAtStr, DateTime.now()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'levy_date': levyDate.toIso8601String(),
      'label': label,
      'amount': amount,
      'category': category,
      'source': source,
      'destination': destination,
      'costs': costs,
      'is_validate': isValidate,
    };
  }
}