import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/usecases/add_transaction.dart';
import '../../domain/usecases/delete_transaction.dart';
import '../../domain/usecases/get_transactions.dart';
import '../../domain/usecases/update_transaction.dart';
import 'transaction_event.dart';
import 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final GetTransactions _getTransactions;
  final AddTransaction _addTransaction;
  final UpdateTransaction _updateTransaction;
  final DeleteTransaction _deleteTransaction;

  TransactionBloc({
    required GetTransactions getTransactions,
    required AddTransaction addTransaction,
    required UpdateTransaction updateTransaction,
    required DeleteTransaction deleteTransaction,
  }) : _getTransactions = getTransactions,
       _addTransaction = addTransaction,
       _updateTransaction = updateTransaction,
       _deleteTransaction = deleteTransaction,
       super(const TransactionState.initial()) {
    on<LoadTransactions>(_onLoadTransactions);
    on<AddTransactionRequested>(_onAddTransactionRequested);
    on<UpdateTransactionRequested>(_onUpdateTransactionRequested);
    on<DeleteTransactionRequested>(_onDeleteTransactionRequested);
    on<ChangeTransactionFilter>(_onChangeFilter);
    on<SetDateRange>(_onSetDateRange);
    on<ClearDateRange>(_onClearDateRange);
  }

  String _messageFromError(Object e) {
    if (e is Failure) return e.message;
    return 'Something went wrong';
  }

  Future<void> _onLoadTransactions(
    LoadTransactions event,
    Emitter<TransactionState> emit,
  ) async {
    emit(state.copyWith(status: TransactionStatus.loading, errorMessage: null));
    try {
      final tx = await _getTransactions();
      emit(state.copyWith(status: TransactionStatus.success, transactions: tx));
    } catch (e) {
      emit(
        state.copyWith(
          status: TransactionStatus.failure,
          errorMessage: _messageFromError(e),
        ),
      );
    }
  }

  Future<void> _onAddTransactionRequested(
    AddTransactionRequested event,
    Emitter<TransactionState> emit,
  ) async {
    emit(state.copyWith(status: TransactionStatus.loading, errorMessage: null));
    try {
      await _addTransaction(event.transaction);
      final updated = await _getTransactions();
      emit(
        state.copyWith(
          status: TransactionStatus.success,
          transactions: updated,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: TransactionStatus.failure,
          errorMessage: _messageFromError(e),
        ),
      );
    }
  }

  Future<void> _onUpdateTransactionRequested(
    UpdateTransactionRequested event,
    Emitter<TransactionState> emit,
  ) async {
    emit(state.copyWith(status: TransactionStatus.loading, errorMessage: null));
    try {
      await _updateTransaction(event.transaction);
      final updated = await _getTransactions();
      emit(
        state.copyWith(
          status: TransactionStatus.success,
          transactions: updated,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: TransactionStatus.failure,
          errorMessage: _messageFromError(e),
        ),
      );
    }
  }

  Future<void> _onDeleteTransactionRequested(
    DeleteTransactionRequested event,
    Emitter<TransactionState> emit,
  ) async {
    emit(state.copyWith(status: TransactionStatus.loading, errorMessage: null));
    try {
      await _deleteTransaction(event.id);
      final updated = await _getTransactions();
      emit(
        state.copyWith(
          status: TransactionStatus.success,
          transactions: updated,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: TransactionStatus.failure,
          errorMessage: _messageFromError(e),
        ),
      );
    }
  }

  void _onChangeFilter(
    ChangeTransactionFilter event,
    Emitter<TransactionState> emit,
  ) {
    emit(state.copyWith(filter: event.filter));
  }

  void _onSetDateRange(SetDateRange event, Emitter<TransactionState> emit) {
    emit(state.copyWith(dateRange: event.range));
  }

  void _onClearDateRange(ClearDateRange event, Emitter<TransactionState> emit) {
    emit(state.copyWith(clearDateRange: true));
  }
}
