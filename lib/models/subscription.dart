class Subscription {
  final int id;
  String label;
  double amount;
  String category;

  String? source;
  String? destination;
  double costs;
  bool active;

  int intervalValue;
  String intervalUnit; // 'days' | 'weeks' | 'months'

  DateTime startDate;
  DateTime? endDate;
  int? dayOfMonth;
  DateTime? lastGeneratedAt;

  final int userId;
  DateTime createdAt;
  DateTime updatedAt;

  Subscription({
    required this.id,
    required this.label,
    required this.amount,
    required this.category,
    this.source,
    this.destination,
    required this.costs,
    required this.active,
    required this.intervalValue,
    required this.intervalUnit,
    required this.startDate,
    this.endDate,
    this.dayOfMonth,
    this.lastGeneratedAt,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Subscription.fromJson(Map<String, dynamic> j) {
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

    return Subscription(
      id: parseId(j['id']),
      label: j['label'] ?? '',
      amount: parseDouble(j['amount']),
      category: j['category'] ?? '',
      source: j['source'],
      destination: j['destination'],
      costs: parseDouble(j['costs']),
      active: parseBool(j['active']),
      intervalValue: (j['interval_value'] is int) ? j['interval_value'] : int.tryParse(j['interval_value']?.toString() ?? '') ?? 1,
      intervalUnit: j['interval_unit'] ?? 'months',
      startDate: parseDate(j['start_date']),
      endDate: j['end_date'] == null ? null : parseDate(j['end_date']),
      dayOfMonth: j['day_of_month'] == null ? null : (j['day_of_month'] is int ? j['day_of_month'] : int.tryParse(j['day_of_month']?.toString() ?? '')),
      lastGeneratedAt: j['last_generated_at'] == null ? null : parseDate(j['last_generated_at']),
      userId: parseId(j['user_id']),
      createdAt: parseDate(j['created_at'], DateTime.now()),
      updatedAt: parseDate(j['updated_at'], DateTime.now()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'amount': amount,
      'category': category,
      'source': source,
      'destination': destination,
      'costs': costs,
      'active': active,
      'interval_value': intervalValue,
      'interval_unit': intervalUnit,
      'start_date': "${startDate.year.toString().padLeft(4, '0')}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}",
      'end_date': endDate?.toIso8601String(),
      'day_of_month': dayOfMonth,
      'last_generated_at': lastGeneratedAt?.toIso8601String(),
    };
  }
}
