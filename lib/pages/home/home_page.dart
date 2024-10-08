import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:simandika/models/order_model.dart';
import 'package:simandika/models/stock_model.dart';
import 'package:simandika/models/user_model.dart';
import 'package:simandika/providers/auth_provider.dart';
import 'package:simandika/services/order_service.dart';
import 'package:simandika/services/stock_service.dart';
import 'package:simandika/theme.dart';
import 'package:fl_chart/fl_chart.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  var _pendingCount = 0;
  var _awaitingPaymentCount = 0;
  var _verificationCount = 0;
  var _completedCount = 0;
  double _totalInQuantity = 0;
  double _totalOutQuantity = 0;
  final OrderService _orderService = OrderService();
  final StockService _stockService = StockService();
  Map<DateTime, Map<String, double>> _dailyQuantity = {};
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _setStatusBarColor();
    _loadOrdersByStatus();
    _loadAyamQuantity();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _setStatusBarColor() {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: primaryColor,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  Future<bool> _onWillPop() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text('Logout'),
              onPressed: () async {
                try {
                  await Provider.of<AuthProvider>(context, listen: false)
                      .logout();
                  Navigator.of(context).pop(true);
                } catch (e) {
                  debugPrint('Logout failed: $e');
                  Navigator.of(context).pop(false);
                }
              },
            ),
          ],
        );
      },
    );
    return shouldLogout ?? false;
  }

  Future<void> _loadAyamQuantity() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.user.token;
    final List<StockMovementModel> jsonData =
        await _stockService.getAllStocks(token!);

    double totalInQuantity = 0.0;
    double totalOutQuantity = 0.0;
    Map<DateTime, Map<String, double>> dailyQuantity = {};

    for (var data in jsonData) {
      if (data.type == 'in') {
        totalInQuantity += data.quantity;
      } else if (data.type == 'out') {
        totalOutQuantity += data.quantity;
      }

      DateTime date = data.createdAt.toLocal();
      if (!dailyQuantity.containsKey(date)) {
        dailyQuantity[date] = {'in': 0.0, 'out': 0.0};
      }

      if (data.type == 'in') {
        dailyQuantity[date]!['in'] =
            (dailyQuantity[date]!['in'] ?? 0) + data.quantity;
      } else if (data.type == 'out') {
        dailyQuantity[date]!['out'] =
            (dailyQuantity[date]!['out'] ?? 0) + data.quantity;
      }
    }

    setState(() {
      _totalInQuantity = totalInQuantity;
      _totalOutQuantity = totalOutQuantity;
      _dailyQuantity = Map.fromEntries(
        dailyQuantity.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
      );
    });
  }

  Future<void> _loadOrdersByStatus() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.user.token;
    List<OrderModel> pendingOrders =
        await _orderService.getOrdersByStatus(token!, 'pending');
    List<OrderModel> awaitingPaymentOrders =
        await _orderService.getOrdersByStatus(token, 'awaiting_payment');
    List<OrderModel> verificationPaymentOrders =
        await _orderService.getOrdersByStatus(token, 'payment_verification');
    List<OrderModel> completedOrders =
        await _orderService.getOrdersByStatus(token, 'completed');

    int pendingCount = pendingOrders.length;
    int awaitingPaymentCount = awaitingPaymentOrders.length;
    int verificationPaymentCount = verificationPaymentOrders.length;
    int completedCount = completedOrders.length;

    // debugPrint('Total Pending: $pendingCount');
    // debugPrint('Total Waiting: $awaitingPaymentCount');
    // debugPrint('Total Completed: $completedCount');
    // Update UI dengan jumlah order yang diterima
    setState(() {
      _pendingCount = pendingCount;
      _awaitingPaymentCount = awaitingPaymentCount;
      _verificationCount = verificationPaymentCount;
      _completedCount = completedCount;
    });
  }

  @override
  Widget build(BuildContext context) {
    AuthProvider authProvider = Provider.of<AuthProvider>(context);
    UserModel user = authProvider.user;

    Widget header() {
      return Container(
        color: primaryColor,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        width: double.infinity,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset('assets/logo_text.png', width: 200),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(user.name,
                        style: primaryTextStyle.copyWith(fontSize: 16)),
                  ),
                ],
              ),
            ),
            Image.asset(
              'assets/notif.png',
              width: 30.0,
              height: 30.0,
            )
          ],
        ),
      );
    }

    Widget _buildLegendItem(String label, Color color, String value) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 12, height: 12, color: color),
          SizedBox(width: 4),
          Text('$label: $value',
              style: TextStyle(color: Colors.white, fontSize: 12)),
        ],
      );
    }

    BarChartGroupData _makeGroupData(int x, double y1, double y2) {
      return BarChartGroupData(
        x: x,
        barRods: [
          BarChartRodData(toY: y1, color: Colors.blue, width: 7),
          BarChartRodData(toY: y2, color: Colors.orange, width: 7),
        ],
      );
    }

    Widget dashboard() {
      return Container(
        padding: const EdgeInsets.all(16),
        color: Color(0xFF1E1E1E),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Overview',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      Text('Show: This Year',
                          style: TextStyle(color: Colors.white, fontSize: 12)),
                      Icon(Icons.arrow_drop_down,
                          color: Colors.white, size: 16),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Container(
              height: 200, // Reduced height
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return PieChart(
                        PieChartData(
                          sectionsSpace: 0,
                          centerSpaceRadius: 50, // Smaller center space
                          sections: [
                            PieChartSectionData(
                              value: _pendingCount.toDouble(),
                              color: Colors.blue,
                              title: '',
                              radius: 25 * _animation.value,
                              // Thinner and animated
                            ),
                            PieChartSectionData(
                              value: _verificationCount.toDouble(),
                              color: Colors.orange,
                              title: '',
                              radius: 25 * _animation.value,
                              // Thinner and animated
                            ),
                            PieChartSectionData(
                              value: _awaitingPaymentCount.toDouble(),
                              color: Colors.green,
                              title: '',
                              radius:
                                  25 * _animation.value, // Thinner and animated
                            ),
                            PieChartSectionData(
                              value: _completedCount.toDouble(),
                              color: Colors.yellow,
                              title: '',
                              radius:
                                  25 * _animation.value, // Thinner and animated
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _totalOutQuantity.toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28, // Slightly smaller font
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Penjualan',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _buildLegendItem(
                    'Pending', Colors.blue, _pendingCount.toString()),
                _buildLegendItem('Verification Payment', Colors.orange,
                    _verificationCount.toString()),
                _buildLegendItem('Awaiting Payment', Colors.green,
                    _awaitingPaymentCount.toString()),
                _buildLegendItem(
                    'Completed', Colors.yellow, _completedCount.toString()),
              ],
            ),
            SizedBox(height: 24),
            Text('Stok Ayam',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            StockChart(dailyQuantity: _dailyQuantity, animation: _animation),
          ],
        ),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) {
          return;
        }
        final navigator = Navigator.of(context);
        bool value = await _onWillPop();
        if (value) {
          navigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: backgroundColor1,
        body: SafeArea(
          child: Column(
            children: [
              header(),
              Expanded(
                child: SingleChildScrollView(
                  child: dashboard(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StockChart extends StatelessWidget {
  final Map<DateTime, Map<String, double>> dailyQuantity;
  final Animation<double> animation;

  const StockChart({
    Key? key,
    required this.dailyQuantity,
    required this.animation,
  }) : super(key: key);

  List<BarChartGroupData> _prepareChartData() {
    Map<int, Map<String, double>> groupedData = {};
    for (var entry in dailyQuantity.entries) {
      int dayOfWeek = entry.key.weekday;
      if (!groupedData.containsKey(dayOfWeek)) {
        groupedData[dayOfWeek] = {'in': 0, 'out': 0};
      }
      groupedData[dayOfWeek]!['in'] =
          (groupedData[dayOfWeek]!['in'] ?? 0) + (entry.value['in'] ?? 0);
      groupedData[dayOfWeek]!['out'] =
          (groupedData[dayOfWeek]!['out'] ?? 0) + (entry.value['out'] ?? 0);
    }

    return groupedData.entries.map((entry) {
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: (entry.value['in'] ?? 0) * animation.value,
            color: Colors.blue,
            width: 7,
          ),
          BarChartRodData(
            toY: (entry.value['out'] ?? 0) * animation.value,
            color: Colors.orange,
            width: 7,
          ),
        ],
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final chartGroups = _prepareChartData();
    final maxY = chartGroups.fold<double>(
        0,
        (prev, group) => group.barRods
            .fold<double>(prev, (p, rod) => rod.toY > p ? rod.toY : p));

    return AspectRatio(
        aspectRatio: 1.7,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: maxY,
            barTouchData: BarTouchData(enabled: false),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    const weekDays = [
                      '',
                      'Mon',
                      'Tue',
                      'Wed',
                      'Thu',
                      'Fri',
                      'Sat',
                      'Sun'
                    ];
                    return Text(
                      weekDays[value.toInt()],
                      style: TextStyle(color: Colors.white, fontSize: 10),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      value.toInt().toString(),
                      style: TextStyle(color: Colors.white, fontSize: 10),
                    );
                  },
                  reservedSize: 30,
                ),
              ),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles:
                  AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            gridData: FlGridData(show: false),
            borderData: FlBorderData(show: false),
            barGroups: chartGroups,
            extraLinesData: ExtraLinesData(
              horizontalLines: [
                HorizontalLine(
                  y: maxY,
                  color: Colors.white.withOpacity(0.5),
                  strokeWidth: 1,
                  label: HorizontalLineLabel(
                    show: true,
                    labelResolver: (line) => '${line.y.toStringAsFixed(0)}',
                    style: TextStyle(color: Colors.white, fontSize: 10),
                    alignment: Alignment.topRight,
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
