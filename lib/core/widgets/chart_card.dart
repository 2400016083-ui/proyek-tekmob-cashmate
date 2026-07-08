import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../data/dummy_data.dart';

/// Small decorative up-trend line used as an accent on balance/profit cards.
class MiniSparkline extends StatelessWidget {
  final Color color;
  final List<double> values;

  const MiniSparkline({
    super.key,
    required this.color,
    this.values = const [2, 4, 3, 5, 4, 6, 8],
  });

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineTouchData: const LineTouchData(enabled: false),
        lineBarsData: [
          LineChartBarData(
            spots: [
              for (var i = 0; i < values.length; i++)
                FlSpot(i.toDouble(), values[i]),
            ],
            isCurved: true,
            color: color,
            barWidth: 2,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(show: false),
          ),
        ],
      ),
    );
  }
}

/// Donut chart for "Pengeluaran Berdasarkan Kategori".
class CategoryDonutChart extends StatelessWidget {
  final List<CategoryBreakdown> data;

  const CategoryDonutChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 120,
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 30,
          sections: [
            for (final item in data)
              PieChartSectionData(
                value: item.percent,
                color: item.color,
                showTitle: false,
                radius: 22,
              ),
          ],
        ),
      ),
    );
  }
}

/// Grouped bar chart for "Pemasukan dan Pengeluaran" per month.
class MonthlyBarChart extends StatelessWidget {
  final List<MonthlyChartPoint> data;

  const MonthlyBarChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final maxY = data
            .map((e) => e.income > e.expense ? e.income : e.expense)
            .fold<double>(0, (a, b) => a > b ? a : b) *
        1.2;

    return SizedBox(
      height: 140,
      child: BarChart(
        BarChartData(
          maxY: maxY,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            leftTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= data.length) {
                    return const SizedBox();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      data[index].month,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.black54,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: [
            for (var i = 0; i < data.length; i++)
              BarChartGroupData(
                x: i,
                barsSpace: 4,
                barRods: [
                  BarChartRodData(
                    toY: data[i].income,
                    color: const Color(0xFF16A34A),
                    width: 7,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  BarChartRodData(
                    toY: data[i].expense,
                    color: const Color(0xFFDC2626),
                    width: 7,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
