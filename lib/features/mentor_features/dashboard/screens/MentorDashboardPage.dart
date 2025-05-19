// lib/features/mentor_features/dashboard/screens/MentorDashboardPage.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../state_management/auth_provider.dart';

// --- Renk Sabitleri ---
// Üstteki 2 özel kart için renkler
const Color statCardDarkBackground = Color(0xFF262626);
const Color statCardPrimaryTextLight =
    Colors.white; // Kart içindeki başlıklar için
const Color statCardValueAccentColor = Color.fromARGB(
  255,
  255,
  130,
  40,
); // Turuncu (100 gibi değerler)
const Color statCardUnitTextLight = Colors.white70; // "Saat" gibi birimler için

// Genel sayfa ve diğer elemanlar için (açık tema)
const Color pageBackgroundColor = Colors.white; // Veya Colors.grey[100]
const Color chartCardBackgroundColor = Color(
  0xFFF0F0F0,
); // Grafik kartlarının arka planı (açık gri)
const Color chartTitleColor = Color(
  0xFF1F2937,
); // Grafik başlıkları için koyu renk
const Color chartAxisLabelColor = Color(
  0xFF6B7280,
); // Grafik eksen etiketleri için gri

// Grafik renkleri (açık tema üzerinde daha iyi görünecek şekilde ayarlanabilir)
const Color barColorOrange = Color(0xFFFFA500); // Ana vurgu rengi
const Color barColorGreyLight = Color(0xFFD1D5DB); // Sütun grafik için açık gri
const Color lineColorOrange = Color(0xFFFFA500);
const Color pieColorMale = Colors.blueAccent;
const Color pieColorFemale = Colors.pinkAccent;
const Color pieColorOther = Colors.grey;
// --- Renk Sabitleri Bitiş ---

class MentorDashboardPage extends StatefulWidget {
  const MentorDashboardPage({Key? key}) : super(key: key);

  @override
  State<MentorDashboardPage> createState() => _MentorDashboardPageState();
}

class _MentorDashboardPageState extends State<MentorDashboardPage> {
  final int _supportedUserCount = 100;
  final int _appTimeHours = 22;

  final List<FlSpot> _dailySupportSpots = const [
    FlSpot(0, 2),
    FlSpot(1, 5),
    FlSpot(2, 3),
    FlSpot(3, 7),
    FlSpot(4, 4),
    FlSpot(5, 6),
    FlSpot(6, 8),
  ];

  final List<BarChartGroupData> _ageDistributionBars = [
    _makeGroupData(0, 5, 3),
    _makeGroupData(1, 8, 6),
    _makeGroupData(2, 12, 10),
    _makeGroupData(3, 7, 4),
    _makeGroupData(4, 3, 2),
  ];
  final List<String> _ageGroupLabels = [
    '<18',
    '18-22',
    '23-27',
    '28-32',
    '>32',
  ];

  final Map<String, double> _genderDistributionData = {
    'Erkek': 40,
    'Kadın': 55,
    'Diğer': 5,
  };
  int _touchedPieIndex = -1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (!authProvider.isAuthenticated ||
          authProvider.userRole != UserRole.mentor) {
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.login,
            (route) => false,
          );
        }
      } else {
        print("MentorDashboardPage: Mentor yetkili.");
      }
    });
  }

  static BarChartGroupData _makeGroupData(int x, double y1, double y2) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y1,
          color: barColorGreyLight,
          width: 14,
          borderRadius: BorderRadius.circular(4),
        ), // Genişlik ve radius ayarlandı
        BarChartRodData(
          toY: y2,
          color: barColorOrange,
          width: 14,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // AppBar stilleri main.dart'taki appBarTheme'den gelecek.
    // Bu sayfanın genel arka planı açık tema olacak.
    return Scaffold(
      backgroundColor:
          Theme.of(context).scaffoldBackgroundColor, // Genel temadan al
      appBar: AppBar(
        title: const Text("İstatistikler"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacementNamed(context, AppRoutes.mentorHome);
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- ÜST İKİ KART (KOYU ARKA PLANLI) ---
            _buildDarkStatCard(
              title: "Destek Verilen Kullanıcı",
              value: _supportedUserCount.toString(),
              imageAssetPath:
                  'assets/images/user_count_icon.png', // <<< KENDİ RESİM YOLUNUZ
            ),
            const SizedBox(height: 16),
            _buildDarkStatCard(
              title: "Uygulamada Geçen Süre",
              value: _appTimeHours.toString(),
              unit: "Saat",
              imageAssetPath:
                  'assets/images/time_icon.png', // <<< KENDİ RESİM YOLUNUZ
              valueColor:
                  Colors.blueAccent, // Değer için farklı renk (resimdeki gibi)
            ),
            // --- ÜST İKİ KART BİTİŞ ---
            const SizedBox(height: 24),
            _buildChartCard(
              title: "Son 7 Günlük Destek Sayısı",
              chart: _buildLineChart(),
            ),
            const SizedBox(height: 24),
            _buildChartCard(
              title: "Destek Verilen Öğrencilerin Yaş Dağılımı",
              chart: _buildBarChart(),
            ),
            const SizedBox(height: 24),
            _buildChartCard(
              title: "Cinsiyet Dağılımı",
              chart: _buildPieChart(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Referans resimdeki gibi koyu arka planlı ve özel stilli kartlar için
  Widget _buildDarkStatCard({
    required String title,
    required String value,
    String? unit,
    required String imageAssetPath, // IconData yerine String path
    Color valueColor =
        statCardValueAccentColor, // Değer için varsayılan turuncu
  }) {
    return Card(
      color: statCardDarkBackground, // Koyu arka plan
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ), // Daha yuvarlak köşeler
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 10.0,
          vertical: 10,
        ), // Padding artırıldı
        child: Row(
          children: [
            Container(
              // Resim için container (referans resimdeki gibi)
              width: 105,
              height: 105, // Resim boyutu
              padding: const EdgeInsets.all(8), // Resim etrafında iç boşluk
              decoration: BoxDecoration(
                // color: iconBackgroundColor.withOpacity(0.2), // Bu kaldırıldı, resim direkt
                borderRadius: BorderRadius.circular(
                  12,
                ), // Yuvarlak köşeli resim alanı
              ),
              child: Image.asset(
                imageAssetPath,
                fit: BoxFit.contain,
              ), // Icon yerine Image.asset
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      color: statCardPrimaryTextLight,
                      fontWeight: FontWeight.w500,
                    ), // Font boyutu ve rengi ayarlandı
                  ),
                  const SizedBox(height: 6), // Boşluk artırıldı
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        value,
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: valueColor,
                        ), // Değer rengi parametrik
                      ),
                      if (unit != null) const SizedBox(width: 6),
                      if (unit != null)
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 4.0,
                          ), // Birimi biraz aşağı almak için
                          child: Text(
                            unit,
                            style: const TextStyle(
                              fontSize: 18,
                              color: statCardUnitTextLight,
                              fontWeight: FontWeight.w500,
                            ), // Birim rengi ve boyutu
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Grafik kartları için (açık tema)
  Widget _buildChartCard({required String title, required Widget chart}) {
    return Card(
      color: chartCardBackgroundColor, // Açık gri grafik kartı arka planı
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ), // Köşeler yuvarlatıldı
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 20), // Padding ayarlandı
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: chartTitleColor,
              ), // Başlık stili ayarlandı
            ),
            const SizedBox(height: 24), // Başlık ve grafik arası boşluk
            SizedBox(height: 200, child: chart),
          ],
        ),
      ),
    );
  }

  Widget _buildLineChart() {
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: 2.5,
          verticalInterval: 1, // Aralıklar ayarlandı
          getDrawingHorizontalLine:
              (value) => FlLine(
                color: Colors.grey.shade300,
                strokeWidth: 0.8,
              ), // Çizgi rengi açıldı
          getDrawingVerticalLine:
              (value) => FlLine(color: Colors.grey.shade300, strokeWidth: 0.8),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: 2.5,
              getTitlesWidget: _axisTitleWidgets,
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              interval: 1,
              getTitlesWidget: _bottomLineTitleWidgets,
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey.shade300, width: 1),
        ), // Border rengi açıldı
        minX: 0,
        maxX: 6,
        minY: 0,
        maxY: 10,
        lineBarsData: [
          LineChartBarData(
            spots: _dailySupportSpots,
            isCurved: true,
            color: lineColorOrange,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: lineColorOrange.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart() {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 15,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor:
                (group) =>
                    Colors.blueGrey.shade700, // Tooltip rengi koyulaştırıldı
            tooltipRoundedRadius: 8,
            tooltipPadding: const EdgeInsets.all(8),
            tooltipMargin: 8,
            getTooltipItem: (
              BarChartGroupData group,
              int groupIndex,
              BarChartRodData rod,
              int rodIndex,
            ) {
              String label;
              if (groupIndex >= 0 && groupIndex < _ageGroupLabels.length) {
                label = _ageGroupLabels[groupIndex];
              } else {
                label = '';
              }
              return BarTooltipItem(
                '$label\n',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: (rod.toY - (rodIndex == 1 ? group.barRods[0].toY : 0))
                        .toStringAsFixed(0),
                    style: TextStyle(
                      color: rod.color,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: _bottomBarTitleWidgets,
            ),
          ), // reservedSize ayarlandı
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: 3,
              getTitlesWidget: _axisTitleWidgets,
            ),
          ), // reservedSize ayarlandı
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: _ageDistributionBars,
        gridData: const FlGridData(show: false),
      ),
    );
  }

  Widget _buildPieChart() {
    List<PieChartSectionData> sections = [];
    double total = _genderDistributionData.values.fold(
      0,
      (prev, element) => prev + element,
    );
    if (total == 0)
      return const Center(
        child: Text("Veri yok", style: TextStyle(color: chartAxisLabelColor)),
      );
    int i = 0;
    _genderDistributionData.forEach((key, value) {
      final isTouched = i == _touchedPieIndex;
      final fontSize = isTouched ? 15.0 : 11.0; // Boyutlar ayarlandı
      final radius = isTouched ? 70.0 : 60.0;
      final percentage = (value / total * 100).toStringAsFixed(0);
      Color sectionColor;
      switch (key) {
        case 'Erkek':
          sectionColor = pieColorMale;
          break;
        case 'Kadın':
          sectionColor = pieColorFemale;
          break;
        default:
          sectionColor = pieColorOther;
      }
      sections.add(
        PieChartSectionData(
          color: sectionColor,
          value: value,
          title: '$percentage%\n$key',
          radius: radius,
          titleStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [const Shadow(color: Colors.black38, blurRadius: 2)],
          ),
          titlePositionPercentageOffset: 0.55,
        ),
      );
      i++;
    });
    return PieChart(
      PieChartData(
        pieTouchData: PieTouchData(
          touchCallback: (FlTouchEvent event, pieTouchResponse) {
            setState(() {
              if (!event.isInterestedForInteractions ||
                  pieTouchResponse == null ||
                  pieTouchResponse.touchedSection == null) {
                _touchedPieIndex = -1;
                return;
              }
              _touchedPieIndex =
                  pieTouchResponse.touchedSection!.touchedSectionIndex;
            });
          },
        ),
        borderData: FlBorderData(show: false),
        sectionsSpace: 2,
        centerSpaceRadius: 45,
        sections: sections,
      ),
    );
  }

  // Eksen Başlıkları İçin Yardımcı Metot (Hem Line hem Bar chart için ortak olabilir)
  Widget _axisTitleWidgets(double value, TitleMeta meta) {
    final style = TextStyle(
      color: chartAxisLabelColor,
      fontWeight: FontWeight.bold,
      fontSize: 10,
    );
    String text;
    if (value == meta.max || value == meta.min) {
      // Sadece min ve max değerleri gösterme (isteğe bağlı)
      return Container();
    }
    if (value.toInt() % meta.appliedInterval.toInt() == 0) {
      text = value.toInt().toString();
    } else {
      return Container();
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 4,
      child: Text(text, style: style),
    );
  }

  Widget _bottomLineTitleWidgets(double value, TitleMeta meta) {
    final style = TextStyle(
      color: chartAxisLabelColor,
      fontWeight: FontWeight.bold,
      fontSize: 10,
    );
    Widget text;
    switch (value.toInt()) {
      case 0:
        text = Text('7GÖ', style: style);
        break;
      case 1:
        text = Text('6GÖ', style: style);
        break;
      case 2:
        text = Text('5GÖ', style: style);
        break;
      case 3:
        text = Text('4GÖ', style: style);
        break;
      case 4:
        text = Text('3GÖ', style: style);
        break;
      case 5:
        text = Text('DÜN', style: style);
        break;
      case 6:
        text = Text('BUGÜN', style: style);
        break;
      default:
        text = Text('', style: style);
        break;
    }
    return SideTitleWidget(axisSide: meta.axisSide, space: 4, child: text);
  }

  Widget _bottomBarTitleWidgets(double value, TitleMeta meta) {
    final style = TextStyle(
      color: chartAxisLabelColor,
      fontWeight: FontWeight.bold,
      fontSize: 10,
    );
    Widget text;
    int index = value.toInt();
    if (index >= 0 && index < _ageGroupLabels.length) {
      text = Text(_ageGroupLabels[index], style: style);
    } else {
      text = Text('', style: style);
    }
    return SideTitleWidget(axisSide: meta.axisSide, space: 4.0, child: text);
  }
}
