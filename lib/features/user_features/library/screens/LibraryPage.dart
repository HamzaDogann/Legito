// lib/features/user_features/library/screens/LibraryPage.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared_widgets/content_card_widget.dart';
import '../../../../state_management/auth_provider.dart';
import '../../../../core/navigation/app_routes.dart';
import '../models/resource_enums.dart';
import '../state_management/library_provider.dart';

// LibraryBookItem UI modeli (API'den gelen ResourceResponseModel'den maplenir)
class LibraryBookItem {
  String id;
  Gradient gradient;
  UiResourceType? resourceType;
  String? author;
  String? resourceName;
  String? status;

  LibraryBookItem({
    required this.id,
    required this.gradient,
    this.resourceType,
    this.author,
    this.resourceName,
    this.status,
  });
}

class LibraryPage extends StatefulWidget {
  const LibraryPage({Key? key}) : super(key: key);

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  static const Color textDark = Color(0xFF1F2937);
  static const Color sectionTitleColor = Color(0xFF374151);
  static const Color newResourceButtonBackground = Color.fromARGB(
    255,
    35,
    35,
    35,
  );
  static const Color newResourceButtonTextColor = Colors.white;
  static const Color saveButtonColor = Color(0xFFFF8128);
  static const Color inputFillColor = Color(0xFFF3F4F6);
  static const Color cancelButtonColor = Color.fromARGB(255, 35, 35, 35);

  LibraryBookItem? _selectedBookForEditingAppBar;
  bool _isEditingModeAppBar = false;

  final _formKey = GlobalKey<FormState>();
  UiResourceType? _selectedUiResourceTypeInModal;
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _resourceNameController = TextEditingController();
  String? _selectedUiStatusInModal;

  final List<String> _uiStatusOptions = [
    statusCurrentlyReading,
    statusCompleted,
    statusToBeRead,
  ];
  final List<UiResourceType> _uiResourceTypeOptions = UiResourceType.values;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (!authProvider.isAuthenticated || !authProvider.isUser()) {
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.login,
            (route) => false,
          );
        }
      } else {
        Provider.of<LibraryProvider>(context, listen: false).fetchResources();
      }
    });
  }

  Gradient _getGradientForUiResourceType(UiResourceType? type) {
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
      default:
        return const LinearGradient(
          colors: [Color(0xFF4B5563), Color(0xFF6B7280)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  IconData _getIconForUiResourceType(UiResourceType? type) {
    switch (type) {
      case UiResourceType.book:
        return Icons.menu_book_rounded;
      case UiResourceType.journal:
        return Icons.article_outlined;
      case UiResourceType.article:
        return Icons.description_outlined;
      case UiResourceType.blog:
        return Icons.web_asset_outlined;
      case UiResourceType.encyclopedia:
        return Icons.shelves;
      case UiResourceType.other:
      default:
        return Icons.notes_rounded;
    }
  }

  void _onBookLongPress(LibraryBookItem book) {
    setState(() {
      _selectedBookForEditingAppBar = book;
      _isEditingModeAppBar = true;
    });
  }

  void _exitEditingModeAppBar() {
    setState(() {
      _selectedBookForEditingAppBar = null;
      _isEditingModeAppBar = false;
    });
  }

  void _deleteSelectedBookFromAppBar() {
    if (_selectedBookForEditingAppBar != null) {
      showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          // Farklı context adı
          return AlertDialog(
            title: const Text("Kaynağı Sil"),
            content: Text(
              "'${_selectedBookForEditingAppBar!.resourceName ?? "Bu kaynak"}' silinecek. Emin misiniz?",
            ),
            actions: <Widget>[
              TextButton(
                child: const Text("İptal"),
                onPressed: () => Navigator.of(dialogContext).pop(),
              ),
              TextButton(
                child: const Text("Sil", style: TextStyle(color: Colors.red)),
                onPressed: () async {
                  Navigator.of(dialogContext).pop();
                  final success = await Provider.of<LibraryProvider>(
                    context,
                    listen: false,
                  ) // Ana context
                  .deleteResource(_selectedBookForEditingAppBar!.id);
                  if (mounted) {
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Kaynak silindi.")),
                      );
                      _exitEditingModeAppBar();
                    } else {
                      final errorMsg =
                          Provider.of<LibraryProvider>(
                            context,
                            listen: false,
                          ).errorMessage;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "Silme hatası: ${errorMsg ?? 'Bilinmeyen hata'}",
                          ),
                        ),
                      );
                    }
                  }
                },
              ),
            ],
          );
        },
      );
    }
  }

  void _openAddEditModal({LibraryBookItem? bookToEdit}) {
    bool isEditing = bookToEdit != null;
    if (isEditing) {
      _selectedUiResourceTypeInModal =
          bookToEdit.resourceType ?? _uiResourceTypeOptions[0];
      _authorController.text = bookToEdit.author ?? '';
      _resourceNameController.text = bookToEdit.resourceName ?? '';
      _selectedUiStatusInModal = bookToEdit.status ?? _uiStatusOptions[0];
    } else {
      _selectedUiResourceTypeInModal = _uiResourceTypeOptions[0];
      _authorController.clear();
      _resourceNameController.clear();
      _selectedUiStatusInModal = _uiStatusOptions[0];
    }

    showModalBottomSheet(
      context: context, // Ana context
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (BuildContext modalContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter modalSetState) {
            // Bu context modal'ın kendi context'i
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
                      const SizedBox(height: 20),
                      const Padding(
                        padding: EdgeInsets.only(top: 8.0, bottom: 4.0),
                        child: Text(
                          "Kaynak Türü",
                          style: TextStyle(
                            color: textDark,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: inputFillColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonFormField<UiResourceType>(
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                          ),
                          value: _selectedUiResourceTypeInModal,
                          dropdownColor: Colors.white,
                          items:
                              _uiResourceTypeOptions
                                  .map(
                                    (UiResourceType type) =>
                                        DropdownMenuItem<UiResourceType>(
                                          value: type,
                                          child: Text(
                                            getResourceTypeUIName(type),
                                          ),
                                        ),
                                  )
                                  .toList(),
                          onChanged:
                              (newValue) => modalSetState(
                                () => _selectedUiResourceTypeInModal = newValue,
                              ),
                          validator:
                              (value) =>
                                  value == null ? 'Kaynak türü seçiniz' : null,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildFormTextField("Yazar", _authorController),
                      _buildFormTextField(
                        "Kaynak Adı",
                        _resourceNameController,
                        isRequired: true,
                      ),
                      const Padding(
                        padding: EdgeInsets.only(top: 8.0, bottom: 4.0),
                        child: Text(
                          "Durumu",
                          style: TextStyle(
                            color: textDark,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: inputFillColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                          ),
                          value: _selectedUiStatusInModal,
                          dropdownColor: Colors.white,
                          items:
                              _uiStatusOptions
                                  .map(
                                    (String value) => DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    ),
                                  )
                                  .toList(),
                          onChanged:
                              (newValue) => modalSetState(
                                () => _selectedUiStatusInModal = newValue,
                              ),
                          validator:
                              (value) => value == null ? 'Durum seçiniz' : null,
                        ),
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
                                  final libraryProvider =
                                      Provider.of<LibraryProvider>(
                                        this.context,
                                        listen: false,
                                      ); // Ana context
                                  bool success;
                                  if (isEditing && bookToEdit != null) {
                                    success = await libraryProvider
                                        .updateResource(
                                          resourceId: bookToEdit.id,
                                          name:
                                              _resourceNameController.text
                                                  .trim(),
                                          author:
                                              _authorController.text
                                                      .trim()
                                                      .isEmpty
                                                  ? null
                                                  : _authorController.text
                                                      .trim(),
                                          uiResourceType:
                                              _selectedUiResourceTypeInModal!,
                                          uiStatus: _selectedUiStatusInModal!,
                                        );
                                  } else {
                                    success = await libraryProvider.addResource(
                                      name: _resourceNameController.text.trim(),
                                      author:
                                          _authorController.text.trim().isEmpty
                                              ? null
                                              : _authorController.text.trim(),
                                      uiResourceType:
                                          _selectedUiResourceTypeInModal!,
                                      uiStatus: _selectedUiStatusInModal!,
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
                                                ? "Kaynak güncellendi."
                                                : "Kaynak eklendi.",
                                          ),
                                        ),
                                      );
                                      if (_isEditingModeAppBar)
                                        _exitEditingModeAppBar();
                                    } else {
                                      final errorMsg =
                                          libraryProvider.errorMessage;
                                      ScaffoldMessenger.of(
                                        this.context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            isEditing
                                                ? "Güncelleme hatası: ${errorMsg ?? ''}"
                                                : "Ekleme hatası: ${errorMsg ?? ''}",
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
                              child: const Text(
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
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFormTextField(
    String label,
    TextEditingController controller, {
    bool isRequired = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
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
                            ? '$label alanı boş bırakılamaz'
                            : null
                    : null,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated || !authProvider.isUser()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.login,
            (route) => false,
          );
        }
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.orange)),
      );
    }

    return Consumer<LibraryProvider>(
      builder: (context, libraryProvider, child) {
        if (libraryProvider.isLoading &&
            libraryProvider.currentlyReading.isEmpty &&
            libraryProvider.completedBooks.isEmpty &&
            libraryProvider.toBeReadBooks.isEmpty) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Kitaplığım'),
              centerTitle: false,
              titleSpacing: 0,
            ),
            body: const Center(
              child: CircularProgressIndicator(color: Colors.orange),
            ),
          );
        }

        return Scaffold(
          backgroundColor: Colors.white,
          appBar:
              _isEditingModeAppBar
                  ? AppBar(
                    leading: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: _exitEditingModeAppBar,
                    ),
                    title: Text(
                      _selectedBookForEditingAppBar?.resourceName ??
                          'Kaynağı Düzenle',
                      overflow: TextOverflow.ellipsis,
                    ),
                    actions: [
                      IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          color: Theme.of(context).colorScheme.error,
                          size: 26,
                        ),
                        onPressed: _deleteSelectedBookFromAppBar,
                        tooltip: 'Sil',
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 26),
                        onPressed: () {
                          if (_selectedBookForEditingAppBar != null)
                            _openAddEditModal(
                              bookToEdit: _selectedBookForEditingAppBar,
                            );
                        },
                        tooltip: 'Düzenle',
                      ),
                      const SizedBox(width: 10),
                    ],
                  )
                  : AppBar(
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        if (Navigator.canPop(context))
                          Navigator.of(context).pop();
                        else
                          Navigator.pushReplacementNamed(
                            context,
                            AppRoutes.publicHome,
                          );
                      },
                    ),
                    title: const Text('Kitaplığım'),
                    centerTitle: false,
                    titleSpacing: 0,
                  ),
          body: Stack(
            children: [
              RefreshIndicator(
                onRefresh: () => libraryProvider.fetchResources(),
                color: Colors.orange,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(
                    left: 20.0,
                    right: 20.0,
                    top: 24.0,
                    bottom: 90.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (libraryProvider.isLoading &&
                          (libraryProvider.currentlyReading.isNotEmpty ||
                              libraryProvider.completedBooks.isNotEmpty ||
                              libraryProvider.toBeReadBooks.isNotEmpty))
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.orange,
                              ),
                            ),
                          ),
                        ),

                      _buildBookListSection(
                        "Şuan Okunanlar",
                        libraryProvider.currentlyReading,
                        libraryProvider,
                      ),
                      const SizedBox(height: 30),
                      _buildBookListSection(
                        "Tamamlananlar",
                        libraryProvider.completedBooks,
                        libraryProvider,
                      ),
                      const SizedBox(height: 30),
                      _buildBookListSection(
                        "Okunacaklar",
                        libraryProvider.toBeReadBooks,
                        libraryProvider,
                      ),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(
                    bottom: 20.0,
                    left: 20.0,
                    right: 20.0,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          libraryProvider.isLoading
                              ? null
                              : () =>
                                  _openAddEditModal(), // Yüklenirken butonu devre dışı bırak
                      style: ElevatedButton.styleFrom(
                        backgroundColor: newResourceButtonBackground,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                      ),
                      child:
                          libraryProvider.isLoading &&
                                  libraryProvider.currentlyReading.isEmpty &&
                                  libraryProvider.completedBooks.isEmpty &&
                                  libraryProvider.toBeReadBooks.isEmpty
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                              : const Text(
                                'Yeni Kaynak Ekle',
                                style: TextStyle(
                                  color: newResourceButtonTextColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBookListSection(
    String title,
    List<LibraryBookItem> items,
    LibraryProvider provider,
  ) {
    const double horizontalListHeight = ContentCardWidget.cardHeight + 10;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: sectionTitleColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        if (items.isEmpty && !provider.isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20.0),
            child: Center(
              child: Text(
                "Bu rafta henüz kaynak yok.",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        else if (items.isEmpty && provider.isLoading)
          SizedBox(
            height: horizontalListHeight,
            child: Center(
              child: CircularProgressIndicator(color: Colors.orange[600]),
            ),
          )
        else
          SizedBox(
            height: horizontalListHeight,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              itemBuilder: (context, index) {
                final book = items[index];
                return Padding(
                  padding: EdgeInsets.only(
                    right: index == items.length - 1 ? 0 : 12.0,
                  ),
                  child: ContentCardWidget(
                    gradient: _getGradientForUiResourceType(book.resourceType),
                    iconData: _getIconForUiResourceType(book.resourceType),
                    title: book.resourceName ?? "Başlık Yok",
                    subtitlePrefix: "Yazar: ",
                    subtitleText:
                        (book.author != null && book.author!.isNotEmpty)
                            ? book.author
                            : "Yok",
                    onTap:
                        provider.isLoading
                            ? null
                            : () => _onBookLongPress(
                              book,
                            ), // Yüklenirken tap'ı engelle
                    onLongPress:
                        provider.isLoading
                            ? null
                            : () => _onBookLongPress(
                              book,
                            ), // Yüklenirken long press'i engelle
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

// Bu fonksiyonu sayfanın dışına veya bir utility dosyasına taşıyabilirsiniz.
String getResourceTypeUIName(UiResourceType type) {
  switch (type) {
    case UiResourceType.book:
      return "Kitap";
    case UiResourceType.journal:
      return "Dergi";
    case UiResourceType.article:
      return "Makale";
    case UiResourceType.blog:
      return "Blog Yazısı";
    case UiResourceType.encyclopedia:
      return "Ansiklopedi";
    case UiResourceType.other:
      return "Diğer";
  }
}
