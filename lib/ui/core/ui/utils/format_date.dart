import 'package:intl/intl.dart';

String? formatDate(DateTime? date, {String? customFormat}) {
  if (date == null) return null;

  final DateFormat formatter = DateFormat(customFormat ?? 'dd/MM/yyyy');
  return formatter.format(date);
}