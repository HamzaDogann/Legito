// lib/features/mentor_features/tips_mentor/state_management/tip_provider.dart
import 'package:flutter/material.dart';
import '../../../../state_management/auth_provider.dart';
import '../models/tip_response_dto.dart';
import '../models/create_update_tip_request_dto.dart';
import '../services/tip_service.dart';
import '../models/tip_enums.dart'; // ApiTipAvatar için

// UI'da kullanılacak TipItem (TipsPage'den buraya taşınabilir veya oradaki kullanılabilir)
// Şimdilik TipsPage'deki TipItem modelini kullanacağımızı varsayıyorum.
// Eğer bu provider'dan UI'a direkt TipItem listesi verilecekse, burada da tanımlanabilir.

class TipProvider with ChangeNotifier {
  final TipService _tipService = TipService();
  final AuthProvider _authProvider;

  List<TipResponseDto> _mentorTips = []; // API'den gelen ham DTO listesi
  bool _isLoading = false;
  String? _errorMessage;
  TipResponseDto? _randomTipForPublicHome; // Public Home için

  List<TipResponseDto> get mentorTips => _mentorTips;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  TipResponseDto? get randomTipForPublicHome => _randomTipForPublicHome;

  TipProvider(this._authProvider) {
    // Mentor giriş yaptıysa ve token varsa ipuçlarını yükle
    if (_authProvider.isAuthenticated &&
        _authProvider.isMentor() &&
        _authProvider.token != null) {
      fetchUserTips();
    }
    // Public home için rastgele ipucunu da burada veya app açılışında çekebiliriz.
    // Şimdilik ayrı bir metodla çağrılacak.
  }

  void clearErrorMessage() {
    _errorMessage = null;
    // notifyListeners(); // Genellikle bir işlem sonrası çağrılır, sadece temizlerken gerekmeyebilir.
  }

  Future<void> fetchRandomTipForPublicHome() async {
    _isLoading = true;
    _errorMessage = null;
    // notifyListeners(); // Public home'da bu provider dinlenmiyorsa gereksiz olabilir

    _randomTipForPublicHome = await _tipService.getRandomTip();

    _isLoading = false;
    if (_randomTipForPublicHome == null) {
      _errorMessage = "Rastgele ipucu yüklenemedi.";
    }
    notifyListeners(); // Public home'da dinleniyorsa UI güncellenir
  }

  Future<void> fetchUserTips() async {
    if (!_authProvider.isMentor() || _authProvider.token == null) {
      _errorMessage = "Bu işlem için mentor yetkisi ve oturum gereklidir.";
      _mentorTips = [];
      notifyListeners();
      return;
    }
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _tipService.getUserTips(_authProvider.token!);
    if (response.isSuccess && response.data != null) {
      _mentorTips = response.data!;
    } else {
      _errorMessage =
          response.message ?? "Mentor ipuçları yüklenirken bir hata oluştu.";
      _mentorTips = [];
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createTip({
    required String title,
    required String content,
    required int apiAvatarIndex, // ApiTipAvatar.values[index].index
  }) async {
    if (!_authProvider.isMentor() || _authProvider.token == null) {
      _errorMessage = "İşlem için mentor yetkisi ve oturum gereklidir.";
      notifyListeners();
      return false;
    }
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final requestDto = CreateUpdateTipRequestDto(
      title: title,
      content: content,
      avatar: apiAvatarIndex,
    );

    final response = await _tipService.createTip(
      requestDto,
      _authProvider.token!,
    );
    _isLoading = false;
    if (response.isSuccess && response.data != null) {
      // _mentorTips.add(response.data!); // Listeye ekle
      // Veya daha güvenli olan: Listeyi yeniden çek
      await fetchUserTips();
      notifyListeners();
      return true;
    } else {
      _errorMessage =
          response.message ?? "İpucu oluşturulurken bir hata oluştu.";
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateTip({
    required String tipId,
    required String title,
    required String content,
    required int apiAvatarIndex,
  }) async {
    if (!_authProvider.isMentor() || _authProvider.token == null) {
      _errorMessage = "İşlem için mentor yetkisi ve oturum gereklidir.";
      notifyListeners();
      return false;
    }
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final requestDto = CreateUpdateTipRequestDto(
      title: title,
      content: content,
      avatar: apiAvatarIndex,
    );

    final response = await _tipService.updateTip(
      tipId,
      requestDto,
      _authProvider.token!,
    );
    _isLoading = false;
    if (response.isSuccess) {
      await fetchUserTips(); // Listeyi güncelle
      notifyListeners();
      return true;
    } else {
      _errorMessage =
          response.message ?? "İpucu güncellenirken bir hata oluştu.";
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteTip(String tipId) async {
    if (!_authProvider.isMentor() || _authProvider.token == null) {
      _errorMessage = "İşlem için mentor yetkisi ve oturum gereklidir.";
      notifyListeners();
      return false;
    }
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _tipService.deleteTip(tipId, _authProvider.token!);
    _isLoading = false;
    if (response.isSuccess) {
      _mentorTips.removeWhere(
        (tip) => tip.id == tipId,
      ); // Lokal listeden de sil
      notifyListeners();
      return true;
    } else {
      _errorMessage = response.message ?? "İpucu silinirken bir hata oluştu.";
      notifyListeners();
      return false;
    }
  }
}
