// lib/state_management/auth_provider.dart
import 'dart:convert'; // base64Encode için
import 'dart:io'; // File için
import 'package:flutter/foundation.dart';
// image_picker UI katmanında kullanılacak, AuthProvider'a direkt import etmeye gerek yok.
// File objesi UI'dan AuthProvider'a gelecek.
import 'package:jwt_decode/jwt_decode.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/enums/user_role.dart';
import '../features/auth/services/auth_service.dart';
import '../features/user_features/account/services/user_service.dart';
import '../features/auth/models/login_response_model.dart';
import '../features/user_features/models/user_info_model.dart';
import '../features/auth/models/register_request_model.dart';
import '../features/auth/models/signup_response_model.dart';
import '../features/user_features/account/models/update_user_request_model.dart';
import '../features/user_features/account/models/update_user_photo_request_model.dart';
import '../features/user_features/account/models/update_password_request_model.dart';
import '../core/models/general_api_response_model.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

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

  String? get token => _accessToken;
  String? get refreshTokenValue => _refreshToken;
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
    // SplashScreen checkAuthStatus'u çağırıyorsa, bu satır gereksizdir.
    // Eğer SplashScreen'de çağrı yoksa, bu satır aktif olmalıdır.
    // Varsayılan olarak SplashScreen'in çağırdığını kabul ediyorum.
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
    if (_isAuthenticated) {
      print(
        'AuthProvider: Login ve kullanıcı bilgileri başarıyla alındı. Rol: $_userRole, ID: $_userId, Ad: $_displayName',
      );
    } else {
      print(
        'AuthProvider: Login başarısız veya kullanıcı bilgileri alınamadı. Mesaj: $_operationError',
      );
    }
    return _isAuthenticated;
  }

  Future<bool> _fetchAndSetUserInfo(
    String currentToken, {
    String? emailIfNull,
    UserInfoData? updatedUserData,
  }) async {
    if (updatedUserData != null) {
      _displayName = updatedUserData.displayName ?? _displayName;
      _email = updatedUserData.email ?? _email;
      _userRole = updatedUserData.userRoleEnum;
      _profilePhotoUrl = updatedUserData.photoUrl ?? _profilePhotoUrl;
      _userCreationDate =
          updatedUserData.registrationDateTime ?? _userCreationDate;
      // userId genellikle token'dan veya ilk yüklemeden gelir, burada değişmemeli.
      notifyListeners();
      print("AuthProvider: Kullanıcı bilgileri lokal olarak güncellendi.");
      return true;
    }

    try {
      Map<String, dynamic> decodedToken = Jwt.parseJwt(currentToken);
      _userId =
          decodedToken['sub'] as String? ??
          decodedToken['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier']
              as String?;
    } catch (e) {
      _userId = null;
      print(
        "AuthProvider HATA (_fetchAndSetUserInfo): Token decode edilemedi: $e",
      );
    }

    UserInfoResponseModel userInfoResponse = await _authService.getUserInfo(
      currentToken,
    );
    if (userInfoResponse.isSuccess && userInfoResponse.data != null) {
      final userData = userInfoResponse.data!;
      if (_userId == null &&
          userData.backendSpecificUserId.isNotEmpty &&
          !userData.backendSpecificUserId.contains('@')) {
        _userId = userData.backendSpecificUserId;
      }
      if (_userId == null)
        print(
          'AuthProvider KRİTİK UYARI (_fetchAndSetUserInfo): Kullanıcı ID\'si (userId) belirlenemedi!',
        );
      _displayName = userData.displayName;
      _email = userData.email ?? emailIfNull;
      _userRole = userData.userRoleEnum;
      _profilePhotoUrl = userData.photoUrl;
      _userCreationDate = userData.registrationDateTime;
      print(
        'AuthProvider (_fetchAndSetUserInfo): API\'den kullanıcı bilgileri başarıyla alındı.',
      );
      return true;
    } else {
      _operationError =
          userInfoResponse.message ?? "Kullanıcı detayları API\'den alınamadı.";
      print(
        'AuthProvider (_fetchAndSetUserInfo): Kullanıcı bilgileri API\'den alınamadı. Mesaj: $_operationError',
      );
      return false;
    }
  }

  Future<void> checkAuthStatus() async {
    print("AuthProvider: checkAuthStatus çağrıldı.");
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
        print(
          "AuthProvider: Oturum başarıyla yüklendi. Rol: $_userRole, ID: $_userId",
        );
      } else {
        await _clearAuthDataAndPrefs();
        _isAuthenticated = false;
        _operationError =
            _operationError ?? "Oturum yüklenirken bir sorun oluştu.";
        print(
          "AuthProvider: Kayıtlı token ile kullanıcı bilgileri alınamadı. Lokal çıkış yapıldı.",
        );
      }
    } else {
      _logoutInternal(notify: false); // _isAuthenticated = false olur
      print("AuthProvider: Kayıtlı token bulunamadı.");
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    print('AuthProvider: Logout işlemi başlatıldı.');
    if (!_isAuthenticated && _refreshToken == null && _accessToken == null) {
      print(
        'AuthProvider: Zaten çıkış yapılmış veya token yok. İşlem yapılmayacak.',
      );
      if (_isLoading) {
        // Eğer bir şekilde true kaldıysa
        _isLoading = false;
        notifyListeners();
      }
      return;
    }

    _isLoading = true;
    notifyListeners();

    String? tokenForSignOutApi = _refreshToken;
    String? currentAccessTokenForHeader =
        _accessToken; // SignOut servisi için gerekebilir

    await _clearAuthDataAndPrefs(); // Lokal state ve SP temizlenir, _isAuthenticated false olur
    _operationError = null; // Önceki hataları temizle
    print('AuthProvider: Lokal veriler ve SharedPreferences temizlendi.');

    if (tokenForSignOutApi != null && tokenForSignOutApi.isNotEmpty) {
      print('AuthProvider: Sunucudan çıkış yapılıyor (refreshToken ile)...');
      SignOutResponseModel signOutResponse = await _authService.signOut(
        tokenForSignOutApi,
        accessTokenForHeader: currentAccessTokenForHeader,
      );
      if (signOutResponse.isSuccess) {
        print(
          'AuthProvider: Sunucudan başarıyla çıkış yapıldı. Mesaj: ${signOutResponse.message}',
        );
      } else {
        print(
          'AuthProvider UYARI: Sunucudan çıkış yapılamadı. Mesaj: ${signOutResponse.message}',
        );
        // _operationError = signOutResponse.message ?? "Sunucudan çıkış yapılamadı."; // Kullanıcıya gösterilecekse
      }
    } else {
      print(
        'AuthProvider: Refresh token bulunmadığı için sunucudan çıkış yapılmıyor.',
      );
    }

    _isLoading = false;
    notifyListeners();
    print('AuthProvider: Logout işlemi tamamlandı.');
  }

  Future<void> _clearAuthDataAndPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_spAccessTokenKey);
    await prefs.remove(_spRefreshTokenKey);
    _logoutInternal(notify: false);
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
    // _operationError = null; // Bu metodu çağıran yerin hata yönetimini bozmama adına burada sıfırlanmayabilir.
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
    print("AuthProvider: Tokenlar SharedPreferences'e kaydedildi.");
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
      default:
        genderValue = 2;
        break;
    }
    String formattedBirthDate;
    try {
      final parts = birthDate.split('/');
      if (parts.length == 3)
        formattedBirthDate =
            "${parts[2]}-${parts[1].padLeft(2, '0')}-${parts[0].padLeft(2, '0')}";
      else
        throw const FormatException("Geçersiz tarih formatı.");
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
    if (signUpResponse.isSuccess)
      _operationError = null;
    else
      _operationError =
          signUpResponse.message ??
          "Kayıt sırasında bilinmeyen bir hata oluştu.";
    notifyListeners();
    return signUpResponse.isSuccess;
  }

  Future<bool> updateUserProfile({
    String? displayName,
    String? email,
    int? gender,
    String? birthDate, // "YYYY-MM-DD"
  }) async {
    if (!_isAuthenticated || _accessToken == null) {
      _operationError = "Güncelleme için oturum açmış olmanız gerekir.";
      notifyListeners();
      return false;
    }
    _isLoading = true;
    _operationError = null;
    notifyListeners();
    final requestModel = UpdateUserRequestModel(
      displayName: displayName,
      email: email,
      gender: gender,
      birthDate: birthDate,
    );

    // UserService.updateUserProfile metodunun UserInfoResponseModel döndüğünü varsayıyoruz.
    final UserInfoResponseModel response = await _userService.updateUserProfile(
      requestModel,
      _accessToken!,
    );

    _isLoading = false;
    if (response.isSuccess && response.data != null) {
      // Başarılı güncelleme sonrası AuthProvider'daki state'i güncelle
      // response.data zaten UserInfoData tipindedir.
      await _fetchAndSetUserInfo(
        _accessToken!,
        updatedUserData: response.data,
      ); // <<< DÜZELTİLDİ
      _operationError = null;
      print("AuthProvider: Profil başarıyla güncellendi.");
      notifyListeners();
      return true;
    } else {
      _operationError =
          response.message ??
          response.errors?.join(", ") ??
          "Profil güncellenirken bir hata oluştu.";
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateUserPhoto(File imageFile) async {
    if (!_isAuthenticated || _accessToken == null) {
      _operationError =
          "Fotoğraf güncelleme için oturum açmış olmanız gerekir.";
      notifyListeners();
      return false;
    }
    _isLoading = true;
    _operationError = null;
    notifyListeners();
    try {
      List<int> imageBytes = await imageFile.readAsBytes();
      String base64Image = base64Encode(imageBytes);
      // API sadece saf base64 bekliyorsa:
      String base64Content = base64Image;
      // API "data:image/jpeg;base64," gibi bir prefix bekliyorsa:
      // String extension = imageFile.path.split('.').last.toLowerCase();
      // String mimeType = (extension == 'jpg' || extension == 'jpeg') ? 'jpeg' : extension;
      // String base64Content = "data:image/$mimeType;base64,$base64Image";

      final requestModel = UpdateUserPhotoRequestModel(
        base64Content: base64Content,
      );
      final response = await _userService.updateUserPhoto(
        requestModel,
        _accessToken!,
      );
      _isLoading = false;
      if (response.isSuccess) {
        // Başarılı fotoğraf güncellemesi sonrası güncel kullanıcı bilgilerini çek
        // (API yeni fotoğraf URL'sini direkt dönmüyorsa)
        bool userInfoSuccess = await _fetchAndSetUserInfo(_accessToken!);
        if (userInfoSuccess) {
          print(
            "AuthProvider: Profil fotoğrafı başarıyla güncellendi ve bilgiler yenilendi.",
          );
          _operationError = null;
        } else {
          _operationError =
              _operationError ??
              "Fotoğraf güncellendi ancak bilgiler yenilenemedi.";
        }
        notifyListeners();
        return userInfoSuccess; // Veya response.isSuccess dönebilir, API'ye bağlı
      } else {
        _operationError =
            response.message ??
            response.errors?.join(", ") ??
            "Fotoğraf güncellenirken bir hata oluştu.";
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _operationError =
          "Fotoğraf hazırlanırken veya gönderilirken bir hata oluştu: $e";
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateUserPassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordAgain,
  }) async {
    if (!_isAuthenticated || _accessToken == null) {
      _operationError = "Şifre güncelleme için oturum açmış olmanız gerekir.";
      notifyListeners();
      return false;
    }
    _isLoading = true;
    _operationError = null;
    notifyListeners();
    final requestModel = UpdatePasswordRequestModel(
      currentPassword: currentPassword,
      newPassword: newPassword,
      newPasswordAgain: newPasswordAgain,
    );
    final response = await _userService.updateUserPassword(
      requestModel,
      _accessToken!,
    );
    _isLoading = false;
    if (response.isSuccess) {
      print("AuthProvider: Şifre başarıyla güncellendi.");
      _operationError = null;
      // ÖNEMLİ: Şifre değişikliği sonrası güvenlik için genellikle logout yapılması önerilir.
      // API yeni token dönmüyorsa ve eski token'lar geçersiz kılındıysa bu zorunludur.
      // Eğer API yeni bir token seti dönüyorsa, o token'ları burada set edebilirsiniz.
      // Şimdilik, başarılı işlem sonrası logout yapıyoruz.
      await logout(); // Kullanıcıyı tekrar login olmaya zorla
      notifyListeners();
      return true;
    } else {
      _operationError =
          response.message ??
          response.errors?.join(", ") ??
          "Şifre güncellenirken bir hata oluştu.";
      notifyListeners();
      return false;
    }
  }

  void clearOperationError() {
    _operationError = null;
    notifyListeners();
  }
}
