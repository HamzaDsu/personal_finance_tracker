import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:personal_finance_tracker/core/ui/category_colors.dart';

class CategoryPieChart extends StatelessWidget {
  final Map<String, double> data;

  const CategoryPieChart({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: Text('No expense data to display'));
    }

    final total = data.values.fold<double>(0, (a, b) => a + b);

    final entries = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value)); // biggest first

    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 45,
        sections: entries.map((e) {
          final percent = (e.value / total) * 100;
          final showTitle = percent >= 8; // hide tiny labels

          return PieChartSectionData(
            color: CategoryColors.forCategory(e.key),
            value: e.value,
            radius: 55,
            title: showTitle ? '${percent.toStringAsFixed(0)}%' : '',
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        }).toList(),
      ),
    );
  }
}
