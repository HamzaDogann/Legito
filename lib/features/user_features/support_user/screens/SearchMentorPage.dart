// lib/features/user_features/support_user/screens/SearchMentorPage.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../state_management/auth_provider.dart';
import '../models/chat_args.dart';

class SearchMentorPage extends StatefulWidget {
  const SearchMentorPage({Key? key}) : super(key: key);

  @override
  State<SearchMentorPage> createState() => _SearchMentorPageState();
}

class _SearchMentorPageState extends State<SearchMentorPage> {
  final List<Map<String, dynamic>> _allMentors = [
    {
      'id': 'gemini_ai_001',
      'name': 'Gemini',
      'image': 'assets/images/Gemini.png',
      'verified': true,
      'category': 'Yapay Zeka',
    },
    {
      'id': 'mentor_nk_002',
      'name': 'Nazmi Koçak',
      'image': 'assets/images/Profilimg.png',
      'verified': false,
      'category': 'Diğer',
    },
    {
      'id': 'mentor_ry_003',
      'name': 'Ramazan Yiğit',
      'image': 'assets/images/Profilimg4.png',
      'verified': true,
      'category': 'Diğer',
    },
    {
      'id': 'mentor_ryz_004',
      'name': 'Rabia Yazlı',
      'image': 'assets/images/Profilimg3.png',
      'verified': false,
      'category': 'Diğer',
    },
  ];

  List<Map<String, dynamic>> _filteredMentors = [];
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredMentors = _allMentors;
    _searchController.addListener(_onSearchChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (!authProvider.isAuthenticated) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.login,
          (route) => false,
        );
      }
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      if (_searchQuery.isEmpty) {
        _filteredMentors = _allMentors;
      } else {
        _filteredMentors =
            _allMentors
                .where(
                  (mentor) => mentor['name'].toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  ),
                )
                .toList();
      }
    });
  }

  void _navigateToChat(Map<String, dynamic> mentor) {
    Navigator.pushNamed(
      context,
      AppRoutes.chatWithMentor,
      arguments: ChatArgs(
        chatPartnerId: mentor['id'] ?? 'unknown_id',
        chatPartnerName: mentor['name'],
        chatPartnerImage: mentor['image'],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    if (!authProvider.isAuthenticated) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final aiMentor = _filteredMentors.firstWhere(
      (m) => m['category'] == 'Yapay Zeka',
      orElse: () => {},
    );
    final otherMentors =
        _filteredMentors.where((m) => m['category'] != 'Yapay Zeka').toList();

    // AppBar için temadan gelen renkleri ve stilleri kullanacağız.
    // final appBarTheme = Theme.of(context).appBarTheme;
    // final Color currentAppBarForegroundColor = appBarTheme.foregroundColor ?? Colors.black;

    return Scaffold(
      backgroundColor: Colors.white, // Sayfa arka planı
      appBar: AppBar(
        // backgroundColor: const Color(0xFFF4F4F4), // KALDIRILDI - Temadan gelecek
        // elevation: 0.5, // Temadan gelebilir veya özel ayarlanabilir
        // foregroundColor: Colors.black, // KALDIRILDI - Temadan gelecek (ikonlar için)
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
          ), // Renk temadan (appBarTheme.iconTheme veya foregroundColor)
          onPressed: () => Navigator.pop(context),
        ),
        // titleSpacing ve centerTitle temadan gelir veya burada override edilebilir.
        // Arama çubuğu title'da olduğu için titleSpacing'i 0 yapmak iyi olabilir.
        titleSpacing: 0,
        title: Container(
          // AppBar'ın title'ına TextField'ı yerleştirmek için Container
          height: 40,
          margin: const EdgeInsets.only(
            right: 16.0,
          ), // Sağ tarafta biraz boşluk bırakmak için (actions yoksa)
          decoration: BoxDecoration(
            color:
                Theme.of(context).scaffoldBackgroundColor, // Veya Colors.white
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300, width: 0.8),
          ),
          alignment: Alignment.centerLeft,
          child: TextField(
            controller: _searchController,
            textAlignVertical: TextAlignVertical.center, // Metni dikeyde ortala
            decoration: InputDecoration(
              hintText: 'Mentor Ara...',
              hintStyle: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 15,
              ), // Hint stili
              border: InputBorder.none,
              prefixIcon: Icon(
                Icons.search,
                color: Colors.grey.shade600,
                size: 20,
              ),
              contentPadding: const EdgeInsets.only(
                left: 0,
                right: 10,
                bottom: 0,
                top: 0,
              ), // contentPadding ayarlandı
              isDense: true, // TextField'ı daha kompakt yapar
              suffixIcon:
                  _searchQuery.isNotEmpty
                      ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: Colors.grey.shade600,
                          size: 20,
                        ),
                        onPressed: () {
                          _searchController.clear();
                        },
                        padding:
                            EdgeInsets.zero, // Butonun iç padding'ini kaldır
                        constraints:
                            const BoxConstraints(), // Butonun min boyutlarını kaldır
                      )
                      : null,
            ),
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF1F2937),
            ), // Yazı rengi
          ),
        ),
        actions: const [
          // Buraya actions eklenirse, title'daki Container'ın margin'i ayarlanmalı.
          // Veya AppBar'ın default action spacing'i kullanılabilir.
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (aiMentor.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Yapay Zeka Asistanınız',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: _buildMentorButton(context, aiMentor),
              ),
              const SizedBox(height: 24),
            ],
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Mentörler',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child:
                  _filteredMentors.isEmpty && _searchQuery.isNotEmpty
                      ? Center(
                        child: Text(
                          'Aramanızla eşleşen mentor bulunamadı.',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 16,
                          ),
                        ),
                      )
                      : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        itemCount: otherMentors.length,
                        itemBuilder: (context, index) {
                          return _buildMentorButton(
                            context,
                            otherMentors[index],
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMentorButton(BuildContext context, Map<String, dynamic> mentor) {
    if (mentor.isEmpty) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () => _navigateToChat(mentor),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.grey.shade200,
              backgroundImage: AssetImage(mentor['image']),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                mentor['name'],
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Colors.black87,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (mentor['verified'] == true)
              const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(
                  Icons.verified,
                  color: Colors.orangeAccent,
                  size: 20,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
