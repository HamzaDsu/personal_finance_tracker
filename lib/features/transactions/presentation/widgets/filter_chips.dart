import 'package:flutter/material.dart';

import '../bloc/transaction_filter.dart';

class FilterChips extends StatelessWidget {
  final TransactionFilter current;
  final ValueChanged<TransactionFilter> onChanged;

  const FilterChips({
    super.key,
    required this.current,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    ChoiceChip chip(String label, TransactionFilter value) {
      return ChoiceChip(
        label: Text(label),
        selected: current == value,
        onSelected: (_) => onChanged(value),
      );
    }

    return Row(
      children: [
        chip('All', TransactionFilter.all),
        const SizedBox(width: 8),
        chip('Income', TransactionFilter.income),
        const SizedBox(width: 8),
        chip('Expense', TransactionFilter.expense),
      ],
    );
  }
}
