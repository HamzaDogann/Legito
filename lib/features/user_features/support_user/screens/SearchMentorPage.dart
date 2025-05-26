// lib/features/user_features/support_user/screens/SearchMentorPage.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../state_management/auth_provider.dart';
import '../../../../state_management/chat_provider.dart'; // Import ChatProvider for IDs
import '../models/chat_args.dart';

class SearchMentorPage extends StatefulWidget {
  const SearchMentorPage({Key? key}) : super(key: key);

  @override
  State<SearchMentorPage> createState() => _SearchMentorPageState();
}

class _SearchMentorPageState extends State<SearchMentorPage> {
  // Ensure IDs match those defined in ChatProvider
  final List<Map<String, dynamic>> _allMentors = [
    {
      'id': ChatProvider.geminiId,
      'name': 'Gemini',
      'image': 'assets/images/Gemini.png',
      'verified': true,
      'category': 'Yapay Zeka',
    },
    {
      'id': ChatProvider.mentorNkId,
      'name': 'Nazmi Koçak',
      'image': 'assets/images/Profilimg.png',
      'verified': false,
      'category': 'Diğer',
    },
    {
      'id': ChatProvider.mentorRyId,
      'name': 'Ramazan Yiğit',
      'image': 'assets/images/Profilimg4.png',
      'verified': true,
      'category': 'Diğer',
    },
    {
      'id': ChatProvider.mentorRyzId,
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
        chatPartnerId: mentor['id'],
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
      orElse: () => <String, dynamic>{}, // Return an empty map if not found
    );
    final otherMentors =
        _filteredMentors.where((m) => m['category'] != 'Yapay Zeka').toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Container(
          height: 40,
          margin: const EdgeInsets.only(right: 16.0),
          decoration: BoxDecoration(
            color: Colors.white, // Keep search bar white for contrast
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300, width: 0.8),
          ),
          alignment: Alignment.centerLeft,
          child: TextField(
            controller: _searchController,
            textAlignVertical: TextAlignVertical.center,
            decoration: InputDecoration(
              hintText: 'Mentor Ara...',
              hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 15),
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
              ),
              isDense: true,
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
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      )
                      : null,
            ),
            style: const TextStyle(fontSize: 15, color: Color(0xFF1F2937)),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (aiMentor.isNotEmpty &&
                (_searchQuery.isEmpty ||
                    aiMentor['name'].toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ))) ...[
              // Show AI if not filtered out
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
            if (otherMentors
                .isNotEmpty) // Only show "Mentörler" title if there are other mentors
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
