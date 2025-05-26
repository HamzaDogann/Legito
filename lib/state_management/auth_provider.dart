// lib/state_management/auth_provider.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
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
import '../core/models/general_api_response_model.dart'; // Ensure this is used or remove if not

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

  String? _operationError; // General error message or first error
  List<String>? _operationErrorsList; // List of specific errors from API
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
  List<String>? get operationErrorsList => _operationErrorsList;
  bool get isLoading => _isLoading;

  AuthProvider() {
    // checkAuthStatus(); // Typically called from SplashScreen
  }

  void _clearErrors() {
    _operationError = null;
    _operationErrorsList = null;
  }

  Future<bool> login(String emailInput, String password) async {
    _clearErrors();
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
      } else {
        // _fetchAndSetUserInfo already sets _operationError if it fails
        await _clearAuthDataAndPrefs();
        _isAuthenticated = false;
      }
    } else {
      _isAuthenticated = false;
      _operationError = loginResponse.message ?? "E-posta veya şifre hatalı.";
      _operationErrorsList = loginResponse.errors;
      // If errors list is not empty and general message is generic, use first error as general
      if ((_operationErrorsList?.isNotEmpty ?? false) &&
          (_operationError == "E-posta veya şifre hatalı." ||
              _operationError == loginResponse.message)) {
        _operationError = _operationErrorsList!.first;
      }
    }
    _isLoading = false;
    notifyListeners();
    if (_isAuthenticated) {
      print(
        'AuthProvider: Login ve kullanıcı bilgileri başarıyla alındı. Rol: $_userRole, ID: $_userId, Ad: $_displayName',
      );
    } else {
      print(
        'AuthProvider: Login başarısız. Hata: $_operationError, Hatalar: $_operationErrorsList',
      );
    }
    return _isAuthenticated;
  }

  Future<bool> _fetchAndSetUserInfo(
    String currentToken, {
    String? emailIfNull,
    UserInfoData? updatedUserData,
  }) async {
    _clearErrors(); // Clear previous errors before fetching/setting
    if (updatedUserData != null) {
      _displayName = updatedUserData.displayName ?? _displayName;
      _email = updatedUserData.email ?? _email;
      _userRole = updatedUserData.userRoleEnum;
      _profilePhotoUrl = updatedUserData.photoUrl ?? _profilePhotoUrl;
      _userCreationDate =
          updatedUserData.registrationDateTime ?? _userCreationDate;
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
      _operationErrorsList = userInfoResponse.errors;
      if ((_operationErrorsList?.isNotEmpty ?? false) &&
          _operationError == userInfoResponse.message) {
        _operationError = _operationErrorsList!.first;
      }
      print(
        'AuthProvider (_fetchAndSetUserInfo): Kullanıcı bilgileri API\'den alınamadı. Hata: $_operationError, Hatalar: $_operationErrorsList',
      );
      return false;
    }
  }

  Future<void> checkAuthStatus() async {
    print("AuthProvider: checkAuthStatus çağrıldı.");
    _clearErrors();
    _isLoading = true;
    notifyListeners(); // Notify for loading start

    final prefs = await SharedPreferences.getInstance();
    final storedAccessToken = prefs.getString(_spAccessTokenKey);

    if (storedAccessToken != null && storedAccessToken.isNotEmpty) {
      _accessToken = storedAccessToken;
      _refreshToken = prefs.getString(_spRefreshTokenKey);
      bool success = await _fetchAndSetUserInfo(storedAccessToken);
      if (success) {
        _isAuthenticated = true;
        print(
          "AuthProvider: Oturum başarıyla yüklendi. Rol: $_userRole, ID: $_userId",
        );
      } else {
        // _fetchAndSetUserInfo already sets _operationError/_operationErrorsList
        await _clearAuthDataAndPrefs(); // This sets _isAuthenticated = false
        print(
          "AuthProvider: Kayıtlı token ile kullanıcı bilgileri alınamadı. Lokal çıkış yapıldı.",
        );
      }
    } else {
      _logoutInternal(notify: false); // Sets _isAuthenticated = false
      print("AuthProvider: Kayıtlı token bulunamadı.");
    }
    _isLoading = false;
    notifyListeners(); // Notify for loading end and state changes
  }

  Future<void> logout() async {
    print('AuthProvider: Logout işlemi başlatıldı.');
    if (!_isAuthenticated && _refreshToken == null && _accessToken == null) {
      print(
        'AuthProvider: Zaten çıkış yapılmış veya token yok. İşlem yapılmayacak.',
      );
      if (_isLoading) {
        _isLoading = false;
        notifyListeners();
      }
      return;
    }

    _isLoading = true;
    _clearErrors(); // Clear errors before logout attempt
    notifyListeners();

    String? tokenForSignOutApi = _refreshToken;
    String? currentAccessTokenForHeader = _accessToken;

    await _clearAuthDataAndPrefs(); // Local state and SP cleaned, _isAuthenticated = false
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
        // Don't set operationError for logout failure typically, as user is already logged out locally.
        // If you need to show it, uncomment:
        // _operationError = signOutResponse.message ?? "Sunucudan çıkış yapılamadı.";
        // _operationErrorsList = signOutResponse.errors;
        print(
          'AuthProvider UYARI: Sunucudan çıkış yapılamadı. Mesaj: ${signOutResponse.message}, Hatalar: ${signOutResponse.errors}',
        );
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
    // _clearErrors(); // Let the calling method manage error display contextually
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
    _clearErrors();
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
      // Success, errors should be clear
    } else {
      _operationError =
          signUpResponse.message ??
          "Kayıt sırasında bilinmeyen bir hata oluştu.";
      _operationErrorsList = signUpResponse.errors;
      // If errors list is not empty and general message is generic, use first error
      if ((_operationErrorsList?.isNotEmpty ?? false) &&
          _operationError == signUpResponse.message) {
        _operationError = _operationErrorsList!.first;
      }
    }
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
    _clearErrors();
    notifyListeners();

    final requestModel = UpdateUserRequestModel(
      displayName: displayName,
      email: email,
      gender: gender,
      birthDate: birthDate,
    );

    final UserInfoResponseModel response = await _userService.updateUserProfile(
      requestModel,
      _accessToken!,
    );
    _isLoading = false;

    if (response.isSuccess && response.data != null) {
      await _fetchAndSetUserInfo(_accessToken!, updatedUserData: response.data);
      print("AuthProvider: Profil başarıyla güncellendi.");
      notifyListeners();
      return true;
    } else {
      _operationError =
          response.message ??
          response.errors?.join(", ") ??
          "Profil güncellenirken bir hata oluştu.";
      _operationErrorsList = response.errors;
      if ((_operationErrorsList?.isNotEmpty ?? false) &&
          _operationError == response.message) {
        _operationError = _operationErrorsList!.first;
      }
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
    _clearErrors();
    notifyListeners();

    try {
      List<int> imageBytes = await imageFile.readAsBytes();
      String base64Image = base64Encode(imageBytes);
      String base64Content = base64Image;

      final requestModel = UpdateUserPhotoRequestModel(
        base64Content: base64Content,
      );
      final GeneralApiResponseModel response = await _userService
          .updateUserPhoto(
            requestModel,
            _accessToken!,
          ); // Assuming GeneralApiResponseModel
      _isLoading = false;

      if (response.isSuccess) {
        bool userInfoSuccess = await _fetchAndSetUserInfo(
          _accessToken!,
        ); // Refetch to get new photo URL
        if (userInfoSuccess) {
          print(
            "AuthProvider: Profil fotoğrafı başarıyla güncellendi ve bilgiler yenilendi.",
          );
        } else {
          // _fetchAndSetUserInfo sets its own errors
        }
        notifyListeners();
        return userInfoSuccess;
      } else {
        _operationError =
            response.message ??
            response.errors?.join(", ") ??
            "Fotoğraf güncellenirken bir hata oluştu.";
        _operationErrorsList = response.errors;
        if ((_operationErrorsList?.isNotEmpty ?? false) &&
            _operationError == response.message) {
          _operationError = _operationErrorsList!.first;
        }
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
    _clearErrors();
    notifyListeners();

    final requestModel = UpdatePasswordRequestModel(
      currentPassword: currentPassword,
      newPassword: newPassword,
      newPasswordAgain: newPasswordAgain,
    );
    final GeneralApiResponseModel response = await _userService
        .updateUserPassword(
          requestModel,
          _accessToken!,
        ); // Assuming GeneralApiResponseModel
    _isLoading = false;

    if (response.isSuccess) {
      print("AuthProvider: Şifre başarıyla güncellendi.");
      await logout(); // Force re-login for security
      // notifyListeners() is called by logout()
      return true;
    } else {
      _operationError =
          response.message ??
          response.errors?.join(", ") ??
          "Şifre güncellenirken bir hata oluştu.";
      _operationErrorsList = response.errors;
      if ((_operationErrorsList?.isNotEmpty ?? false) &&
          _operationError == response.message) {
        _operationError = _operationErrorsList!.first;
      }
      notifyListeners();
      return false;
    }
  }

  // Renamed from clearOperationError to avoid confusion
  void clearDisplayedError() {
    _clearErrors();
    notifyListeners();
  }
}
