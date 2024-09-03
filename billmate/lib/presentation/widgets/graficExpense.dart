import 'package:billmate/core/theme/app_themes.dart';
import 'package:billmate/data/service/expense_service.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:billmate/data/models/expense_model.dart';

class ExpensesChart extends StatelessWidget {
  final ExpenseService expenseService;
  final double fixedIncome; // Renda fixa do usuário

  ExpensesChart({required this.expenseService, required this.fixedIncome});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ExpenseModel>>(
      future: expenseService.getAllExpenses(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
              child: Text('Erro: ${snapshot.error}',
                  style: TextStyle(color: Colors.white)));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
              child: Text('Nenhuma despesa encontrada',
                  style: TextStyle(color: Colors.white)));
        } else {
          final expenses = snapshot.data!;
          final totalExpenses = _calculateTotalExpenses(expenses);

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Comparação de Despesas e Renda Fixa',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 16),
                Expanded(
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: _getMaxY(totalExpenses, fixedIncome),
                      barTouchData: BarTouchData(
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipColor: (totalExpenses) => AppThemes
                              .darkTheme
                              .colorScheme
                              .error, // Ajuste de cor de fundo
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            return BarTooltipItem(
                              rod.toY.toString(),
                              TextStyle(color: Colors.white),
                            );
                          },
                        ),
                        touchCallback:
                            (FlTouchEvent event, BarTouchResponse? response) {
                          // Implementar a lógica desejada para o evento de toque
                          // Por exemplo, você pode usar `response` para obter informações sobre o toque
                        },
                        handleBuiltInTouches: true,
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 63, // Diminuído o espaço reservado
                            getTitlesWidget: (value, meta) {
                              return SideTitleWidget(
                                axisSide: meta.axisSide,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      right: 4.0), // Ajustado o padding
                                  child: Text(
                                    value.toString(),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize:
                                          12, // Diminuído o tamanho da fonte
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40, // Diminuído o espaço reservado
                            getTitlesWidget: (value, meta) {
                              switch (value.toInt()) {
                                case 0:
                                  return Text(
                                    'Despesas Totais',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  );
                                case 1:
                                  return Text(
                                    'Renda Fixa',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  );
                                default:
                                  return SizedBox.shrink();
                              }
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                      gridData: FlGridData(show: true),
                      barGroups: [
                        BarChartGroupData(
                          x: 0,
                          barsSpace: 4,
                          barRods: [
                            BarChartRodData(
                              toY: totalExpenses,
                              color: Colors.red,
                              width: 16, // Ajustado a largura
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ],
                        ),
                        BarChartGroupData(
                          x: 1,
                          barsSpace: 4,
                          barRods: [
                            BarChartRodData(
                              toY: fixedIncome,
                              color: Colors.green,
                              width: 16, // Ajustado a largura
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      height: 10,
                      width: 30,
                      color: Colors.blue,
                      margin: EdgeInsets.only(right: 8),
                    ),
                    Text('Despesas Totais',
                        style: TextStyle(color: Colors.white)),
                    SizedBox(width: 16),
                    Container(
                      height: 10,
                      width: 30,
                      color: Colors.green,
                      margin: EdgeInsets.only(right: 8),
                    ),
                    Text('Renda Fixa', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ],
            ),
          );
        }
      },
    );
  }

  double _calculateTotalExpenses(List<ExpenseModel> expenses) {
    return expenses
        .map((expense) => double.parse(expense.amount))
        .reduce((a, b) => a + b);
  }

  double _getMaxY(double totalExpenses, double fixedIncome) {
    return totalExpenses > fixedIncome
        ? totalExpenses * 1.2
        : fixedIncome * 1.2; // Adiciona um pouco de espaço extra no gráfico
  }
}
