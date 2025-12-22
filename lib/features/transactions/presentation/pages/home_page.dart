import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/theme/theme_cubit.dart';
import '../../../../app/theme/theme_state.dart';
import '../bloc/transaction_bloc.dart';
import '../bloc/transaction_event.dart';
import '../bloc/transaction_state.dart';
import '../widgets/balance_header.dart';
import '../widgets/filter_chips.dart';
import '../widgets/transaction_list.dart';
import 'add_transaction_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Personal Finance Tracker'),
            actions: [
              IconButton(
                tooltip: themeState.isDark ? 'Switch to Light' : 'Switch to Dark',
                onPressed: () => context.read<ThemeCubit>().toggleTheme(),
                icon: Icon(themeState.isDark ? Icons.light_mode : Icons.dark_mode),
              ),
            ],
          ),
          body: BlocConsumer<TransactionBloc, TransactionState>(
            listenWhen: (prev, curr) => prev.status != curr.status,
            listener: (context, state) {
              if (state.status == TransactionStatus.failure) {
                final msg = state.errorMessage ?? 'Something went wrong';
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(msg)),
                );
              }
            },
            builder: (context, state) {
              if (state.status == TransactionStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              }

              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    BalanceHeader(
                      balance: state.balance,
                      income: state.totalIncome,
                      expense: state.totalExpense,
                    ),
                    const SizedBox(height: 12),
                    FilterChips(
                      current: state.filter,
                      onChanged: (f) => context
                          .read<TransactionBloc>()
                          .add(ChangeTransactionFilter(f)),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: TransactionList(
                        transactions: state.visibleTransactions,
                        onTap: (tx) async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => AddTransactionPage(initial: tx),
                            ),
                          );
                        },
                        onDelete: (id) {
                          context
                              .read<TransactionBloc>()
                              .add(DeleteTransactionRequested(id));

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Transaction deleted')),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AddTransactionPage()),
              );
            },
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}
