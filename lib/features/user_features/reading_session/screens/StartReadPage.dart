// lib/features/user_features/reading_session/screens/StartReadPage.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../state_management/auth_provider.dart';
import '../state_management/reading_provider.dart';

class StartReadPage extends StatefulWidget {
  const StartReadPage({Key? key}) : super(key: key);

  @override
  State<StartReadPage> createState() => _StartReadPageState();
}

class _StartReadPageState extends State<StartReadPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<ReadingProvider>(context, listen: false).resetTimer();
      }
    });
  }

  Future<void> _pickImageFromSource(
    BuildContext context,
    ImageSource source,
  ) async {
    final readingProvider = Provider.of<ReadingProvider>(
      context,
      listen: false,
    );
    // Yeni dosya seçmeden önce önceki hatayı temizle (UI'da kalmasın diye)
    readingProvider.clearLastPickedFileAndError();
    await readingProvider.pickAndProcessFile(source);
    if (readingProvider.operationError != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Resim işlenirken hata: ${readingProvider.operationError}",
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bContext) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galeriden Seç'),
                onTap: () {
                  Navigator.of(bContext).pop();
                  _pickImageFromSource(context, ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Kameradan Çek'),
                onTap: () {
                  Navigator.of(bContext).pop();
                  _pickImageFromSource(context, ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted)
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.login,
            (route) => false,
          );
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return WillPopScope(
      onWillPop: () async {
        Provider.of<ReadingProvider>(context, listen: false).resetTimer();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Okuma Seansı'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Provider.of<ReadingProvider>(context, listen: false).resetTimer();
              Navigator.pop(context);
            },
          ),
        ),
        body: Consumer<ReadingProvider>(
          builder: (context, readingProvider, child) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      if (readingProvider.currentStatus ==
                          ReadingStatus.initial)
                        _buildInitialView(context, readingProvider),
                      if (readingProvider.currentStatus ==
                              ReadingStatus.started ||
                          readingProvider.currentStatus == ReadingStatus.paused)
                        _buildTimerView(context, readingProvider),
                      if (readingProvider.currentStatus ==
                          ReadingStatus.finishedFileProcessing)
                        _buildFileProcessingView(context, readingProvider),
                      if (readingProvider.currentStatus ==
                              ReadingStatus.finishedSession &&
                          readingProvider.sessionResult != null)
                        _buildSessionResultView(context, readingProvider),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInitialView(
    BuildContext context,
    ReadingProvider readingProvider,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.timer_outlined,
          size: 100,
          color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
        ),
        const SizedBox(height: 30),
        Text(
          "Okuma hızınızı ölçmek ve geliştirmek için yeni bir seans başlatın.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, color: Colors.grey.shade700),
        ),
        const SizedBox(height: 40),
        ElevatedButton.icon(
          icon: const Icon(Icons.play_arrow, size: 32),
          label: const Text('Okumaya Başla', style: TextStyle(fontSize: 20)),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: readingProvider.startTimer,
        ),
      ],
    );
  }

  Widget _buildTimerView(
    BuildContext context,
    ReadingProvider readingProvider,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          readingProvider.displayTime,
          style: TextStyle(
            fontSize: 72,
            fontWeight: FontWeight.w300,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 50),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildTimerButton(
              icon: Icons.refresh,
              label: 'Sıfırla',
              onPressed: readingProvider.resetTimer,
              color: Colors.grey.shade700,
            ),
            _buildTimerButton(
              icon:
                  readingProvider.isTimerRunning
                      ? Icons.pause
                      : Icons.play_arrow,
              label: readingProvider.isTimerRunning ? 'Duraklat' : 'Devam Et',
              onPressed:
                  readingProvider.isTimerRunning
                      ? readingProvider.pauseTimer
                      : readingProvider.resumeTimer,
              color: Theme.of(context).colorScheme.primary,
              isFilled: true,
            ),
            _buildTimerButton(
              icon: Icons.stop,
              label: 'Bitir',
              onPressed: readingProvider.finishFileProcessingPhase,
              color: Colors.green.shade700,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimerButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
    bool isFilled = false,
  }) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 20),
      label: Text(label),
      onPressed: onPressed,
      style:
          isFilled
              ? ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                textStyle: const TextStyle(fontSize: 14),
              )
              : OutlinedButton.styleFrom(
                foregroundColor: color,
                side: BorderSide(color: color),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                textStyle: const TextStyle(fontSize: 14),
              ),
    );
  }

  Widget _buildFileProcessingView(
    BuildContext context,
    ReadingProvider readingProvider,
  ) {
    bool canAddMoreFiles =
        !readingProvider.isLoadingFile && !readingProvider.isSubmittingSession;
    bool canSave =
        readingProvider.totalWordCount > 0 &&
        !readingProvider.isSubmittingSession &&
        !readingProvider.isLoadingFile;

    return Column(
      // SingleChildScrollView yerine Column, çünkü parent'ı zaten SingleChildScrollView
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "Okuma Süreniz: ${readingProvider.displayTime}",
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 25),
        const Text(
          "Okuduğunuz metnin fotoğrafını yükleyin:",
          style: TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 15),

        // "Fotoğraf Ekle" veya "Yeni Fotoğraf Ekle" Butonu
        ElevatedButton.icon(
          icon: const Icon(Icons.add_a_photo_outlined),
          label: Text(
            readingProvider.totalWordCount > 0
                ? 'Yeni Fotoğraf Ekle'
                : 'Fotoğraf Ekle',
          ),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            // backgroundColor: Colors.blueGrey.shade700, // Farklı bir renk
          ),
          onPressed:
              canAddMoreFiles
                  ? () => _showImageSourceActionSheet(context)
                  : null,
        ),

        if (readingProvider.isLoadingFile)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 15.0),
            child: Center(child: CircularProgressIndicator()),
          ),

        if (readingProvider.operationError != null &&
            !readingProvider.isLoadingFile)
          Padding(
            padding: const EdgeInsets.only(top: 15.0),
            child: Text(
              readingProvider.operationError!,
              style: const TextStyle(color: Colors.red, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ),

        // Kelime sayısı sadece dosya yüklendikten sonra ve hata yoksa gösterilir.
        if (readingProvider.totalWordCount > 0 &&
            !readingProvider.isLoadingFile &&
            readingProvider.operationError == null)
          Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Text(
              "Toplam Eklenen Kelime Sayısı: ${readingProvider.totalWordCount}",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
              textAlign: TextAlign.center,
            ),
          )
        else if (readingProvider.totalWordCount == 0 &&
            !readingProvider.isLoadingFile &&
            readingProvider.operationError == null)
          const Padding(
            padding: EdgeInsets.only(top: 20.0),
            child: Text(
              "Henüz kelime eklenmedi.",
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ),

        const SizedBox(height: 35),
        ElevatedButton(
          onPressed:
              canSave
                  ? () async {
                    bool success = await readingProvider.saveReadingSession();
                    if (mounted &&
                        !success &&
                        readingProvider.operationError != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "Kaydetme hatası: ${readingProvider.operationError}",
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                  : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary, // Ana renk
            padding: const EdgeInsets.symmetric(vertical: 15),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          child:
              readingProvider.isSubmittingSession
                  ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  )
                  : const Text('Okuma Sonuçlarını Gör'),
        ),
        const SizedBox(height: 20),
        TextButton(
          onPressed:
              readingProvider.isSubmittingSession
                  ? null
                  : () => readingProvider.resetTimer(),
          child: const Text(
            "Okuma Seansını İptal Et",
            style: TextStyle(color: Colors.redAccent, fontSize: 15),
          ),
        ),
      ],
    );
  }

  Widget _buildSessionResultView(
    BuildContext context,
    ReadingProvider readingProvider,
  ) {
    final result = readingProvider.sessionResult!;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.check_circle_outline, color: Colors.green, size: 80),
        const SizedBox(height: 20),
        Text(
          "Harika İş Çıkardın!",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
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
                _buildResultRow(
                  "Okunan Kelime Sayısı:",
                  "${result.wordCount} kelime",
                ),
                _buildResultRow("Toplam Okuma Süresi:", result.duration),
                const SizedBox(height: 10),
                Divider(),
                const SizedBox(height: 10),
                Text(
                  "Okuma Hızınız",
                  style: TextStyle(
                    fontSize: 18,
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  "${result.speed} K/Dk",
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: () => readingProvider.resetTimer(),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          ),
          child: const Text(
            'Yeni Okuma Seansı Başlat',
            style: TextStyle(fontSize: 16),
          ),
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: () {
            readingProvider.resetTimer(); // Provider'ı sıfırla
            Navigator.pop(context);
          },
          child: const Text("Ana Sayfaya Dön", style: TextStyle(fontSize: 15)),
        ),
      ],
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
