import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AnimatedLineChart extends StatefulWidget {
  final LineChartData data;
  final Duration animationDuration;

  AnimatedLineChart({
    required this.data,
    this.animationDuration = const Duration(milliseconds: 500),
  });

  @override
  _AnimatedLineChartState createState() => _AnimatedLineChartState();
}

class _AnimatedLineChartState extends State<AnimatedLineChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return LineChart(
          LineChartData(
            lineBarsData: widget.data.lineBarsData.map((barData) {
              return barData.copyWith(
                spots: barData.spots.map((spot) {
                  return FlSpot(spot.x, spot.y * _animation.value);
                }).toList(),
              );
            }).toList(),
            titlesData: widget.data.titlesData,
            gridData: widget.data.gridData,
            borderData: widget.data.borderData,
            minX: widget.data.minX,
            maxX: widget.data.maxX,
            minY: widget.data.minY,
            maxY: widget.data.maxY,
          ),
        );
      },
    );
  }
}
