import 'package:flutter/material.dart';
import 'package:legitoproject/shared_widgets/cover_card_widget.dart';
// import 'dart:io'; // Bu örnekte kullanılmıyor
// CoverCardWidget importu

// --- YENİ ORTAK SABİTLER ---
const double kUnifiedListItemCoverSize = 80.0;
const BorderRadius kUnifiedListItemBorderRadius = BorderRadius.all(
  Radius.circular(12.0),
);
// --- ---

// İpucu öğesini temsil edecek model
class TipItem {
  String id;
  String title;
  String content;
  String animalIconPath; // Seçilen hayvan ikonunun asset yolu
  Gradient gradient; // Kartın arka plan gradient'i

  TipItem({
    required this.id,
    required this.title,
    required this.content,
    required this.animalIconPath,
    required this.gradient,
  });
}

class TipsPage extends StatefulWidget {
  const TipsPage({super.key});

  @override
  State<TipsPage> createState() => _TipsPageState();
}

class _TipsPageState extends State<TipsPage> {
  // Renkler ve Sabitler
  static const Color appBarBackground = Color(0xFFF4F6F9);
  static const Color textDark = Color.fromARGB(255, 36, 36, 36);
  static const Color searchButtonColor = Color(0xFFFF8128); // Turuncu
  static const Color searchInputHintColor = Color(0xFF9CA3AF);
  static const Color fabColor = Color(0xFFFF8128); // + butonu için turuncu
  static const Color itemTitleColor = Color.fromARGB(255, 36, 36, 36);
  static const Color itemContentColor = Color.fromARGB(
    255,
    80,
    80,
    80,
  ); // İçerik rengi biraz daha açık
  static const Color inputFillColor = Color(0xFFF3F4F6);
  static const Color saveButtonColor = Color(0xFFFF8128);
  static const Color cancelButtonColor = Color.fromARGB(255, 36, 36, 36);
  static const Color animalIconCircleBg = Color(0xFFE5E7EB);
  static const Color activeAnimalIconCircleBg = Color(0xFF374151);

  // Örnek Gradientler (Kartlar için)
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
  final List<Gradient> _availableCardGradients = [
    gradientRed,
    gradientPurple,
    gradientGreen,
    gradientDarkGrey,
  ];

  final List<String> _animalIconPaths = [
    'assets/images/bunny.png',
    'assets/images/cow.png',
    'assets/images/dog_tip.png',
    'assets/images/tiger.png',
    'assets/images/bird.png',
  ];

  // ESKİ SABİTLER KALDIRILDI veya YORUMA ALINDI
  // static const double kTipCoverCardSize = 72.0;
  // static const BorderRadius kTipCoverCardBorderRadius =
  //     BorderRadius.all(Radius.circular(12.0));

  List<TipItem> _tips = [];
  List<TipItem> _filteredTips = [];
  String _searchTerm = '';
  TipItem? _selectedTip;
  bool _isSelectionMode = false;

  final TextEditingController _searchController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  int _selectedAnimalIconIndex = 2;
  PageController? _animalPageController;

  @override
  void initState() {
    super.initState();
    _loadInitialTips();
    _filteredTips = List.from(_tips);
    _searchController.addListener(() {
      setState(() {
        _searchTerm = _searchController.text;
        _filterTips();
      });
    });
    _animalPageController = PageController(
      initialPage: _selectedAnimalIconIndex,
      viewportFraction: 0.25,
    );
  }

  Gradient _getRandomCardGradient() {
    return _availableCardGradients[DateTime.now().millisecondsSinceEpoch %
        _availableCardGradients.length];
  }

  void _loadInitialTips() {
    _tips = [
      TipItem(
        id: 't1',
        title: "Biliyor muydun?",
        content: "Lorem Ipsum Dore Ferhano...",
        animalIconPath: _animalIconPaths[2],
        gradient: gradientRed,
      ),
      TipItem(
        id: 't2',
        title: "Önemli Bir Not",
        content:
            "Okuma hızını artırmak için çeşitli teknikler bulunmaktadır. Bunlardan biri de göz kaslarını eğitmektir.",
        animalIconPath: _animalIconPaths[1],
        gradient: gradientPurple,
      ),
      TipItem(
        id: 't3',
        title: "Günün Tavsiyesi",
        content:
            "Her gün en az 15 dakika odaklanarak kitap okumak, anlama yeteneğinizi geliştirir.",
        animalIconPath: _animalIconPaths[3],
        gradient: gradientGreen,
      ),
      TipItem(
        id: 't4',
        title: "Unutma!",
        content:
            "Anlamadığın yerleri tekrar etmekten çekinme, bu öğrenmenin bir parçasıdır.",
        animalIconPath: _animalIconPaths[0],
        gradient: gradientDarkGrey,
      ),
    ];
  }

  void _filterTips() {
    if (_searchTerm.isEmpty) {
      _filteredTips = List.from(_tips);
    } else {
      _filteredTips =
          _tips
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
  }

  void _onTipLongPress(TipItem tip) {
    setState(() {
      _selectedTip = tip;
      _isSelectionMode = true;
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _selectedTip = null;
      _isSelectionMode = false;
    });
  }

  void _deleteSelectedTip() {
    if (_selectedTip != null) {
      showDialog(
        context: context,
        builder:
            (BuildContext context) => AlertDialog(
              title: Text("İpucunu Sil"),
              content: Text(
                "'${_selectedTip!.title}' başlıklı ipucu silinecek. Emin misiniz?",
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
                      _tips.removeWhere((t) => t.id == _selectedTip!.id);
                      _filterTips();
                      _exitSelectionMode();
                    });
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text("İpucu silindi.")));
                  },
                ),
              ],
            ),
      );
    }
  }

  void _openAddEditTipModal({TipItem? tipToEdit}) {
    bool isEditing = tipToEdit != null;
    if (isEditing) {
      _titleController.text = tipToEdit.title;
      _contentController.text = tipToEdit.content;
      _selectedAnimalIconIndex = _animalIconPaths.indexOf(
        tipToEdit.animalIconPath,
      );
      if (_selectedAnimalIconIndex == -1) _selectedAnimalIconIndex = 2;
    } else {
      _titleController.clear();
      _contentController.clear();
      _selectedAnimalIconIndex = 2;
    }
    if (_animalPageController?.hasClients ?? false) {
      Future.delayed(Duration(milliseconds: 50), () {
        if (_animalPageController?.hasClients ?? false) {
          _animalPageController?.animateToPage(
            _selectedAnimalIconIndex,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      });
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
                      SizedBox(
                        height: 100,
                        child: PageView.builder(
                          controller: _animalPageController,
                          itemCount: _animalIconPaths.length,
                          onPageChanged: (index) {
                            modalSetState(() {
                              _selectedAnimalIconIndex = index;
                            });
                          },
                          itemBuilder: (context, index) {
                            bool isActive = index == _selectedAnimalIconIndex;
                            double scale = isActive ? 1.2 : 0.8;
                            double iconSize = isActive ? 60 : 45;
                            return AnimatedScale(
                              scale: scale,
                              duration: Duration(milliseconds: 200),
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
                                      width: iconSize,
                                      height: iconSize,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 25),
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
                                  _saveOrUpdateTip(tipToEdit);
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
                                isEditing ? 'Güncelle' : 'İpucu Oluştur',
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

  void _saveOrUpdateTip(TipItem? existingTip) {
    setState(() {
      final selectedAnimalIcon = _animalIconPaths[_selectedAnimalIconIndex];
      if (existingTip != null) {
        existingTip.title = _titleController.text.trim();
        existingTip.content = _contentController.text.trim();
        existingTip.animalIconPath = selectedAnimalIcon;
      } else {
        final newTip = TipItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: _titleController.text.trim(),
          content: _contentController.text.trim(),
          animalIconPath: selectedAnimalIcon,
          gradient: _getRandomCardGradient(),
        );
        _tips.add(newTip);
      }
      _filterTips();
      if (_isSelectionMode) _exitSelectionMode();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          existingTip != null ? "İpucu güncellendi." : "İpucu oluşturuldu.",
        ),
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar:
          _isSelectionMode && _selectedTip != null
              ? AppBar(
                backgroundColor: appBarBackground,
                elevation: 0,
                leading: IconButton(
                  icon: Icon(Icons.close, color: textDark),
                  onPressed: _exitSelectionMode,
                ),
                title: Text(
                  _selectedTip!.title,
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
                    onPressed: _deleteSelectedTip,
                    tooltip: 'Sil',
                  ),
                  IconButton(
                    icon: Icon(Icons.edit_outlined, color: textDark, size: 26),
                    onPressed: () {
                      if (_selectedTip != null) {
                        _openAddEditTipModal(tipToEdit: _selectedTip);
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
                  'İpuçları',
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
                _filteredTips.isEmpty && _searchTerm.isNotEmpty
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
                      itemCount: _filteredTips.length,
                      itemBuilder: (context, index) {
                        final tip = _filteredTips[index];
                        return _buildTipListItem(tip);
                      },
                      separatorBuilder:
                          (context, index) => Divider(
                            height: 20,
                            thickness: 0.5,
                            color: Colors.grey.shade300,
                          ),
                    ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddEditTipModal(),
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
                hintText: 'İpucu Ara...',
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
              _filterTips();
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

  Widget _buildTipListItem(TipItem tip) {
    return InkWell(
      onTap: () {
        _onTipLongPress(tip);
      },
      onLongPress: () => _onTipLongPress(tip),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            CoverCardWidget(
              size: kUnifiedListItemCoverSize, // <<< DEĞİŞTİ
              borderRadius: kUnifiedListItemBorderRadius, // <<< DEĞİŞTİ
              gradient: tip.gradient,
              imageAssetPath: tip.animalIconPath,
              // iconOrImageSize: kUnifiedListItemCoverSize * 0.8, // İsteğe bağlı
            ),
            SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tip.title,
                    style: TextStyle(
                      color: itemTitleColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 5),
                  Text(
                    tip.content,
                    style: TextStyle(fontSize: 15, color: itemContentColor),
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
