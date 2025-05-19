// lib/state_management/auth_provider.dart
import 'package:flutter/foundation.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/enums/user_role.dart';
import '../features/auth/services/auth_service.dart';
import '../features/auth/models/login_response_model.dart';
import '../features/user_features/models/user_info_model.dart';
import '../features/auth/models/register_request_model.dart';
import '../features/auth/models/signup_response_model.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  String? _accessToken;
  String? _refreshToken;
  UserRole _userRole = UserRole.guest;
  bool _isAuthenticated = false;
  String? _userId;
  String? _displayName;
  String? _email;
  String? _profilePhotoUrl;
  DateTime? _userCreationDate;

  String? _operationError;
  bool _isLoading = false;

  static const String _spAccessTokenKey = 'accessToken';
  static const String _spRefreshTokenKey = 'refreshToken';

  String? get token => _accessToken; // Genellikle accessToken'ı ifade eder
  String? get refreshTokenValue => _refreshToken; // Refresh token'a erişim için
  UserRole get userRole => _userRole;
  bool get isAuthenticated => _isAuthenticated;
  String? get userId => _userId;
  String? get displayName => _displayName;
  String? get email => _email;
  String? get profilePhotoUrl => _profilePhotoUrl;
  DateTime? get userCreationDate => _userCreationDate;
  String? get operationError => _operationError;
  bool get isLoading => _isLoading;

  AuthProvider() {
    // SplashScreen'in checkAuthStatus'u çağırdığı varsayılıyor.
    // Eğer çağırmıyorsa bu yorumu kaldırın:
    // checkAuthStatus();
  }

  Future<bool> login(String emailInput, String password) async {
    _operationError = null;
    _isLoading = true;
    notifyListeners();
    LoginResponseModel loginResponse = await _authService.signInWithEmail(
      emailInput,
      password,
    );
    if (loginResponse.isSuccess &&
        loginResponse.data != null &&
        loginResponse.data!.accessToken.isNotEmpty) {
      _accessToken = loginResponse.data!.accessToken;
      _refreshToken = loginResponse.data!.refreshToken;
      await _saveAuthDataToPrefs();
      bool userInfoSuccess = await _fetchAndSetUserInfo(
        _accessToken!,
        emailIfNull: emailInput,
      );
      if (userInfoSuccess) {
        _isAuthenticated = true;
        _operationError = null;
      } else {
        _operationError =
            _operationError ?? "Kullanıcı detayları alınamadı (login sonrası).";
        await _clearAuthDataAndPrefs();
        _isAuthenticated = false;
      }
    } else {
      _operationError =
          loginResponse.message ??
          "E-posta veya şifre hatalı/Login API hatası.";
      _isAuthenticated = false;
    }
    _isLoading = false;
    notifyListeners();
    if (_isAuthenticated)
      print('AuthProvider: Login başarılı.');
    else
      print('AuthProvider: Login başarısız. Mesaj: $_operationError');
    return _isAuthenticated;
  }

  Future<bool> _fetchAndSetUserInfo(
    String currentToken, {
    String? emailIfNull,
  }) async {
    try {
      Map<String, dynamic> decodedToken = Jwt.parseJwt(currentToken);
      _userId =
          decodedToken['sub'] as String? ??
          decodedToken['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier']
              as String?;
    } catch (e) {
      _userId = null;
    }
    UserInfoResponseModel userInfoResponse = await _authService.getUserInfo(
      currentToken,
    );
    if (userInfoResponse.isSuccess && userInfoResponse.data != null) {
      final userData = userInfoResponse.data!;
      if (_userId == null &&
          userData.backendSpecificUserId.isNotEmpty &&
          !userData.backendSpecificUserId.contains('@'))
        _userId = userData.backendSpecificUserId;
      if (_userId == null)
        print(
          'AuthProvider KRİTİK UYARI (_fetchAndSetUserInfo): Kullanıcı ID\'si (userId) belirlenemedi!',
        );
      _displayName = userData.displayName;
      _email = userData.email ?? emailIfNull;
      _userRole = userData.userRoleEnum;
      _profilePhotoUrl = userData.photoUrl;
      _userCreationDate = userData.registrationDateTime;
      return true;
    } else {
      _operationError =
          userInfoResponse.message ?? "Kullanıcı detayları alınamadı.";
      return false;
    }
  }

  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    final storedAccessToken = prefs.getString(_spAccessTokenKey);
    if (storedAccessToken != null && storedAccessToken.isNotEmpty) {
      _accessToken = storedAccessToken;
      _refreshToken = prefs.getString(_spRefreshTokenKey);
      bool success = await _fetchAndSetUserInfo(storedAccessToken);
      if (success) {
        _isAuthenticated = true;
        _operationError = null;
      } else {
        await _clearAuthDataAndPrefs();
        _isAuthenticated = false;
        _operationError =
            _operationError ?? "Oturum yüklenirken bir sorun oluştu.";
      }
    } else {
      _logoutInternal(notify: false);
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    print('AuthProvider: Logout işlemi başlatıldı.');
    if (!_isAuthenticated && _refreshToken == null && _accessToken == null) {
      print('AuthProvider: Zaten çıkış yapılmış veya token yok.');
      _isLoading = false; // Eğer isLoading true kaldıysa diye
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    String? currentRefreshToken = _refreshToken;
    String? currentAccessToken =
        _accessToken; // Eğer API signOut için accessToken header'ı da istiyorsa

    // Önce lokal verileri ve SharedPreferences'i temizle
    await _clearAuthDataAndPrefs();
    // _isAuthenticated false ve diğer state'ler null _clearAuthDataAndPrefs içinde _logoutInternal ile yapıldı.
    _operationError = null; // Önceki hataları temizle
    print('AuthProvider: Lokal veriler ve SharedPreferences temizlendi.');

    // Sonra (eğer refreshToken varsa) sunucudan çıkış yapmayı dene
    if (currentRefreshToken != null && currentRefreshToken.isNotEmpty) {
      print('AuthProvider: Sunucudan çıkış yapılıyor (refreshToken ile)...');
      // AuthService.signOut'a accessTokenForHeader parametresini de ekledik.
      // API'niz signOut için accessToken header'ı da istiyorsa currentAccessToken'ı gönderin.
      // İstemiyorsa null geçebilirsiniz veya AuthService.signOut'tan bu parametreyi kaldırabilirsiniz.
      SignOutResponseModel signOutResponse = await _authService.signOut(
        currentRefreshToken,
        accessTokenForHeader: currentAccessToken,
      );
      if (signOutResponse.isSuccess) {
        print(
          'AuthProvider: Sunucudan başarıyla çıkış yapıldı. Mesaj: ${signOutResponse.message}',
        );
      } else {
        print(
          'AuthProvider UYARI: Sunucudan çıkış yapılamadı. Mesaj: ${signOutResponse.message}',
        );
        // _operationError = signOutResponse.message ?? "Sunucudan çıkış yapılamadı."; // Opsiyonel
      }
    } else {
      print(
        'AuthProvider: Refresh token bulunmadığı için sunucudan çıkış yapılmıyor.',
      );
    }

    _isLoading = false;
    notifyListeners(); // UI'yı son durumla (logout olmuş ve _isLoading false) güncelle.
    print('AuthProvider: Logout işlemi tamamlandı.');
  }

  Future<void> _clearAuthDataAndPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_spAccessTokenKey);
    await prefs.remove(_spRefreshTokenKey);
    _logoutInternal(
      notify: false,
    ); // State'i sıfırla, UI'yı hemen güncelleme (notify:false)
  }

  void _logoutInternal({bool notify = true}) {
    _accessToken = null;
    _refreshToken = null;
    _userRole = UserRole.guest;
    _isAuthenticated = false;
    _userId = null;
    _displayName = null;
    _email = null;
    _profilePhotoUrl = null;
    _userCreationDate = null;
    // _operationError = null; // Genellikle logout sonrası temizlenir, ancak çağıran yerin yönetmesi daha iyi olabilir.
    if (notify) {
      notifyListeners();
    }
  }

  Future<void> _saveAuthDataToPrefs() async {
    if (_accessToken == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_spAccessTokenKey, _accessToken!);
    if (_refreshToken != null) {
      await prefs.setString(_spRefreshTokenKey, _refreshToken!);
    } else {
      await prefs.remove(_spRefreshTokenKey);
    }
  }

  bool isUser() => _isAuthenticated && _userRole == UserRole.user;
  bool isMentor() => _isAuthenticated && _userRole == UserRole.mentor;
  bool isAdmin() => _isAuthenticated && _userRole == UserRole.admin;

  Future<bool> register({
    required String displayName,
    required String email,
    required String password,
    required String passwordAgain,
    required String birthDate,
    required String? gender,
  }) async {
    _operationError = null;
    _isLoading = true;
    notifyListeners();
    int genderValue;
    switch (gender) {
      case 'Erkek':
        genderValue = 0;
        break;
      case 'Kadın':
        genderValue = 1;
        break;
      case 'Belirtmek istemiyorum':
      default:
        genderValue = 2;
        break;
    }
    String formattedBirthDate;
    try {
      final parts = birthDate.split('/');
      if (parts.length == 3) {
        formattedBirthDate =
            "${parts[2]}-${parts[1].padLeft(2, '0')}-${parts[0].padLeft(2, '0')}";
      } else {
        throw const FormatException("Geçersiz tarih formatı.");
      }
    } catch (e) {
      _operationError = "Geçersiz doğum tarihi formatı.";
      _isLoading = false;
      notifyListeners();
      return false;
    }
    final requestModel = RegisterRequestModel(
      displayName: displayName,
      email: email,
      password: password,
      passwordAgain: passwordAgain,
      gender: genderValue,
      birthDate: formattedBirthDate,
    );
    SignUpResponseModel signUpResponse = await _authService.signUp(
      requestModel,
    );
    _isLoading = false;
    if (signUpResponse.isSuccess) {
      _operationError = null;
    } else {
      _operationError =
          signUpResponse.message ??
          "Kayıt sırasında bilinmeyen bir hata oluştu.";
    }
    notifyListeners();
    return signUpResponse.isSuccess;
  }
}
