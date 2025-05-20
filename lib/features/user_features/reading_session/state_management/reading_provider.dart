// lib/features/user_features/reading_session/state_management/reading_provider.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
// import 'package:file_picker/file_picker.dart'; // KALDIRILDI
import 'package:image_picker/image_picker.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import '../../../../state_management/auth_provider.dart';
import '../models/file_word_count_response_dto.dart';
import '../services/reading_service.dart';
import '../models/reading_file_request_dto.dart';
import '../models/create_reading_session_request_dto.dart';
import '../models/reading_session_result_dto.dart';

enum ReadingStatus {
  initial,
  started,
  paused,
  finishedFileProcessing,
  finishedSession,
}

// FileTypeToUpload enum'ı artık sadece image içeriyor veya UI'da seçime gerek kalmadığı için
// bu enum ve _selectedFileType alanı tamamen kaldırılabilir.
// Şimdilik provider içinde _selectedFileType = FileTypeToUpload.image olarak sabit bırakıyorum.
enum FileTypeToUpload { image } // Sadece image

class ReadingProvider with ChangeNotifier {
  final ReadingService _readingService = ReadingService();
  final AuthProvider _authProvider;

  final StopWatchTimer _stopWatchTimer = StopWatchTimer(
    mode: StopWatchMode.countUp,
  );
  String _displayTime = "00:00:00";
  int _recordedTimeInSeconds = 0;

  ReadingStatus _currentStatus = ReadingStatus.initial;
  final FileTypeToUpload _selectedFileType =
      FileTypeToUpload.image; // Her zaman image
  bool _isLoadingFile = false;
  bool _isSubmittingSession = false;

  int _totalWordCount = 0;
  File? _lastPickedFile;
  String? _operationError;
  ReadingSessionResultDataDto? _sessionResult;

  String get displayTime => _displayTime;
  ReadingStatus get currentStatus => _currentStatus;
  FileTypeToUpload get selectedFileType =>
      _selectedFileType; // UI'da kullanılmayacaksa kaldırılabilir
  bool get isLoadingFile => _isLoadingFile;
  bool get isSubmittingSession => _isSubmittingSession;
  int get totalWordCount => _totalWordCount;
  String? get operationError => _operationError;
  ReadingSessionResultDataDto? get sessionResult => _sessionResult;
  bool get isTimerRunning => _stopWatchTimer.isRunning;

  ReadingProvider(this._authProvider) {
    _stopWatchTimer.rawTime.listen((value) {
      _displayTime = StopWatchTimer.getDisplayTime(
        value,
        hours: true,
        minute: true,
        second: true,
        milliSecond: false,
      );
      _recordedTimeInSeconds = (value / 1000).floor();
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _stopWatchTimer.dispose();
    super.dispose();
  }

  void startTimer() {
    if (_currentStatus == ReadingStatus.initial ||
        _currentStatus == ReadingStatus.paused) {
      _stopWatchTimer.onExecute.add(StopWatchExecute.start);
      _currentStatus = ReadingStatus.started;
      _sessionResult = null;
      _totalWordCount = 0;
      _operationError = null;
      _lastPickedFile = null; // Yeni seans için önceki dosyayı temizle
      notifyListeners();
    }
  }

  void pauseTimer() {
    if (_currentStatus == ReadingStatus.started) {
      _stopWatchTimer.onExecute.add(StopWatchExecute.stop);
      _currentStatus = ReadingStatus.paused;
      notifyListeners();
    }
  }

  void resumeTimer() {
    startTimer(); // Zaten paused durumunu kontrol ediyor
  }

  void resetTimer() {
    _stopWatchTimer.onExecute.add(StopWatchExecute.reset);
    _displayTime = "00:00:00"; // Manuel set et, listener bazen gecikebilir
    _recordedTimeInSeconds = 0;
    _currentStatus = ReadingStatus.initial;
    _totalWordCount = 0;
    _sessionResult = null;
    _operationError = null;
    _lastPickedFile = null;
    notifyListeners();
  }

  void finishFileProcessingPhase() {
    if (_currentStatus == ReadingStatus.started ||
        _currentStatus == ReadingStatus.paused) {
      _stopWatchTimer.onExecute.add(StopWatchExecute.stop);
      _currentStatus = ReadingStatus.finishedFileProcessing;
      _operationError = null;
      notifyListeners();
    }
  }

  // selectFileType metodu artık sadece image için olduğundan kaldırılabilir veya özel bir mantığı kalmaz.
  // void selectFileType(FileTypeToUpload type) {
  //   // _selectedFileType = type; // Hep image
  //   _lastPickedFile = null;
  //   notifyListeners();
  // }

  Future<void> pickAndProcessFile(ImageSource imageSource) async {
    // Sadece ImageSource alır
    if (_authProvider.token == null) {
      _operationError = "İşlem için oturum gerekli.";
      notifyListeners();
      return;
    }
    _isLoadingFile = true;
    _operationError = null;
    _lastPickedFile = null; // Her yeni seçimde öncekini temizle
    notifyListeners();

    String? base64Content;
    String fileNameForLog = "fotoğraf";

    try {
      // Sadece image seçme mantığı
      final XFile? pickedXFile = await ImagePicker().pickImage(
        source: imageSource,
        imageQuality: 70, // %70 kalite
        maxWidth: 1024, // Maksimum genişlik
        maxHeight: 1024, // Maksimum yükseklik (isteğe bağlı)
      );

      if (pickedXFile != null) {
        _lastPickedFile = File(pickedXFile.path);
        fileNameForLog = pickedXFile.name;
        final bytes = await _lastPickedFile!.readAsBytes();
        base64Content = base64Encode(bytes);
      }

      if (base64Content == null || _lastPickedFile == null) {
        _isLoadingFile = false;
        // _operationError = "Fotoğraf seçilemedi."; // Hata mesajını burada set etme, kullanıcıya UI'da bilgi verilebilir.
        notifyListeners();
        return; // Kullanıcı dosya seçmediyse işlem yapma
      }

      print("ReadingProvider: '$fileNameForLog' işleniyor (Resim).");
      final requestDto = ReadingFileRequestDto(base64Content: base64Content);
      // Sadece getWordCountFromImage çağrılacak
      FileWordCountApiResponseDto response = await _readingService
          .getWordCountFromImage(requestDto, _authProvider.token!);

      if (response.isSuccess && response.data != null) {
        _totalWordCount += response.data!.wordCount.toInt();
        _operationError = null;
        print(
          "ReadingProvider: Kelime sayısı eklendi: ${response.data!.wordCount}, Toplam: $_totalWordCount",
        );
      } else {
        _operationError =
            response.errors?.join(", ") ??
            "Fotoğraftan kelime sayısı alınamadı.";
      }
    } catch (e) {
      _operationError = "Fotoğraf işlenirken bir hata oluştu: $e";
      print("ReadingProvider: pickAndProcessFile Hata: $e");
    } finally {
      _isLoadingFile = false;
      notifyListeners();
    }
  }

  void clearLastPickedFileAndError() {
    _lastPickedFile = null;
    _operationError = null;
    notifyListeners();
  }

  Future<bool> saveReadingSession() async {
    if (_authProvider.token == null) {
      _operationError = "İşlem için oturum gerekli.";
      notifyListeners();
      return false;
    }
    if (_totalWordCount == 0) {
      _operationError =
          "Kaydedilecek kelime bulunmuyor. Lütfen önce fotoğraf ekleyin.";
      notifyListeners();
      return false;
    }
    if (_recordedTimeInSeconds == 0 &&
        _currentStatus != ReadingStatus.initial) {
      // Eğer hiç başlamadıysa süre 0 olabilir
      _operationError =
          "Okuma süresi sıfır olamaz. Lütfen zamanlayıcıyı başlatın veya dosya ekleyin.";
      notifyListeners();
      return false;
    }

    _isSubmittingSession = true;
    _operationError = null;
    _sessionResult = null;
    notifyListeners();

    int hours = (_recordedTimeInSeconds ~/ 3600);
    int minutes = ((_recordedTimeInSeconds % 3600) ~/ 60);
    int seconds = _recordedTimeInSeconds % 60;
    String durationString =
        "${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";

    final requestDto = CreateReadingSessionRequestDto(
      wordCount: _totalWordCount,
      duration: durationString,
    );
    final ReadingSessionResultApiResponseDto response = await _readingService
        .createReadingSession(requestDto, _authProvider.token!);
    _isSubmittingSession = false;

    if (response.isSuccess && response.data != null) {
      _sessionResult = response.data!;
      _currentStatus = ReadingStatus.finishedSession;
      _operationError = null;
      print(
        "ReadingProvider: Okuma seansı başarıyla kaydedildi. Hız: ${_sessionResult!.speed} K/Dk",
      );
      notifyListeners();
      return true;
    } else {
      _operationError =
          response.errors?.join(", ") ?? "Okuma seansı kaydedilemedi.";
      notifyListeners();
      return false;
    }
  }
}
