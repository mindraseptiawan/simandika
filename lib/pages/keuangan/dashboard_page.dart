import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/widgets.dart';
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

class CashflowChart extends StatefulWidget {
  final List<CashflowModel> cashflows;

  CashflowChart({required this.cashflows});

  @override
  _CashflowChartState createState() => _CashflowChartState();
}

class _CashflowChartState extends State<CashflowChart> {
  String _selectedTimeRange = '7 days';
  DateTimeRange? _customDateRange;

  List<CashflowModel> _getFilteredCashflows() {
    final now = DateTime.now();
    switch (_selectedTimeRange) {
      case '7 days':
        return widget.cashflows
            .where((cf) => cf.date.isAfter(now.subtract(Duration(days: 7))))
            .toList();
      case '1 month':
        return widget.cashflows
            .where((cf) => cf.date.isAfter(now.subtract(Duration(days: 30))))
            .toList();
      case 'Custom':
        if (_customDateRange != null) {
          return widget.cashflows
              .where((cf) =>
                  // Ensure the date is exactly within the selected range
                  cf.date.isAtSameMomentAs(_customDateRange!.start) ||
                  cf.date.isAtSameMomentAs(_customDateRange!.end) ||
                  (cf.date.isAfter(_customDateRange!.start) &&
                      cf.date.isBefore(_customDateRange!.end)))
              .toList();
        }
        return widget.cashflows;
      default:
        return widget.cashflows;
    }
  }

  Future<void> _selectCustomDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      initialDateRange: _customDateRange ??
          DateTimeRange(
              start: DateTime.now().subtract(Duration(days: 7)),
              end: DateTime.now()),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFF6750A4),
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedTimeRange = 'Custom';
        _customDateRange = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredCashflows = _getFilteredCashflows();
    if (filteredCashflows.isEmpty) {
      return Center(child: Text('Tidak ada data cashflows'));
    }
    for (final cashflow in filteredCashflows) {
      print(
          'Cashflow: type=${cashflow.type}, amount=${cashflow.amount}, balance=${cashflow.balance}, date=${cashflow.date}');
    }
    final latestBalance = filteredCashflows.last.balance;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Arus Kas',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            PopupMenuButton<String>(
              initialValue: _selectedTimeRange,
              onSelected: (String value) async {
                if (value == 'Custom') {
                  await _selectCustomDateRange(context);
                } else {
                  setState(() {
                    _selectedTimeRange = value;
                    _customDateRange = null;
                  });
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: '7 days',
                  child: Text('7 Days'),
                ),
                const PopupMenuItem<String>(
                  value: '1 month',
                  child: Text('1 Month'),
                ),
                const PopupMenuItem<String>(
                  value: 'Custom',
                  child: Text('Custom Range'),
                ),
              ],
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Color(0xFF6750A4),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Text(
                      _selectedTimeRange == 'Custom' && _customDateRange != null
                          ? '${DateFormat('dd/MM').format(_customDateRange!.start)} - ${DateFormat('dd/MM').format(_customDateRange!.end)}'
                          : _selectedTimeRange,
                      style: TextStyle(color: Colors.white),
                    ),
                    Icon(Icons.arrow_drop_down, color: Colors.white),
                  ],
                ),
              ),
            ),
          ],
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
                  _createLineChartBarData(filteredCashflows, Colors.blue,
                      (cf) => cf.type == 'in' ? cf.amount : 0),
                  _createLineChartBarData(filteredCashflows, Colors.red,
                      (cf) => cf.type == 'out' ? cf.amount : 0),
                  _createLineChartBarData(
                      filteredCashflows, Colors.green, (cf) => cf.balance),
                ],
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 &&
                            value.toInt() < filteredCashflows.length) {
                          return Text(
                            DateFormat('dd/MM')
                                .format(filteredCashflows[value.toInt()].date),
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
    // Debug logging
    if (_cashflows != null) {
      for (final cashflow in _cashflows!) {
        print(
            'Cashflow: type=${cashflow.type}, amount=${cashflow.amount}, balance=${cashflow.balance}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text(
              'Dashboard',
              style: TextStyle(
                  color: primaryTextColor, fontWeight: FontWeight.bold),
            ),
            backgroundColor: Color(0xFF6750A4),
            iconTheme: IconThemeData(color: Colors.white)),
        body: Container(
          color: Color(0xFF1C1B1F),
          child: _cashflows == null
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
        ));
  }
}
