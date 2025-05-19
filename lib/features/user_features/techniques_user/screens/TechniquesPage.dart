// lib/features/user_features/techniques_user/screens/TechniquesPage.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../shared_widgets/content_card_widget.dart';
import '../../../../state_management/auth_provider.dart';
import '../models/lesson_detail_args.dart';

// Teknik kartlarını temsil edecek model
class TechniqueItem {
  final String id;
  final String coverImageUrl; // ContentCardWidget'a coverImage olarak geçilecek
  final String title;
  final String? mentor;

  TechniqueItem({
    required this.id,
    required this.coverImageUrl,
    required this.title,
    this.mentor,
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

  // Örnek resim URL'si
  static const String _defaultCoverImageUrl =
      'https://ichef.bbci.co.uk/news/1024/cpsprodpb/14235/production/_100058428_mediaitem100058424.jpg.webp';

  final List<TechniqueItem> _popularTechniques = [
    TechniqueItem(
      id: 'p1',
      coverImageUrl: _defaultCoverImageUrl,
      title: 'Hızlı Okuma Tekniği A ve Daha Fazla Uzun Başlık Denemesi',
      mentor: 'Dr. Hızlı Oku',
    ),
    TechniqueItem(
      id: 'p2',
      coverImageUrl: _defaultCoverImageUrl,
      title: 'Anlama Odaklı Yöntem',
      mentor: 'Prof. Anlar',
    ),
    TechniqueItem(
      id: 'p3',
      coverImageUrl: _defaultCoverImageUrl,
      title: 'Kelime Ezberleme Stratejisi',
      mentor: 'Uz. Dil Bilir',
    ),
    TechniqueItem(
      id: 'p4',
      coverImageUrl: _defaultCoverImageUrl,
      title: 'Not Alma Sanatı',
      mentor: 'Yazar Not Alır',
    ),
    TechniqueItem(
      id: 'p5',
      coverImageUrl: _defaultCoverImageUrl,
      title: 'Zihin Haritalama',
      mentor: 'Kaşif Zihin',
    ),
  ];

  final List<TechniqueItem> _recentTechniques = [
    TechniqueItem(
      id: 'r1',
      coverImageUrl: _defaultCoverImageUrl,
      title: 'Görselleştirme Tekniği',
      mentor: 'Hayal Perest',
    ),
    TechniqueItem(
      id: 'r2',
      coverImageUrl: _defaultCoverImageUrl,
      title: 'SQ3R Metodu',
      mentor: 'Metodik Yaklaşımcı',
    ),
    TechniqueItem(
      id: 'r3',
      coverImageUrl: _defaultCoverImageUrl,
      title: 'Pomodoro ile Çalışma',
      mentor: 'Zaman Yöneticisi',
    ),
    TechniqueItem(
      id: 'r4',
      coverImageUrl: _defaultCoverImageUrl,
      title: 'Eleştirel Okuma',
      mentor: 'Sorgulayan Akıl',
    ),
  ];

  final TextEditingController _searchController = TextEditingController();
  String _searchTerm = '';
  List<TechniqueItem> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (!authProvider.isAuthenticated || !authProvider.isUser()) {
        print("TechniquesPage initState: Yetkisiz. Login'e yönlendiriliyor.");
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.login,
          (route) => false,
        );
      } else {
        print("TechniquesPage initState: Yetkili kullanıcı.");
      }
    });
  }

  void _onSearchChanged() {
    setState(() {
      _searchTerm = _searchController.text;
      if (_searchTerm.isNotEmpty) {
        _isSearching = true;
        _performSearch();
      } else {
        _isSearching = false;
        _searchResults.clear();
      }
    });
  }

  void _performSearch() {
    if (_searchTerm.isEmpty) {
      setState(() => _searchResults.clear());
      return;
    }
    final allTechniques = [..._popularTechniques, ..._recentTechniques];
    setState(() {
      _searchResults =
          allTechniques
              .where(
                (tech) => tech.title.toLowerCase().contains(
                  _searchTerm.toLowerCase(),
                ),
              )
              .toList();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToLessonDetail(TechniqueItem technique) {
    print(
      'DEBUG: _navigateToLessonDetail çağrıldı. Teknik: ${technique.title}, ID: ${technique.id}',
    );
    Navigator.pushNamed(
      context,
      AppRoutes.lessonDetailUser,
      arguments: LessonDetailArgs(
        lessonId: technique.id,
        title: technique.title,
        videoUrl:
            'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4', // Örnek URL
        description:
            'Bu ${technique.title} tekniği için örnek bir açıklamadır. Detaylar yakında eklenecektir.',
        initialFavoriteState: false,
        viewCount: "100+",
        likeCount: "10+",
        publishDate: "Ocak 2024",
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated || !authProvider.isUser()) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.of(context).pop();
            } else {
              Navigator.pushReplacementNamed(context, AppRoutes.publicHome);
            }
          },
        ),
        title: const Text('Teknikleri Öğren'),
        centerTitle: false,
        titleSpacing: 0,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 24.0,
              ),
              child:
                  _isSearching ? _buildSearchResults() : _buildDefaultContent(),
            ),
          ),
        ],
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
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tekniklerde Ara...',
                hintStyle: const TextStyle(
                  color: searchInputHintColor,
                  fontSize: 16,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey.shade600,
                  size: 22,
                ),
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
                  borderSide: const BorderSide(
                    color: searchButtonColor,
                    width: 1.5,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 16,
                ),
                suffixIcon:
                    _searchTerm.isNotEmpty
                        ? IconButton(
                          icon: Icon(
                            Icons.clear,
                            color: Colors.grey.shade600,
                            size: 20,
                          ),
                          onPressed: () {
                            _searchController.clear();
                          },
                        )
                        : null,
              ),
              style: const TextStyle(color: textDark, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHorizontalListSection("Popüler Teknikler", _popularTechniques),
        const SizedBox(height: 30),
        _buildHorizontalListSection("Son Eklenenler", _recentTechniques),
      ],
    );
  }

  Widget _buildHorizontalListSection(String title, List<TechniqueItem> items) {
    const double horizontalListHeight =
        ContentCardWidget.cardHeight +
        10; // ContentCardWidget'ın sabit yüksekliğini kullan

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
                  coverImage: NetworkImage(item.coverImageUrl),
                  title: item.title,
                  subtitlePrefix:
                      (item.mentor != null && item.mentor!.isNotEmpty)
                          ? "Mentor: "
                          : null,
                  subtitleText:
                      (item.mentor != null && item.mentor!.isNotEmpty)
                          ? item.mentor
                          : null,
                  onTap: () => _navigateToLessonDetail(item),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty && _searchTerm.isNotEmpty) {
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
    if (_searchResults.isEmpty && _searchTerm.isEmpty) {
      // Arama yapılmıyorsa veya arama terimi boşsa hiçbir şey gösterme
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          // Arama sonuçları başlığı
          padding: const EdgeInsets.only(
            bottom: 16.0,
            top: 8.0,
          ), // Üstte biraz boşluk
          child: Text(
            "Arama Sonuçları (${_searchResults.length})",
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
          itemCount: _searchResults.length,
          itemBuilder: (context, index) {
            final technique = _searchResults[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Align(
                // Kartları sola yaslamak için (eğer Column daha genişse)
                alignment: Alignment.centerLeft,
                child: ContentCardWidget(
                  coverImage: NetworkImage(technique.coverImageUrl),
                  title: technique.title,
                  subtitlePrefix:
                      (technique.mentor != null && technique.mentor!.isNotEmpty)
                          ? "Mentor: "
                          : null,
                  subtitleText:
                      (technique.mentor != null && technique.mentor!.isNotEmpty)
                          ? technique.mentor
                          : null,
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
