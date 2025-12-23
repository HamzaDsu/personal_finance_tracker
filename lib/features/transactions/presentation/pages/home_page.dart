import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/theme/theme_cubit.dart';
import '../../../../app/theme/theme_state.dart';
import '../../../../core/utils/category_aggregator.dart';
import '../../../../core/utils/date_range.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/transaction_entity.dart';
import '../bloc/transaction_bloc.dart';
import '../bloc/transaction_event.dart';
import '../bloc/transaction_state.dart';
import '../widgets/balance_header.dart';
import '../widgets/category_legend.dart';
import '../widgets/category_pie_chart.dart';
import '../widgets/filter_chips.dart';
import 'add_transaction_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  DateRange _last30Days() {
    final now = DateTime.now();
    final start = now.subtract(const Duration(days: 30));
    return DateRange(start: start, end: now);
  }

  DateRange _thisMonth() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 0);
    return DateRange(start: start, end: end);
  }

  Future<void> _pickCustomRange(
    BuildContext context,
    TransactionState state,
  ) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(DateTime.now().year - 5),
      lastDate: DateTime(DateTime.now().year + 5),
      initialDateRange: state.dateRange == null
          ? null
          : DateTimeRange(
              start: state.dateRange!.start,
              end: state.dateRange!.end,
            ),
    );

    if (picked != null) {
      context.read<TransactionBloc>().add(
        SetDateRange(DateRange(start: picked.start, end: picked.end)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Personal Finance Tracker'),
            actions: [
              IconButton(
                tooltip: themeState.isDark
                    ? 'Switch to Light'
                    : 'Switch to Dark',
                onPressed: () => context.read<ThemeCubit>().toggleTheme(),
                icon: Icon(
                  themeState.isDark ? Icons.light_mode : Icons.dark_mode,
                ),
              ),
            ],
          ),
          body: BlocConsumer<TransactionBloc, TransactionState>(
            listenWhen: (prev, curr) => prev.status != curr.status,
            listener: (context, state) {
              if (state.status == TransactionStatus.failure) {
                final msg = state.errorMessage ?? 'Something went wrong';
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(msg)));
              }
            },
            builder: (context, state) {
              if (state.status == TransactionStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              }

              final expenseData = expenseByCategory(state.visibleTransactions);

              return CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        BalanceHeader(
                          balance: state.balance,
                          income: state.totalIncome,
                          expense: state.totalExpense,
                        ),
                        const SizedBox(height: 12),

                        FilterChips(
                          current: state.filter,
                          onChanged: (f) => context.read<TransactionBloc>().add(
                            ChangeTransactionFilter(f),
                          ),
                        ),
                        const SizedBox(height: 12),

                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => context
                                    .read<TransactionBloc>()
                                    .add(SetDateRange(_thisMonth())),
                                child: const Text('This Month'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => context
                                    .read<TransactionBloc>()
                                    .add(SetDateRange(_last30Days())),
                                child: const Text('Last 30 Days'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () =>
                                    _pickCustomRange(context, state),
                                icon: const Icon(Icons.date_range),
                                label: Text(
                                  state.dateRange == null
                                      ? 'Custom Range'
                                      : '${Formatters.date(state.dateRange!.start)} - ${Formatters.date(state.dateRange!.end)}',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (state.dateRange != null)
                              IconButton(
                                tooltip: 'Clear date filter',
                                onPressed: () => context
                                    .read<TransactionBloc>()
                                    .add(const ClearDateRange()),
                                icon: const Icon(Icons.clear),
                              ),
                          ],
                        ),

                        if (expenseData.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Text(
                            'Spending by Category',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 220,
                            child: CategoryPieChart(data: expenseData),
                          ),
                          const SizedBox(height: 8),
                          CategoryLegend(data: expenseData),
                        ],

                        const SizedBox(height: 16),
                        Text(
                          'Transactions',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                      ]),
                    ),
                  ),

                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final tx = state.visibleTransactions[index];

                        final isIncome = tx.type == TransactionType.income;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Dismissible(
                            key: ValueKey(tx.id),
                            direction: DismissDirection.endToStart,
                            confirmDismiss: (_) async {
                              return await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('Delete transaction?'),
                                      content: const Text(
                                        'This action cannot be undone.',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(ctx).pop(false),
                                          child: const Text('Cancel'),
                                        ),
                                        FilledButton(
                                          onPressed: () =>
                                              Navigator.of(ctx).pop(true),
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                    ),
                                  ) ??
                                  false;
                            },
                            onDismissed: (_) {
                              context.read<TransactionBloc>().add(
                                DeleteTransactionRequested(tx.id),
                              );

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Transaction deleted'),
                                ),
                              );
                            },
                            background: Container(
                              padding: const EdgeInsets.only(right: 16),
                              alignment: Alignment.centerRight,
                              child: const Icon(Icons.delete),
                            ),
                            child: Card(
                              child: ListTile(
                                onTap: () async {
                                  await Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          AddTransactionPage(initial: tx),
                                    ),
                                  );
                                },
                                leading: CircleAvatar(
                                  child: Icon(
                                    isIncome
                                        ? Icons.south_west
                                        : Icons.north_east,
                                  ),
                                ),
                                title: Text(tx.category),
                                subtitle: Text(
                                  [
                                    Formatters.date(tx.date),
                                    if ((tx.notes ?? '').trim().isNotEmpty)
                                      tx.notes!.trim(),
                                  ].join(' • '),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: Text(
                                  '${isIncome ? '+' : '-'} ${Formatters.money(tx.amount)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }, childCount: state.visibleTransactions.length),
                    ),
                  ),
                ],
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
