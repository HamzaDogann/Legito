import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../state_management/auth_provider.dart';
import '../models/mentor_home_args.dart';
import '../../interactions_mentor/models/user_account_args.dart';

// Header için özel renkler
const Color mentorHeaderDarkBackground = Color(0xFF1F1F1F);
const Color mentorHeaderTextLight = Colors.white;
const Color mentorHeaderSecondaryTextLight = Color(0xFFB0B0B0);
const Color mentorProfileBorderColor = Color.fromRGBO(255, 130, 40, 1);

// Sayfa gövdesi için (açık tema)
const Color pageBodyTextDark = Color(0xFF1F2937);
const Color pageBodySectionTitleColor = Color(0xFF374151);
const Color pageBodyCardBackgroundColor = Colors.white;
const Color pageBodyAccentColor = Color.fromRGBO(255, 130, 40, 1);

// BottomNavBar ve FAB için renkler
const Color bottomNavBackground = Color(0xFFF0F0F0);
const Color bottomNavIconColor = Color(
  0xFF303030,
); // Her zaman bu renk kullanılacak
const Color fabButtonBackground = Color.fromARGB(255, 24, 24, 24);
const Color fabIconActiveColor =
    pageBodyAccentColor; // FAB ikonu için hala kullanılabilir

class ListedUser {
  final String id;
  final String name;
  final String imageUrl;
  final String stat;
  final IconData statIcon;
  final Color statIconColor;

  ListedUser({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.stat,
    required this.statIcon,
    this.statIconColor = pageBodyAccentColor,
  });
}

class MentorHomePage extends StatefulWidget {
  final MentorHomeArgs args;
  const MentorHomePage({Key? key, required this.args}) : super(key: key);

  @override
  _MentorHomePageState createState() => _MentorHomePageState();
}

class _MentorHomePageState extends State<MentorHomePage> {
  // _currentBottomNavIndex artık aktif item rengi için kullanılmayacak,
  // ancak hangi item'a tıklandığını loglamak veya başka bir mantık için tutulabilir.
  // Veya tamamen kaldırılabilir eğer başka bir yerde kullanılmıyorsa.
  // Şimdilik loglama için bırakıyorum.
  // int _currentBottomNavIndex = 0; // Kaldırılabilir veya loglama için kalabilir

  final List<ListedUser> _activeUsers = [
    ListedUser(
      id: 'user1',
      name: 'Nazmi Koçak',
      imageUrl: 'assets/images/Profilimg.png',
      stat: '50 Saat',
      statIcon: Icons.timer_outlined,
    ),
    ListedUser(
      id: 'user2',
      name: 'Ramazan Yiğit',
      imageUrl: 'assets/images/Profilimg4.png',
      stat: '34 Saat',
      statIcon: Icons.timer_outlined,
    ),
    ListedUser(
      id: 'user3',
      name: 'Elif Yılmaz',
      imageUrl: 'assets/images/Profilimg3.png',
      stat: '16 Saat',
      statIcon: Icons.timer_outlined,
    ),
  ];
  final List<ListedUser> _fastestReaders = [
    ListedUser(
      id: 'user1',
      name: 'Nazmi Koçak',
      imageUrl: 'assets/images/Profilimg.png',
      stat: '120 WPM',
      statIcon: Icons.speed_outlined,
    ),
    ListedUser(
      id: 'user2',
      name: 'Ramazan Yiğit',
      imageUrl: 'assets/images/Profilimg4.png',
      stat: '70 WPM',
      statIcon: Icons.speed_outlined,
    ),
    ListedUser(
      id: 'user3',
      name: 'Elif Yılmaz',
      imageUrl: 'assets/images/Profilimg3.png',
      stat: '55 WPM',
      statIcon: Icons.speed_outlined,
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (!authProvider.isAuthenticated ||
          authProvider.userRole != UserRole.mentor) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.login,
          (route) => false,
        );
      } else {
        print(
          "Mentor ana sayfası açıldı. Mentor: ${widget.args.mentorName}, ID: ${widget.args.mentorId}",
        );
      }
    });
  }

  void _navigateToUserAccount(ListedUser user) {
    Navigator.pushNamed(
      context,
      AppRoutes.userAccountViewByMentor,
      arguments: UserAccountArgs(
        userId: user.id,
        userName: user.name,
        userImage: user.imageUrl,
        userEmail:
            '${user.name.toLowerCase().replaceAll(' ', '.')}@example.com',
        userRole: 'Kullanıcı',
      ),
    );
  }

  void _onMentorBottomNavItemTapped(int index, String tappedItemLabel) {
    print('--- MentorBottomNav onTap BAŞLANGIÇ ---');
    print('Alınan Index: $index, Label: "$tappedItemLabel"');
    // setState(() { _currentBottomNavIndex = index; }); // <<< BU SATIR KALDIRILDI/YORUMLANDI

    String? routeNameAssigned;
    switch (index) {
      case 0:
        routeNameAssigned = AppRoutes.mentorDashboard;
        break;
      case 1:
        routeNameAssigned = AppRoutes.tipsMentor;
        break;
      case 2:
        routeNameAssigned = AppRoutes.techniquesLessonMentor;
        break;
      case 3:
        routeNameAssigned = AppRoutes.account;
        break;
      default:
        routeNameAssigned = null;
    }
    print(
      'Switch sonrası routeNameAssigned (Mentor) değeri: $routeNameAssigned',
    );
    if (routeNameAssigned != null) {
      final currentRoute = ModalRoute.of(context)?.settings.name;
      if (currentRoute == routeNameAssigned) {
        // Eğer zaten o sayfadaysak tekrar push etme
        print("Zaten '$routeNameAssigned' rotasındasınız.");
        return;
      }
      Navigator.pushNamed(context, routeNameAssigned);
      print('Navigator.pushNamed("$routeNameAssigned") başarıyla çağrıldı.');
    } else {
      print('Bu item için henüz rota tanımlanmadı: $tappedItemLabel');
    }
    print('--- MentorBottomNav onTap BİTİŞ ---');
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    if (!authProvider.isAuthenticated ||
        authProvider.userRole != UserRole.mentor) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final String mentorDisplayName =
        authProvider.displayName ?? widget.args.mentorName;
    final String? mentorProfileImageUrl = authProvider.profilePhotoUrl;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildMentorHeader(context, mentorDisplayName, mentorProfileImageUrl),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildUserListSection(
                    "En Aktif Kullanıcılar",
                    _activeUsers,
                    context,
                  ),
                  const SizedBox(height: 20.0),
                  _buildUserListSection(
                    "En Hızlı Okuyanlar",
                    _fastestReaders,
                    context,
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildMentorBottomNavigationBar(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _buildMentorFloatingActionButton(context),
    );
  }

  Widget _buildMentorHeader(
    BuildContext context,
    String mentorName,
    String? profilePhotoUrl,
  ) {
    /* ... aynı ... */
    const String placeholderProfileImage = 'assets/images/Profilimg3.png';
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 15.0,
        left: 20.0,
        right: 15.0,
        bottom: 20.0,
      ),
      decoration: const BoxDecoration(color: mentorHeaderDarkBackground),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 38,
            backgroundColor: mentorProfileBorderColor,
            child: CircleAvatar(
              radius: 35,
              backgroundImage:
                  (profilePhotoUrl != null &&
                          profilePhotoUrl.startsWith('http'))
                      ? NetworkImage(profilePhotoUrl)
                      : AssetImage(profilePhotoUrl ?? placeholderProfileImage)
                          as ImageProvider,
              onBackgroundImageError:
                  (e, s) => print("Header profil resmi yüklenemedi: $e"),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Hoşgeldin,',
                  style: TextStyle(
                    fontSize: 18,
                    color: mentorHeaderSecondaryTextLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  mentorName,
                  style: const TextStyle(
                    fontSize: 26,
                    color: mentorHeaderTextLight,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Tooltip(
            message: "Çıkış Yap",
            child: IconButton(
              icon: const Icon(
                Icons.logout,
                color: mentorHeaderSecondaryTextLight,
                size: 26,
              ),
              onPressed: () async {
                await Provider.of<AuthProvider>(
                  context,
                  listen: false,
                ).logout();
                if (mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.login,
                    (route) => false,
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserListSection(
    String title,
    List<ListedUser> users,
    BuildContext context,
  ) {
    /* ... aynı ... */
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color:
                Theme.of(context).textTheme.titleLarge?.color ??
                pageBodyTextDark,
          ),
        ),
        const SizedBox(height: 8.0),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: users.length,
          itemBuilder:
              (context, index) => _buildUserCard(users[index], context),
        ),
      ],
    );
  }

  Widget _buildUserCard(ListedUser user, BuildContext context) {
    /* ... aynı ... */
    return Card(
      color: pageBodyCardBackgroundColor,
      elevation: 2.0,
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: InkWell(
        onTap: () => _navigateToUserAccount(user),
        borderRadius: BorderRadius.circular(10.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: AssetImage(user.imageUrl),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Text(
                  user.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color:
                        Theme.of(context).textTheme.bodyLarge?.color ??
                        pageBodyTextDark,
                  ),
                ),
              ),
              const SizedBox(width: 8.0),
              Icon(user.statIcon, color: user.statIconColor, size: 18),
              const SizedBox(width: 4.0),
              Text(
                user.stat,
                style: TextStyle(
                  fontSize: 14,
                  color:
                      Theme.of(context).textTheme.bodySmall?.color ??
                      Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMentorBottomNavigationBar(BuildContext context) {
    Widget buildNavItem(
      String imageAssetPath,
      String label,
      int itemIndex,
      String targetRouteNameIfAny,
    ) {
      // isSelected HER ZAMAN false olacak, böylece aktif renk kullanılmayacak.
      const bool isSelected = false;

      // Renkler her zaman pasif ikon rengi olacak.
      const Color iconColor = bottomNavIconColor;
      const Color labelColor = bottomNavIconColor;

      return Expanded(
        child: InkWell(
          onTap: () => _onMentorBottomNavItemTapped(itemIndex, label),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                imageAssetPath,
                height: 35,
                width: 35,
                color: iconColor,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: labelColor,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      );
    }

    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      color: bottomNavBackground,
      elevation: 10,
      child: SizedBox(
        height: 65,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            buildNavItem(
              'assets/images/progress_icon.png',
              'İstatistikler',
              0,
              AppRoutes.mentorDashboard,
            ),
            buildNavItem(
              'assets/images/tips_icon.png',
              'İpuçları',
              1,
              AppRoutes.tipsMentor,
            ),
            const SizedBox(width: 50),
            buildNavItem(
              'assets/images/tech_icon.png',
              'Teknik Ders',
              2,
              AppRoutes.techniquesLessonMentor,
            ),
            buildNavItem(
              'assets/images/account_icon.png',
              'Hesabım',
              3,
              AppRoutes.account,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMentorFloatingActionButton(BuildContext context) {
    return SizedBox(
      width: 65.0,
      height: 65.0,
      child: FloatingActionButton(
        shape: const CircleBorder(),
        onPressed: () {
          print('Mentor FAB tıklandı -> Modal gösterilecek');
          showDialog(
            context: context,
            builder: (BuildContext dialogContext) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                iconPadding: const EdgeInsets.only(top: 20.0),
                icon: Icon(
                  Icons.error_outline, // Exclamation mark in a circle
                  color: Colors.grey.shade500, // Slightly lighter grey for icon
                  size: 70.0,
                ),
                contentPadding: const EdgeInsets.fromLTRB(
                  24.0,
                  12.0,
                  24.0,
                  0,
                ), // Reduced top padding for content
                content: Text(
                  "Üzgünüz, bu özellik şu an kullanılabilir değil.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color:
                        Theme.of(context).textTheme.bodyLarge?.color ??
                        Colors.black87,
                  ),
                ),
                actionsPadding:
                    EdgeInsets.zero, // Remove default padding for actions
                actionsAlignment: MainAxisAlignment.center,
                actions: <Widget>[
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(
                      top: 20.0,
                    ), // Space between content and separator line
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: Colors.grey.shade300,
                          width: 1.0,
                        ),
                      ),
                    ),
                    child: TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15.0),
                        shape: const RoundedRectangleBorder(
                          // To ensure button part of dialog corners are rounded
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(12.0),
                            bottomRight: Radius.circular(12.0),
                          ),
                        ),
                      ),
                      child: const Text(
                        "Tamam",
                        style: TextStyle(
                          color: pageBodyAccentColor, // Orange color from theme
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(dialogContext).pop(); // Close the dialog
                      },
                    ),
                  ),
                ],
              );
            },
          );
        },
        backgroundColor: fabButtonBackground,
        elevation: 4.0,
        child: Image.asset(
          'assets/images/support_icon.png',
          height: 30,
          width: 30,
          color: fabIconActiveColor,
        ),
      ),
    );
  }
}
