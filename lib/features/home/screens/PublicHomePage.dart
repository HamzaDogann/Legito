// lib/features/home/screens/PublicHomeScreen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/enums/user_role.dart'; // Bu import'a gerek kalmayabilir eğer direkt AuthProvider.isUser() kullanılıyorsa
import '../../../core/navigation/app_routes.dart';
import '../../../state_management/auth_provider.dart';

class PublicHomeScreen extends StatefulWidget {
  const PublicHomeScreen({Key? key}) : super(key: key);

  // Renk ve Gradient sabitleri
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

  @override
  State<PublicHomeScreen> createState() => _PublicHomeScreenState();
}

class _PublicHomeScreenState extends State<PublicHomeScreen> {
  @override
  void initState() {
    super.initState();
    // initState içinde context'e bağlı işlemler için addPostFrameCallback kullanmak güvenlidir.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // context'in build metodu tamamlandıktan sonra Provider'a erişim sağlıyoruz.
      if (mounted) {
        // Widget'ın hala ağaçta olduğundan emin ol
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        print(
          "PublicHomeScreen initState: Auth Durumu: ${authProvider.isAuthenticated}, Kullanıcı Rolü: ${authProvider.userRole}, Kullanıcı mı?: ${authProvider.isUser()}",
        );
        if (!authProvider.isAuthenticated || !authProvider.isUser()) {
          print(
            "PublicHomeScreen initState: Yetkisiz veya yanlış rol. Login'e yönlendiriliyor.",
          );
          // Yönlendirme yapmadan önce widget'ın hala mounted olup olmadığını tekrar kontrol etmek iyi bir pratiktir.
          if (mounted) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.login,
              (route) => false,
            );
          }
        } else {
          print(
            "PublicHomeScreen initState: Kullanıcı yetkili. Hoş geldiniz: ${authProvider.displayName ?? 'Kullanıcı'}. Profil Resmi URL: ${authProvider.profilePhotoUrl}",
          );
        }
      }
    });
  }

  void _onItemTapped(int index, String tappedItemLabel) {
    print('--- PublicHomeScreen _onItemTapped BAŞLANGIÇ ---');
    print('Alınan Index: $index');
    print('Alınan Label: "$tappedItemLabel"');

    String? routeNameAssigned;
    switch (index) {
      case 0: // İlerlemem
        routeNameAssigned = AppRoutes.userDashboard;
        break;
      case 1: // Kitaplığım
        routeNameAssigned = AppRoutes.library;
        break;
      case 2: // Destek
        routeNameAssigned = AppRoutes.supportUser;
        break;
      case 3: // Hesabım
        routeNameAssigned = AppRoutes.account;
        break;
      default:
        routeNameAssigned = null;
    }
    print('Switch sonrası routeNameAssigned değeri: $routeNameAssigned');
    if (routeNameAssigned != null) {
      print('Yönlendirme denenecek: $routeNameAssigned');
      // Navigator.pushNamed'i try-catch içine almak, rota bulunamazsa hatayı yakalamak için iyidir.
      try {
        Navigator.pushNamed(context, routeNameAssigned);
        print('Navigator.pushNamed("$routeNameAssigned") başarıyla çağrıldı.');
      } catch (e, s) {
        print(
          'Navigator.pushNamed çağrılırken HATA: $e. Rota tanımlı mı kontrol edin.',
        );
        print('Stack Trace: $s');
        // Kullanıcıya hata mesajı gösterilebilir
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Sayfa bulunamadı: $routeNameAssigned")),
        );
      }
    } else {
      print('Rota adı null, yönlendirme yapılmayacak.');
    }
    print('--- PublicHomeScreen _onItemTapped BİTİŞ ---');
  }

  @override
  Widget build(BuildContext context) {
    // Build metodunda Provider.of ile authProvider'a erişirken listen: true (varsayılan) olmalı
    // ki AuthProvider'daki değişikliklerde bu widget yeniden build edilsin.
    final authProvider = Provider.of<AuthProvider>(context);

    // initState'te yapılan kontrol build'de de olmalı, çünkü state değişebilir.
    if (!authProvider.isAuthenticated || !authProvider.isUser()) {
      print(
        "PublicHomeScreen build: Yetkisiz veya yanlış rol. Login'e yönlendirme beklemede veya yükleme ekranı.",
      );
      // initState'deki yönlendirme gerçekleşene kadar bir yükleme göstergesi göstermek daha iyi olabilir.
      // Ancak initState'teki yönlendirme çok hızlı olacağından, bu blok nadiren uzun süre görünür.
      // Eğer yönlendirme anlık değilse, bu return önemli.
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

    print(
      "PublicHomeScreen build: Kullanıcı yetkili. Sayfa oluşturuluyor. Profil URL: ${authProvider.profilePhotoUrl}",
    );

    const String placeholderProfileImage =
        'assets/images/profile.png'; // Bu dosyanın assets altında olduğundan emin olun
    const double desiredAppBarContentHeight = 44;
    const double appBarVerticalPadding = 20.0;
    const double totalAppBarHeight =
        desiredAppBarContentHeight + (appBarVerticalPadding * 2);

    // Profil resmi için ImageProvider'ı belirleyelim
    ImageProvider profileImage;
    final photoUrl = authProvider.profilePhotoUrl;

    if (photoUrl != null &&
        photoUrl.trim().isNotEmpty &&
        (photoUrl.startsWith('http://') || photoUrl.startsWith('https://'))) {
      print("PublicHomeScreen build: NetworkImage kullanılacak: $photoUrl");
      profileImage = NetworkImage(photoUrl);
    } else {
      print(
        "PublicHomeScreen build: AssetImage (placeholder) kullanılacak. Gelen URL: $photoUrl",
      );
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
                radius: 30, // AppBar için uygun bir boyut
                backgroundColor:
                    Colors
                        .grey
                        .shade300, // NetworkImage yüklenirken görünecek arka plan
                backgroundImage:
                    profileImage, // Önceden belirlenen ImageProvider
                onBackgroundImageError: (exception, stackTrace) {
                  // NetworkImage yüklenirken hata olursa burası çalışır.
                  // İsteğe bağlı olarak loglama yapabilir veya placeholder'ı burada set edebilirsiniz.
                  print(
                    "PublicHomeScreen AppBar CircleAvatar HATA: NetworkImage yüklenemedi. URL: $photoUrl, Hata: $exception",
                  );
                  // Bu durumda placeholder zaten `profileImage` içinde set edilmiş olmalı.
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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDidYouKnowBanner(),
                const SizedBox(height: 30),
                _buildQuickStartTitle(),
                const SizedBox(height: 20),
                _buildQuickStartGrid(context),
                const SizedBox(height: 80), // BottomNav ve FAB için boşluk
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  Widget _buildDidYouKnowBanner() {
    const String longText =
        'Lorem ipsum dolor sit amet consectetur adipisicing elit. Faucibus duis blandit in. ';
    const double dogImageHeight = 120.0;
    return Container(
      width: double.infinity,
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/dog.png',
              height: dogImageHeight,
            ), // Bu resmin assets'te olduğundan emin olun
            const SizedBox(width: 15),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Biliyor muydun?',
                    style: TextStyle(
                      color: PublicHomeScreen.textLight,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Padding(
                    padding: EdgeInsets.only(right: 5.0),
                    child: Text(
                      longText,
                      style: TextStyle(
                        color: Color.fromARGB(255, 241, 241, 241),
                        fontSize: 13,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
                child: Image.asset(
                  imagePath,
                  height: imageHeight,
                ), // Bu resimlerin assets'te olduğundan emin olun
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
      childAspectRatio: 1.05, // Kartların en-boy oranını ayarlar
      children: [
        buildGridItem(
          title: 'Odağını\nGeliştir',
          backgroundGradient: PublicHomeScreen.greenGradient,
          imagePath: 'assets/images/target.png', // Assets kontrolü
          imageHeight: 110,
          onTap: () {
            print('DEBUG: "Odağını Geliştir" tıklandı.');
            // Navigator.pushNamed(context, AppRoutes.focusTrainingPage); // Örnek bir rota
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Odağını Geliştir sayfası henüz tanımlanmadı."),
              ),
            );
          },
        ),
        buildGridItem(
          title: 'Kelimeleri\nKavra',
          backgroundGradient: PublicHomeScreen.blueGradient,
          imagePath: 'assets/images/notepad.png', // Assets kontrolü
          imageHeight: 115,
          onTap: () {
            print('DEBUG: "Kelimeleri Kavra" tıklandı.');
            // Navigator.pushNamed(context, AppRoutes.vocabularyPage); // Örnek bir rota
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Kelimeleri Kavra sayfası henüz tanımlanmadı."),
              ),
            );
          },
        ),
        buildGridItem(
          title: 'Okumaya\nBaşla',
          backgroundGradient: PublicHomeScreen.purpleGradient,
          imagePath: 'assets/images/book.png', // Assets kontrolü
          imageHeight: 110,
          onTap: () {
            print(
              'DEBUG: "Okumaya Başla" tıklandı -> Yönlendiriliyor: ${AppRoutes.library}',
            );
            Navigator.pushNamed(context, AppRoutes.library);
          },
        ),
        buildGridItem(
          title: 'Teknikleri\nÖğren',
          backgroundGradient: PublicHomeScreen.orangeGradient,
          imagePath: 'assets/images/tablet.png', // Assets kontrolü
          imageHeight: 115,
          onTap: () {
            print(
              'DEBUG: "Teknikleri Öğren" tıklandı -> Yönlendiriliyor: ${AppRoutes.techniquesUser}',
            );
            Navigator.pushNamed(context, AppRoutes.techniquesUser);
          },
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
      bool isSelected = false;

      // PublicHomeScreen'deyken "İlerlemem" (index 0) seçili olmalı
      if (currentRoute == AppRoutes.publicHome && itemIndex == 0) {
        isSelected = true;
      }
      // userDashboard'dayken "İlerlemem" (index 0) seçili olmalı
      else if (currentRoute == AppRoutes.userDashboard && itemIndex == 0) {
        isSelected = true;
      }
      // Diğer durumlarda, hedef rota mevcut rota ile eşleşiyorsa seçili
      else if (targetRouteName == currentRoute) {
        isSelected = true;
      }

      Color itemColor =
          isSelected
              ? PublicHomeScreen.fabIconColor
              : PublicHomeScreen.bottomNavIconColor;

      return Expanded(
        child: InkWell(
          onTap: () {
            print(
              '--- buildNavItem onTap İÇİNDE --- Label: "$label", Index: $itemIndex, Hedef Rota: $targetRouteName',
            );
            // Eğer zaten o sayfadaysak tekrar push etmeyelim (isteğe bağlı)
            if (currentRoute != targetRouteName) {
              _onItemTapped(itemIndex, label);
            } else {
              print(
                'Zaten "$label" ($targetRouteName) sayfasındasınız. Yönlendirme yapılmadı.',
              );
            }
          },
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                imagePath,
                height: 35,
                width: 35,
                color: itemColor,
              ), // Bu resimlerin assets'te olduğundan emin olun
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
      elevation: 10, // Gölge
      child: SizedBox(
        height: 65, // BottomAppBar yüksekliği
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
            const SizedBox(width: 50), // FAB için boşluk
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
            color: Colors.black.withOpacity(0.15), // Daha yumuşak bir gölge
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FloatingActionButton(
        shape: const CircleBorder(), // Tam daire olmasını sağlar
        onPressed: () {
          print(
            'DEBUG: FAB tıklandı -> Yönlendiriliyor: ${AppRoutes.techniquesUser}',
          );
          Navigator.pushNamed(context, AppRoutes.techniquesUser);
        },
        backgroundColor: PublicHomeScreen.fabBackground,
        elevation: 0, // Container'ın gölgesi kullanılacak
        child: Image.asset(
          'assets/images/grid_icon.png', // Bu resmin assets'te olduğundan emin olun
          height: 30,
          width: 30,
          color: PublicHomeScreen.fabIconColor,
        ),
      ),
    );
  }
}
