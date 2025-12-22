import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:personal_finance_tracker/features/transactions/domain/entities/transaction_entity.dart';
import 'package:personal_finance_tracker/features/transactions/domain/usecases/add_transaction.dart';
import 'package:personal_finance_tracker/features/transactions/domain/usecases/delete_transaction.dart';
import 'package:personal_finance_tracker/features/transactions/domain/usecases/get_transactions.dart';
import 'package:personal_finance_tracker/features/transactions/domain/usecases/update_transaction.dart';
import 'package:personal_finance_tracker/features/transactions/presentation/bloc/transaction_bloc.dart';
import 'package:personal_finance_tracker/features/transactions/presentation/bloc/transaction_event.dart';
import 'package:personal_finance_tracker/features/transactions/presentation/bloc/transaction_filter.dart';
import 'package:personal_finance_tracker/features/transactions/presentation/bloc/transaction_state.dart';

class MockGetTransactions extends Mock implements GetTransactions {}

class MockAddTransaction extends Mock implements AddTransaction {}

class MockUpdateTransaction extends Mock implements UpdateTransaction {}

class MockDeleteTransaction extends Mock implements DeleteTransaction {}

void main() {
  late MockGetTransactions mockGetTransactions;
  late MockAddTransaction mockAddTransaction;
  late MockUpdateTransaction mockUpdateTransaction;
  late MockDeleteTransaction mockDeleteTransaction;

  TransactionEntity tx({
    String id = 't1',
    TransactionType type = TransactionType.expense,
    double amount = 10,
    String category = 'Food',
    DateTime? date,
    String? notes,
  }) {
    return TransactionEntity(
      id: id,
      type: type,
      amount: amount,
      category: category,
      date: date ?? DateTime(2025, 1, 1),
      notes: notes,
    );
  }

  setUpAll(() {
    // Needed for mocktail's any<TransactionEntity>()
    registerFallbackValue(
      TransactionEntity(
        id: 'fallback',
        type: TransactionType.expense,
        amount: 1,
        category: 'General',
        date: DateTime(2025, 1, 1),
        notes: null,
      ),
    );
  });

  setUp(() {
    mockGetTransactions = MockGetTransactions();
    mockAddTransaction = MockAddTransaction();
    mockUpdateTransaction = MockUpdateTransaction();
    mockDeleteTransaction = MockDeleteTransaction();
  });

  TransactionBloc buildBloc() {
    return TransactionBloc(
      getTransactions: mockGetTransactions,
      addTransaction: mockAddTransaction,
      updateTransaction: mockUpdateTransaction,
      deleteTransaction: mockDeleteTransaction,
    );
  }

  group('TransactionBloc', () {
    test('initial state is TransactionState.initial()', () {
      final bloc = buildBloc();
      expect(bloc.state, const TransactionState.initial());
      bloc.close();
    });

    blocTest<TransactionBloc, TransactionState>(
      'emits [loading, success] with transactions when LoadTransactions succeeds',
      build: () {
        when(() => mockGetTransactions()).thenAnswer((_) async => [
          tx(id: '1', type: TransactionType.income, amount: 100, category: 'Salary'),
          tx(id: '2', type: TransactionType.expense, amount: 30, category: 'Food'),
        ]);
        return buildBloc();
      },
      act: (bloc) => bloc.add(const LoadTransactions()),
      expect: () => [
        const TransactionState.initial()
            .copyWith(status: TransactionStatus.loading, errorMessage: null),
        predicate<TransactionState>((s) {
          return s.status == TransactionStatus.success &&
              s.transactions.length == 2 &&
              s.balance == 70; // 100 - 30
        }),
      ],
      verify: (_) {
        verify(() => mockGetTransactions()).called(1);
      },
    );

    blocTest<TransactionBloc, TransactionState>(
      'emits [loading, failure] when LoadTransactions throws',
      build: () {
        when(() => mockGetTransactions()).thenThrow(Exception('boom'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const LoadTransactions()),
      expect: () => [
        const TransactionState.initial()
            .copyWith(status: TransactionStatus.loading, errorMessage: null),
        predicate<TransactionState>((s) =>
        s.status == TransactionStatus.failure &&
            (s.errorMessage ?? '').isNotEmpty),
      ],
    );

    blocTest<TransactionBloc, TransactionState>(
      'AddTransactionRequested: emits loading then success and reloads list',
      build: () {
        when(() => mockAddTransaction(any())).thenAnswer((_) async {});
        when(() => mockGetTransactions()).thenAnswer((_) async => [
          tx(id: '1', type: TransactionType.expense, amount: 20, category: 'Food'),
        ]);
        return buildBloc();
      },
      act: (bloc) => bloc.add(AddTransactionRequested(
        tx(id: 'new', type: TransactionType.expense, amount: 20, category: 'Food'),
      )),
      expect: () => [
        const TransactionState.initial()
            .copyWith(status: TransactionStatus.loading, errorMessage: null),
        predicate<TransactionState>((s) =>
        s.status == TransactionStatus.success &&
            s.transactions.length == 1 &&
            s.totalExpense == 20),
      ],
      verify: (_) {
        verify(() => mockAddTransaction(any())).called(1);
        verify(() => mockGetTransactions()).called(1);
      },
    );

    blocTest<TransactionBloc, TransactionState>(
      'UpdateTransactionRequested: emits loading then success and reloads list',
      build: () {
        when(() => mockUpdateTransaction(any())).thenAnswer((_) async {});
        when(() => mockGetTransactions()).thenAnswer((_) async => [
          tx(id: '1', type: TransactionType.expense, amount: 99, category: 'Bills'),
        ]);
        return buildBloc();
      },
      act: (bloc) => bloc.add(UpdateTransactionRequested(
        tx(id: '1', type: TransactionType.expense, amount: 99, category: 'Bills'),
      )),
      expect: () => [
        const TransactionState.initial()
            .copyWith(status: TransactionStatus.loading, errorMessage: null),
        predicate<TransactionState>((s) =>
        s.status == TransactionStatus.success &&
            s.transactions.single.amount == 99),
      ],
      verify: (_) {
        verify(() => mockUpdateTransaction(any())).called(1);
        verify(() => mockGetTransactions()).called(1);
      },
    );

    blocTest<TransactionBloc, TransactionState>(
      'DeleteTransactionRequested: emits loading then success and reloads list',
      build: () {
        when(() => mockDeleteTransaction(any())).thenAnswer((_) async {});
        when(() => mockGetTransactions()).thenAnswer((_) async => []);
        return buildBloc();
      },
      act: (bloc) => bloc.add(const DeleteTransactionRequested('1')),
      expect: () => [
        const TransactionState.initial()
            .copyWith(status: TransactionStatus.loading, errorMessage: null),
        predicate<TransactionState>((s) =>
        s.status == TransactionStatus.success && s.transactions.isEmpty),
      ],
      verify: (_) {
        verify(() => mockDeleteTransaction('1')).called(1);
        verify(() => mockGetTransactions()).called(1);
      },
    );

    blocTest<TransactionBloc, TransactionState>(
      'ChangeTransactionFilter updates filter without touching data',
      build: () => buildBloc(),
      act: (bloc) => bloc.add(const ChangeTransactionFilter(TransactionFilter.income)),
      expect: () => [
        const TransactionState.initial().copyWith(filter: TransactionFilter.income),
      ],
    );
  });
}
