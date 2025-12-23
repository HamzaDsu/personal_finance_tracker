import 'package:equatable/equatable.dart';

import '../../../../core/utils/date_range.dart';
import '../../domain/entities/transaction_entity.dart';
import 'transaction_filter.dart';

enum TransactionStatus { initial, loading, success, failure }

class TransactionState extends Equatable {
  final TransactionStatus status;
  final List<TransactionEntity> transactions;
  final TransactionFilter filter;
  final DateRange? dateRange;
  final String? errorMessage;

  const TransactionState({
    required this.status,
    required this.transactions,
    required this.filter,
    required this.dateRange,
    required this.errorMessage,
  });

  const TransactionState.initial()
    : status = TransactionStatus.initial,
      transactions = const [],
      filter = TransactionFilter.all,
      dateRange = null,
      errorMessage = null;

  TransactionState copyWith({
    TransactionStatus? status,
    List<TransactionEntity>? transactions,
    TransactionFilter? filter,
    DateRange? dateRange,
    bool clearDateRange = false,
    String? errorMessage,
  }) {
    return TransactionState(
      status: status ?? this.status,
      transactions: transactions ?? this.transactions,
      filter: filter ?? this.filter,
      dateRange: clearDateRange ? null : (dateRange ?? this.dateRange),
      errorMessage: errorMessage,
    );
  }

  double get totalIncome {
    return transactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get totalExpense {
    return transactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get balance => totalIncome - totalExpense;

  List<TransactionEntity> get visibleTransactions {
    Iterable<TransactionEntity> list = transactions;

    // Type filter
    if (filter == TransactionFilter.income) {
      list = list.where((t) => t.type == TransactionType.income);
    } else if (filter == TransactionFilter.expense) {
      list = list.where((t) => t.type == TransactionType.expense);
    }

    // Date range filter
    if (dateRange != null) {
      list = list.where((t) => dateRange!.contains(t.date));
    }

    return list.toList();
  }

  @override
  List<Object?> get props => [
    status,
    transactions,
    filter,
    dateRange,
    errorMessage,
  ];
}
