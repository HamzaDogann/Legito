import 'package:flutter/material.dart';
import 'dart:io'; // File işlemleri için
import 'package:image_picker/image_picker.dart';

import '../../../../shared_widgets/cover_card_widget.dart'; // Resim seçici
// CoverCardWidget importu

// --- YENİ ORTAK SABİTLER ---
const double kUnifiedListItemCoverSize = 80.0;
const BorderRadius kUnifiedListItemBorderRadius = BorderRadius.all(
  Radius.circular(12.0),
);
// --- ---

// Teknik ders öğesini temsil edecek model
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
  const TechniquesLessonPage({super.key});

  @override
  State<TechniquesLessonPage> createState() => _TechniquesLessonPageState();
}

class _TechniquesLessonPageState extends State<TechniquesLessonPage> {
  // Renkler ve Sabitler
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

  static const Gradient gradientRed = LinearGradient(
    colors: [Color(0xFFFA8072), Color(0xFFEF4444)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const Gradient gradientPurple = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const Gradient gradientGreen = LinearGradient(
    colors: [Color(0xFF34D399), Color(0xFF10B981)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const Gradient gradientDarkGrey = LinearGradient(
    colors: [Color(0xFF4B5563), Color(0xFF374151)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  final List<Gradient> _availableGradients = [
    gradientRed,
    gradientPurple,
    gradientGreen,
    gradientDarkGrey,
  ];

  // ESKİ SABİTLER KALDIRILDI veya YORUMA ALINDI
  // static const double kLessonItemCoverSize = 85.0;
  // static const BorderRadius kLessonItemBorderRadius =
  //     BorderRadius.all(Radius.circular(16.0));

  // Modal için olanlar farklı kalabilir, isteğe bağlı olarak birleştirilebilir.
  static const double kModalCoverSize = 120.0;
  static const BorderRadius kModalCoverBorderRadius = BorderRadius.all(
    Radius.circular(12.0),
  );
  static const String kDefaultCoverIconAsset = 'assets/images/BookIcon.png';

  List<TechniqueLessonItem> _lessons = [];
  List<TechniqueLessonItem> _filteredLessons = [];
  String _searchTerm = '';

  TechniqueLessonItem? _selectedLesson;
  bool _isSelectionMode = false;

  final TextEditingController _searchController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _videoUrlController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  File? _selectedCoverImageFile;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadInitialLessons();
    _filteredLessons = List.from(_lessons);
    _searchController.addListener(() {
      setState(() {
        _searchTerm = _searchController.text;
        _filterLessons();
      });
    });
  }

  Gradient _getRandomGradient() {
    return _availableGradients[DateTime.now().millisecondsSinceEpoch %
        _availableGradients.length];
  }

  void _loadInitialLessons() {
    _lessons = [
      TechniqueLessonItem(
        id: 'l1',
        gradient: gradientRed,
        title: "Etkili Okuma Yöntemi ile Anlama Kapasitenizi Artırın",
        date: "11 Mayıs 2025",
        views: "110B",
        videoUrl: "https://example.com/video1.mp4",
        description: "Bu derste etkili okuma tekniklerini öğreneceksiniz.",
      ),
      TechniqueLessonItem(
        id: 'l2',
        gradient: gradientPurple,
        title: "Zihin Haritalama Teknikleri ve Uygulamaları",
        date: "12 Mayıs 2025",
        views: "230B",
        videoUrl: "https://example.com/video2.mp4",
        description: "Zihin haritaları ile not alma ve öğrenme.",
      ),
      TechniqueLessonItem(
        id: 'l3',
        gradient: gradientGreen,
        title: "Hızlı Not Alma Stratejileri",
        date: "13 Mayıs 2025",
        views: "85B",
      ),
    ];
  }

  void _filterLessons() {
    if (_searchTerm.isEmpty) {
      _filteredLessons = List.from(_lessons);
    } else {
      _filteredLessons =
          _lessons
              .where(
                (lesson) => lesson.title.toLowerCase().contains(
                  _searchTerm.toLowerCase(),
                ),
              )
              .toList();
    }
  }

  void _onLessonLongPress(TechniqueLessonItem lesson) {
    setState(() {
      _selectedLesson = lesson;
      _isSelectionMode = true;
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _selectedLesson = null;
      _isSelectionMode = false;
    });
  }

  void _deleteSelectedLesson() {
    if (_selectedLesson != null) {
      showDialog(
        context: context,
        builder:
            (BuildContext context) => AlertDialog(
              title: Text("Dersi Sil"),
              content: Text(
                "'${_selectedLesson!.title}' dersi silinecek. Emin misiniz?",
              ),
              actions: <Widget>[
                TextButton(
                  child: Text("İptal"),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: Text("Sil", style: TextStyle(color: Colors.red)),
                  onPressed: () {
                    Navigator.of(context).pop();
                    setState(() {
                      _lessons.removeWhere((l) => l.id == _selectedLesson!.id);
                      _filterLessons();
                      _exitSelectionMode();
                    });
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text("Ders silindi.")));
                  },
                ),
              ],
            ),
      );
    }
  }

  Future<void> _pickImage(ImageSource source, StateSetter modalSetState) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 70,
      );
      if (pickedFile != null) {
        modalSetState(() {
          _selectedCoverImageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      print("Resim seçme hatası: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Resim seçilemedi.")));
    }
  }

  void _removeCoverImage(StateSetter modalSetState) {
    modalSetState(() {
      _selectedCoverImageFile = null;
    });
  }

  void _openAddEditLessonModal({TechniqueLessonItem? lessonToEdit}) {
    bool isEditing = lessonToEdit != null;
    _selectedCoverImageFile = null;

    if (isEditing) {
      _videoUrlController.text = lessonToEdit!.videoUrl ?? '';
      _titleController.text = lessonToEdit.title;
      _descriptionController.text = lessonToEdit.description ?? '';
    } else {
      _videoUrlController.clear();
      _titleController.clear();
      _descriptionController.clear();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (BuildContext modalContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter modalSetState) {
            File? imageFileToShowInModal;
            String? imagePathFromLesson;
            bool showDefaultCoverInModal = true;

            if (_selectedCoverImageFile != null &&
                _selectedCoverImageFile!.existsSync()) {
              imageFileToShowInModal = _selectedCoverImageFile;
              showDefaultCoverInModal = false;
            } else if (isEditing &&
                lessonToEdit?.coverImagePath != null &&
                File(lessonToEdit!.coverImagePath!).existsSync()) {
              imageFileToShowInModal = File(lessonToEdit!.coverImagePath!);
              showDefaultCoverInModal = false;
            }

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
                    children: <Widget>[
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
                      SizedBox(height: 25),
                      Center(
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            GestureDetector(
                              onTap:
                                  () => _showImageSourceActionSheet(
                                    modalContext,
                                    modalSetState,
                                  ),
                              child: CoverCardWidget(
                                size: kModalCoverSize,
                                borderRadius: kModalCoverBorderRadius,
                                imageFile: imageFileToShowInModal,
                                gradient:
                                    showDefaultCoverInModal
                                        ? gradientRed
                                        : null,
                                imageAssetPath:
                                    showDefaultCoverInModal
                                        ? kDefaultCoverIconAsset
                                        : null,
                                iconColor:
                                    showDefaultCoverInModal
                                        ? Colors.white
                                        : null,
                                iconOrImageSize: kModalCoverSize * 0.6,
                              ),
                            ),
                            if (!showDefaultCoverInModal)
                              Positioned(
                                right: -8,
                                top: -8,
                                child: InkWell(
                                  onTap: () => _removeCoverImage(modalSetState),
                                  child: Container(
                                    padding: EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.red[400],
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
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
                                      () => _showImageSourceActionSheet(
                                        modalContext,
                                        modalSetState,
                                      ),
                                  child: Container(
                                    padding: EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: coverEditIconBg,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 4,
                                          offset: Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
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
                      SizedBox(height: 25),
                      _buildFormTextField("Video URL", _videoUrlController),
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
                      SizedBox(height: 25),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => Navigator.pop(modalContext),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: cancelButtonColor,
                                padding: EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                'Vazgeç',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  _saveOrUpdateLesson(lessonToEdit);
                                  Navigator.pop(modalContext);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: saveButtonColor,
                                padding: EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                'Kaydet',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    ).then((_) {
      setState(() {
        _selectedCoverImageFile = null;
      });
    });
  }

  void _showImageSourceActionSheet(
    BuildContext modalContext,
    StateSetter modalSetState,
  ) {
    showModalBottomSheet(
      context: modalContext,
      builder: (BuildContext bContext) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Galeriden Seç'),
                onTap: () {
                  _pickImage(ImageSource.gallery, modalSetState);
                  Navigator.of(bContext).pop();
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_camera),
                title: Text('Kameradan Çek'),
                onTap: () {
                  _pickImage(ImageSource.camera, modalSetState);
                  Navigator.of(bContext).pop();
                },
              ),
            ],
          ),
        );
      },
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
            style: TextStyle(
              color: textDark,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          SizedBox(height: 6),
          TextFormField(
            controller: controller,
            style: TextStyle(color: textDark),
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
              contentPadding: EdgeInsets.symmetric(
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

  void _saveOrUpdateLesson(TechniqueLessonItem? existingLesson) {
    setState(() {
      String? finalCoverImagePath;
      if (_selectedCoverImageFile != null) {
        finalCoverImagePath = _selectedCoverImageFile!.path;
      } else if (existingLesson != null) {
        // Yeni resim seçilmedi ama düzenleme modundayız.
        // Eğer kullanıcı resmi kaldırmadıysa (yani _removeCoverImage çağrılmadıysa
        // ve dolayısıyla _selectedCoverImageFile null değilse),
        // eski resmi korumalıyız.
        // Ancak _selectedCoverImageFile zaten null ise, bu durumda resim ya hiç yoktu
        // ya da kaldırıldı demektir.
        finalCoverImagePath =
            existingLesson.coverImagePath; // Eski resmi koru (eğer varsa)
        // Eğer _selectedCoverImageFile null ise (yani modal'da resim yok veya silindi)
        // ve mevcut dersin bir resmi varsa, bu yolun silinmesi gerekir.
        // Bu mantık _openAddEditLessonModal içindeki _selectedCoverImageFile'ın
        // nasıl yönetildiğine bağlı. Eğer _removeCoverImage çağrıldığında _selectedCoverImageFile null
        // oluyorsa ve kullanıcı kaydederse, existingLesson.coverImagePath'in de null olması gerekir.
        // Şu anki kodda, _selectedCoverImageFile null ise, finalCoverImagePath = null olur.
        // Eğer kullanıcı var olan resmi silip kaydederse, _selectedCoverImageFile null olacak.
        // Bu durumda existingLesson.coverImagePath'i de null yapmalıyız.
        if (_selectedCoverImageFile == null &&
            existingLesson.coverImagePath != null) {
          // Bu durum, kullanıcının modalda resmi sildiği anlamına gelebilir
          // VEYA yeni resim seçmediği anlamına gelebilir.
          // Eğer modalda resim silindiyse (selectedCoverImageFile null olduysa)
          // finalCoverImagePath'in null olması gerekir.
          // Eğer sadece yeni resim seçilmediyse ve eskisi varsa o kalmalı.
          // Bu mantığı netleştirmek için, _removeCoverImage içinde bir flag tutulabilir
          // ya da _selectedCoverImageFile null olduğunda ve isEditing olduğunda
          // finalCoverImagePath'e eski değeri değil null ataması yapılır.
          // Şimdilik, _selectedCoverImageFile null ise resim yok kabul edelim.
          finalCoverImagePath = null;
        } else if (_selectedCoverImageFile == null &&
            existingLesson.coverImagePath == null) {
          finalCoverImagePath = null;
        } else if (_selectedCoverImageFile == null &&
            existingLesson.coverImagePath != null) {
          // Yeni resim seçilmedi, eski resim var, onu koru
          finalCoverImagePath = existingLesson.coverImagePath;
        }
      }

      if (existingLesson != null) {
        existingLesson.title = _titleController.text.trim();
        existingLesson.videoUrl = _videoUrlController.text.trim();
        existingLesson.description = _descriptionController.text.trim();
        existingLesson.coverImagePath = finalCoverImagePath;
      } else {
        final newLesson = TechniqueLessonItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          gradient: _getRandomGradient(),
          title: _titleController.text.trim(),
          date:
              "${DateTime.now().day} ${ayAdi(DateTime.now().month)} ${DateTime.now().year}",
          views: "0B",
          videoUrl: _videoUrlController.text.trim(),
          description: _descriptionController.text.trim(),
          coverImagePath: finalCoverImagePath,
        );
        _lessons.add(newLesson);
      }
      _filterLessons();
      if (_isSelectionMode && existingLesson != null) _exitSelectionMode();
      _selectedCoverImageFile = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          existingLesson != null ? "Ders güncellendi." : "Ders eklendi.",
        ),
      ),
    );
  }

  String ayAdi(int month) {
    const aylar = [
      "Ocak",
      "Şubat",
      "Mart",
      "Nisan",
      "Mayıs",
      "Haziran",
      "Temmuz",
      "Ağustos",
      "Eylül",
      "Ekim",
      "Kasım",
      "Aralık",
    ];
    return aylar[month - 1];
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar:
          _isSelectionMode && _selectedLesson != null
              ? AppBar(
                backgroundColor: appBarBackground,
                elevation: 0,
                leading: IconButton(
                  icon: Icon(Icons.close, color: textDark),
                  onPressed: _exitSelectionMode,
                ),
                title: Text(
                  _selectedLesson!.title,
                  style: TextStyle(
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
                    onPressed: _deleteSelectedLesson,
                    tooltip: 'Sil',
                  ),
                  IconButton(
                    icon: Icon(Icons.edit_outlined, color: textDark, size: 26),
                    onPressed: () {
                      if (_selectedLesson != null) {
                        _openAddEditLessonModal(lessonToEdit: _selectedLesson);
                      }
                    },
                    tooltip: 'Düzenle',
                  ),
                  SizedBox(width: 10),
                ],
              )
              : AppBar(
                backgroundColor: appBarBackground,
                elevation: 0,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back, color: textDark),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                title: Text(
                  'Teknik Ders',
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
          Expanded(
            child:
                _filteredLessons.isEmpty && _searchTerm.isNotEmpty
                    ? Center(
                      child: Text(
                        "Arama sonucu bulunamadı.",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    )
                    : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 16.0,
                      ),
                      itemCount: _filteredLessons.length,
                      itemBuilder: (context, index) {
                        final lesson = _filteredLessons[index];
                        return _buildLessonItem(lesson);
                      },
                      separatorBuilder:
                          (context, index) => Divider(
                            height: 30,
                            thickness: 0.5,
                            color: Colors.grey.shade300,
                          ),
                    ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddEditLessonModal(),
        backgroundColor: fabColor,
        child: Icon(Icons.add, color: Colors.white, size: 32),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
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
                hintText: 'Tekniklerde Ara...',
                hintStyle: TextStyle(color: searchInputHintColor, fontSize: 16),
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: searchButtonColor, width: 1.5),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
              style: TextStyle(color: textDark, fontSize: 16),
            ),
          ),
          SizedBox(width: 12),
          InkWell(
            onTap: () {
              _filterLessons();
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
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Icon(Icons.search, color: Colors.white, size: 28),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonItem(TechniqueLessonItem lesson) {
    File? coverImageFile;
    bool useDefaultCover = true;

    if (lesson.coverImagePath != null &&
        File(lesson.coverImagePath!).existsSync()) {
      coverImageFile = File(lesson.coverImagePath!);
      useDefaultCover = false;
    }

    return InkWell(
      onTap: () {
        _onLessonLongPress(lesson);
      },
      onLongPress: () => _onLessonLongPress(lesson),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CoverCardWidget(
              size: kUnifiedListItemCoverSize, // <<< DEĞİŞTİ
              borderRadius:
                  kUnifiedListItemBorderRadius, // <<< DEĞİŞTİ (veya kLessonItemBorderRadius'u kUnifiedListItemBorderRadius ile aynı değere ayarlayın)
              imageFile: coverImageFile,
              gradient: useDefaultCover ? lesson.gradient : null,
              imageAssetPath: useDefaultCover ? kDefaultCoverIconAsset : null,
              iconColor: useDefaultCover ? Colors.white : null,
              iconOrImageSize:
                  kUnifiedListItemCoverSize * 0.7, // Boyuta göre orantılı
            ),
            SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    lesson.title,
                    style: TextStyle(
                      color: itemTitleColor,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 16,
                        color: iconColor,
                      ),
                      SizedBox(width: 5),
                      Text(
                        lesson.date,
                        style: TextStyle(
                          fontSize: 13,
                          color: itemSubtitleColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 14),
                      Icon(
                        Icons.visibility_outlined,
                        size: 18,
                        color: iconColor,
                      ),
                      SizedBox(width: 5),
                      Text(
                        lesson.views,
                        style: TextStyle(
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
