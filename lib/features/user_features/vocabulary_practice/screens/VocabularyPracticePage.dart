import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../state_management/auth_provider.dart';
import '../../../../core/navigation/app_routes.dart';
import '../state_management/vocabulary_provider.dart';
import '../models/word_enums.dart';

class VocabularyLevel {
  final String id;
  final String title;
  final int wpm;
  final Color tagColor;
  final Color textColor;

  const VocabularyLevel({
    required this.id,
    required this.title,
    required this.wpm,
    required this.tagColor,
    this.textColor = Colors.white,
  });
}

class VocabularyPracticePage extends StatefulWidget {
  const VocabularyPracticePage({Key? key}) : super(key: key);

  @override
  State<VocabularyPracticePage> createState() => _VocabularyPracticePageState();
}

class _VocabularyPracticePageState extends State<VocabularyPracticePage> {
  static const Color _levelLowColor = Color(0xFFEF4444);
  static const Color _levelNormalColor = Color(0xFFF59E0B);
  static const Color _levelGoodColor = Color(0xFFEAB308);
  static const Color _levelGreatColor = Color(0xFF22C55E);
  static const Color _levelAmazingColor = Color(0xFF8B5CF6);
  static const Color _textDark = Color(0xFF1F2937);

  static const Color _pageBackgroundColor = Color(0xFFF9FAFB);
  static const Color _sectionTitleColor = Color(0xFF1F2937);
  static const Color _cardBackgroundColor = Colors.white;
  static const Color _cardTextColor = Color(0xFF4B5563);

  final List<VocabularyLevel> _levels = const [
    VocabularyLevel(
      id: 'low',
      title: 'Düşük',
      wpm: 75,
      tagColor: _levelLowColor,
    ),
    VocabularyLevel(
      id: 'normal',
      title: 'Normal',
      wpm: 125,
      tagColor: _levelNormalColor,
    ),
    VocabularyLevel(
      id: 'good',
      title: 'İyi',
      wpm: 400,
      tagColor: _levelGoodColor,
      textColor: _textDark,
    ),
    VocabularyLevel(
      id: 'great',
      title: 'Harika',
      wpm: 625,
      tagColor: _levelGreatColor,
    ),
    VocabularyLevel(
      id: 'amazing',
      title: 'İnanılmaz',
      wpm: 875,
      tagColor: _levelAmazingColor,
    ),
  ];
  final double _levelTagWidth = 110.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        if (!authProvider.isAuthenticated) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.login,
            (route) => false,
          );
        } else {
          Provider.of<VocabularyProvider>(
            context,
            listen: false,
          ).goBackToLevelSelection();
        }
      }
    });
  }

  void _onLevelSelected(BuildContext context, VocabularyLevel level) {
    final vocabProvider = Provider.of<VocabularyProvider>(
      context,
      listen: false,
    );
    vocabProvider.selectLevelAndStartLoading(level);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Consumer<VocabularyProvider>(
      builder: (context, vocabProvider, child) {
        return WillPopScope(
          onWillPop: () async {
            if (vocabProvider.status != VocabPracticeStatus.levelSelection) {
              vocabProvider.goBackToLevelSelection();
              return false;
            }
            return true;
          },
          child: Scaffold(
            backgroundColor: _pageBackgroundColor,
            appBar: AppBar(
              title: Text(_getAppBarTitle(vocabProvider.status)),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  if (vocabProvider.status !=
                      VocabPracticeStatus.levelSelection) {
                    vocabProvider.goBackToLevelSelection();
                  } else {
                    if (Navigator.canPop(context))
                      Navigator.pop(context);
                    else
                      Navigator.pushReplacementNamed(
                        context,
                        AppRoutes.publicHome,
                      );
                  }
                },
              ),
            ),
            body: _buildBodyContent(context, vocabProvider),
          ),
        );
      },
    );
  }

  String _getAppBarTitle(VocabPracticeStatus status) {
    switch (status) {
      case VocabPracticeStatus.levelSelection:
        return 'Seviye Seç';
      case VocabPracticeStatus.loadingWords:
        return 'Kelimeler Yükleniyor...';
      case VocabPracticeStatus.displayingWords:
      case VocabPracticeStatus.paused:
        return 'Kelime Alıştırması';
      case VocabPracticeStatus.results:
        return 'Alıştırma Sonucu';
      case VocabPracticeStatus.error:
        return 'Hata Oluştu';
      default:
        return 'Kelimeleri Kavra';
    }
  }

  Widget _buildBodyContent(
    BuildContext context,
    VocabularyProvider vocabProvider,
  ) {
    switch (vocabProvider.status) {
      case VocabPracticeStatus.levelSelection:
        return _buildLevelSelectionView(context, vocabProvider);
      case VocabPracticeStatus.loadingWords:
        return const Center(
          child: CircularProgressIndicator(color: Colors.orange),
        );
      case VocabPracticeStatus.displayingWords:
      case VocabPracticeStatus.paused:
        return _buildWordDisplayView(context, vocabProvider);
      case VocabPracticeStatus.results:
        return _buildResultsView(context, vocabProvider);
      case VocabPracticeStatus.error:
        return _buildErrorView(context, vocabProvider);
      default:
        return const Center(child: Text("Bilinmeyen durum."));
    }
  }

  Widget _buildLevelSelectionView(
    BuildContext context,
    VocabularyProvider vocabProvider,
  ) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 20.0),
          child: Text(
            'Seviyeler',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: _sectionTitleColor,
            ),
          ),
        ),
        ..._levels
            .map((level) => _buildLevelCard(level, vocabProvider))
            .toList(),
      ],
    );
  }

  Widget _buildLevelCard(
    VocabularyLevel level,
    VocabularyProvider vocabProvider,
  ) {
    Color wpmValueColor = level.tagColor;
    if (level.tagColor == _levelGoodColor)
      wpmValueColor = Colors.amber.shade800;
    else if (level.tagColor == _levelNormalColor)
      wpmValueColor = Colors.orange.shade800;
    else if (level.tagColor == _levelLowColor)
      wpmValueColor = Colors.red.shade700;
    else if (level.tagColor == _levelGreatColor)
      wpmValueColor = Colors.green.shade700;
    else if (level.tagColor == _levelAmazingColor)
      wpmValueColor = Colors.purple.shade700;

    return Card(
      elevation: 1.5,
      margin: const EdgeInsets.only(bottom: 12.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      color: _cardBackgroundColor,
      child: InkWell(
        onTap:
            vocabProvider.isLoading
                ? null
                : () => _onLevelSelected(context, level),
        borderRadius: BorderRadius.circular(16.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 18.0),
          child: Row(
            children: [
              Container(
                width: _levelTagWidth,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 10.0,
                ),
                decoration: BoxDecoration(
                  color: level.tagColor,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Center(
                  child: Text(
                    level.title,
                    style: TextStyle(
                      color: level.textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 16, color: _cardTextColor),
                    children: <TextSpan>[
                      TextSpan(
                        text: '${level.wpm}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: wpmValueColor,
                          fontSize: 26,
                        ),
                      ),
                      const TextSpan(
                        text: ' kelime/dk',
                        style: TextStyle(
                          fontSize: 15,
                          color: _cardTextColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey.shade400,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWordDisplayView(
    BuildContext context,
    VocabularyProvider vocabProvider,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          vocabProvider.sessionDisplayTime,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 40),
        Container(
          height: 150,
          alignment: Alignment.center,
          child: Text(
            vocabProvider.displayedWord,
            style: const TextStyle(
              fontSize: 60,
              fontWeight: FontWeight.bold,
              color: _textDark,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 50),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: vocabProvider.resumeWordDisplay,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: Text(
                vocabProvider.status == VocabPracticeStatus.paused
                    ? 'Devam Et'
                    : 'Başlat',
                style: const TextStyle(fontSize: 16),
              ),
            ),
            ElevatedButton(
              onPressed: vocabProvider.pauseWordDisplay,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade700,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text('Duraklat', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Center(
          child: TextButton(
            onPressed: () => vocabProvider.goBackToLevelSelection(),
            child: const Text(
              "Seviye Seçimine Dön",
              style: TextStyle(color: Colors.redAccent, fontSize: 15),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultsView(
    BuildContext context,
    VocabularyProvider vocabProvider,
  ) {
    final wpm = vocabProvider.selectedLevel?.wpm ?? 0;
    final Map<ApiWordType, int> counts = vocabProvider.wordTypeCounts;
    final List<Widget> typeWidgets = [];

    counts.forEach((type, count) {
      if (count > 0) {
        typeWidgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${getApiWordTypeDisplayName(type)}:",
                  style: TextStyle(fontSize: 16, color: _cardTextColor),
                ),
                Text(
                  "$count kelime",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: _textDark,
                  ),
                ),
              ],
            ),
          ),
        );
      }
    });

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(
            Icons.emoji_events_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 20),
          Text(
            'Alıştırma Tamamlandı!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: _sectionTitleColor,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Seviye: ${vocabProvider.selectedLevel?.title ?? ""}',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, color: _cardTextColor),
          ),
          const SizedBox(height: 25),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Text(
                    'Hedeflenen Hız',
                    style: TextStyle(
                      fontSize: 17,
                      color: _cardTextColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '$wpm Kelime/dk',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  if (typeWidgets.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    const Text(
                      'Kelime Türü Dağılımı:',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: _textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...typeWidgets,
                  ] else
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.0),
                      child: Text(
                        "Kelime türü bilgisi bulunamadı.",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              OutlinedButton(
                onPressed: () => vocabProvider.restartPractice(),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  textStyle: const TextStyle(fontSize: 16),
                ),
                child: const Text('Tekrar Dene'),
              ),
              ElevatedButton(
                onPressed: () => vocabProvider.goBackToLevelSelection(),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  textStyle: const TextStyle(fontSize: 16),
                ),
                child: const Text('Başa Dön'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(
    BuildContext context,
    VocabularyProvider vocabProvider,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade400, size: 70),
            const SizedBox(height: 20),
            Text(
              "Bir Sorun Oluştu",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              vocabProvider.errorMessage ?? "Bilinmeyen bir hata.",
              style: TextStyle(fontSize: 16, color: _cardTextColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 25),
            ElevatedButton(
              onPressed: () => vocabProvider.goBackToLevelSelection(),
              child: const Text('Seviye Seçimine Dön'),
            ),
          ],
        ),
      ),
    );
  }
}
