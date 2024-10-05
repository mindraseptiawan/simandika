import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:simandika/models/cashflow_model.dart';
import 'package:simandika/providers/auth_provider.dart';
import 'package:simandika/services/cashflow_service.dart';
import 'package:simandika/theme.dart';
import 'package:simandika/widgets/animate_chart.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class CashflowChart extends StatelessWidget {
  final List<CashflowModel> cashflows;

  CashflowChart({required this.cashflows});

  @override
  Widget build(BuildContext context) {
    if (cashflows.isEmpty) {
      return Center(child: Text('Tidak ada data cashflows'));
    }

    final latestBalance = cashflows.last.balance;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cashflows',
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: primaryTextColor),
        ),
        Text(
          'Rp ${NumberFormat('#,###').format(latestBalance)}',
          style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: primaryTextColor),
        ),
        SizedBox(height: 20),
        AspectRatio(
          aspectRatio: 1.5,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: LineChart(
              LineChartData(
                lineBarsData: [
                  _createLineChartBarData(cashflows, Colors.blue,
                      (cf) => cf.type == 'in' ? cf.amount : 0),
                  _createLineChartBarData(cashflows, Colors.red,
                      (cf) => cf.type == 'out' ? cf.amount : 0),
                  _createLineChartBarData(
                      cashflows, Colors.green, (cf) => cf.balance),
                ],
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 &&
                            value.toInt() < cashflows.length) {
                          return Text(
                            DateFormat('MM/dd')
                                .format(cashflows[value.toInt()].date),
                            style: TextStyle(
                                fontSize: 10, color: primaryTextColor),
                          );
                        }
                        return const Text('');
                      },
                      reservedSize: 22,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          NumberFormat('#,###').format(value),
                          style:
                              TextStyle(fontSize: 10, color: primaryTextColor),
                        );
                      },
                      reservedSize: 40,
                    ),
                  ),
                  topTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(show: true),
                borderData: FlBorderData(show: true),
              ),
            ),
          ),
        ),
        SizedBox(height: 20),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 20,
          runSpacing: 10,
          children: [
            _buildLegendItem('Pemasukan', Colors.blue),
            _buildLegendItem('Pengeluaran', Colors.red),
            _buildLegendItem('Saldo', Colors.green),
          ],
        ),
      ],
    );
  }

  LineChartBarData _createLineChartBarData(List<CashflowModel> cashflows,
      Color color, double Function(CashflowModel) getValue) {
    return LineChartBarData(
      spots: cashflows.asMap().entries.map((entry) {
        return FlSpot(entry.key.toDouble(), getValue(entry.value));
      }).toList(),
      isCurved: true,
      color: color,
      barWidth: 2,
      isStrokeCapRound: true,
      dotData: FlDotData(show: false),
      belowBarData: BarAreaData(show: false),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          color: color,
        ),
        SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(color: primaryTextColor),
        ),
      ],
    );
  }
}

class MonthlyChart extends StatelessWidget {
  final String title;
  final List<CashflowModel> cashflows;
  final Color lineColor;
  final double Function(CashflowModel) getValue;

  MonthlyChart({
    required this.title,
    required this.cashflows,
    required this.lineColor,
    required this.getValue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        SizedBox(height: 10),
        Row(
          children: [
            Text('Monthly',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white)),
            SizedBox(width: 10),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.purple,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Monthly',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        SizedBox(height: 20),
        AspectRatio(
          aspectRatio: 1.5,
          child: AnimatedLineChart(
            data: LineChartData(
              lineBarsData: [
                LineChartBarData(
                  spots: _getMonthlyData(),
                  isCurved: true,
                  color: lineColor,
                  barWidth: 2,
                  isStrokeCapRound: true,
                  dotData: FlDotData(show: false),
                  belowBarData: BarAreaData(
                      show: true, color: lineColor.withOpacity(0.1)),
                ),
              ],
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      const months = [
                        'Jan',
                        'Feb',
                        'Mar',
                        'Apr',
                        'May',
                        'Jun',
                        'Jul',
                        'Aug',
                        'Sep',
                        'Oct',
                        'Nov',
                        'Dec'
                      ];
                      final index = value.toInt();
                      if (index >= 0 && index < months.length) {
                        return Text(months[index],
                            style:
                                TextStyle(color: Colors.white70, fontSize: 10));
                      }
                      return const Text('');
                    },
                    reservedSize: 22,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        'Rp ${NumberFormat('#,###').format(value)}',
                        style: TextStyle(fontSize: 10, color: Colors.white70),
                      );
                    },
                    reservedSize: 60,
                  ),
                ),
                topTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
                getDrawingHorizontalLine: (value) {
                  return FlLine(color: Colors.white10, strokeWidth: 1);
                },
                getDrawingVerticalLine: (value) {
                  return FlLine(color: Colors.white10, strokeWidth: 1);
                },
              ),
              borderData: FlBorderData(show: false),
              backgroundColor: Colors.transparent,
              minX: 0,
              maxX: 11,
              minY: 0,
            ),
            animationDuration: Duration(milliseconds: 1000),
          ),
        ),
      ],
    );
  }

  List<FlSpot> _getMonthlyData() {
    final monthlyData = <int, double>{};
    for (var cashflow in cashflows) {
      final month = cashflow.date.month - 1; // Adjust to 0-based index
      monthlyData[month] = (monthlyData[month] ?? 0) + getValue(cashflow);
    }

    // Debug print
    print('$title Monthly Data:');
    monthlyData.forEach((month, value) {
      final monthName = DateFormat('MMMM').format(DateTime(2023, month + 1));
      print('$monthName: Rp ${NumberFormat('#,###').format(value)}');
    });

    return List.generate(12, (index) {
      return FlSpot(index.toDouble(), monthlyData[index] ?? 0);
    });
  }
}

class _DashboardPageState extends State<DashboardPage> {
  List<CashflowModel>? _cashflows;

  @override
  void initState() {
    super.initState();
    _loadCashflows();
  }

  Future<void> _loadCashflows() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.user.token;
    final cashflowService = CashflowService();
    final cashflows = await cashflowService.getCashflows(token!);
    setState(() {
      _cashflows = cashflows;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        backgroundColor: Color(0xFF6750A4),
      ),
      body: _cashflows == null
          ? Center(child: CircularProgressIndicator())
          : Container(
              color: Color(0xFF1C1B1F),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      CashflowChart(cashflows: _cashflows!),
                      SizedBox(height: 30),
                      MonthlyChart(
                        title: 'Pendapatan',
                        cashflows: _cashflows!,
                        lineColor: Color(0xFF6750A4),
                        getValue: (cf) => cf.type == 'in' ? cf.amount : 0,
                      ),
                      SizedBox(height: 30),
                      MonthlyChart(
                        title: 'Pengeluaran',
                        cashflows: _cashflows!,
                        lineColor: Color(0xFFE94560),
                        getValue: (cf) => cf.type == 'out' ? cf.amount : 0,
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
