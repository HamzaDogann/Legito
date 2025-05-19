// lib/features/user_features/library/state_management/library_provider.dart
import 'package:flutter/material.dart';
import '../../../../state_management/auth_provider.dart'; // AuthProvider'dan token almak için
import '../models/resource_enums.dart';
import '../models/resource_request_model.dart';
import '../models/resource_response_model.dart'; // API'den gelen model
import '../services/resource_service.dart';
import '../screens/LibraryPage.dart'
    show LibraryBookItem; // UI modelini kullanmak için

class LibraryProvider with ChangeNotifier {
  final ResourceService _resourceService = ResourceService();
  final AuthProvider _authProvider; // AuthProvider'a erişim

  List<ResourceResponseModel> _allResources = []; // API'den gelen tüm kaynaklar
  List<LibraryBookItem> _currentlyReading = [];
  List<LibraryBookItem> _completedBooks = [];
  List<LibraryBookItem> _toBeReadBooks = [];

  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<LibraryBookItem> get currentlyReading => _currentlyReading;
  List<LibraryBookItem> get completedBooks => _completedBooks;
  List<LibraryBookItem> get toBeReadBooks => _toBeReadBooks;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  LibraryProvider(this._authProvider) {
    // AuthProvider'ın durumu hazır olduğunda kaynakları yükle
    if (_authProvider.isAuthenticated && _authProvider.token != null) {
      fetchResources();
    } else {
      // AuthProvider'ın yüklenmesini beklemek için bir listener eklenebilir
      // veya AuthProvider'dan bir callback/event ile tetiklenebilir.
      // Şimdilik, eğer hemen yüklenemiyorsa, sayfa açıldığında manuel çağrı yapılabilir.
      print("LibraryProvider: AuthProvider henüz hazır değil veya token yok.");
    }
  }

  // API'den gelen ResourceResponseModel'i UI'da kullanılan LibraryBookItem'a çevir
  LibraryBookItem _mapResourceToLibraryItem(
    ResourceResponseModel resource,
    Gradient defaultGradient,
  ) {
    return LibraryBookItem(
      id: resource.id,
      gradient: _getGradientForUiResourceType(
        resource.uiResourceType,
        defaultGradient,
      ), // Helper eklenecek
      resourceType: resource.uiResourceType,
      author: resource.author,
      resourceName: resource.name,
      status: resource.uiStatus, // ResourceResponseModel'deki getter'ı kullanır
    );
  }

  // Helper: UiResourceType'a göre gradient döndürür
  Gradient _getGradientForUiResourceType(
    UiResourceType type,
    Gradient defaultGradient,
  ) {
    // Bu fonksiyon LibraryPage'deki _getGradientForResourceType ile aynı mantıkta olmalı
    // veya oradan çağrılmalı/paylaşılmalı. Şimdilik buraya kopyalıyorum.
    switch (type) {
      case UiResourceType.book:
        return const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF818CF8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case UiResourceType.journal:
        return const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF34D399)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case UiResourceType.article:
        return const LinearGradient(
          colors: [Color(0xFFEF4444), Color(0xFFF87171)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case UiResourceType.blog:
        return const LinearGradient(
          colors: [Color(0xFFF59E0B), Color(0xFFFCD34D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case UiResourceType.encyclopedia:
        return const LinearGradient(
          colors: [Color(0xFF0EA5E9), Color(0xFF38BDF8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case UiResourceType.other:
        return const LinearGradient(
          colors: [Color(0xFF4B5563), Color(0xFF6B7280)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return defaultGradient;
    }
  }

  // Helper: UiResourceType'ı API'nin beklediği int'e çevirir
  int _mapUiResourceTypeToApiInt(UiResourceType uiType) {
    switch (uiType) {
      case UiResourceType.book:
        return ApiResourceType.book.index;
      case UiResourceType.journal:
        return ApiResourceType.journal.index;
      case UiResourceType.article:
        return ApiResourceType.article.index;
      case UiResourceType.blog:
        return ApiResourceType.blog.index;
      case UiResourceType.encyclopedia:
        return ApiResourceType.encyclopedia.index;
      case UiResourceType.other:
        return ApiResourceType.other.index;
      default:
        return ApiResourceType.other.index; // Varsayılan
    }
  }

  // Helper: UI status string'ini API'nin beklediği int'e çevirir
  int _mapUiStatusToApiInt(String uiStatus) {
    switch (uiStatus) {
      case statusCurrentlyReading:
        return ApiSourceStatus.continues.index;
      case statusCompleted:
        return ApiSourceStatus.complete.index;
      case statusToBeRead:
        return ApiSourceStatus.waiting.index;
      default:
        return ApiSourceStatus.waiting.index; // Varsayılan
    }
  }

  Future<void> fetchResources() async {
    if (_authProvider.token == null) {
      _errorMessage = "Oturum bulunamadı. Lütfen tekrar giriş yapın.";
      notifyListeners();
      return;
    }
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _resourceService.getResources(_authProvider.token!);
    if (response.isSuccess && response.data != null) {
      _allResources = response.data!;
      _categorizeResources(); // Kaynakları UI listelerine ayır
    } else {
      _errorMessage =
          response.message ?? "Kaynaklar yüklenirken bir hata oluştu.";
      _allResources = []; // Hata durumunda listeyi boşalt
      _clearUiLists();
    }
    _isLoading = false;
    notifyListeners();
  }

  void _categorizeResources() {
    _clearUiLists();
    Gradient defaultGradient = _getGradientForUiResourceType(
      UiResourceType.other,
      const LinearGradient(colors: [Colors.grey, Colors.blueGrey]),
    ); // Varsayılan gradient

    for (var resource in _allResources) {
      final uiItem = _mapResourceToLibraryItem(resource, defaultGradient);
      if (resource.uiStatus == statusCurrentlyReading) {
        _currentlyReading.add(uiItem);
      } else if (resource.uiStatus == statusCompleted) {
        _completedBooks.add(uiItem);
      } else if (resource.uiStatus == statusToBeRead) {
        _toBeReadBooks.add(uiItem);
      }
    }
  }

  void _clearUiLists() {
    _currentlyReading.clear();
    _completedBooks.clear();
    _toBeReadBooks.clear();
  }

  Future<bool> addResource({
    required String name,
    String? author,
    required UiResourceType uiResourceType,
    required String uiStatus,
  }) async {
    if (_authProvider.token == null) {
      _errorMessage = "İşlem için oturum gerekli.";
      notifyListeners();
      return false;
    }
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final requestModel = ResourceRequestModel(
      name: name,
      author: author,
      type: _mapUiResourceTypeToApiInt(uiResourceType),
      status: _mapUiStatusToApiInt(uiStatus),
    );

    final response = await _resourceService.createResource(
      requestModel,
      _authProvider.token!,
    );
    _isLoading = false;
    if (response.isSuccess) {
      // Başarılı olursa listeyi yeniden çekmek en güncel hali sağlar
      await fetchResources(); // Veya response.data'dan yeni eklenen item'ı alıp ekle
      notifyListeners();
      return true;
    } else {
      _errorMessage = response.message ?? "Kaynak eklenirken bir hata oluştu.";
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateResource({
    required String resourceId,
    required String name,
    String? author,
    required UiResourceType uiResourceType,
    required String uiStatus,
  }) async {
    if (_authProvider.token == null) {
      _errorMessage = "İşlem için oturum gerekli.";
      notifyListeners();
      return false;
    }
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final requestModel = ResourceRequestModel(
      name: name,
      author: author,
      type: _mapUiResourceTypeToApiInt(uiResourceType),
      status: _mapUiStatusToApiInt(uiStatus),
    );

    final response = await _resourceService.updateResource(
      resourceId,
      requestModel,
      _authProvider.token!,
    );
    _isLoading = false;
    if (response.isSuccess) {
      await fetchResources(); // Listeyi güncelle
      notifyListeners();
      return true;
    } else {
      _errorMessage =
          response.message ?? "Kaynak güncellenirken bir hata oluştu.";
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteResource(String resourceId) async {
    if (_authProvider.token == null) {
      _errorMessage = "İşlem için oturum gerekli.";
      notifyListeners();
      return false;
    }
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _resourceService.deleteResource(
      resourceId,
      _authProvider.token!,
    );
    _isLoading = false;
    if (response.isSuccess) {
      _allResources.removeWhere(
        (res) => res.id == resourceId,
      ); // Lokal listeden de sil
      _categorizeResources(); // UI listelerini yeniden oluştur
      notifyListeners();
      return true;
    } else {
      _errorMessage = response.message ?? "Kaynak silinirken bir hata oluştu.";
      notifyListeners();
      return false;
    }
  }
}
