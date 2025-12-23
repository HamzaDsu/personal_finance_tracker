import 'package:equatable/equatable.dart';

class DateRange extends Equatable {
  final DateTime start;
  final DateTime end;

  const DateRange({
    required this.start,
    required this.end,
  });

  bool contains(DateTime d) {
    final s = DateTime(start.year, start.month, start.day);
    final e = DateTime(end.year, end.month, end.day, 23, 59, 59, 999);
    return !d.isBefore(s) && !d.isAfter(e);
  }

  @override
  List<Object?> get props => [start, end];
}
