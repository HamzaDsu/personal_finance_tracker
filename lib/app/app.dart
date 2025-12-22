import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/storage/theme_storage.dart';
import '../features/transactions/data/datasources/transaction_local_datasource.dart';
import '../features/transactions/data/repositories/transaction_repository_impl.dart';
import '../features/transactions/domain/usecases/add_transaction.dart';
import '../features/transactions/domain/usecases/delete_transaction.dart';
import '../features/transactions/domain/usecases/get_transactions.dart';
import '../features/transactions/domain/usecases/update_transaction.dart';
import '../features/transactions/presentation/bloc/transaction_bloc.dart';
import '../features/transactions/presentation/bloc/transaction_event.dart';
import '../features/transactions/presentation/pages/home_page.dart';
import 'theme/app_theme.dart';
import 'theme/theme_cubit.dart';
import 'theme/theme_state.dart';

class FinanceApp extends StatelessWidget {
  const FinanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeStorage = ThemeStorage();

    final local = TransactionLocalDataSource();
    final repo = TransactionRepositoryImpl(local: local);

    final getTransactions = GetTransactions(repo);
    final addTransaction = AddTransaction(repo);
    final updateTransaction = UpdateTransaction(repo);
    final deleteTransaction = DeleteTransaction(repo);

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => ThemeCubit(storage: themeStorage),
        ),
        BlocProvider(
          create: (_) => TransactionBloc(
            getTransactions: getTransactions,
            addTransaction: addTransaction,
            updateTransaction: updateTransaction,
            deleteTransaction: deleteTransaction,
          )..add(const LoadTransactions()),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, state) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Personal Finance Tracker',
            themeMode: state.themeMode,
            theme: AppThemes.light,
            darkTheme: AppThemes.dark,
            home: const HomePage(),
          );
        },
      ),
    );
  }
}
