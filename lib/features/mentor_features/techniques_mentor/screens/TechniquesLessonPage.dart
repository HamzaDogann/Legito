import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../../shared_widgets/cover_card_widget.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../state_management/auth_provider.dart';
import '../../../course/state_management/course_provider.dart';
import '../../../course/models/course_item_dto.dart';

class TechniqueLessonItem {
  String id;
  Gradient gradient;
  String title;
  String date;
  String views;
  String? videoUrl;
  String? description;
  String? coverImagePath;

  TechniqueLessonItem({
    required this.id,
    required this.gradient,
    required this.title,
    required this.date,
    required this.views,
    this.videoUrl,
    this.description,
    this.coverImagePath,
  });
}

class TechniquesLessonPage extends StatefulWidget {
  const TechniquesLessonPage({Key? key}) : super(key: key);
  @override
  State<TechniquesLessonPage> createState() => _TechniquesLessonPageState();
}

class _TechniquesLessonPageState extends State<TechniquesLessonPage> {
  static const Color appBarBackground = Color(0xFFF4F6F9);
  static const Color textDark = Color(0xFF1F2937);
  static const Color searchButtonColor = Color(0xFFFF8128);
  static const Color searchInputHintColor = Color(0xFF9CA3AF);
  static const Color fabColor = Color(0xFFFF8128);
  static const Color iconColor = Color(0xFF6B7280);
  static const Color itemTitleColor = Color(0xFF1F2937);
  static const Color itemSubtitleColor = Color(0xFF6B7280);
  static const Color inputFillColor = Color(0xFFF3F4F6);
  static const Color saveButtonColor = Color(0xFFFF8128);
  static const Color cancelButtonColor = Color.fromARGB(255, 27, 27, 27);
  static const Color coverEditIconBg = Colors.white;
  static const double kUnifiedListItemCoverSize = 80.0;
  static const BorderRadius kUnifiedListItemBorderRadius = BorderRadius.all(
    Radius.circular(12.0),
  );
  static const double kModalCoverSize = 120.0;
  static const BorderRadius kModalCoverBorderRadius = BorderRadius.all(
    Radius.circular(12.0),
  );
  static const String kDefaultCoverIconAsset = 'assets/images/BookIcon.png';
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

  String _searchTerm = '';
  TechniqueLessonItem? _selectedLessonUI;
  bool _isSelectionMode = false;
  final TextEditingController _searchController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _videoUrlController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  File? _modalSelectedCoverImageFile;
  bool _modalRemoveCoverImage = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (!authProvider.isAuthenticated || !authProvider.isMentor()) {
        if (mounted)
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.login,
            (route) => false,
          );
      } else {
        Provider.of<CourseProvider>(
          context,
          listen: false,
        ).fetchMentorCourses();
      }
    });
    _searchController.addListener(() {
      if (mounted) setState(() => _searchTerm = _searchController.text);
    });
  }

  TechniqueLessonItem _mapCourseDtoToTechniqueLessonItem(
    CourseItemDto dto, {
    String? descriptionFromDetail,
    String? videoUrlFromDetail,
  }) {
    return TechniqueLessonItem(
      id: dto.id,
      gradient:
          _availableGradients[dto.id.hashCode % _availableGradients.length],
      title: dto.title,
      date: DateFormat('dd MMM yyyy', 'tr_TR').format(dto.createdDate),
      views: "${dto.viewCount} G",
      videoUrl: videoUrlFromDetail ?? dto.video, // Detaydan gelen öncelikli
      description: descriptionFromDetail, // Detaydan gelen description
      coverImagePath: dto.thumbnail,
    );
  }

  Gradient _getRandomGradient(String idBasedSeed) =>
      _availableGradients[idBasedSeed.hashCode % _availableGradients.length];

  Future<void> _onLessonLongPress(TechniqueLessonItem lessonFromList) async {
    final courseProvider = Provider.of<CourseProvider>(context, listen: false);

    print(
      "TechniquesLessonPage: Long press on ${lessonFromList.id}. Fetching details for modal...",
    );
    // Detayları çek, _selectedCourseDetail provider'da güncellenecek
    await courseProvider.fetchCourseDetail(lessonFromList.id);

    if (mounted) {
      // Provider'daki güncel detayı al
      final detailedCourse = courseProvider.selectedCourseDetail;
      TechniqueLessonItem lessonForSelection = lessonFromList; // Fallback

      if (detailedCourse != null && detailedCourse.id == lessonFromList.id) {
        // Güncel detaylarla yeni bir UI objesi oluştur (veya eskisini güncelle)
        lessonForSelection = TechniqueLessonItem(
          id: detailedCourse.id,
          gradient: lessonFromList.gradient, // Gradient'i listeden koru
          title: detailedCourse.title,
          date: DateFormat(
            'dd MMM yyyy',
            'tr_TR',
          ).format(detailedCourse.createdDate),
          views: "${detailedCourse.viewCount} G",
          videoUrl: detailedCourse.video,
          description: detailedCourse.description,
          coverImagePath:
              lessonFromList.coverImagePath, // Thumbnail listeden koru
        );
        print(
          "TechniquesLessonPage: Details fetched. Description: '${lessonForSelection.description}'",
        );
      } else {
        print(
          "TechniquesLessonPage: Could not fetch/match details for ${lessonFromList.id}. Using list data. Error: ${courseProvider.errorDetail}",
        );
        // Hata varsa kullanıcıya gösterilebilir (opsiyonel)
        if (courseProvider.errorDetail != null &&
            courseProvider.errorDetail!.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Ders detayı yüklenemedi: ${courseProvider.errorDetail}",
              ),
            ),
          );
        }
      }
      setState(() {
        _selectedLessonUI = lessonForSelection;
        _isSelectionMode = true;
      });
    }
  }

  void _exitSelectionMode() => setState(() {
    _selectedLessonUI = null;
    _isSelectionMode = false;
  });

  void _deleteSelectedLesson() {
    if (_selectedLessonUI == null) return;
    showDialog(
      context: context,
      builder:
          (BuildContext dCtx) => AlertDialog(
            title: const Text("Dersi Sil"),
            content: Text("'${_selectedLessonUI!.title}' silinecek?"),
            actions: [
              TextButton(
                child: const Text("İptal"),
                onPressed: () => Navigator.of(dCtx).pop(),
              ),
              TextButton(
                child: const Text("Sil", style: TextStyle(color: Colors.red)),
                onPressed: () async {
                  Navigator.of(dCtx).pop();
                  final cp = Provider.of<CourseProvider>(
                    context,
                    listen: false,
                  );
                  final success = await cp.deleteCourse(_selectedLessonUI!.id);
                  if (mounted) {
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Ders silindi.")),
                      );
                      _exitSelectionMode();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "Hata: ${cp.errorSubmit ?? 'Bilinmeyen bir sorun.'}",
                          ),
                        ),
                      );
                    }
                  }
                },
              ),
            ],
          ),
    );
  }

  Future<void> _pickImageForModal(
    ImageSource source,
    StateSetter modalSetState,
  ) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 1024,
        maxHeight: 768,
      );
      if (pickedFile != null)
        modalSetState(() {
          _modalSelectedCoverImageFile = File(pickedFile.path);
          _modalRemoveCoverImage = false;
        });
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Resim seçilemedi.")));
    }
  }

  void _removeCoverImageInModal(StateSetter modalSetState) => modalSetState(() {
    _modalSelectedCoverImageFile = null;
    _modalRemoveCoverImage = true;
  });
  void _showImageSourceActionSheetForModal(
    BuildContext modalCtx,
    StateSetter modalSetSt,
  ) {
    showModalBottomSheet(
      context: modalCtx,
      builder: (BuildContext bCtx) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galeriden Seç'),
                onTap: () {
                  _pickImageForModal(ImageSource.gallery, modalSetSt);
                  Navigator.of(bCtx).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Kameradan Çek'),
                onTap: () {
                  _pickImageForModal(ImageSource.camera, modalSetSt);
                  Navigator.of(bCtx).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _openAddEditLessonModal({TechniqueLessonItem? lessonToEdit}) {
    bool isEditing = lessonToEdit != null;
    _modalSelectedCoverImageFile = null;
    _modalRemoveCoverImage = false;

    if (isEditing && lessonToEdit != null) {
      _videoUrlController.text = lessonToEdit.videoUrl ?? '';
      _titleController.text = lessonToEdit.title;
      _descriptionController.text =
          lessonToEdit.description ?? ''; // _onLessonLongPress'te güncellendi
      print(
        "Modal açılıyor (Düzenleme): Title='${lessonToEdit.title}', Description='${lessonToEdit.description}', Video='${lessonToEdit.videoUrl}'",
      );
    } else {
      _videoUrlController.clear();
      _titleController.clear();
      _descriptionController.clear();
      print("Modal açılıyor (Yeni Ekleme)");
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (BuildContext modalContext) {
        return StatefulBuilder(
          builder: (BuildContext ssbContext, StateSetter modalSetState) {
            String? currentCoverNetworkPath =
                (isEditing &&
                        lessonToEdit?.coverImagePath != null &&
                        !_modalRemoveCoverImage)
                    ? lessonToEdit!.coverImagePath
                    : null;
            File? coverFileToShow = _modalSelectedCoverImageFile;

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(modalContext).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),
                      Center(
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            GestureDetector(
                              onTap:
                                  () => _showImageSourceActionSheetForModal(
                                    modalContext,
                                    modalSetState,
                                  ),
                              child: CoverCardWidget(
                                size: kModalCoverSize,
                                borderRadius: kModalCoverBorderRadius,
                                imageFile: coverFileToShow,
                                imageNetworkPath:
                                    coverFileToShow == null
                                        ? currentCoverNetworkPath
                                        : null,
                                gradient:
                                    (coverFileToShow == null &&
                                            currentCoverNetworkPath == null)
                                        ? _getRandomGradient("modal_default")
                                        : null,
                                imageAssetPath:
                                    (coverFileToShow == null &&
                                            currentCoverNetworkPath == null)
                                        ? kDefaultCoverIconAsset
                                        : null,
                                iconColor:
                                    (coverFileToShow == null &&
                                            currentCoverNetworkPath == null)
                                        ? Colors.white
                                        : null,
                                iconOrImageSize: kModalCoverSize * 0.6,
                              ),
                            ),
                            if ((coverFileToShow != null ||
                                    currentCoverNetworkPath != null) &&
                                isEditing)
                              Positioned(
                                right: -8,
                                top: -8,
                                child: InkWell(
                                  onTap:
                                      () => _removeCoverImageInModal(
                                        modalSetState,
                                      ),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.red[400],
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              )
                            else
                              Positioned(
                                child: InkWell(
                                  onTap:
                                      () => _showImageSourceActionSheetForModal(
                                        modalContext,
                                        modalSetState,
                                      ),
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: coverEditIconBg,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 4,
                                          offset: const Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.edit_outlined,
                                      size: 20,
                                      color: textDark,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 25),
                      _buildFormTextField(
                        "Video URL",
                        _videoUrlController,
                        isRequired: true,
                      ),
                      _buildFormTextField(
                        "Başlık",
                        _titleController,
                        isRequired: true,
                      ),
                      _buildFormTextField(
                        "Açıklama",
                        _descriptionController,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 25),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => Navigator.pop(modalContext),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: cancelButtonColor,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                'Vazgeç',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  final courseProvider =
                                      Provider.of<CourseProvider>(
                                        this.context,
                                        listen: false,
                                      );
                                  bool success;
                                  if (isEditing && lessonToEdit != null) {
                                    success = await courseProvider.updateCourse(
                                      courseId: lessonToEdit.id,
                                      title: _titleController.text.trim(),
                                      videoUrl: _videoUrlController.text.trim(),
                                      description:
                                          _descriptionController.text
                                                  .trim()
                                                  .isEmpty
                                              ? null
                                              : _descriptionController.text
                                                  .trim(),
                                      coverImageFile:
                                          _modalSelectedCoverImageFile,
                                      removeCoverImage: _modalRemoveCoverImage,
                                    );
                                  } else {
                                    success = await courseProvider.createCourse(
                                      title: _titleController.text.trim(),
                                      videoUrl: _videoUrlController.text.trim(),
                                      description:
                                          _descriptionController.text
                                                  .trim()
                                                  .isEmpty
                                              ? null
                                              : _descriptionController.text
                                                  .trim(),
                                      coverImageFile:
                                          _modalSelectedCoverImageFile,
                                    );
                                  }
                                  Navigator.pop(modalContext);
                                  if (mounted) {
                                    if (success) {
                                      ScaffoldMessenger.of(
                                        this.context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            isEditing
                                                ? "Ders güncellendi."
                                                : "Ders oluşturuldu.",
                                          ),
                                        ),
                                      );
                                      if (_isSelectionMode)
                                        _exitSelectionMode();
                                    } else {
                                      ScaffoldMessenger.of(
                                        this.context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            isEditing
                                                ? "Güncelleme hatası: ${courseProvider.errorSubmit ?? 'Bilinmeyen sorun.'}"
                                                : "Oluşturma hatası: ${courseProvider.errorSubmit ?? 'Bilinmeyen sorun.'}",
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: saveButtonColor,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                isEditing ? 'Güncelle' : 'Oluştur',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(
      () => setState(() {
        _modalSelectedCoverImageFile = null;
        _modalRemoveCoverImage = false;
      }),
    );
  }

  Widget _buildFormTextField(
    String label,
    TextEditingController controller, {
    bool isRequired = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: textDark,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            style: const TextStyle(color: textDark),
            maxLines: maxLines,
            decoration: InputDecoration(
              filled: true,
              fillColor: inputFillColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: saveButtonColor.withOpacity(0.7),
                  width: 1.5,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),
              hintStyle: TextStyle(color: textDark.withOpacity(0.5)),
            ),
            validator:
                isRequired
                    ? (value) =>
                        (value == null || value.isEmpty)
                            ? '$label giriniz'
                            : null
                    : null,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _videoUrlController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated || !authProvider.isMentor()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted)
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.login,
            (route) => false,
          );
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Consumer<CourseProvider>(
      builder: (context, courseProvider, child) {
        final List<TechniqueLessonItem> allMentorUiCourses =
            courseProvider.mentorCourses.map((dto) {
              String? currentDescription;
              String? currentVideoUrl;
              // _selectedLessonUI, _onLessonLongPress ile en son seçilen ve detayları çekilen dersi tutar.
              // Bu, listenin build edilmesi sırasında, o anki DTO'nun ID'si ile eşleşiyorsa kullanılır.
              if (_selectedLessonUI != null &&
                  _selectedLessonUI!.id == dto.id) {
                currentDescription = _selectedLessonUI!.description;
                currentVideoUrl = _selectedLessonUI!.videoUrl;
              }
              // Eğer provider'da genel bir selectedCourseDetail varsa (başka bir yerden set edilmiş olabilir),
              // onu da fallback olarak kullanabiliriz.
              else if (courseProvider.selectedCourseDetail != null &&
                  courseProvider.selectedCourseDetail!.id == dto.id) {
                currentDescription =
                    courseProvider.selectedCourseDetail!.description;
                currentVideoUrl = courseProvider.selectedCourseDetail!.video;
              }
              return _mapCourseDtoToTechniqueLessonItem(
                dto,
                descriptionFromDetail: currentDescription,
                videoUrlFromDetail: currentVideoUrl,
              );
            }).toList();

        List<TechniqueLessonItem> filteredUiLessons;
        if (_searchTerm.isEmpty) {
          filteredUiLessons = allMentorUiCourses;
        } else {
          filteredUiLessons =
              allMentorUiCourses
                  .where(
                    (lesson) => lesson.title.toLowerCase().contains(
                      _searchTerm.toLowerCase(),
                    ),
                  )
                  .toList();
        }

        Widget bodyContent;
        if (courseProvider.isLoadingMentorCourses &&
            allMentorUiCourses.isEmpty) {
          bodyContent = const Center(
            child: CircularProgressIndicator(color: Colors.orange),
          );
        } else if (!courseProvider.isLoadingMentorCourses &&
            courseProvider.mentorCourses.isEmpty &&
            (courseProvider.errorMentorCourses == null ||
                courseProvider.errorMentorCourses!.isEmpty)) {
          bodyContent = Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.school_outlined,
                  size: 60,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  "Henüz hiç ders eklenmemiş.",
                  style: TextStyle(fontSize: 17, color: Colors.grey.shade700),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: () => _openAddEditLessonModal(),
                  icon: const Icon(Icons.add),
                  label: const Text("İlk Dersi Ekle"),
                ),
              ],
            ),
          );
        } else if (!courseProvider.isLoadingMentorCourses &&
            courseProvider.errorMentorCourses != null &&
            courseProvider.errorMentorCourses!.isNotEmpty) {
          bodyContent = Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.red.shade300,
                    size: 50,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Bir Hata Oluştu",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade700,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    courseProvider.errorMentorCourses!,
                    style: TextStyle(color: Colors.red.shade600, fontSize: 15),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: () {
                      courseProvider.fetchMentorCourses();
                    },
                    child: const Text("Tekrar Dene"),
                  ),
                ],
              ),
            ),
          );
        } else if (filteredUiLessons.isEmpty && _searchTerm.isNotEmpty) {
          bodyContent = const Center(
            child: Text(
              "Arama sonucu bulunamadı.",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        } else if (filteredUiLessons.isNotEmpty) {
          bodyContent = RefreshIndicator(
            onRefresh: () => courseProvider.fetchMentorCourses(),
            color: Colors.orange,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 16.0,
              ),
              itemCount: filteredUiLessons.length,
              itemBuilder:
                  (ctx, index) => _buildLessonItem(
                    filteredUiLessons[index],
                    courseProvider.isSubmitting,
                  ),
              separatorBuilder:
                  (ctx, index) => Divider(
                    height: 30,
                    thickness: 0.5,
                    color: Colors.grey.shade300,
                  ),
            ),
          );
        } else {
          bodyContent = const Center(
            child: Text("Dersler yükleniyor veya bir sorun oluştu."),
          );
        }

        return Scaffold(
          backgroundColor: Colors.white,
          appBar:
              _isSelectionMode && _selectedLessonUI != null
                  ? AppBar(
                    backgroundColor: appBarBackground,
                    elevation: 0,
                    leading: IconButton(
                      icon: const Icon(Icons.close, color: textDark),
                      onPressed: _exitSelectionMode,
                    ),
                    title: Text(
                      _selectedLessonUI!.title,
                      style: const TextStyle(
                        color: textDark,
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    actions: [
                      IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          color: Colors.red[400],
                          size: 28,
                        ),
                        onPressed:
                            courseProvider.isSubmitting
                                ? null
                                : _deleteSelectedLesson,
                        tooltip: 'Sil',
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.edit_outlined,
                          color: textDark,
                          size: 26,
                        ),
                        onPressed:
                            courseProvider.isSubmitting
                                ? null
                                : () {
                                  if (_selectedLessonUI != null)
                                    _openAddEditLessonModal(
                                      lessonToEdit: _selectedLessonUI,
                                    );
                                },
                        tooltip: 'Düzenle',
                      ),
                      const SizedBox(width: 10),
                    ],
                  )
                  : AppBar(
                    backgroundColor: appBarBackground,
                    elevation: 0,
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back, color: textDark),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    title: const Text(
                      'Teknik Ders Yönetimi',
                      style: TextStyle(
                        color: textDark,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    centerTitle: false,
                    titleSpacing: 0,
                  ),
          body: Column(
            children: [
              _buildSearchBar(),
              if (courseProvider.isLoadingMentorCourses &&
                  allMentorUiCourses.isNotEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Center(
                    child: SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.orange,
                      ),
                    ),
                  ),
                ),
              Expanded(child: bodyContent),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed:
                courseProvider.isSubmitting ||
                        courseProvider.isLoadingMentorCourses
                    ? null
                    : () => _openAddEditLessonModal(),
            backgroundColor: fabColor,
            child:
                (courseProvider.isSubmitting ||
                        (courseProvider.isLoadingMentorCourses &&
                            allMentorUiCourses.isEmpty))
                    ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    )
                    : const Icon(Icons.add, color: Colors.white, size: 32),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.only(
        left: 20.0,
        right: 20.0,
        top: 16.0,
        bottom: 8.0,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Derslerde Ara...',
                hintStyle: const TextStyle(
                  color: searchInputHintColor,
                  fontSize: 16,
                ),
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: searchButtonColor, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
              style: const TextStyle(color: textDark, fontSize: 16),
            ),
          ),
          const SizedBox(width: 12),
          InkWell(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            borderRadius: BorderRadius.circular(28),
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: searchButtonColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(Icons.search, color: Colors.white, size: 28),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonItem(TechniqueLessonItem lesson, bool isSubmitting) {
    return InkWell(
      onTap: isSubmitting ? null : () => _onLessonLongPress(lesson),
      onLongPress: isSubmitting ? null : () => _onLessonLongPress(lesson),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CoverCardWidget(
              size: kUnifiedListItemCoverSize,
              borderRadius: kUnifiedListItemBorderRadius,
              imageNetworkPath: lesson.coverImagePath,
              gradient: lesson.coverImagePath == null ? lesson.gradient : null,
              imageAssetPath:
                  lesson.coverImagePath == null ? kDefaultCoverIconAsset : null,
              iconColor: lesson.coverImagePath == null ? Colors.white : null,
              iconOrImageSize: kUnifiedListItemCoverSize * 0.7,
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    lesson.title,
                    style: const TextStyle(
                      color: itemTitleColor,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 16,
                        color: iconColor,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        lesson.date,
                        style: const TextStyle(
                          fontSize: 13,
                          color: itemSubtitleColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Icon(
                        Icons.visibility_outlined,
                        size: 18,
                        color: iconColor,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        lesson.views,
                        style: const TextStyle(
                          fontSize: 13,
                          color: itemSubtitleColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
