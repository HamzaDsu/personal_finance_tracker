import 'package:equatable/equatable.dart';

import '../../../../core/utils/date_range.dart';
import '../../domain/entities/transaction_entity.dart';
import 'transaction_filter.dart';

sealed class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object?> get props => [];
}

class LoadTransactions extends TransactionEvent {
  const LoadTransactions();
}

class AddTransactionRequested extends TransactionEvent {
  final TransactionEntity transaction;

  const AddTransactionRequested(this.transaction);

  @override
  List<Object?> get props => [transaction];
}

class UpdateTransactionRequested extends TransactionEvent {
  final TransactionEntity transaction;

  const UpdateTransactionRequested(this.transaction);

  @override
  List<Object?> get props => [transaction];
}

class DeleteTransactionRequested extends TransactionEvent {
  final String id;

  const DeleteTransactionRequested(this.id);

  @override
  List<Object?> get props => [id];
}

class ChangeTransactionFilter extends TransactionEvent {
  final TransactionFilter filter;

  const ChangeTransactionFilter(this.filter);

  @override
  List<Object?> get props => [filter];
}

class SetDateRange extends TransactionEvent {
  final DateRange range;

  const SetDateRange(this.range);

  @override
  List<Object?> get props => [range];
}

class ClearDateRange extends TransactionEvent {
  const ClearDateRange();
}
