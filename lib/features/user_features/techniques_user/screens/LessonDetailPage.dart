// lib/features/user_features/techniques_user/screens/LessonDetailPage.dart
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../models/lesson_detail_args.dart';
import 'package:provider/provider.dart';
import '../../../../state_management/auth_provider.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../core/enums/user_role.dart';

class LessonDetailPage extends StatefulWidget {
  final LessonDetailArgs args;

  const LessonDetailPage({Key? key, required this.args}) : super(key: key);

  @override
  State<LessonDetailPage> createState() => _LessonDetailPageState();
}

class _LessonDetailPageState extends State<LessonDetailPage> {
  // --- Sayfa İçi Kullanılacak Renk Sabitleri ---
  // Bu renkler, AppBar teması dışındaki UI elemanları için.
  // Eğer bu renkler de temadan yönetilecekse, Theme.of(context) ile erişilebilir.
  static const Color _pageLevelTextDark = Color(
    0xFF1F2937,
  ); // Sayfa içi koyu metinler için
  static const Color _pageLevelTextGrey = Color(
    0xFF6B7280,
  ); // Sayfa içi gri metinler için
  static const Color _iconButtonBackground =
      Colors.white; // Actions butonlarının arka planı
  static const Color _favoriteIconColor = Color(
    0xFFEF4444,
  ); // Beğenildi ikonu rengi
  static const Color _videoPlaceholderColor = Color(0xFF374151);
  static const Color _chewieProgressColor = Color(
    0xFFFF8128,
  ); // Tema primary rengiyle aynı olabilir

  // --- State Değişkenleri ---
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.args.initialFavoriteState;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (!authProvider.isAuthenticated || !authProvider.isUser()) {
        print("LessonDetailPage initState: Yetkisiz. Login'e yönlendiriliyor.");
        if (mounted) {
          // mounted kontrolü eklendi
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.login,
            (route) => false,
          );
        }
      } else {
        print(
          "LessonDetailPage initState: Yetkili. Video URL: ${widget.args.videoUrl}",
        );
        if (widget.args.videoUrl.isNotEmpty &&
            Uri.tryParse(widget.args.videoUrl)?.isAbsolute == true) {
          _initializeVideoPlayer();
        } else {
          print(
            "LessonDetailPage: Geçersiz veya boş video URL'i, oynatıcı başlatılmayacak.",
          );
        }
      }
    });
  }

  void _initializeVideoPlayer() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(widget.args.videoUrl),
      )
      ..initialize()
          .then((_) {
            if (mounted) {
              _createChewieController();
              setState(() {});
            }
          })
          .catchError((error) {
            print("Video yüklenirken hata oluştu ($runtimeType): $error");
            if (mounted) setState(() {});
          });
  }

  void _createChewieController() {
    if (_videoPlayerController == null ||
        !_videoPlayerController!.value.isInitialized)
      return;
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController!,
      autoPlay: false,
      looping: false,
      placeholder: Container(
        color: _videoPlaceholderColor,
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      ),
      errorBuilder:
          (context, errorMessage) => Center(
            child: Text(
              "Video yüklenemedi: $errorMessage",
              style: const TextStyle(color: Colors.white),
            ),
          ),
      materialProgressColors: ChewieProgressColors(
        playedColor: _chewieProgressColor,
        handleColor: _chewieProgressColor,
        bufferedColor: Colors.grey.shade600,
        backgroundColor: Colors.grey.shade800,
      ),
    );
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });
    print('Ders ID: ${widget.args.lessonId}, Yeni Beğeni Durumu: $_isFavorite');
    // TODO: Backend'e kaydet
  }

  void _shareContent() {
    print("Paylaş butonuna tıklandı! Ders ID: ${widget.args.lessonId}");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Paylaşma özelliği henüz eklenmedi.')),
    );
    // TODO: share_plus ile paylaşım ekle
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated || !authProvider.isUser()) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
          ),
        ),
      );
    }

    // AppBar için renkler ve stiller main.dart'taki appBarTheme'den gelecek.
    final ThemeData appTheme = Theme.of(context); // Genel temayı al

    return Scaffold(
      backgroundColor: Colors.white, // Sayfa arka planı
      appBar: AppBar(
        // backgroundColor, foregroundColor, elevation özellikleri temadan gelecek.
        // titleTextStyle ve iconTheme de temadan gelecek.
        leading: IconButton(
          icon: const Icon(Icons.arrow_back), // İkon rengi temadan
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.of(context).pop();
            } else {
              Navigator.pushReplacementNamed(context, AppRoutes.techniquesUser);
            }
          },
        ),
        title: Text(
          widget.args.title,
          // Temadan gelen başlık stilini alıp üzerine yazabiliriz veya direkt kullanabiliriz.
          // Eğer temadaki AppBar başlık stili (main.dart'ta tanımlı) zaten bold ise,
          // burada tekrar fontWeight belirtmeye gerek yok.
          // style: appTheme.appBarTheme.titleTextStyle?.copyWith(fontWeight: FontWeight.bold),
          // Ya da, temadaki stil tamamen uygunsa direkt bırakın:
          // style: appTheme.appBarTheme.titleTextStyle, (Bu zaten varsayılan davranış)
          // Şimdilik, temadan gelenin üzerine fontWeight.bold ekleyelim (eğer temada yoksa diye):
          style: (appTheme.appBarTheme.titleTextStyle ?? const TextStyle()).copyWith(
            fontWeight: FontWeight.bold,
            // fontSize: 20, // Temadan gelen fontSize'ı kullanır, gerekirse override edin
            // color: appTheme.appBarTheme.foregroundColor, // Temadan gelen rengi kullanır
          ),
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: false, // Bu sayfaya özel
        titleSpacing: 0, // Bu sayfaya özel
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
            decoration: BoxDecoration(
              color: _iconButtonBackground,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(
                _isFavorite ? Icons.favorite : Icons.favorite_border,
                color: _isFavorite ? _favoriteIconColor : _pageLevelTextGrey,
              ),
              onPressed: _toggleFavorite,
              tooltip: 'Beğen',
            ),
          ),
          Container(
            margin: const EdgeInsets.only(
              top: 8,
              bottom: 8,
              right: 16,
              left: 6,
            ),
            decoration: BoxDecoration(
              color: _iconButtonBackground,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(
                Icons.ios_share_outlined,
                color: _pageLevelTextGrey,
              ),
              onPressed: _shareContent,
              tooltip: 'Paylaş',
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Video Oynatıcı
            if (_videoPlayerController != null &&
                _videoPlayerController!.value.isInitialized &&
                _chewieController != null)
              AspectRatio(
                aspectRatio: _videoPlayerController!.value.aspectRatio,
                child: Chewie(controller: _chewieController!),
              )
            else if (_videoPlayerController != null &&
                _videoPlayerController!.value.hasError)
              Container(
                height: 200,
                color: _videoPlaceholderColor,
                child: const Center(
                  child: Text(
                    'Video yüklenirken bir hata oluştu.',
                    style: TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else if (widget.args.videoUrl.isNotEmpty &&
                Uri.tryParse(widget.args.videoUrl)?.isAbsolute == true)
              Container(
                height: 200,
                color: _videoPlaceholderColor,
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              )
            else
              Container(
                height: 200,
                color: Colors.grey.shade300,
                child: const Center(
                  child: Icon(
                    Icons.videocam_off_outlined,
                    size: 50,
                    color: Colors.grey,
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.args.title,
                    style: const TextStyle(
                      color: _pageLevelTextDark,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildStatsRow(
                    likes: widget.args.likeCount,
                    views: widget.args.viewCount,
                    date: widget.args.publishDate,
                  ),
                  const Divider(
                    height: 32,
                    thickness: 1,
                    color: Colors.grey,
                  ), // Divider rengi açık gri olabilir
                  if (widget.args.description != null &&
                      widget.args.description!.isNotEmpty)
                    _buildContentText(widget.args.description!)
                  else
                    _buildContentText(
                      "Bu ders için henüz bir açıklama eklenmemiş.",
                    ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow({String? likes, String? views, String? date}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (likes != null) _buildStatItem(likes, "Beğeni"),
        if (views != null) _buildStatItem(views, "Görüntülenme"),
        if (date != null) _buildStatItem(date, "Yayınlandı"),
      ],
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: _pageLevelTextDark,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: _pageLevelTextGrey, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildContentText(String text) {
    return Text(
      text,
      style: TextStyle(
        color: _pageLevelTextDark.withOpacity(0.85),
        fontSize: 16,
        height: 1.5,
      ),
    );
  }
}
