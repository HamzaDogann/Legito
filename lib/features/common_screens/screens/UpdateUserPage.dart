// lib/features/common_screens/screens/UpdateUserPage.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../../state_management/auth_provider.dart';

// GenderEnum ve helper fonksiyonları (ayrı bir dosyada olabilir)
enum GenderEnum { male, female, other }

String genderEnumToString(GenderEnum gender, BuildContext context) {
  switch (gender) {
    case GenderEnum.male:
      return "Erkek";
    case GenderEnum.female:
      return "Kadın";
    case GenderEnum.other:
      return "Belirtmek İstemiyorum";
  }
}

int genderEnumToApiInt(GenderEnum gender) {
  switch (gender) {
    case GenderEnum.male:
      return 0;
    case GenderEnum.female:
      return 1;
    case GenderEnum.other:
      return 2;
  }
}

GenderEnum? apiIntToGenderEnum(int? apiGender) {
  if (apiGender == null) return null;
  switch (apiGender) {
    case 0:
      return GenderEnum.male;
    case 1:
      return GenderEnum.female;
    case 2:
      return GenderEnum.other;
    default:
      return null;
  }
}

class UpdateUserPage extends StatefulWidget {
  const UpdateUserPage({Key? key}) : super(key: key);

  @override
  State<UpdateUserPage> createState() => _UpdateUserPageState();
}

class _UpdateUserPageState extends State<UpdateUserPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _displayNameController;
  late TextEditingController _emailController;
  late TextEditingController _birthDateController;

  GenderEnum? _selectedGender;
  DateTime? _selectedBirthDateObject;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('tr_TR', null);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    _displayNameController = TextEditingController(
      text: authProvider.displayName ?? '',
    );
    _emailController = TextEditingController(text: authProvider.email ?? '');
    _birthDateController = TextEditingController();

    // AuthProvider'dan veya UserInfoData'dan mevcut cinsiyet ve doğum tarihini yükle
    // Örnek (UserInfoData'da int? userGenderApi ve DateTime? userBirthDateApi olduğunu varsayalım):
    // _selectedGender = apiIntToGenderEnum(authProvider.userInfoData?.userGenderApi);
    // _selectedBirthDateObject = authProvider.userInfoData?.userBirthDateApi;
    // Bu alanların AuthProvider ve UserInfoData modelinizde olması gerekir.
    // Şimdilik null bırakıyorum, UI'da seçilirse değer alacaklar.

    if (_selectedBirthDateObject != null) {
      _birthDateController.text = DateFormat(
        'dd/MM/yyyy',
        'tr_TR',
      ).format(_selectedBirthDateObject!);
    }
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  Future<void> _selectBirthDate(BuildContext context) async {
    FocusScope.of(context).unfocus();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          _selectedBirthDateObject ??
          DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: 'Doğum Tarihinizi Seçin',
      cancelText: 'İptal',
      confirmText: 'Tamam',
      locale: const Locale('tr', 'TR'),
    );
    if (picked != null) {
      // && picked != _selectedBirthDateObject - bu kontrol kaldırıldı, her seçimde update et
      setState(() {
        _selectedBirthDateObject = picked;
        _birthDateController.text = DateFormat(
          'dd/MM/yyyy',
          'tr_TR',
        ).format(picked);
      });
    }
  }

  Future<void> _submitUpdate() async {
    if (!_formKey.currentState!.validate()) {
      if (_isLoading) setState(() => _isLoading = false);
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.clearDisplayedError();

    // Formdaki o anki tüm değerleri al
    final String displayNameValue = _displayNameController.text.trim();
    final String emailValue = _emailController.text.trim();
    final int? genderValue =
        _selectedGender != null ? genderEnumToApiInt(_selectedGender!) : null;
    final String? birthDateForApi =
        _selectedBirthDateObject != null
            ? DateFormat('yyyy-MM-dd').format(_selectedBirthDateObject!)
            : null;

    print("Gönderilecek Değerler (Kaydet Butonu):");
    print("DisplayName: $displayNameValue");
    print("Email: $emailValue");
    print("Gender: $genderValue");
    print("BirthDate: $birthDateForApi");

    // UpdateUserRequestModel sadece null olmayanları gönderecek şekilde ayarlıydı,
    // bu yüzden displayNameValue ve emailValue boş string olsa bile gönderilir.
    // Eğer API boş stringleri kabul etmiyorsa, validator'larınız bunu yakalamalı.
    // Ya da burada ek kontrol yapıp, boşsa null gönderebilirsiniz:
    // displayName: displayNameValue.isEmpty ? null : displayNameValue,
    // email: emailValue.isEmpty ? null : emailValue,
    // Ancak isteğiniz "ne varsa gönder" olduğu için direkt gönderiyoruz.

    bool success = await authProvider.updateUserProfile(
      displayName: displayNameValue, // Boş string ise boş string gider
      email: emailValue, // Boş string ise boş string gider
      gender: genderValue, // Seçilmediyse null gider
      birthDate: birthDateForApi, // Seçilmediyse null gider
    );

    setState(() => _isLoading = false);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil bilgileri başarıyla güncellendi!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Güncelleme hatası: ${authProvider.operationError ?? "Bilinmeyen bir sorun oluştu."}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bilgilerimi Güncelle"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _displayNameController,
                decoration: const InputDecoration(labelText: 'Ad Soyad'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ad Soyad boş bırakılamaz.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'E-Posta'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'E-posta boş bırakılamaz.';
                  }
                  if (!RegExp(
                    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
                  ).hasMatch(value)) {
                    return 'Geçerli bir e-posta adresi girin.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<GenderEnum>(
                decoration: const InputDecoration(labelText: 'Cinsiyet'),
                value: _selectedGender,
                items:
                    GenderEnum.values.map((GenderEnum gender) {
                      return DropdownMenuItem<GenderEnum>(
                        value: gender,
                        child: Text(genderEnumToString(gender, context)),
                      );
                    }).toList(),
                onChanged: (GenderEnum? newValue) {
                  setState(() => _selectedGender = newValue);
                },
                // validator: (value) => value == null ? 'Lütfen bir cinsiyet seçin.' : null, // API null kabul ediyorsa opsiyonel
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _birthDateController,
                decoration: InputDecoration(
                  labelText: 'Doğum Tarihi (GG/AA/YYYY)',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _selectBirthDate(context),
                  ),
                ),
                readOnly: true,
                onTap: () => _selectBirthDate(context),
                // validator: (value) => value == null || value.isEmpty ? 'Lütfen doğum tarihinizi seçin.' : null, // API null kabul ediyorsa opsiyonel
              ),
              const SizedBox(height: 40),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          _isLoading ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.grey),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'İptal',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitUpdate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF8128),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child:
                          _isLoading
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.0,
                                ),
                              )
                              : const Text(
                                'Kaydet',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
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
  }
}
