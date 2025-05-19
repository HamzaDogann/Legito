// lib/features/mentor_features/tips_mentor/screens/TipsPage.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared_widgets/cover_card_widget.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../state_management/auth_provider.dart';
import '../state_management/tip_provider.dart';
import '../models/tip_response_dto.dart';
import '../models/tip_enums.dart';

class TipItemUI {
  String id;
  String title;
  String content;
  String animalIconPath;
  Gradient gradient;
  int apiAvatarIndex;
  TipItemUI({
    required this.id,
    required this.title,
    required this.content,
    required this.animalIconPath,
    required this.gradient,
    required this.apiAvatarIndex,
  });
}

class TipsPage extends StatefulWidget {
  const TipsPage({Key? key}) : super(key: key);
  @override
  State<TipsPage> createState() => _TipsPageState();
}

class _TipsPageState extends State<TipsPage> {
  static const Color appBarBackground = Color(0xFFF4F6F9);
  static const Color textDark = Color.fromARGB(255, 36, 36, 36);
  static const Color searchButtonColor = Color(0xFFFF8128);
  static const Color searchInputHintColor = Color(0xFF9CA3AF);
  static const Color fabColor = Color(0xFFFF8128);
  static const Color itemTitleColor = Color.fromARGB(255, 36, 36, 36);
  static const Color itemContentColor = Color.fromARGB(255, 80, 80, 80);
  static const Color inputFillColor = Color(0xFFF3F4F6);
  static const Color saveButtonColor = Color(0xFFFF8128);
  static const Color cancelButtonColor = Color.fromARGB(255, 36, 36, 36);
  static const Color animalIconCircleBg = Color(0xFFE5E7EB);
  static const Color activeAnimalIconCircleBg = Color(0xFF374151);
  static const double kUnifiedListItemCoverSize = 80.0;
  static const BorderRadius kUnifiedListItemBorderRadius = BorderRadius.all(
    Radius.circular(12.0),
  );
  final List<Gradient> _availableCardGradients = const [
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
  final List<String> _animalIconPaths = const [
    'assets/images/cow.png',
    'assets/images/tiger.png',
    'assets/images/dog_tip.png',
    'assets/images/bird.png',
    'assets/images/bunny.png',
  ];

  String _searchTerm = '';
  TipItemUI? _selectedTipUI;
  bool _isSelectionMode = false;
  final TextEditingController _searchController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  int _selectedAnimalIconIndexInModal = 2;
  PageController? _animalPageController;

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
        Provider.of<TipProvider>(context, listen: false).fetchUserTips();
      }
    });
    _searchController.addListener(() {
      if (mounted)
        setState(() {
          _searchTerm = _searchController.text;
        });
    });
  }

  String _getAnimalIconPathFromApiIndex(int apiIndex) {
    if (apiIndex >= 0 && apiIndex < _animalIconPaths.length)
      return _animalIconPaths[apiIndex];
    return _animalIconPaths[2];
  }

  Gradient _getRandomCardGradient(String idBasedSeed) {
    return _availableCardGradients[idBasedSeed.hashCode %
        _availableCardGradients.length];
  }

  void _onTipLongPress(TipItemUI tip) => setState(() {
    _selectedTipUI = tip;
    _isSelectionMode = true;
  });
  void _exitSelectionMode() => setState(() {
    _selectedTipUI = null;
    _isSelectionMode = false;
  });

  void _deleteSelectedTip() {
    if (_selectedTipUI == null) return;
    showDialog(
      context: context,
      builder:
          (BuildContext dCtx) => AlertDialog(
            title: const Text("İpucunu Sil"),
            content: Text("'${_selectedTipUI!.title}' silinecek?"),
            actions: [
              TextButton(
                child: const Text("İptal"),
                onPressed: () => Navigator.of(dCtx).pop(),
              ),
              TextButton(
                child: const Text("Sil", style: TextStyle(color: Colors.red)),
                onPressed: () async {
                  Navigator.of(dCtx).pop();
                  final tp = Provider.of<TipProvider>(context, listen: false);
                  final success = await tp.deleteTip(_selectedTipUI!.id);
                  if (mounted) {
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("İpucu silindi.")),
                      );
                      _exitSelectionMode();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "Hata: ${tp.errorMessage ?? 'Bilinmeyen bir sorun.'}",
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

  void _openAddEditTipModal({TipItemUI? tipToEdit}) {
    bool isEditing = tipToEdit != null;
    if (isEditing) {
      _titleController.text = tipToEdit!.title;
      _contentController.text = tipToEdit.content;
      _selectedAnimalIconIndexInModal = tipToEdit.apiAvatarIndex;
    } else {
      _titleController.clear();
      _contentController.clear();
      _selectedAnimalIconIndexInModal = 2;
    }
    _animalPageController = PageController(
      initialPage: _selectedAnimalIconIndexInModal,
      viewportFraction: 0.25,
    );
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (BuildContext mCtx) {
        return StatefulBuilder(
          builder: (BuildContext ssbCtx, StateSetter mSetState) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_animalPageController!.hasClients &&
                  _animalPageController!.page?.round() !=
                      _selectedAnimalIconIndexInModal) {
                _animalPageController!.jumpToPage(
                  _selectedAnimalIconIndexInModal,
                );
              }
            });
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(mCtx).viewInsets.bottom,
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
                      const SizedBox(height: 25),
                      SizedBox(
                        height: 100,
                        child: PageView.builder(
                          controller: _animalPageController,
                          itemCount: _animalIconPaths.length,
                          onPageChanged:
                              (index) => mSetState(
                                () => _selectedAnimalIconIndexInModal = index,
                              ),
                          itemBuilder: (pctx, index) {
                            bool isActive =
                                index == _selectedAnimalIconIndexInModal;
                            return AnimatedScale(
                              scale: isActive ? 1.2 : 0.8,
                              duration: const Duration(milliseconds: 200),
                              child: Center(
                                child: CircleAvatar(
                                  radius: isActive ? 35 : 28,
                                  backgroundColor:
                                      isActive
                                          ? activeAnimalIconCircleBg
                                          : animalIconCircleBg,
                                  child: Padding(
                                    padding: EdgeInsets.all(isActive ? 6 : 4),
                                    child: Image.asset(
                                      _animalIconPaths[index],
                                      width: isActive ? 60 : 45,
                                      height: isActive ? 60 : 45,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 25),
                      _buildFormTextField(
                        "Başlık",
                        _titleController,
                        isRequired: true,
                      ),
                      _buildFormTextField(
                        "İçerik",
                        _contentController,
                        isRequired: true,
                        maxLines: 4,
                      ),
                      const SizedBox(height: 25),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => Navigator.pop(mCtx),
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
                                  final tp = Provider.of<TipProvider>(
                                    context,
                                    listen: false,
                                  );
                                  bool success;
                                  if (isEditing && tipToEdit != null) {
                                    success = await tp.updateTip(
                                      tipId: tipToEdit.id,
                                      title: _titleController.text.trim(),
                                      content: _contentController.text.trim(),
                                      apiAvatarIndex:
                                          _selectedAnimalIconIndexInModal,
                                    );
                                  } else {
                                    success = await tp.createTip(
                                      title: _titleController.text.trim(),
                                      content: _contentController.text.trim(),
                                      apiAvatarIndex:
                                          _selectedAnimalIconIndexInModal,
                                    );
                                  }
                                  Navigator.pop(mCtx);
                                  if (mounted) {
                                    if (success) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            isEditing
                                                ? "İpucu güncellendi."
                                                : "İpucu oluşturuldu.",
                                          ),
                                        ),
                                      );
                                      if (_isSelectionMode)
                                        _exitSelectionMode();
                                    } else {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            isEditing
                                                ? "Güncelleme hatası: ${tp.errorMessage ?? 'Bilinmeyen sorun.'}"
                                                : "Oluşturma hatası: ${tp.errorMessage ?? 'Bilinmeyen sorun.'}",
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
    _titleController.dispose();
    _contentController.dispose();
    _animalPageController?.dispose();
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

    return Consumer<TipProvider>(
      builder: (context, tipProvider, child) {
        final List<TipItemUI> allUiTips =
            tipProvider.mentorTips
                .map(
                  (dto) => TipItemUI(
                    id: dto.id,
                    title: dto.title,
                    content: dto.content,
                    animalIconPath: _getAnimalIconPathFromApiIndex(dto.avatar),
                    gradient: _getRandomCardGradient(dto.id),
                    apiAvatarIndex: dto.avatar,
                  ),
                )
                .toList();

        List<TipItemUI> filteredTipsUI;
        if (_searchTerm.isEmpty) {
          filteredTipsUI = allUiTips;
        } else {
          filteredTipsUI =
              allUiTips
                  .where(
                    (tip) =>
                        tip.title.toLowerCase().contains(
                          _searchTerm.toLowerCase(),
                        ) ||
                        tip.content.toLowerCase().contains(
                          _searchTerm.toLowerCase(),
                        ),
                  )
                  .toList();
        }

        Widget bodyContent;

        if (tipProvider.isLoading && allUiTips.isEmpty) {
          bodyContent = const Center(
            child: CircularProgressIndicator(color: Colors.orange),
          );
        } else if (!tipProvider.isLoading &&
            tipProvider.mentorTips.isEmpty &&
            (tipProvider.errorMessage == null ||
                tipProvider.errorMessage!.isEmpty)) {
          bodyContent = Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  size: 60,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  "Henüz hiç ipucu eklenmemiş.",
                  style: TextStyle(fontSize: 17, color: Colors.grey.shade700),
                ),
                const SizedBox(height: 10),
                Text(
                  "Yeni bir ipucu oluşturarak başlayın!",
                  style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => _openAddEditTipModal(),
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text("İlk İpucunu Ekle"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          );
        } else if (!tipProvider.isLoading &&
            tipProvider.errorMessage != null &&
            tipProvider.errorMessage!.isNotEmpty) {
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
                    tipProvider.errorMessage!,
                    style: TextStyle(color: Colors.red.shade600, fontSize: 15),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: () {
                      tipProvider.clearErrorMessage();
                      tipProvider.fetchUserTips();
                    },
                    child: const Text("Tekrar Dene"),
                  ),
                ],
              ),
            ),
          );
        } else if (filteredTipsUI.isEmpty && _searchTerm.isNotEmpty) {
          bodyContent = const Center(
            child: Text(
              "Arama sonucu bulunamadı.",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        } else if (filteredTipsUI.isNotEmpty) {
          bodyContent = RefreshIndicator(
            onRefresh: () async {
              await tipProvider.fetchUserTips();
            },
            color: Colors.orange,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 16.0,
              ),
              itemCount: filteredTipsUI.length,
              itemBuilder: (context, index) {
                final tip = filteredTipsUI[index];
                return _buildTipListItem(tip, tipProvider.isLoading);
              },
              separatorBuilder:
                  (context, index) => Divider(
                    height: 20,
                    thickness: 0.5,
                    color: Colors.grey.shade300,
                  ),
            ),
          );
        } else {
          bodyContent = Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  size: 60,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  "Henüz hiç ipucu mevcut değil.",
                  style: TextStyle(fontSize: 17, color: Colors.grey.shade700),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: () => _openAddEditTipModal(),
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text("İpucu Ekle"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          backgroundColor: Colors.white,
          appBar:
              _isSelectionMode && _selectedTipUI != null
                  ? AppBar(
                    backgroundColor: appBarBackground,
                    elevation: 0,
                    leading: IconButton(
                      icon: const Icon(Icons.close, color: textDark),
                      onPressed: _exitSelectionMode,
                    ),
                    title: Text(
                      _selectedTipUI!.title,
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
                            tipProvider.isLoading ? null : _deleteSelectedTip,
                        tooltip: 'Sil',
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.edit_outlined,
                          color: textDark,
                          size: 26,
                        ),
                        onPressed:
                            tipProvider.isLoading
                                ? null
                                : () {
                                  if (_selectedTipUI != null)
                                    _openAddEditTipModal(
                                      tipToEdit: _selectedTipUI,
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
                      'İpuçları Yönetimi',
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
              if (tipProvider.isLoading && allUiTips.isNotEmpty)
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
                tipProvider.isLoading ? null : () => _openAddEditTipModal(),
            backgroundColor: fabColor,
            child:
                (tipProvider.isLoading && allUiTips.isEmpty)
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
                hintText: 'İpucu Ara...',
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

  Widget _buildTipListItem(TipItemUI tip, bool isLoading) {
    return InkWell(
      onTap: isLoading ? null : () => _onTipLongPress(tip),
      onLongPress: isLoading ? null : () => _onTipLongPress(tip),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            CoverCardWidget(
              size: kUnifiedListItemCoverSize,
              borderRadius: kUnifiedListItemBorderRadius,
              gradient: tip.gradient,
              imageAssetPath: tip.animalIconPath,
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tip.title,
                    style: const TextStyle(
                      color: itemTitleColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    tip.content,
                    style: const TextStyle(
                      fontSize: 15,
                      color: itemContentColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
