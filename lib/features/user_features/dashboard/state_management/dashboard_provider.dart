// lib/features/user_features/dashboard/state_management/dashboard_provider.dart
import 'package:flutter/material.dart';
import '../../../../state_management/auth_provider.dart';
import '../services/dashboard_service.dart';
import '../models/dashboard_dtos.dart';

class DashboardProvider with ChangeNotifier {
  final DashboardService _dashboardService = DashboardService();
  final AuthProvider _authProvider;

  UserDashboardDataDto? _dashboardData;
  bool _isLoading = false;
  String? _errorMessage;

  UserDashboardDataDto? get dashboardData => _dashboardData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  DashboardProvider(this._authProvider) {
    // AuthProvider hazırsa ve kullanıcı login ise verileri çek
    if (_authProvider.isAuthenticated &&
        _authProvider.isUser() &&
        _authProvider.token != null) {
      fetchDashboardData();
    }
  }

  Future<void> fetchDashboardData() async {
    if (!_authProvider.isUser() || _authProvider.token == null) {
      _errorMessage =
          "Dashboard verilerini almak için kullanıcı oturumu gereklidir.";
      _isLoading = false; // Ekstra güvenlik
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _dashboardService.getUserDashboardData(
      _authProvider.token!,
    );

    if (response.isSuccess && response.data != null) {
      _dashboardData = response.data!;
      _errorMessage = null;
    } else {
      _dashboardData = null; // Hata durumunda veriyi temizle
      _errorMessage =
          response.errors?.join(", ") ?? "Dashboard verileri yüklenemedi.";
    }
    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
