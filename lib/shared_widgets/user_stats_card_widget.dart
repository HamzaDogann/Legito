import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

// Ortak Renk Sabitleri (Eğer farklı sayfalarda farklı renkler kullanılmayacaksa)
// Veya bu renkleri widget'lara parametre olarak da geçebilirsiniz.
const Color cardBackground = Color(0xFF262626);
const Color textLight = Colors.white;
const Color textSecondaryStats = Color(0xFF9CA3AF);
const Color unitReddish = Color(0xFFF87171);
const Color unitBlue = Color(0xFF60A5FA);
const Color chartOrange = Color(0xFFF59E0B);
const Color chartGrey = Color(0xFF9CA3AF);
const Color chartContainerBackground = Color(0xFFFFFFFF);
const Color textDarkForCharts = Color(0xFF1F2937); // Grafik eksenleri için

// --- İstatistik Kartları Widget'ı ---
class StatsGrid extends StatelessWidget {
  final double labelMaxWidth;

  const StatsGrid({Key? key, required this.labelMaxWidth}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const double gridSpacing = 15.0;
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisSpacing: gridSpacing,
      mainAxisSpacing: 15,
      childAspectRatio: 1.25,
      children: [
        _buildInfoCard(
          value: "16",
          label: "Gün Seri",
          imagePath: 'assets/images/calendar_icon.png',
          imageHeight: 75,
          labelMaxWidth: labelMaxWidth,
        ),
        _buildInfoCard(
          value: "34",
          unit: "Saat",
          unitColor: unitReddish,
          label: "Uygulamada geçen süre",
          imagePath: 'assets/images/clock_icon.png',
          imageHeight: 65,
          labelMaxWidth: labelMaxWidth,
        ),
        _buildInfoCard(
          value: "1500",
          label: "Okunan Kelime",
          imagePath: 'assets/images/folder_icon.png',
          imageHeight: 65,
          labelMaxWidth: labelMaxWidth,
        ),
        _buildInfoCard(
          value: "46",
          unit: "dk",
          unitColor: unitBlue,
          label: "Okuma Süresi",
          imagePath: 'assets/images/hourglass_icon.png',
          imageHeight: 70,
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
    return Container(
      /* ... _buildInfoCard içeriği UserAccountPage'den kopyalanacak ... */
      clipBehavior: Clip.none,
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 16.0,
              top: 18.0,
              right: 16.0,
              bottom: 16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      value,
                      style: TextStyle(
                        color: textLight,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        height: 1.1,
                      ),
                    ),
                    if (unit != null) SizedBox(width: 6),
                    if (unit != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          unit,
                          style: TextStyle(
                            color: unitColor ?? textLight.withOpacity(0.9),
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 4),
                SizedBox(
                  width: labelMaxWidth > 0 ? labelMaxWidth : 100,
                  child: Text(
                    label,
                    style: TextStyle(color: textSecondaryStats, fontSize: 15),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: -8,
            bottom: -10,
            child: Image.asset(imagePath, height: imageHeight),
          ),
        ],
      ),
    );
  }
}

// --- Grafikler Bölümü Widget'ı ---
class ChartsSection extends StatelessWidget {
  const ChartsSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      /* ... _buildChartsSection içeriği UserAccountPage'den kopyalanacak ... */
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: chartContainerBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(height: 10),
          SizedBox(height: 180, child: _buildBarChart()),
          SizedBox(height: 30),
          SizedBox(height: 180, child: _buildLineChart()),
        ],
      ),
    );
  }

  // Bu fonksiyonlar private kalabilir veya ChartsSection içinde çağrılabilir.
  // Veya ayrı stateless widget'lar olarak da tanımlanabilirler.
  Widget _buildBarChart() {
    /* ... _buildBarChart içeriği UserAccountPage'den kopyalanacak ... */
    final List<double> orangeData = [1, 1, 1.5, 6, 8, 4, 3, 2, 3];
    final List<double> greyData = [2, 3, 2.5, 3, 10, 5, 4, 2.5, 6];
    const double barWidth = 7.0;
    List<BarChartGroupData> barGroups = [];
    for (int i = 0; i < orangeData.length; i++) {
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: greyData[i],
              color: chartGrey.withOpacity(0.7),
              width: barWidth,
              borderRadius: BorderRadius.zero,
            ),
            BarChartRodData(
              toY: orangeData[i],
              color: chartOrange,
              width: barWidth,
              borderRadius: BorderRadius.zero,
            ),
          ],
          barsSpace: 3,
        ),
      );
    }
    return BarChart(
      BarChartData(
        maxY: 11,
        alignment: BarChartAlignment.spaceAround,
        barGroups: barGroups,
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: 2.5,
              getTitlesWidget: (value, meta) {
                String text = '';
                if (value == 0)
                  text = '0';
                else if (value == 2.5)
                  text = '2.5';
                else if (value == 5)
                  text = '05';
                else if (value == 7.5)
                  text = '07';
                else if (value == 10)
                  text = '10';
                else
                  return Container();
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 4,
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 10,
                      color: textDarkForCharts.withOpacity(0.6),
                    ),
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              interval: 1,
              getTitlesWidget: (value, meta) {
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 4,
                  child: Text(
                    value.toInt().toString(),
                    style: TextStyle(
                      fontSize: 10,
                      color: textDarkForCharts.withOpacity(0.6),
                    ),
                  ),
                );
              },
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(show: false),
        barTouchData: BarTouchData(enabled: false),
      ),
    );
  }

  Widget _buildLineChart() {
    /* ... _buildLineChart içeriği UserAccountPage'den kopyalanacak ... */
    final List<FlSpot> spots = [
      FlSpot(0, 6),
      FlSpot(1, 9),
      FlSpot(2, 3),
      FlSpot(3, 10),
      FlSpot(4, 10),
      FlSpot(5, 1),
      FlSpot(6, 7.5),
      FlSpot(7, 8.5),
      FlSpot(8, 9.5),
      FlSpot(9, 1),
    ];
    return LineChart(
      LineChartData(
        minX: 0,
        maxX: 9,
        minY: 0,
        maxY: 11,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: false,
            color: chartGrey.withOpacity(0.8),
            barWidth: 1.5,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter:
                  (spot, percent, barData, index) => FlDotCirclePainter(
                    radius: 3.5,
                    color: Colors.white,
                    strokeWidth: 1.5,
                    strokeColor: chartGrey.withOpacity(0.8),
                  ),
            ),
            belowBarData: BarAreaData(show: false),
          ),
        ],
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: 2.5,
              getTitlesWidget: (value, meta) {
                String text = '';
                if (value == 0)
                  text = '0';
                else if (value == 2.5)
                  return Container();
                else if (value == 5)
                  text = '05';
                else if (value == 7.5)
                  text = '07';
                else if (value == 10)
                  text = '10';
                else
                  return Container();
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 4,
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 10,
                      color: textDarkForCharts.withOpacity(0.6),
                    ),
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              interval: 1,
              getTitlesWidget: (value, meta) {
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 4,
                  child: Text(
                    value.toInt().toString(),
                    style: TextStyle(
                      fontSize: 10,
                      color: textDarkForCharts.withOpacity(0.6),
                    ),
                  ),
                );
              },
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(show: false),
        lineTouchData: LineTouchData(enabled: false),
      ),
    );
  }
}
