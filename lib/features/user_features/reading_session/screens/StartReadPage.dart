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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext bContext) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Galeriden Seç'),
                onTap: () {
                  Navigator.of(bContext).pop();
                  _pickImageFromSource(context, ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
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

    final Color primaryColor = Theme.of(context).colorScheme.primary;
    final Color onPrimaryColor = Theme.of(context).colorScheme.onPrimary;
    final Color secondaryTextColor = Colors.grey.shade700;
    final Color errorColor = Theme.of(context).colorScheme.error;
    final Color subtleTextColor = Colors.grey.shade600;
    final Color cardBackgroundColor = Theme.of(context).cardColor;
    final Color disabledButtonColor = Colors.grey.shade400;

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
            Widget content;
            switch (readingProvider.currentStatus) {
              case ReadingStatus.initial:
                content = _buildInitialView(
                  context,
                  readingProvider,
                  primaryColor,
                  onPrimaryColor,
                  secondaryTextColor,
                );
                break;
              case ReadingStatus.started:
              case ReadingStatus.paused:
                content = _buildTimerView(
                  context,
                  readingProvider,
                  primaryColor,
                  onPrimaryColor,
                  secondaryTextColor,
                );
                break;
              case ReadingStatus.finishedFileProcessing:
                content = _buildFileProcessingView(
                  context,
                  readingProvider,
                  primaryColor,
                  onPrimaryColor,
                  secondaryTextColor,
                  errorColor,
                  subtleTextColor,
                  disabledButtonColor,
                );
                break;
              case ReadingStatus.finishedSession:
                if (readingProvider.sessionResult != null) {
                  content = _buildSessionResultView(
                    context,
                    readingProvider,
                    primaryColor,
                    onPrimaryColor,
                    secondaryTextColor,
                    cardBackgroundColor,
                  );
                } else {
                  content = _buildInitialView(
                    context,
                    readingProvider,
                    primaryColor,
                    onPrimaryColor,
                    secondaryTextColor,
                  );
                }
                break;
            }
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 30.0,
                ),
                child: SingleChildScrollView(child: content),
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
    Color primaryColor,
    Color onPrimaryColor,
    Color secondaryTextColor,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(
          Icons.timer_outlined,
          size: 120,
          color: primaryColor.withOpacity(0.8),
        ),
        const SizedBox(height: 30),
        Text(
          "Okuma hızınızı ölçmek ve geliştirmek için yeni bir seans başlatın.",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            color: secondaryTextColor,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 50),
        ElevatedButton.icon(
          icon: const Icon(Icons.play_arrow_rounded, size: 32),
          label: const Text('Okumaya Başla'),
          style: ElevatedButton.styleFrom(
            textStyle: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 32),
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
    Color primaryColor,
    Color onPrimaryColor,
    Color secondaryTextColor,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          readingProvider.displayTime,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 80,
            fontWeight: FontWeight.w200,
            color: primaryColor,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 70), // Zamanlayıcı ile ilk buton arası boşluk
        // 1. Duraklat/Devam Et Butonu (Tam Genişlik)
        SizedBox(
          width: double.infinity,
          child: _buildTimerButton(
            icon:
                readingProvider.isTimerRunning
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
            label: readingProvider.isTimerRunning ? 'Duraklat' : 'Devam Et',
            onPressed:
                readingProvider.isTimerRunning
                    ? readingProvider.pauseTimer
                    : readingProvider.resumeTimer,
            color: primaryColor, // Ana tema rengi
            isFilled: true, // Dolgulu buton
            fontSize: 18, // Biraz daha büyük font
            padding: const EdgeInsets.symmetric(vertical: 16), // Dikey padding
          ),
        ),
        const SizedBox(height: 20), // Buton grupları arası boşluk
        // 2. Sıfırla ve Bitir Butonları (Yan Yana, Yarı Genişlik)
        Row(
          children: [
            Expanded(
              child: _buildTimerButton(
                icon: Icons.refresh_rounded,
                label: 'Sıfırla',
                onPressed: readingProvider.resetTimer,
                color: secondaryTextColor, // Gri ton
                isFilled: false, // Outlined stil
                fontSize: 16,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            const SizedBox(width: 16), // İki buton arası boşluk
            Expanded(
              child: _buildTimerButton(
                icon: Icons.stop_rounded,
                label: 'Bitir',
                onPressed: readingProvider.finishFileProcessingPhase,
                color: primaryColor, // Ana tema rengi (çerçeve için)
                isFilled: false, // Outlined stil
                isOutlinedPrimary: true, // Ana tema renginde outline
                fontSize: 16,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
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
    bool isOutlinedPrimary = false,
    double fontSize = 15,
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 12,
    ),
  }) {
    final ButtonStyle style =
        isFilled
            ? ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor:
                  Colors.white, // Dolgulu butonlarda metin genellikle beyaz
              padding: padding,
              textStyle: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            )
            : OutlinedButton.styleFrom(
              foregroundColor: isOutlinedPrimary ? color : color,
              side: BorderSide(color: color, width: 1.5),
              padding: padding,
              textStyle: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            );

    if (isFilled) {
      return ElevatedButton.icon(
        icon: Icon(icon, size: fontSize + 4),
        label: Text(label),
        onPressed: onPressed,
        style: style,
      );
    } else {
      return OutlinedButton.icon(
        icon: Icon(icon, size: fontSize + 4),
        label: Text(label),
        onPressed: onPressed,
        style: style,
      );
    }
  }

  Widget _buildFileProcessingView(
    BuildContext context,
    ReadingProvider readingProvider,
    Color primaryColor,
    Color onPrimaryColor,
    Color secondaryTextColor,
    Color errorColor,
    Color subtleTextColor,
    Color disabledButtonColor,
  ) {
    bool canAddMoreFiles =
        !readingProvider.isLoadingFile && !readingProvider.isSubmittingSession;
    bool canSave =
        readingProvider.totalWordCount > 0 &&
        !readingProvider.isSubmittingSession &&
        !readingProvider.isLoadingFile;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "Okuma Süreniz: ${readingProvider.displayTime}",
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 30),
        Text(
          "Okuduğunuz metnin fotoğrafını yükleyin:",
          style: TextStyle(fontSize: 17, color: secondaryTextColor),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          icon: const Icon(Icons.add_a_photo_outlined, size: 24),
          label: Text(
            readingProvider.totalWordCount > 0
                ? 'Yeni Fotoğraf Ekle'
                : 'Fotoğraf Ekle',
            style: const TextStyle(fontSize: 16),
          ),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            // backgroundColor: canAddMoreFiles ? primaryColor.withOpacity(0.1) : disabledButtonColor.withOpacity(0.5), // Outlined benzeri görünüm
            // foregroundColor: canAddMoreFiles ? primaryColor : Colors.white70,
            // side: canAddMoreFiles ? BorderSide(color: primaryColor) : null
          ),
          onPressed:
              canAddMoreFiles
                  ? () => _showImageSourceActionSheet(context)
                  : null,
        ),
        if (readingProvider.isLoadingFile)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20.0),
            child: Center(child: CircularProgressIndicator()),
          ),
        if (readingProvider.operationError != null &&
            !readingProvider.isLoadingFile)
          Padding(
            padding: const EdgeInsets.only(top: 15.0),
            child: Text(
              readingProvider.operationError!,
              style: TextStyle(color: errorColor, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ),
        if (readingProvider.totalWordCount > 0 &&
            !readingProvider.isLoadingFile &&
            readingProvider.operationError == null)
          Padding(
            padding: const EdgeInsets.only(top: 25.0),
            child: Text(
              "Toplam Eklenen Kelime: ${readingProvider.totalWordCount}",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade700,
              ),
              textAlign: TextAlign.center,
            ),
          )
        else if (readingProvider.totalWordCount == 0 &&
            !readingProvider.isLoadingFile &&
            readingProvider.operationError == null)
          Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Text(
              "Henüz kelime eklenmedi.",
              style: TextStyle(fontSize: 16, color: subtleTextColor),
              textAlign: TextAlign.center,
            ),
          ),
        const SizedBox(height: 40),
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
                          backgroundColor: errorColor,
                        ),
                      );
                    }
                  }
                  : null,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 18),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child:
              readingProvider.isSubmittingSession
                  ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: onPrimaryColor,
                      strokeWidth: 3,
                    ),
                  )
                  : const Text('Okuma Sonuçlarını Gör'),
        ),
        const SizedBox(height: 15),
        TextButton(
          onPressed:
              readingProvider.isSubmittingSession
                  ? null
                  : () => readingProvider.resetTimer(),
          child: Text(
            "Okuma Seansını İptal Et",
            style: TextStyle(color: errorColor.withOpacity(0.9), fontSize: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildSessionResultView(
    BuildContext context,
    ReadingProvider readingProvider,
    Color primaryColor,
    Color onPrimaryColor,
    Color secondaryTextColor,
    Color cardBgColor,
  ) {
    final result = readingProvider.sessionResult!;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(
          Icons.check_circle_outline,
          color: Colors.green.shade600,
          size: 80,
        ),
        const SizedBox(height: 20),
        const Text(
          "Harika İş Çıkardın!",
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 30),
        Card(
          elevation: 4,
          shadowColor: Colors.grey.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          color: cardBgColor, // Temadan gelen kart rengi (genellikle beyaz)
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 25.0,
            ),
            child: Column(
              children: [
                _buildResultRow(
                  "Okunan Kelime Sayısı:",
                  "${result.wordCount} kelime",
                ),
                _buildResultRow("Toplam Okuma Süresi:", result.duration),
                const SizedBox(height: 15),
                Divider(color: Colors.grey.shade300),
                const SizedBox(height: 15),
                Text(
                  "Okuma Hızınız",
                  style: TextStyle(
                    fontSize: 20,
                    color: primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  "${result.speed} K/Dk",
                  style: TextStyle(
                    fontSize: 52,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 35),
        ElevatedButton(
          onPressed: () => readingProvider.resetTimer(),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            textStyle: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('Yeni Okuma Seansı Başlat'),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () {
            readingProvider.resetTimer();
            Navigator.pop(context);
          },
          child: Text(
            "Ana Sayfaya Dön",
            style: TextStyle(fontSize: 16, color: secondaryTextColor),
          ),
        ),
      ],
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 17, color: Colors.grey.shade800),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    );
  }
}
