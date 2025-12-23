import 'package:flutter/material.dart';
import 'package:personal_finance_tracker/core/ui/category_colors.dart';

import '../../../../core/utils/formatters.dart';

class CategoryLegend extends StatelessWidget {
  final Map<String, double> data;

  const CategoryLegend({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final entries = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: entries.map((e) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Icon(
                Icons.circle,
                size: 10,
                color: CategoryColors.forCategory(e.key),
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(e.key)),
              Text(Formatters.money(e.value)),
            ],
          ),
        );
      }).toList(),
    );
  }
}
