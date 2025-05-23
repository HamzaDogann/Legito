import 'dart:async';
import 'package:flutter/material.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import '../../../../state_management/auth_provider.dart'; // AuthProvider importu
import '../services/word_service.dart';
import '../models/word_item_dto.dart';
import '../models/word_enums.dart';
import '../screens/VocabularyPracticePage.dart' show VocabularyLevel;

enum VocabPracticeStatus {
  levelSelection,
  loadingWords,
  displayingWords,
  paused,
  results,
  error,
}

class VocabularyProvider with ChangeNotifier {
  final WordService _wordService = WordService();
  final AuthProvider _authProvider;

  final StopWatchTimer _sessionStopWatch = StopWatchTimer(
    mode: StopWatchMode.countDown,
  );
  Timer? _wordDisplayTimer;

  VocabPracticeStatus _status = VocabPracticeStatus.levelSelection;
  VocabularyLevel? _selectedLevel;
  List<WordItemDto> _currentWords = [];
  int _currentWordIndex = 0;
  String _displayedWord = "";
  String _sessionDisplayTime = "01:00";
  bool _isLoading = false;
  String? _errorMessage;
  Map<ApiWordType, int> _wordTypeCounts = {};

  VocabPracticeStatus get status => _status;
  VocabularyLevel? get selectedLevel => _selectedLevel;
  String get displayedWord => _displayedWord;
  String get sessionDisplayTime => _sessionDisplayTime;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<ApiWordType, int> get wordTypeCounts => _wordTypeCounts;
  List<WordItemDto> get currentWords => _currentWords;
  bool get isPracticeInProgress =>
      _status == VocabPracticeStatus.displayingWords ||
      _status == VocabPracticeStatus.paused;
  bool get isTimerEffectivelyRunning =>
      _sessionStopWatch.isRunning &&
      _status == VocabPracticeStatus.displayingWords;

  VocabularyProvider(this._authProvider) {
    _sessionStopWatch.fetchEnded.listen((_) {
      print('VocabularyProvider: Zamanlayıcı bitti (fetchEnded).');
      _finishPractice();
    });
    _sessionStopWatch.rawTime.listen((value) {
      _sessionDisplayTime = StopWatchTimer.getDisplayTime(
        value,
        hours: false,
        minute: true,
        second: true,
        milliSecond: false,
      );
      notifyListeners();
    });
    _resetAndPrepareStopWatch();
  }

  void _resetAndPrepareStopWatch() {
    _sessionStopWatch.onResetTimer();
    _sessionStopWatch.setPresetSecondTime(60); // Her zaman 60 saniye

    _sessionDisplayTime = StopWatchTimer.getDisplayTime(
      60 * 1000, // 60 saniye milisaniye cinsinden
      hours: false,
      minute: true,
      second: true,
      milliSecond: false,
    );
  }

  @override
  void dispose() {
    _sessionStopWatch.dispose();
    _wordDisplayTimer?.cancel();
    super.dispose();
  }

  void selectLevelAndStartLoading(VocabularyLevel level) {
    if (_isLoading && _status == VocabPracticeStatus.loadingWords) return;
    print(
      "VocabularyProvider: Seviye seçildi - ${level.title}, WPM: ${level.wpm}",
    );

    _wordDisplayTimer?.cancel();
    _sessionStopWatch.onStopTimer();
    _resetAndPrepareStopWatch();

    _selectedLevel = level;
    _status = VocabPracticeStatus.loadingWords;
    _isLoading = true;
    _errorMessage = null;
    _currentWords = [];
    _currentWordIndex = 0;
    _displayedWord = "";
    _wordTypeCounts = {};
    notifyListeners();
    _fetchWordsForLevel(level);
  }

  Future<void> _fetchWordsForLevel(VocabularyLevel level) async {
    if (_authProvider.token == null) {
      _errorMessage = "Kelime çekmek için oturum gerekli.";
      _status = VocabPracticeStatus.error;
      _isLoading = false;
      notifyListeners();
      return;
    }

    final response = await _wordService.getRandomWords(
      wordCount: level.wpm,
      accessToken: _authProvider.token!,
    );
    _isLoading = false;

    if (response.isSuccess &&
        response.data != null &&
        response.data!.isNotEmpty) {
      _currentWords = response.data!;
      _startWordDisplay();
    } else {
      _errorMessage =
          response.errors?.join(", ") ??
          "Kelimeler yüklenemedi veya bu seviye için kelime bulunamadı.";
      _status = VocabPracticeStatus.error;
      notifyListeners();
    }
  }

  void _startWordDisplay() {
    if (_currentWords.isEmpty || _selectedLevel == null) {
      _finishPractice(); // Bu durumda bile _finishPractice kontrolü devreye girecek.
      return;
    }

    _status = VocabPracticeStatus.displayingWords;
    _currentWordIndex = -1;
    _wordDisplayTimer?.cancel();

    _sessionStopWatch.onStopTimer();
    _sessionStopWatch.onResetTimer();
    _sessionStopWatch.setPresetSecondTime(60); // Sabit 60 saniye

    _sessionDisplayTime = StopWatchTimer.getDisplayTime(
      60 * 1000,
      hours: false,
      minute: true,
      second: true,
      milliSecond: false,
    );
    notifyListeners();

    _sessionStopWatch.onStartTimer();

    final double displayIntervalSeconds = 60.0 / _selectedLevel!.wpm.toDouble();
    final int displayIntervalMilliseconds = (displayIntervalSeconds * 1000)
        .round()
        .clamp(50, 5000);
    print(
      "Word Display Interval: $displayIntervalMilliseconds ms for WPM: ${_selectedLevel!.wpm}",
    );

    _moveToNextWord(); // İlk kelimeyi hemen göster

    _wordDisplayTimer = Timer.periodic(
      Duration(milliseconds: displayIntervalMilliseconds),
      (timer) {
        if (_status != VocabPracticeStatus.displayingWords ||
            !_sessionStopWatch.isRunning) {
          timer.cancel();
          // Zamanlayıcı durduğunda ve hala kelime gösterme modundaysak bitir.
          // Bu, goBackToLevelSelection çağrıldığında _status değişeceği için sorun olmamalı.
          if (!_sessionStopWatch.isRunning &&
              _status == VocabPracticeStatus.displayingWords) {
            _finishPractice();
          }
          return;
        }
        _moveToNextWord();
      },
    );
  }

  void _moveToNextWord() {
    _currentWordIndex++;
    if (_currentWordIndex < _currentWords.length) {
      _displayedWord = _currentWords[_currentWordIndex].name;
    } else {
      // Kelimeler bitti ama zamanlayıcı hala çalışıyorsa, zamanlayıcının bitmesini bekle.
      // Eğer kelimeler bittiği anda pratiği bitirmek isterseniz, burada _finishPractice() çağrılabilir.
      _displayedWord = "";
      _wordDisplayTimer
          ?.cancel(); // Kelimeler bittiği için kelime gösterme timer'ını durdur.
    }
    notifyListeners();
  }

  void pauseWordDisplay() {
    if (_status == VocabPracticeStatus.displayingWords) {
      _status = VocabPracticeStatus.paused;
      _sessionStopWatch.onStopTimer();
      _wordDisplayTimer?.cancel();
      print(
        "VocabularyProvider: Alıştırma Duraklatıldı. Gösterilen Kelime: $_displayedWord, Index: $_currentWordIndex",
      );
      notifyListeners();
    }
  }

  void resumeWordDisplay() {
    if (_status == VocabPracticeStatus.paused &&
        _selectedLevel != null &&
        _currentWords.isNotEmpty) {
      _status = VocabPracticeStatus.displayingWords;
      notifyListeners();

      _sessionStopWatch.onStartTimer();
      print(
        "VocabularyProvider: Alıştırma Devam Ediyor. Index: $_currentWordIndex",
      );

      final double displayIntervalSeconds =
          60.0 / _selectedLevel!.wpm.toDouble();
      final int displayIntervalMilliseconds = (displayIntervalSeconds * 1000)
          .round()
          .clamp(50, 5000);

      _wordDisplayTimer?.cancel(); // Önceki timer'ı iptal et (eğer varsa)

      // Eğer duraklatıldığında kelime listesinin sonuna gelinmişse, yeni timer başlatma.
      if (_currentWordIndex >= _currentWords.length && _displayedWord.isEmpty) {
        // Kelimeler zaten bitmişse ve son kelime boşsa, bir şey yapma.
        // Zamanlayıcı (StopWatch) devam eder, bittiğinde _finishPractice çağrılır.
        return;
      }

      _wordDisplayTimer = Timer.periodic(
        Duration(milliseconds: displayIntervalMilliseconds),
        (timer) {
          if (_status != VocabPracticeStatus.displayingWords ||
              !_sessionStopWatch.isRunning) {
            timer.cancel();
            if (!_sessionStopWatch.isRunning &&
                _status == VocabPracticeStatus.displayingWords)
              _finishPractice();
            return;
          }
          _moveToNextWord();
        },
      );
    }
  }

  void _finishPractice() {
    // EĞER DURUM ZATEN SONUÇLARSA VEYA SEVİYE SEÇİMİNE GEÇİLMİŞSE, TEKRAR SONUÇLARA GEÇME.
    if (_status == VocabPracticeStatus.results ||
        _status == VocabPracticeStatus.levelSelection) {
      print(
        "VocabularyProvider: _finishPractice çağrıldı ancak durum zaten '$_status'. Sonuçlara geçiş engellendi.",
      );
      // Bu durumda bile zamanlayıcıların durduğundan emin olalım.
      _sessionStopWatch.onStopTimer();
      _wordDisplayTimer?.cancel();
      return;
    }

    print(
      "VocabularyProvider: Alıştırma bitti. Son index: $_currentWordIndex, Toplam kelime: ${_currentWords.length}",
    );
    _status = VocabPracticeStatus.results;
    _sessionStopWatch.onStopTimer();
    _wordDisplayTimer?.cancel();
    _calculateWordTypeCounts();
    notifyListeners();
  }

  void _calculateWordTypeCounts() {
    _wordTypeCounts.clear();
    // Gösterilen kelime sayısı, _currentWordIndex'in bir fazlasıdır (0 tabanlı olduğu için).
    // Ancak _currentWordIndex, listenin boyutunu aşabilir eğer _moveToNextWord çağrılmaya devam ederse.
    // Bu yüzden gerçekten _currentWords listesi içinde kalan indisleri saymalıyız.
    int wordsActuallyDisplayedCount =
        _currentWordIndex + 1; // Potansiyel olarak gösterilenler

    // Eğer _currentWordIndex listenin son elemanını işaret ediyorsa (length - 1),
    // o zaman wordsActuallyDisplayedCount = length olur.
    // Eğer _currentWordIndex, listenin boyutunu aşmışsa (örneğin son kelime gösterildikten sonra bir daha _moveToNextWord çağrılırsa),
    // bunu _currentWords.length ile sınırla.
    if (wordsActuallyDisplayedCount > _currentWords.length) {
      wordsActuallyDisplayedCount = _currentWords.length;
    }
    if (wordsActuallyDisplayedCount < 0)
      wordsActuallyDisplayedCount = 0; // Negatif olamaz.

    print("Hesaplanacak kelime adedi: $wordsActuallyDisplayedCount");
    for (
      int i = 0;
      i < wordsActuallyDisplayedCount && i < _currentWords.length;
      i++
    ) {
      // i < _currentWords.length ek kontrolü, wordsActuallyDisplayedCount'ın
      // _currentWords boşken bile 1 olabileceği durumlar için (currentWordIndex = -1 iken)
      final wordDto = _currentWords[i];
      if (wordDto.type >= 0 && wordDto.type < ApiWordType.values.length) {
        ApiWordType type = ApiWordType.values[wordDto.type];
        _wordTypeCounts[type] = (_wordTypeCounts[type] ?? 0) + 1;
      }
    }
    print("Kelime Türü Sayımları: $_wordTypeCounts");
  }

  void restartPractice() {
    if (_selectedLevel != null) {
      print(
        "VocabularyProvider: Alıştırma yeniden başlatılıyor. Seviye: ${_selectedLevel!.title}",
      );
      selectLevelAndStartLoading(_selectedLevel!);
    } else {
      goBackToLevelSelection();
    }
  }

  void goBackToLevelSelection() {
    print(
      "VocabularyProvider: Seviye seçimine dönülüyor. Mevcut durum: $_status",
    );
    _status = VocabPracticeStatus.levelSelection;
    _wordDisplayTimer?.cancel();
    _sessionStopWatch.onStopTimer();
    _resetAndPrepareStopWatch();

    _currentWords = [];
    _displayedWord = "";
    _selectedLevel = null;
    _errorMessage = null;
    _isLoading = false;
    _wordTypeCounts = {};
    _currentWordIndex = 0;
    notifyListeners();
  }
}
