// lib/features/home/screens/PublicHomeScreen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../state_management/auth_provider.dart';
import '../../mentor_features/tips_mentor/state_management/tip_provider.dart';
import '../../mentor_features/tips_mentor/models/tip_response_dto.dart';
// ApiTipAvatar enum'ını import etmeye gerek yok, index'i kullanıyoruz.

class PublicHomeScreen extends StatefulWidget {
  const PublicHomeScreen({Key? key}) : super(key: key);

  static const Gradient greenGradient = LinearGradient(
    colors: [Color(0xFF34D399), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const Gradient blueGradient = LinearGradient(
    colors: [Color(0xFF60A5FA), Color(0xFF2563EB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const Gradient purpleGradient = LinearGradient(
    colors: [Color(0xFFA78BFA), Color(0xFF7C3AED)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const Gradient orangeGradient = LinearGradient(
    colors: [Color(0xFFFBBF24), Color(0xFFD97706)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const Gradient blackGradient = LinearGradient(
    colors: [Color(0xFF4A5568), Color(0xFF1A202C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const Color textDark = Color(0xFF1F2937);
  static const Color textLight = Colors.white;
  static const Color bottomNavBackground = Color(0xFFF0F0F0);
  static const Color bottomNavIconColor = Color(0xFF303030);
  static const Color fabBackground = Color.fromARGB(255, 34, 34, 34);
  static const Color fabIconColor = Color.fromRGBO(255, 130, 40, 1);

  // Bu liste ApiTipAvatar enum'ının sırasıyla (0:Cow, 1:Tiger, 2:Dog, 3:Bird, 4:Rabbit) eşleşmeli
  static const List<String> tipAnimalIconPaths = [
    'assets/images/cow.png',
    'assets/images/tiger.png',
    'assets/images/dog_tip.png', // Varsayılan olarak bu kullanılabilir
    'assets/images/bird.png',
    'assets/images/bunny.png', // 'bunny.png' veya 'rabbit.png' (TipsPage'dekiyle aynı olmalı)
  ];

  static String getTipAvatarPath(int apiAvatarIndex) {
    if (apiAvatarIndex >= 0 && apiAvatarIndex < tipAnimalIconPaths.length) {
      return tipAnimalIconPaths[apiAvatarIndex];
    }
    // Eğer index geçersizse veya liste dışındaysa, varsayılan bir ikon döndür
    print(
      "PublicHomeScreen Uyarı: Geçersiz avatar index'i ($apiAvatarIndex). Varsayılan kullanılıyor.",
    );
    return tipAnimalIconPaths.isNotEmpty
        ? tipAnimalIconPaths[2]
        : 'assets/images/dog_tip.png'; // Güvenli varsayılan
  }

  @override
  State<PublicHomeScreen> createState() => _PublicHomeScreenState();
}

class _PublicHomeScreenState extends State<PublicHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        if (!authProvider.isAuthenticated || !authProvider.isUser()) {
          if (mounted) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.login,
              (route) => false,
            );
          }
        } else {
          // Kullanıcı yetkiliyse rastgele ipucunu çek
          // Sayfa her açıldığında yeni bir ipucu çekmek için burada çağırılabilir.
          Provider.of<TipProvider>(
            context,
            listen: false,
          ).fetchRandomTipForPublicHome();
        }
      }
    });
  }

  void _onItemTapped(int index, String tappedItemLabel) {
    String? routeNameAssigned;
    switch (index) {
      case 0:
        routeNameAssigned = AppRoutes.userDashboard;
        break;
      case 1:
        routeNameAssigned = AppRoutes.library;
        break;
      case 2:
        routeNameAssigned = AppRoutes.supportUser;
        break;
      case 3:
        routeNameAssigned = AppRoutes.account;
        break;
    }
    if (routeNameAssigned != null) {
      if (ModalRoute.of(context)?.settings.name != routeNameAssigned) {
        // Zaten o sayfada değilse
        Navigator.pushNamed(context, routeNameAssigned);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (!authProvider.isAuthenticated || !authProvider.isUser()) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text("Yönlendiriliyor..."),
            ],
          ),
        ),
      );
    }

    const String placeholderProfileImage = 'assets/images/profile.png';
    const double desiredAppBarContentHeight = 44;
    const double appBarVerticalPadding = 20.0;
    const double totalAppBarHeight =
        desiredAppBarContentHeight + (appBarVerticalPadding * 2);

    ImageProvider profileImage;
    final photoUrl = authProvider.profilePhotoUrl;
    if (photoUrl != null &&
        photoUrl.trim().isNotEmpty &&
        (photoUrl.startsWith('http://') || photoUrl.startsWith('https://'))) {
      profileImage = NetworkImage(photoUrl);
    } else {
      profileImage = const AssetImage(placeholderProfileImage);
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: totalAppBarHeight,
        title: Container(
          padding: const EdgeInsets.symmetric(
            vertical: appBarVerticalPadding,
            horizontal: 0,
          ),
          alignment: Alignment.centerLeft,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.grey.shade300,
                backgroundImage: profileImage,
                onBackgroundImageError: (exception, stackTrace) {
                  print(
                    "AppBar CircleAvatar HATA: URL: $photoUrl, Hata: $exception",
                  );
                },
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hoşgeldin,',
                      style: TextStyle(
                        fontSize: 18,
                        color:
                            Theme.of(context).appBarTheme.titleTextStyle?.color
                                ?.withOpacity(0.8) ??
                            PublicHomeScreen.textDark.withOpacity(0.8),
                      ),
                    ),
                    Text(
                      authProvider.displayName ?? "Kullanıcı",
                      style:
                          Theme.of(context).appBarTheme.titleTextStyle
                              ?.copyWith(fontSize: 20) ??
                          const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: PublicHomeScreen.textDark,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        bottom: true,
        child: RefreshIndicator(
          // Rastgele ipucunu yenilemek için
          onRefresh:
              () =>
                  Provider.of<TipProvider>(
                    context,
                    listen: false,
                  ).fetchRandomTipForPublicHome(),
          color: PublicHomeScreen.orangeGradient.colors.first,
          child: SingleChildScrollView(
            physics:
                const AlwaysScrollableScrollPhysics(), // RefreshIndicator için
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Consumer<TipProvider>(
                    builder: (context, tipProvider, child) {
                      if (tipProvider.isLoading &&
                          tipProvider.randomTipForPublicHome == null) {
                        return const SizedBox(
                          height: 124,
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      // Hata durumu ayrıca ele alınabilir (tipProvider.errorMessage)
                      return _buildDidYouKnowBanner(
                        tipProvider.randomTipForPublicHome,
                      );
                    },
                  ),
                  const SizedBox(height: 30),
                  _buildQuickStartTitle(),
                  const SizedBox(height: 20),
                  _buildQuickStartGrid(context),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  Widget _buildDidYouKnowBanner(TipResponseDto? tip) {
    const double dogImageHeight = 120.0;
    String title = tip?.title ?? 'Biliyor muydun?';
    String content = tip?.content ?? 'Yeni bir ipucu için sayfayı yenileyin!';
    String imagePath =
        (tip != null)
            ? PublicHomeScreen.getTipAvatarPath(tip.avatar)
            : PublicHomeScreen.tipAnimalIconPaths[2]; // Varsayılan dog_tip

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
      decoration: BoxDecoration(
        gradient: PublicHomeScreen.blackGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: PublicHomeScreen.blackGradient.colors.last.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(imagePath, height: dogImageHeight, fit: BoxFit.contain),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: PublicHomeScreen.textLight,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Padding(
                  padding: const EdgeInsets.only(right: 5.0),
                  child: Text(
                    content,
                    style: const TextStyle(
                      color: Color.fromARGB(255, 241, 241, 241),
                      fontSize: 13,
                      height: 1.3,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStartTitle() {
    return const Text(
      'Hızlı Başlangıç',
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: PublicHomeScreen.textDark,
      ),
    );
  }

  Widget _buildQuickStartGrid(BuildContext context) {
    Widget buildGridItem({
      required String title,
      required Gradient backgroundGradient,
      required String imagePath,
      required double imageHeight,
      required VoidCallback onTap,
    }) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          clipBehavior: Clip.none,
          decoration: BoxDecoration(
            gradient: backgroundGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: backgroundGradient.colors.last.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  left: 18.0,
                  top: 18.0,
                  right: 18.0,
                ),
                child: Text(
                  title,
                  style: const TextStyle(
                    color: PublicHomeScreen.textLight,
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                ),
              ),
              Positioned(
                right: -10,
                bottom: -10,
                child: Image.asset(imagePath, height: imageHeight),
              ),
            ],
          ),
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      childAspectRatio: 1.05,
      children: [
        buildGridItem(
          title: 'Odağını\nGeliştir',
          backgroundGradient: PublicHomeScreen.greenGradient,
          imagePath: 'assets/images/target.png',
          imageHeight: 110,
          onTap:
              () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Bu özellik yakında!")),
              ),
        ),
        buildGridItem(
          title: 'Kelimeleri\nKavra',
          backgroundGradient: PublicHomeScreen.blueGradient,
          imagePath: 'assets/images/notepad.png',
          imageHeight: 115,
          onTap:
              () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Bu özellik yakında!")),
              ),
        ),
        buildGridItem(
          title: 'Okumaya\nBaşla',
          backgroundGradient: PublicHomeScreen.purpleGradient,
          imagePath: 'assets/images/book.png',
          imageHeight: 110,
          onTap: () => Navigator.pushNamed(context, AppRoutes.startReadPage),
        ),
        buildGridItem(
          title: 'Teknikleri\nÖğren',
          backgroundGradient: PublicHomeScreen.orangeGradient,
          imagePath: 'assets/images/tablet.png',
          imageHeight: 115,
          onTap: () => Navigator.pushNamed(context, AppRoutes.techniquesUser),
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    Widget buildNavItem(
      String imagePath,
      String label,
      int itemIndex,
      String targetRouteName,
    ) {
      final currentRoute = ModalRoute.of(context)?.settings.name;
      bool isSelected =
          (currentRoute == AppRoutes.publicHome && itemIndex == 0) ||
          (currentRoute == AppRoutes.userDashboard && itemIndex == 0) ||
          (targetRouteName == currentRoute);
      Color itemColor =
          isSelected
              ? PublicHomeScreen.fabIconColor
              : PublicHomeScreen.bottomNavIconColor;
      return Expanded(
        child: InkWell(
          onTap: () {
            if (currentRoute != targetRouteName)
              _onItemTapped(itemIndex, label);
          },
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(imagePath, height: 35, width: 35, color: itemColor),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: itemColor,
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
      color: PublicHomeScreen.bottomNavBackground,
      elevation: 10,
      child: SizedBox(
        height: 65,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            buildNavItem(
              'assets/images/progress_icon.png',
              'İlerlemem',
              0,
              AppRoutes.userDashboard,
            ),
            buildNavItem(
              'assets/images/library_icon.png',
              'Kitaplığım',
              1,
              AppRoutes.library,
            ),
            const SizedBox(width: 50),
            buildNavItem(
              'assets/images/support_icon.png',
              'Destek',
              2,
              AppRoutes.supportUser,
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

  Widget _buildFloatingActionButton(BuildContext context) {
    return Container(
      width: 65.0,
      height: 65.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FloatingActionButton(
        shape: const CircleBorder(),
        onPressed: () => Navigator.pushNamed(context, AppRoutes.techniquesUser),
        backgroundColor: PublicHomeScreen.fabBackground,
        elevation: 0,
        child: Image.asset(
          'assets/images/grid_icon.png',
          height: 30,
          width: 30,
          color: PublicHomeScreen.fabIconColor,
        ),
      ),
    );
  }
}
