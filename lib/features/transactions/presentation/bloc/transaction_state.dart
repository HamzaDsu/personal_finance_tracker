import 'package:equatable/equatable.dart';

import '../../domain/entities/transaction_entity.dart';
import 'transaction_filter.dart';

enum TransactionStatus { initial, loading, success, failure }

class TransactionState extends Equatable {
  final TransactionStatus status;
  final List<TransactionEntity> transactions;
  final TransactionFilter filter;
  final String? errorMessage;

  const TransactionState({
    required this.status,
    required this.transactions,
    required this.filter,
    this.errorMessage,
  });

  const TransactionState.initial()
      : status = TransactionStatus.initial,
        transactions = const [],
        filter = TransactionFilter.all,
        errorMessage = null;

  TransactionState copyWith({
    TransactionStatus? status,
    List<TransactionEntity>? transactions,
    TransactionFilter? filter,
    String? errorMessage,
  }) {
    return TransactionState(
      status: status ?? this.status,
      transactions: transactions ?? this.transactions,
      filter: filter ?? this.filter,
      errorMessage: errorMessage,
    );
  }

  List<TransactionEntity> get visibleTransactions {
    return switch (filter) {
      TransactionFilter.all => transactions,
      TransactionFilter.income =>
          transactions.where((t) => t.type == TransactionType.income).toList(),
      TransactionFilter.expense =>
          transactions.where((t) => t.type == TransactionType.expense).toList(),
    };
  }

  double get totalIncome => transactions
      .where((t) => t.type == TransactionType.income)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get totalExpense => transactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get balance => totalIncome - totalExpense;

  @override
  List<Object?> get props => [status, transactions, filter, errorMessage];
}
