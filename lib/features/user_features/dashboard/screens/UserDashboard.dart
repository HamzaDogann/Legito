// lib/features/user_features/dashboard/screens/UserDashboard.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../../core/enums/user_role.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../state_management/auth_provider.dart';
import '../state_management/dashboard_provider.dart';
import '../models/dashboard_dtos.dart';

const Color _cardBackground = Color(0xFF262626);
const Color _textLight = Colors.white;
const Color _textSecondaryStats = Color(0xFF9CA3AF);
const Color _unitReddish = Color(0xFFF87171);
const Color _unitBlue = Color(0xFF60A5FA);
const Color _chartOrange = Color(0xFFF59E0B);
const Color _chartContainerBackground = Colors.white;
const Color _textDarkForCharts = Color(0xFF1F2937);

String _formatDurationValueForCard(String? durationStr) {
  if (durationStr == null || durationStr == "00:00:00" || durationStr.isEmpty)
    return "0";
  try {
    final parts = durationStr.split(':');
    if (parts.length == 3) {
      int hours = int.parse(parts[0]);
      int minutes = int.parse(parts[1]);
      if (hours > 0) return hours.toString();
      if (minutes > 0) return minutes.toString();
      return "0";
    }
  } catch (e) {
    print("Süre formatlama hatası (değer): $e, Gelen değer: $durationStr");
  }
  return "-";
}

String? _getDurationUnitForCard(String? durationStr) {
  if (durationStr == null || durationStr.isEmpty) return "dk";
  if (durationStr == "0" || durationStr == "00:00:00") return "dk";
  try {
    final parts = durationStr.split(':');
    if (parts.length == 3) {
      int hours = int.parse(parts[0]);
      if (hours > 0) return "Saat";
      return "dk";
    }
  } catch (e) {
    print("Süre formatlama hatası (birim): $e, Gelen değer: $durationStr");
  }
  return null;
}

class StatsGrid extends StatelessWidget {
  final UserStatDto? userStats;
  final ReadingStatDto? readingStats;
  final double labelMaxWidth;

  const StatsGrid({
    Key? key,
    this.userStats,
    this.readingStats,
    required this.labelMaxWidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const double gridSpacing = 15.0;
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: gridSpacing,
      mainAxisSpacing: gridSpacing,
      childAspectRatio: 1.25,
      children: [
        _buildInfoCard(
          value: userStats?.dailySeries.toString() ?? "-",
          label: "Gün Seri",
          imagePath: 'assets/images/calendar_icon.png',
          imageHeight: 70,
          labelMaxWidth: labelMaxWidth,
        ),
        _buildInfoCard(
          value: _formatDurationValueForCard(userStats?.elapsedTime),
          unit: _getDurationUnitForCard(userStats?.elapsedTime),
          unitColor:
              (userStats?.elapsedTime?.startsWith("00:") ?? true) &&
                      (userStats?.elapsedTime != "00:00:00")
                  ? _unitBlue
                  : _unitReddish,
          label: "Geçen Süre",
          imagePath: 'assets/images/clock_icon.png',
          imageHeight: 60,
          labelMaxWidth: labelMaxWidth,
        ),
        _buildInfoCard(
          value: readingStats?.totalWordCount.toString() ?? "-",
          label: "Okunan Kelime",
          imagePath: 'assets/images/folder_icon.png',
          imageHeight: 60,
          labelMaxWidth: labelMaxWidth,
        ),
        _buildInfoCard(
          value: _formatDurationValueForCard(readingStats?.totalDuration),
          unit: _getDurationUnitForCard(readingStats?.totalDuration),
          unitColor:
              (readingStats?.totalDuration?.startsWith("00:") ?? true) &&
                      (readingStats?.totalDuration != "00:00:00")
                  ? _unitBlue
                  : _unitReddish,
          label: "Okuma Süresi",
          imagePath: 'assets/images/hourglass_icon.png',
          imageHeight: 65,
          labelMaxWidth: labelMaxWidth,
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required String value,
    String? unit,
    Color? unitColor,
    required String label,
    required String imagePath,
    required double imageHeight,
    required double labelMaxWidth,
  }) {
    double valueFontSize = 40;
    if (value.length > 2 && value != "-") valueFontSize = 36;
    if (value.length > 3 && value != "-") valueFontSize = 32;
    if (value.length > 4 && value != "-") valueFontSize = 28;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: _cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 20.0,
              top: 40.0,
              right: 16.0,
              bottom: 12.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      value,
                      style: TextStyle(
                        color: _textLight,
                        fontSize: valueFontSize,
                        fontWeight: FontWeight.bold,
                        height: 1.0,
                      ),
                    ), // height: 1.0
                    if (unit != null && value != "0" && value != "-")
                      const SizedBox(width: 4),
                    if (unit != null && value != "0" && value != "-")
                      Padding(
                        padding: const EdgeInsets.only(bottom: 0.0),
                        child: Text(
                          unit,
                          style: TextStyle(
                            color: unitColor ?? _textLight.withOpacity(0.9),
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2), // Azaltılmış boşluk
                SizedBox(
                  width: labelMaxWidth > 0 ? labelMaxWidth : double.infinity,
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: _textSecondaryStats,
                      fontSize: 16,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: -8,
            bottom: -8,
            child: Image.asset(
              imagePath,
              height: imageHeight,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}

class ChartsSection extends StatelessWidget {
  final List<DailyDataPointDto>? readingSpeedData;
  final List<DailyDataPointDto>? readingDurationData;
  const ChartsSection({
    Key? key,
    this.readingSpeedData,
    this.readingDurationData,
  }) : super(key: key);
  double _durationStringToMinutes(String durationStr) {
    final parts = durationStr.split(':');
    if (parts.length == 3) {
      try {
        return (int.parse(parts[0]) * 60) +
            int.parse(parts[1]) +
            (int.parse(parts[2]) / 60.0);
      } catch (e) {
        return 0.0;
      }
    }
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: _chartContainerBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            "Haftalık Okuma Hızı (K/Dk)",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _textDarkForCharts,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child:
                (readingSpeedData != null && readingSpeedData!.isNotEmpty)
                    ? _buildLineChart(
                      context,
                      readingSpeedData!,
                      _chartOrange,
                      (val) => val.toDouble(),
                    )
                    : const Center(child: Text("Okuma hızı verisi yok.")),
          ),
          const SizedBox(height: 30),
          const Text(
            "Haftalık Okuma Süresi (Dakika)",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _textDarkForCharts,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child:
                (readingDurationData != null && readingDurationData!.isNotEmpty)
                    ? _buildBarChart(
                      context,
                      readingDurationData!,
                      _chartOrange.withOpacity(0.7),
                      (val) => _durationStringToMinutes(val as String),
                    )
                    : const Center(child: Text("Okuma süresi verisi yok.")),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(
    BuildContext context,
    List<DailyDataPointDto> dataPoints,
    Color barColor,
    double Function(dynamic) getValue,
  ) {
    if (dataPoints.isEmpty)
      return const Center(child: Text("Grafik için veri yok."));
    final List<BarChartGroupData> barGroups =
        dataPoints.asMap().entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: getValue(entry.value.value),
                color: barColor,
                width: 16,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
            ],
          );
        }).toList();
    double maxY = 0;
    if (dataPoints.isNotEmpty) {
      maxY = dataPoints
          .map((dp) => getValue(dp.value))
          .reduce((a, b) => a > b ? a : b);
      if (maxY < 10)
        maxY = 10;
      else
        maxY = (maxY * 1.2).ceilToDouble();
    }
    return BarChart(
      BarChartData(
        maxY: maxY,
        alignment: BarChartAlignment.spaceAround,
        barGroups: barGroups,
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: maxY > 0 ? maxY / 5 : 2,
              getTitlesWidget:
                  (value, meta) => SideTitleWidget(
                    axisSide: meta.axisSide,
                    space: 4,
                    child: Text(
                      value.toInt().toString(),
                      style: TextStyle(
                        fontSize: 10,
                        color: _textDarkForCharts.withOpacity(0.7),
                      ),
                    ),
                  ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              interval: 1,
              getTitlesWidget:
                  (value, meta) => SideTitleWidget(
                    axisSide: meta.axisSide,
                    space: 4,
                    child: Text(
                      dataPoints.length > value.toInt()
                          ? DateFormat(
                            'E',
                            'tr_TR',
                          ).format(dataPoints[value.toInt()].date)
                          : '',
                      style: TextStyle(
                        fontSize: 10,
                        color: _textDarkForCharts.withOpacity(0.7),
                      ),
                    ),
                  ),
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY > 0 ? maxY / 5 : 2,
          getDrawingHorizontalLine:
              (value) => FlLine(color: Colors.grey.shade300, strokeWidth: 0.5),
        ),
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (group) => Colors.blueGrey.withOpacity(0.9),
            tooltipRoundedRadius: 8,
            getTooltipItem:
                (group, groupIndex, rod, rodIndex) => BarTooltipItem(
                  '${rod.toY.toStringAsFixed(1)} dk',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
          ),
        ),
      ),
    );
  }

  Widget _buildLineChart(
    BuildContext context,
    List<DailyDataPointDto> dataPoints,
    Color lineColor,
    double Function(dynamic) getValue,
  ) {
    if (dataPoints.isEmpty)
      return const Center(child: Text("Grafik için veri yok."));
    final List<FlSpot> spots =
        dataPoints
            .asMap()
            .entries
            .map(
              (entry) =>
                  FlSpot(entry.key.toDouble(), getValue(entry.value.value)),
            )
            .toList();
    double maxY = 0;
    if (dataPoints.isNotEmpty) {
      maxY = dataPoints
          .map((dp) => getValue(dp.value))
          .reduce((a, b) => a > b ? a : b);
      if (maxY < 10)
        maxY = 10;
      else
        maxY = (maxY * 1.2).ceilToDouble();
    }
    return LineChart(
      LineChartData(
        minX: 0,
        maxX: (dataPoints.length - 1).toDouble(),
        minY: 0,
        maxY: maxY,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: lineColor,
            barWidth: 2.5,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter:
                  (spot, percent, barData, index) => FlDotCirclePainter(
                    radius: 4,
                    color: lineColor,
                    strokeWidth: 1.5,
                    strokeColor: Colors.white,
                  ),
            ),
            belowBarData: BarAreaData(
              show: true,
              color: lineColor.withOpacity(0.1),
            ),
          ),
        ],
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: maxY > 0 ? maxY / 5 : 2,
              getTitlesWidget:
                  (value, meta) => SideTitleWidget(
                    axisSide: meta.axisSide,
                    space: 4,
                    child: Text(
                      value.toInt().toString(),
                      style: TextStyle(
                        fontSize: 10,
                        color: _textDarkForCharts.withOpacity(0.7),
                      ),
                    ),
                  ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              interval: 1,
              getTitlesWidget:
                  (value, meta) => SideTitleWidget(
                    axisSide: meta.axisSide,
                    space: 4,
                    child: Text(
                      dataPoints.length > value.toInt()
                          ? DateFormat(
                            'E',
                            'tr_TR',
                          ).format(dataPoints[value.toInt()].date)
                          : '',
                      style: TextStyle(
                        fontSize: 10,
                        color: _textDarkForCharts.withOpacity(0.7),
                      ),
                    ),
                  ),
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY > 0 ? maxY / 5 : 2,
          getDrawingHorizontalLine:
              (value) => FlLine(color: Colors.grey.shade300, strokeWidth: 0.5),
        ),
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (touchedSpot) => Colors.blueGrey.withOpacity(0.9),
            tooltipRoundedRadius: 8,
            getTooltipItems:
                (touchedSpots) =>
                    touchedSpots
                        .map(
                          (spot) => LineTooltipItem(
                            '${spot.y.toStringAsFixed(0)} K/Dk',
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        )
                        .toList(),
          ),
        ),
      ),
    );
  }
}

class UserDashboard extends StatefulWidget {
  const UserDashboard({Key? key}) : super(key: key);
  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        if (!authProvider.isAuthenticated ||
            authProvider.userRole != UserRole.user) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.login,
            (route) => false,
          );
        } else {
          Provider.of<DashboardProvider>(
            context,
            listen: false,
          ).fetchDashboardData();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final appBarTheme = Theme.of(context).appBarTheme;
    final Color currentAppBarBackgroundColor =
        appBarTheme.backgroundColor ?? const Color(0xFFF4F6F9);
    final Color currentAppBarForegroundColor =
        appBarTheme.foregroundColor ?? const Color(0xFF1F2937);
    return Scaffold(
      backgroundColor: currentAppBarBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: currentAppBarForegroundColor),
          onPressed: () {
            if (Navigator.canPop(context))
              Navigator.of(context).pop();
            else
              Navigator.pushReplacementNamed(context, AppRoutes.publicHome);
          },
        ),
        title: const Text('İlerlemem'),
        centerTitle: false,
        titleSpacing: 0,
      ),
      body: Consumer<DashboardProvider>(
        builder: (context, dashboardProvider, child) {
          if (dashboardProvider.isLoading &&
              dashboardProvider.dashboardData == null)
            return const Center(
              child: CircularProgressIndicator(color: Colors.orange),
            );
          if (dashboardProvider.errorMessage != null &&
              dashboardProvider.dashboardData == null)
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.red.shade300,
                      size: 50,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Veriler yüklenirken bir hata oluştu:",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.red.shade700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      dashboardProvider.errorMessage!,
                      style: TextStyle(color: Colors.red.shade600),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => dashboardProvider.fetchDashboardData(),
                      child: const Text("Tekrar Dene"),
                    ),
                  ],
                ),
              ),
            );
          if (dashboardProvider.dashboardData == null &&
              !dashboardProvider.isLoading)
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Dashboard verisi bulunamadı."),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => dashboardProvider.fetchDashboardData(),
                    child: const Text("Yenile"),
                  ),
                ],
              ),
            );
          final dashboardData = dashboardProvider.dashboardData!;
          return RefreshIndicator(
            onRefresh: () => dashboardProvider.fetchDashboardData(),
            color: Theme.of(context).colorScheme.primary,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (dashboardProvider.isLoading &&
                            dashboardProvider.dashboardData != null)
                          const Padding(
                            padding: EdgeInsets.only(bottom: 10.0),
                            child: Center(
                              child: SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                          ),
                        StatsGrid(
                          userStats: dashboardData.userStats,
                          readingStats: dashboardData.readingStats,
                          labelMaxWidth: (constraints.maxWidth / 2) - 30,
                        ),
                        const SizedBox(height: 30),
                        ChartsSection(
                          readingSpeedData: dashboardData.readingSpeed,
                          readingDurationData: dashboardData.readingDuration,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
