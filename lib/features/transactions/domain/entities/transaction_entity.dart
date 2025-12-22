import 'package:equatable/equatable.dart';

enum TransactionType { income, expense }

class TransactionEntity extends Equatable {
  final String id;
  final TransactionType type;
  final double amount;
  final String category;
  final DateTime date;
  final String? notes;

  const TransactionEntity({
    required this.id,
    required this.type,
    required this.amount,
    required this.category,
    required this.date,
    this.notes,
  });

  @override
  List<Object?> get props => [id, type, amount, category, date, notes];
}
