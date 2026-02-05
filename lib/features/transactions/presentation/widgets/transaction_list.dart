import 'package:flutter/material.dart';
import 'package:personal_finance_tracker/core/constants/app_strings.dart';

import '../../../../core/utils/formatters.dart';
import '../../domain/entities/transaction_entity.dart';

class TransactionList extends StatelessWidget {
  final List<TransactionEntity> transactions;
  final void Function(String id) onDelete;
  final void Function(TransactionEntity tx) onTap;

  const TransactionList({
    super.key,
    required this.transactions,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return const _EmptyState();
    }

    return ListView.separated(
      itemCount: transactions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final t = transactions[i];
        final isIncome = t.type == TransactionType.income;

        return Dismissible(
          key: ValueKey(t.id),
          direction: DismissDirection.endToStart,
          confirmDismiss: (_) async {
            return await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text(AppStrings.deleteTitle),
                content: const Text(AppStrings.deleteContent),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: const Text(AppStrings.cancel),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.of(ctx).pop(true),
                    child: const Text(AppStrings.delete),
                  ),
                ],
              ),
            ) ??
                false;
          },
          background: Container(
            padding: const EdgeInsets.only(right: 16),
            alignment: Alignment.centerRight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.delete),
          ),
          onDismissed: (_) => onDelete(t.id),
          child: Card(
            child: ListTile(
              onTap: () => onTap(t),
              leading: CircleAvatar(
                child: Icon(isIncome ? Icons.south_west : Icons.north_east),
              ),
              title: Text(t.category.displayName),
              subtitle: Text(
                [
                  Formatters.date(t.date),
                  if ((t.notes ?? '').trim().isNotEmpty) t.notes!.trim(),
                ].join(' • '),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Text(
                '${isIncome ? '+' : '-'} ${Formatters.money(t.amount)}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long,
              size: 56,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              AppStrings.noTransactions,
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.emptyStateSub,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
