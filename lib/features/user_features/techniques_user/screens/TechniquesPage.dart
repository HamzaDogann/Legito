// lib/features/user_features/techniques_user/screens/TechniquesPage.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../shared_widgets/content_card_widget.dart';
import '../../../../state_management/auth_provider.dart';
import '../models/lesson_detail_args.dart';
// CourseProvider ve UI modeli TechniqueItem için importlar
import '../../../course/state_management/course_provider.dart';
import '../../../course/models/course_item_dto.dart'; // API DTO'su, provider'dan UI modeline maplenecek

// TechniquesPage içinde kullanılan UI modeli
class TechniqueItem {
  final String id;
  final String coverImageUrl;
  final String title;
  final String? mentorName; // API'den bu bilgi gelmiyorsa null olacak
  final String? videoUrl; // LessonDetailPage için
  final String? description; // LessonDetailPage için
  final String publishDateFormatted; // API'deki createdDate'den formatlanacak
  final String viewCountFormatted; // API'deki viewCount'tan formatlanacak

  TechniqueItem({
    required this.id,
    required this.coverImageUrl,
    required this.title,
    this.mentorName,
    this.videoUrl,
    this.description,
    required this.publishDateFormatted,
    required this.viewCountFormatted,
  });
}

class TechniquesPage extends StatefulWidget {
  const TechniquesPage({Key? key}) : super(key: key);

  @override
  State<TechniquesPage> createState() => _TechniquesPageState();
}

class _TechniquesPageState extends State<TechniquesPage> {
  static const Color textDark = Color(0xFF1F2937);
  static const Color searchButtonColor = Color(0xFFFF8128);
  static const Color searchInputHintColor = Color(0xFF9CA3AF);
  static const Color sectionTitleColor = Color(0xFF374151);
  static const String _defaultCoverImageUrl =
      'assets/images/default_course_cover.png'; // Varsayılan kapak

  final TextEditingController _searchController = TextEditingController();
  // _searchTerm, _searchResults, _isSearching artık CourseProvider tarafından yönetilecek

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (!authProvider.isAuthenticated) {
        // Sadece auth kontrolü, rol kontrolü CourseProvider'da yapılabilir
        if (mounted)
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.login,
            (route) => false,
          );
      } else {
        // Verileri CourseProvider üzerinden çek
        final courseProvider = Provider.of<CourseProvider>(
          context,
          listen: false,
        );
        courseProvider.fetchCourseIndex(); // Popüler ve son eklenenleri yükle
        // Arama çubuğu için listener
        _searchController.addListener(() {
          final query = _searchController.text;
          if (query.isNotEmpty) {
            courseProvider.searchCourses(query);
          } else {
            courseProvider
                .clearSearchResults(); // Arama boşsa sonuçları temizle
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // CourseItemDto'yu UI'da kullanılacak TechniqueItem'a çeviren helper
  TechniqueItem _mapCourseItemDtoToTechniqueItem(CourseItemDto dto) {
    return TechniqueItem(
      id: dto.id,
      coverImageUrl: dto.thumbnail ?? _defaultCoverImageUrl,
      title: dto.title,
      mentorName: null, // API'den mentor adı gelmiyorsa null
      videoUrl: dto.video, // API'den video URL'si geliyorsa
      description: null, // Detay sayfasında API'den çekilecek
      publishDateFormatted: DateFormat(
        'dd MMM yyyy',
        'tr_TR',
      ).format(dto.createdDate),
      viewCountFormatted: "${dto.viewCount} G", // "G" Görüntülenme için
    );
  }

  void _navigateToLessonDetail(TechniqueItem technique) {
    // CourseProvider'dan tam detayı çekip LessonDetailArgs'ı doldurabiliriz
    // Veya mevcut bilgilerle LessonDetailArgs oluşturup, detay sayfasında API'den tam veriyi çekeriz.
    // Şimdilik mevcut bilgileri ve örnek videoUrl/description kullanıyoruz.
    // LessonDetailPage'in kendisi API'den tam detayı çekecek şekilde güncellenmeli.
    print('TechniquesPage: Derse git: ${technique.title}, ID: ${technique.id}');
    Navigator.pushNamed(
      context,
      AppRoutes.lessonDetailUser,
      arguments: LessonDetailArgs(
        lessonId: technique.id,
        title: technique.title,
        // Bu alanlar CourseDetailDto'dan gelmeli, şimdilik placeholder
        videoUrl:
            technique.videoUrl ??
            'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
        description:
            technique.description ??
            'Bu ${technique.title} tekniği için örnek bir açıklamadır.',
        initialFavoriteState: false, // Bu bilgi API'den gelmeli
        viewCount: technique.viewCountFormatted, // CourseItemDto'dan geliyor
        likeCount: "0+", // Bu bilgi API'den (CourseDetailDto) gelmeli
        publishDate:
            technique.publishDateFormatted, // CourseItemDto'dan geliyor
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.canPop(context))
              Navigator.of(context).pop();
            else
              Navigator.pushReplacementNamed(context, AppRoutes.publicHome);
          },
        ),
        title: const Text('Teknikleri Öğren'),
        centerTitle: false,
        titleSpacing: 0,
      ),
      body: Consumer<CourseProvider>(
        // CourseProvider'ı dinle
        builder: (context, courseProvider, child) {
          bool isSearching = _searchController.text.isNotEmpty;

          return Column(
            children: [
              _buildSearchBar(), // Arama çubuğu her zaman görünür
              if (courseProvider.isLoadingIndex &&
                  !isSearching &&
                  courseProvider.popularCourses.isEmpty &&
                  courseProvider.lastCreatedCourses.isEmpty)
                const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(color: Colors.orange),
                  ),
                )
              else if (courseProvider.isLoadingSearch &&
                  isSearching &&
                  courseProvider.searchResults.isEmpty)
                const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(color: Colors.orange),
                  ),
                )
              else if (isSearching)
                Expanded(
                  child: _buildSearchResults(
                    courseProvider.searchResults
                        .map(_mapCourseItemDtoToTechniqueItem)
                        .toList(),
                  ),
                )
              else
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => courseProvider.fetchCourseIndex(),
                    color: searchButtonColor,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 24.0,
                      ),
                      child: _buildDefaultContent(
                        courseProvider.popularCourses
                            .map(_mapCourseItemDtoToTechniqueItem)
                            .toList(),
                        courseProvider.lastCreatedCourses
                            .map(_mapCourseItemDtoToTechniqueItem)
                            .toList(),
                        courseProvider
                            .isLoadingIndex, // Refresh sırasında küçük indicator için
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.only(
        left: 20.0,
        right: 20.0,
        top: 20.0,
        bottom: 10.0,
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Tekniklerde Ara...',
          hintStyle: const TextStyle(color: searchInputHintColor, fontSize: 16),
          prefixIcon: Icon(Icons.search, color: Colors.grey.shade600, size: 22),
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: searchButtonColor, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 16,
          ),
          suffixIcon:
              _searchController.text.isNotEmpty
                  ? IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: Colors.grey.shade600,
                      size: 20,
                    ),
                    onPressed: () => _searchController.clear(),
                  )
                  : null,
        ),
        style: const TextStyle(color: textDark, fontSize: 16),
      ),
    );
  }

  Widget _buildDefaultContent(
    List<TechniqueItem> popular,
    List<TechniqueItem> recent,
    bool isLoadingMore,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isLoadingMore &&
            (popular.isNotEmpty || recent.isNotEmpty)) // Refresh sırasında
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.orange,
                ),
              ),
            ),
          ),
        _buildHorizontalListSection("Popüler Teknikler", popular),
        const SizedBox(height: 30),
        _buildHorizontalListSection("Son Eklenenler", recent),
      ],
    );
  }

  Widget _buildHorizontalListSection(String title, List<TechniqueItem> items) {
    const double horizontalListHeight = ContentCardWidget.cardHeight + 10;
    if (items.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: sectionTitleColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const SizedBox(
            height: horizontalListHeight,
            child: Center(
              child: Text(
                "Bu kategoride henüz teknik yok.",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: sectionTitleColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: horizontalListHeight,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Padding(
                padding: EdgeInsets.only(
                  right: index == items.length - 1 ? 0 : 16.0,
                ),
                child: ContentCardWidget(
                  coverImage: NetworkImage(
                    item.coverImageUrl,
                  ), // API'den gelen thumbnail
                  title: item.title,
                  onTap: () => _navigateToLessonDetail(item),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchResults(List<TechniqueItem> results) {
    final courseProvider = Provider.of<CourseProvider>(context, listen: false);
    if (courseProvider.isLoadingSearch && results.isEmpty) {
      // Arama sırasında ve henüz sonuç yoksa
      return const Center(
        child: CircularProgressIndicator(color: Colors.orange),
      );
    }
    if (results.isEmpty &&
        _searchController.text.isNotEmpty &&
        !courseProvider.isLoadingSearch) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40.0),
          child: Text(
            'Aramanızla eşleşen teknik bulunamadı.',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ),
      );
    }
    if (results.isEmpty && _searchController.text.isEmpty) {
      // Arama terimi silindiğinde boş ekran
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0, top: 8.0),
          child: Text(
            "Arama Sonuçları (${results.length})",
            style: const TextStyle(
              color: sectionTitleColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: results.length,
          itemBuilder: (context, index) {
            final technique = results[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: ContentCardWidget(
                  coverImage: NetworkImage(technique.coverImageUrl),
                  title: technique.title,
                  onTap: () => _navigateToLessonDetail(technique),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
