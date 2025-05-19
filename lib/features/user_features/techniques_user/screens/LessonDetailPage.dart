// lib/features/user_features/techniques_user/screens/LessonDetailPage.dart
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../models/lesson_detail_args.dart';
import '../../../../state_management/auth_provider.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../course/state_management/course_provider.dart';
import '../../../course/models/course_detail_dto.dart';

class LessonDetailPage extends StatefulWidget {
  final LessonDetailArgs args;
  const LessonDetailPage({Key? key, required this.args}) : super(key: key);

  @override
  State<LessonDetailPage> createState() => _LessonDetailPageState();
}

class _LessonDetailPageState extends State<LessonDetailPage> {
  static const Color _pageLevelTextDark = Color(0xFF1F2937);
  static const Color _pageLevelTextGrey = Color(0xFF6B7280);
  static const Color _iconButtonBackground = Colors.white;
  static const Color _favoriteIconColor = Color(0xFFEF4444);
  static const Color _videoPlaceholderColor = Color(0xFF374151);
  static const Color _chewieProgressColor = Color(0xFFFF8128);

  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  late bool _isFavorite;
  bool _isVideoPlayerInitialized = false; // Oynatıcının durumu için flag
  bool _videoHasError = false; // Video yükleme hatası için flag
  String? _currentVideoUrl; // Hangi URL ile oynatıcının başlatıldığını takip et

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.args.initialFavoriteState;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (!authProvider.isAuthenticated) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.login,
          (route) => false,
        );
      } else {
        Provider.of<CourseProvider>(
          context,
          listen: false,
        ).fetchCourseDetail(widget.args.lessonId);
      }
    });
  }

  Future<void> _initializeVideoPlayer(String videoUrl) async {
    if (!mounted) return;
    print("LessonDetailPage: _initializeVideoPlayer çağrıldı. URL: $videoUrl");

    // Mevcut controller'ları temizle
    await _videoPlayerController?.dispose();
    _chewieController?.dispose();
    _videoPlayerController = null;
    _chewieController = null;
    _isVideoPlayerInitialized = false;
    _videoHasError = false;
    _currentVideoUrl = videoUrl; // Yeni URL'yi sakla
    setState(() {}); // UI'ı temizlenmiş/yükleniyor durumuna getir

    if (videoUrl.isEmpty || Uri.tryParse(videoUrl)?.isAbsolute != true) {
      print(
        "LessonDetailPage: Geçersiz veya boş video URL'i ($videoUrl), oynatıcı başlatılmayacak.",
      );
      if (mounted) setState(() => _videoHasError = true);
      return;
    }

    try {
      final newController = VideoPlayerController.networkUrl(
        Uri.parse(videoUrl),
      );
      await newController
          .initialize(); // initialize() Future döndürür, await ile beklenmeli
      if (!mounted) {
        // initialize sonrası widget hala mounted mı kontrol et
        await newController.dispose();
        return;
      }
      _videoPlayerController = newController;
      _createChewieController();
      _isVideoPlayerInitialized = true;
      _videoHasError = false;
    } catch (error) {
      print("LessonDetailPage: Video başlatılırken hata oluştu: $error");
      _videoHasError = true;
    } finally {
      if (mounted) setState(() {}); // Her durumda UI'ı güncelle
    }
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
              "Video oynatılamadı: $errorMessage",
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
    print("LessonDetailPage: Disposed video players.");
    super.dispose();
  }

  void _toggleFavorite(CourseDetailDto courseDetail) {
    /* ... (önceki gibi) ... */
  }
  void _shareContent(CourseDetailDto courseDetail) {
    /* ... (önceki gibi) ... */
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Consumer<CourseProvider>(
      builder: (context, courseProvider, child) {
        final CourseDetailDto? courseDetail =
            courseProvider.selectedCourseDetail;
        final bool isLoading = courseProvider.isLoadingDetail;
        final String? error = courseProvider.errorDetail;

        // Sadece courseDetail yüklendiğinde ve video URL'si değiştiğinde oynatıcıyı başlat/güncelle
        if (courseDetail != null &&
            courseDetail.video.isNotEmpty &&
            courseDetail.video != _currentVideoUrl) {
          // Bu setState'i build içinde tetikleyebilir, dikkatli ol.
          // Eğer _currentVideoUrl null ise (ilk yükleme) veya farklıysa ve mounted ise çağır.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && (courseDetail.video != _currentVideoUrl)) {
              _initializeVideoPlayer(courseDetail.video);
            }
          });
        }

        String appBarTitle = courseDetail?.title ?? widget.args.title;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed:
                  () =>
                      Navigator.canPop(context)
                          ? Navigator.of(context).pop()
                          : Navigator.pushReplacementNamed(
                            context,
                            AppRoutes.techniquesUser,
                          ),
            ),
            title: Text(appBarTitle, overflow: TextOverflow.ellipsis),
            centerTitle: false,
            titleSpacing: 0,
            actions:
                courseDetail != null
                    ? [
                      _buildAppBarAction(
                        icon:
                            _isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                        color:
                            _isFavorite
                                ? _favoriteIconColor
                                : _pageLevelTextGrey,
                        tooltip: 'Beğen',
                        onPressed: () => _toggleFavorite(courseDetail),
                      ),
                      _buildAppBarAction(
                        icon: Icons.ios_share_outlined,
                        color: _pageLevelTextGrey,
                        tooltip: 'Paylaş',
                        onPressed: () => _shareContent(courseDetail),
                        marginRight: 16.0,
                      ),
                    ]
                    : [],
          ),
          body: Builder(
            // Builder ekleyerek context'i yeniliyoruz
            builder: (context) {
              if (isLoading && courseDetail == null) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.orange),
                );
              }
              if (error != null && courseDetail == null) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      "Hata: $error",
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }
              if (courseDetail == null) {
                return const Center(child: Text("Ders detayı bulunamadı."));
              }

              // Artık courseDetail null değil
              Widget videoSection;
              if (_videoHasError) {
                videoSection = Container(
                  height: 200,
                  color: _videoPlaceholderColor,
                  child: const Center(
                    child: Text(
                      'Video yüklenirken bir hata oluştu.\nLütfen internet bağlantınızı kontrol edin veya daha sonra tekrar deneyin.',
                      style: TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              } else if (_isVideoPlayerInitialized &&
                  _chewieController != null) {
                videoSection = AspectRatio(
                  aspectRatio: _videoPlayerController!.value.aspectRatio,
                  child: Chewie(controller: _chewieController!),
                );
              } else if (courseDetail.video.isNotEmpty) {
                // URL var ama henüz yüklenmedi
                videoSection = Container(
                  height: 200,
                  color: _videoPlaceholderColor,
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                );
              } else {
                // Video URL yok
                videoSection = Container(
                  height: 200,
                  color: Colors.grey.shade300,
                  child: const Center(
                    child: Icon(
                      Icons.videocam_off_outlined,
                      size: 50,
                      color: Colors.grey,
                    ),
                  ),
                );
              }

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    videoSection,
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            courseDetail.title,
                            style: const TextStyle(
                              color: _pageLevelTextDark,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildStatsRow(
                            likes: "${courseDetail.likeCount}+",
                            views: "${courseDetail.viewCount} G",
                            date: DateFormat(
                              'dd MMM yyyy',
                              'tr_TR',
                            ).format(courseDetail.createdDate),
                          ),
                          const Divider(
                            height: 32,
                            thickness: 1,
                            color: Colors.grey,
                          ),
                          _buildContentText(
                            courseDetail.description ??
                                "Bu ders için henüz bir açıklama eklenmemiş.",
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildAppBarAction({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onPressed,
    double marginRight = 6.0,
  }) {
    return Container(
      margin: EdgeInsets.only(top: 8, bottom: 8, right: marginRight, left: 6),
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
        icon: Icon(icon, color: color),
        onPressed: onPressed,
        tooltip: tooltip,
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
