import 'package:equatable/equatable.dart';

enum TransactionType { income, expense }

enum TransactionCategory {
  general('General'),
  food('Food'),
  transport('Transport'),
  shopping('Shopping'),
  bills('Bills'),
  health('Health'),
  entertainment('Entertainment'),
  salary('Salary'),
  freelance('Freelance');

  final String displayName;
  const TransactionCategory(this.displayName);
}

class TransactionEntity extends Equatable {
  final String id;
  final TransactionType type;
  final double amount;
  final TransactionCategory category;
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
