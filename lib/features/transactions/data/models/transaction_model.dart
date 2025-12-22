import 'package:hive/hive.dart';

import '../../domain/entities/transaction_entity.dart';


part 'transaction_model.g.dart';

@HiveType(typeId: 1)
class TransactionModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final int type; // 0 = income, 1 = expense

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final String category;

  @HiveField(4)
  final DateTime date;

  @HiveField(5)
  final String? notes;

  TransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.category,
    required this.date,
    this.notes,
  });

  TransactionEntity toEntity() {
    return TransactionEntity(
      id: id,
      type: type == 0 ? TransactionType.income : TransactionType.expense,
      amount: amount,
      category: category,
      date: date,
      notes: notes,
    );
  }

  static TransactionModel fromEntity(TransactionEntity e) {
    return TransactionModel(
      id: e.id,
      type: e.type == TransactionType.income ? 0 : 1,
      amount: e.amount,
      category: e.category,
      date: e.date,
      notes: e.notes,
    );
  }
}
