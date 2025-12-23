import '../../features/transactions/domain/entities/transaction_entity.dart';

Map<String, double> expenseByCategory(List<TransactionEntity> transactions) {
  final Map<String, double> result = {};

  for (final tx in transactions) {
    if (tx.type != TransactionType.expense) continue;

    result.update(
      tx.category,
          (value) => value + tx.amount,
      ifAbsent: () => tx.amount,
    );
  }

  return result;
}
