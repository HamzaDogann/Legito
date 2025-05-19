// lib/features/auth/screens/RegisterPage.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../state_management/auth_provider.dart';
// Opsiyonel: Tarih formatlama için
// import 'package:intl/intl.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordAgainController = TextEditingController(); // Şifre tekrarı
  final _birthDateController = TextEditingController();
  String? _selectedGender;
  bool _isAgreementChecked = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordAgainController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  void _navigateToAgreementPage() {
    Navigator.pushNamed(context, AppRoutes.membershipAgreement);
  }

  Future<void> _selectBirthDate(BuildContext context) async {
    FocusScope.of(context).unfocus(); // Klavyeyi kapat
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(
        const Duration(days: 365 * 18),
      ), // 18 yıl öncesi
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: 'Doğum Tarihinizi Seçin',
      cancelText: 'İptal',
      confirmText: 'Tamam',
      locale: const Locale(
        'tr',
        'TR',
      ), // main.dart'ta localizations ayarları yapılmalı
    );
    if (picked != null) {
      // UI'da GG/AA/YYYY formatında gösterelim
      String formattedDate =
          "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      setState(() {
        _birthDateController.text = formattedDate;
      });
    }
  }

  Future<void> _submitForm() async {
    FocusScope.of(context).unfocus(); // Klavyeyi kapat

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    if (!_isAgreementChecked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen üyelik sözleşmesini onaylayınız.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    bool success = await authProvider.register(
      displayName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      passwordAgain: _passwordAgainController.text, // Şifre tekrarını gönder
      birthDate: _birthDateController.text, // GG/AA/YYYY formatında
      gender: _selectedGender,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hesabınız başarıyla oluşturuldu! Lütfen giriş yapın.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login,
        (route) => false,
      );
    } else {
      // Hata mesajı AuthProvider'dan operationError ile gelecek.
      // İsterseniz burada da SnackBar ile gösterebilirsiniz.
      if (authProvider.operationError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.operationError!),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // AuthProvider'ı dinleyerek isLoading durumunu alalım
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/Legito.png', // Bu dosyanın assets klasöründe olduğundan emin olun
                  width: 160,
                  height: 80,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Hesap Oluştur',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Ad Soyad',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator:
                      (value) =>
                          (value == null || value.trim().isEmpty)
                              ? 'Ad Soyad boş olamaz.'
                              : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'E-Posta',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'E-posta boş olamaz.';
                    }
                    // Daha iyi bir email regex'i kullanılabilir.
                    if (!RegExp(
                      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
                    ).hasMatch(value)) {
                      return 'Geçerli bir e-posta girin.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Şifre',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Şifre boş olamaz.';
                    }
                    if (value.length < 6) {
                      return 'Şifre en az 6 karakter olmalı.';
                    }
                    // İsteğe bağlı: API'nizin şifre karmaşıklığı kurallarına göre validator ekleyebilirsiniz.
                    // Örnek:
                    // if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{6,}$').hasMatch(value)) {
                    //   return 'Şifre en az bir harf ve bir rakam içermelidir.';
                    // }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  // Şifre Tekrarı
                  controller: _passwordAgainController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Şifre Tekrar',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Şifre tekrarı boş olamaz.';
                    }
                    if (value != _passwordController.text) {
                      return 'Şifreler eşleşmiyor.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _birthDateController,
                  decoration: InputDecoration(
                    labelText: 'Doğum Tarihi (GG/AA/YYYY)',
                    prefixIcon: const Icon(Icons.calendar_today_outlined),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.edit_calendar_outlined),
                      onPressed: () => _selectBirthDate(context),
                    ),
                  ),
                  readOnly: true,
                  onTap: () => _selectBirthDate(context),
                  validator:
                      (value) =>
                          (value == null || value.trim().isEmpty)
                              ? 'Doğum tarihi boş olamaz.'
                              : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Cinsiyet',
                    prefixIcon: Icon(Icons.wc_outlined),
                  ),
                  value: _selectedGender,
                  items: const [
                    DropdownMenuItem(value: 'Erkek', child: Text('Erkek')),
                    DropdownMenuItem(value: 'Kadın', child: Text('Kadın')),
                    DropdownMenuItem(
                      value: 'Belirtmek istemiyorum',
                      child: Text('Belirtmek İstemiyorum'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedGender = value;
                    });
                  },
                  validator:
                      (value) =>
                          (value == null) ? 'Lütfen cinsiyet seçin.' : null,
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Checkbox(
                      value: _isAgreementChecked,
                      onChanged: (bool? value) {
                        setState(() {
                          _isAgreementChecked = value ?? false;
                        });
                      },
                      activeColor: Theme.of(context).colorScheme.primary,
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: _navigateToAgreementPage,
                        child: Text.rich(
                          TextSpan(
                            text: 'Üyelik sözleşmesini ',
                            style: const TextStyle(fontSize: 13),
                            children: [
                              TextSpan(
                                text: 'okudum ve onaylıyorum.',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  decoration: TextDecoration.underline,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child:
                      authProvider.isLoading
                          ? Center(
                            child: CircularProgressIndicator(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          )
                          : ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: _submitForm,
                            child: const Text(
                              'Hesap Oluştur',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: GestureDetector(
                    onTap:
                        authProvider.isLoading
                            ? null
                            : () {
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                AppRoutes.login,
                                (route) => false,
                              );
                            },
                    child: Text.rich(
                      TextSpan(
                        text: 'Zaten bir hesabın var mı? ',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                        ),
                        children: [
                          TextSpan(
                            text: 'Giriş Yap',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
