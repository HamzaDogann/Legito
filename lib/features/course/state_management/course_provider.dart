// lib/features/course/state_management/course_provider.dart
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // <<< DateFormat İÇİN IMPORT EKLENDİ
import '../../../state_management/auth_provider.dart';
import '../services/course_service.dart';
import '../models/course_item_dto.dart';
import '../models/course_detail_dto.dart';
import '../models/create_course_request_dto.dart';
// UI Modelleri için importlar
// Bu importlar, UI modellerinin tam yoluna göre ayarlanmalı.
// Eğer UI modelleri (TechniqueItem, TechniqueLessonItem) kendi sayfalarında tanımlıysa bu yollar doğru olabilir.
import '../../user_features/techniques_user/screens/TechniquesPage.dart'
    show TechniqueItem;
import '../../mentor_features/techniques_mentor/screens/TechniquesLessonPage.dart'
    show TechniqueLessonItem;

class CourseProvider with ChangeNotifier {
  final CourseService _courseService = CourseService();
  final AuthProvider _authProvider;

  List<CourseItemDto> _popularCourses = [];
  List<CourseItemDto> _lastCreatedCourses = [];
  CourseDetailDto? _selectedCourseDetail;
  List<CourseItemDto> _searchResults = [];
  List<CourseItemDto> _mentorCourses = [];

  bool _isLoadingIndex = false;
  bool _isLoadingDetail = false;
  bool _isLoadingMentorCourses = false;
  bool _isLoadingSearch = false;
  bool _isSubmitting = false;

  String? _errorIndex;
  String? _errorDetail;
  String? _errorMentorCourses;
  String? _errorSearch;
  String? _errorSubmit;

  List<CourseItemDto> get popularCourses => _popularCourses;
  List<CourseItemDto> get lastCreatedCourses => _lastCreatedCourses;
  CourseDetailDto? get selectedCourseDetail => _selectedCourseDetail;
  List<CourseItemDto> get searchResults => _searchResults;
  List<CourseItemDto> get mentorCourses => _mentorCourses;

  bool get isLoadingIndex => _isLoadingIndex;
  bool get isLoadingDetail => _isLoadingDetail;
  bool get isLoadingMentorCourses => _isLoadingMentorCourses;
  bool get isLoadingSearch => _isLoadingSearch;
  bool get isSubmitting => _isSubmitting;

  String? get errorIndex => _errorIndex;
  String? get errorDetail => _errorDetail;
  String? get errorMentorCourses => _errorMentorCourses;
  String? get errorSearch => _errorSearch;
  String? get errorSubmit => _errorSubmit;

  CourseProvider(this._authProvider);

  void clearSubmitError() {
    _errorSubmit = null;
    notifyListeners();
  } // UI'da kullanılabilir

  Future<void> fetchCourseIndex() async {
    _isLoadingIndex = true;
    _errorIndex = null;
    notifyListeners();
    final response = await _courseService.getCourseIndex(_authProvider.token);
    if (response.isSuccess && response.data != null) {
      _popularCourses = response.data!.popularCourses;
      _lastCreatedCourses = response.data!.lastCreatedCourses;
    } else {
      _errorIndex =
          response.errors?.join(", ") ?? "Ana sayfa kursları yüklenemedi.";
      _popularCourses = [];
      _lastCreatedCourses = [];
    }
    _isLoadingIndex = false;
    notifyListeners();
  }

  Future<void> fetchCourseDetail(String courseId) async {
    _isLoadingDetail = true;
    _errorDetail = null;
    _selectedCourseDetail = null;
    notifyListeners();
    final response = await _courseService.getCourseDetail(
      courseId,
      _authProvider.token,
    );
    if (response.isSuccess && response.data != null) {
      _selectedCourseDetail = response.data!;
    } else {
      _errorDetail = response.errors?.join(", ") ?? "Kurs detayı yüklenemedi.";
    }
    _isLoadingDetail = false;
    notifyListeners();
  }

  Future<void> searchCourses(String query) async {
    if (query.isEmpty) {
      _searchResults = [];
      _isLoadingSearch = false;
      _errorSearch = null;
      notifyListeners();
      return;
    }
    _isLoadingSearch = true;
    _errorSearch = null;
    _searchResults = [];
    notifyListeners();
    final response = await _courseService.searchCourses(
      query,
      _authProvider.token,
    );
    if (response.isSuccess && response.data != null) {
      _searchResults = response.data!;
    } else if (response.statusCode == 404 &&
        response.data != null &&
        response.data!.isEmpty) {
      _searchResults = [];
      _errorSearch = null;
    } else {
      _errorSearch =
          response.errors?.join(", ") ?? "Arama sırasında bir hata oluştu.";
      _searchResults = [];
    }
    _isLoadingSearch = false;
    notifyListeners();
  }

  void clearSearchResults() {
    _searchResults = [];
    _errorSearch = null;
    notifyListeners();
  }

  Future<void> fetchMentorCourses() async {
    if (!_authProvider.isMentor() || _authProvider.token == null) {
      _errorMentorCourses = "Bu işlem için mentor yetkisi gereklidir.";
      _mentorCourses = [];
      notifyListeners();
      return;
    }
    _isLoadingMentorCourses = true;
    _errorMentorCourses = null;
    notifyListeners();
    final response = await _courseService.getUserCourses(_authProvider.token!);
    if (response.isSuccess && response.data != null) {
      _mentorCourses = response.data!;
    } else if (response.statusCode == 404 &&
        response.data != null &&
        response.data!.isEmpty) {
      _mentorCourses = [];
      _errorMentorCourses = null;
    } else {
      _errorMentorCourses =
          response.errors?.join(", ") ?? "Mentor kursları yüklenemedi.";
      _mentorCourses = [];
    }
    _isLoadingMentorCourses = false;
    notifyListeners();
  }

  Future<bool> createCourse({
    required String title,
    required String videoUrl,
    String? description,
    File? coverImageFile,
  }) async {
    if (!_authProvider.isMentor() || _authProvider.token == null) {
      _errorSubmit = "Kurs oluşturmak için mentor yetkisi gereklidir.";
      notifyListeners();
      return false;
    }
    _isSubmitting = true;
    _errorSubmit = null;
    notifyListeners();
    String? base64Image;
    if (coverImageFile != null) {
      try {
        final bytes = await coverImageFile.readAsBytes();
        base64Image = base64Encode(bytes);
      } catch (e) {
        _errorSubmit = "Kapak resmi hazırlanırken hata: $e";
        _isSubmitting = false;
        notifyListeners();
        return false;
      }
    }
    final requestDto = CreateCourseRequestDto(
      title: title,
      video: videoUrl,
      description: description,
      base64Image: base64Image,
    );
    final response = await _courseService.createCourse(
      requestDto,
      _authProvider.token!,
    ); // Dönüş tipi CourseDetailApiResponseDto
    _isSubmitting = false;
    if (response.isSuccess && response.data != null) {
      // CourseDetailApiResponseDto'nun data'sı CourseDetailDto
      await fetchMentorCourses();
      return true;
    } else {
      // CourseDetailApiResponseDto'nun errors ve message alanları var.
      _errorSubmit = "Kurs oluşturulamadı.";
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateCourse({
    required String courseId,
    required String title,
    required String videoUrl,
    String? description,
    File? coverImageFile,
    bool removeCoverImage = false,
  }) async {
    if (!_authProvider.isMentor() || _authProvider.token == null) {
      _errorSubmit = "Kurs güncellemek için mentor yetkisi gereklidir.";
      notifyListeners();
      return false;
    }
    _isSubmitting = true;
    _errorSubmit = null;
    notifyListeners();
    String? base64Image;
    if (removeCoverImage)
      base64Image = ""; // API boş string ile silmeyi destekliyorsa
    else if (coverImageFile != null) {
      try {
        final bytes = await coverImageFile.readAsBytes();
        base64Image = base64Encode(bytes);
      } catch (e) {
        _errorSubmit = "Kapak resmi hazırlanırken hata: $e";
        _isSubmitting = false;
        notifyListeners();
        return false;
      }
    }
    final requestDto = CreateCourseRequestDto(
      title: title,
      video: videoUrl,
      description: description,
      base64Image: base64Image,
    );
    final response = await _courseService.updateCourse(
      courseId,
      requestDto,
      _authProvider.token!,
    ); // Dönüş tipi CourseDetailApiResponseDto
    _isSubmitting = false;
    if (response.isSuccess) {
      // Güncelleme başarılıysa data null olabilir (204 No Content)
      await fetchMentorCourses();
      if (_selectedCourseDetail?.id == courseId)
        await fetchCourseDetail(courseId); // Açık olan detayı da güncelle
      return true;
    } else {
      _errorSubmit = "hata";
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteCourse(String courseId) async {
    if (!_authProvider.isMentor() || _authProvider.token == null) {
      _errorSubmit = "Kurs silmek için mentor yetkisi gereklidir.";
      notifyListeners();
      return false;
    }
    _isSubmitting = true;
    _errorSubmit = null;
    notifyListeners();
    final response = await _courseService.deleteCourse(
      courseId,
      _authProvider.token!,
    );
    _isSubmitting = false;
    if (response.isSuccess) {
      _mentorCourses.removeWhere((course) => course.id == courseId);
      notifyListeners();
      return true;
    } else {
      _errorSubmit =
          response.errors?.join(", ") ?? response.message ?? "Kurs silinemedi.";
      notifyListeners();
      return false;
    }
  }

  // UI Modellerine Dönüştürme Getter'ları
  List<TechniqueItem> get popularTechniquesForUI {
    return _popularCourses
        .map(
          (course) => TechniqueItem(
            id: course.id,
            coverImageUrl:
                course.thumbnail ?? 'assets/images/default_course_cover.png',
            title: course.title,
            mentorName: null, // CourseItemDto'da bu bilgi yoktu
            videoUrl: course.video,
            description: null, // Detaydan gelecek
            publishDateFormatted: DateFormat(
              'dd MMM yyyy',
              'tr_TR',
            ).format(course.createdDate),
            viewCountFormatted: "${course.viewCount} G",
          ),
        )
        .toList();
  }

  List<TechniqueItem> get lastCreatedTechniquesForUI {
    return _lastCreatedCourses
        .map(
          (course) => TechniqueItem(
            id: course.id,
            coverImageUrl:
                course.thumbnail ?? 'assets/images/default_course_cover.png',
            title: course.title,
            mentorName: null,
            videoUrl: course.video,
            description: null,
            publishDateFormatted: DateFormat(
              'dd MMM yyyy',
              'tr_TR',
            ).format(course.createdDate),
            viewCountFormatted: "${course.viewCount} G",
          ),
        )
        .toList();
  }

  List<TechniqueItem> get searchResultsForUI {
    return _searchResults
        .map(
          (course) => TechniqueItem(
            id: course.id,
            coverImageUrl:
                course.thumbnail ?? 'assets/images/default_course_cover.png',
            title: course.title,
            mentorName: null,
            videoUrl: course.video,
            description: null,
            publishDateFormatted: DateFormat(
              'dd MMM yyyy',
              'tr_TR',
            ).format(course.createdDate),
            viewCountFormatted: "${course.viewCount} G",
          ),
        )
        .toList();
  }

  List<TechniqueLessonItem> get mentorCoursesForUI {
    return _mentorCourses.map((course) {
      Gradient grad =
          _availableGradients[course.id.hashCode % _availableGradients.length];
      return TechniqueLessonItem(
        id: course.id,
        gradient: grad,
        title: course.title,
        date: DateFormat('dd MMM yyyy', 'tr_TR').format(course.createdDate),
        views: "${course.viewCount} G",
        videoUrl: course.video,
        description: null, // Detaydan alınmalı veya mentor edit'te girmeli
        coverImagePath: course.thumbnail,
      );
    }).toList();
  }

  final List<Gradient> _availableGradients = const [
    LinearGradient(
      colors: [Color(0xFFFA8072), Color(0xFFEF4444)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    LinearGradient(
      colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    LinearGradient(
      colors: [Color(0xFF34D399), Color(0xFF10B981)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    LinearGradient(
      colors: [Color(0xFF4B5563), Color(0xFF374151)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  ];
}
