// lib/features/common_screens/screens/UpdatePasswordPage.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../state_management/auth_provider.dart'; // AuthProvider importu

class UpdatePasswordPage extends StatefulWidget {
  const UpdatePasswordPage({Key? key}) : super(key: key);

  @override
  State<UpdatePasswordPage> createState() => _UpdatePasswordPageState();
}

class _UpdatePasswordPageState extends State<UpdatePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmNewPasswordController = TextEditingController();

  bool _isCurrentPasswordObscured = true;
  bool _isNewPasswordObscured = true;
  bool _isConfirmNewPasswordObscured = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submitUpdatePassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    FocusScope.of(context).unfocus(); // Klavyeyi kapat
    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.clearDisplayedError();

    bool success = await authProvider.updateUserPassword(
      currentPassword: _currentPasswordController.text,
      newPassword: _newPasswordController.text,
      newPasswordAgain: _confirmNewPasswordController.text,
    );

    setState(() => _isLoading = false);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Şifre başarıyla güncellendi! Lütfen tekrar giriş yapın.',
            ),
            backgroundColor: Colors.green,
          ),
        );
        // AuthProvider.updateUserPassword içinde zaten logout çağrılıyor.
        // Bu yüzden burada ek bir Navigator.pushNamedAndRemoveUntil(AppRoutes.login) yapmaya gerek yok,
        // AuthProvider'ın logout'u yönlendirmeyi yapacaktır.
        // Eğer AuthProvider'da logout yapılmıyorsa, burada yönlendirme yapılmalı:
        // Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Şifre güncelleme hatası: ${authProvider.operationError ?? "Bilinmeyen bir sorun."}',
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
        title: const Text("Şifre Değiştir"),
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
                controller: _currentPasswordController,
                obscureText: _isCurrentPasswordObscured,
                decoration: InputDecoration(
                  labelText: 'Mevcut Şifre',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isCurrentPasswordObscured
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed:
                        () => setState(
                          () =>
                              _isCurrentPasswordObscured =
                                  !_isCurrentPasswordObscured,
                        ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Mevcut şifrenizi girin.';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _newPasswordController,
                obscureText: _isNewPasswordObscured,
                decoration: InputDecoration(
                  labelText: 'Yeni Şifre',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isNewPasswordObscured
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed:
                        () => setState(
                          () =>
                              _isNewPasswordObscured = !_isNewPasswordObscured,
                        ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Yeni şifreyi girin.';
                  if (value.length < 6) return 'Şifre en az 6 karakter olmalı.';
                  // İsteğe bağlı: Daha karmaşık şifre kuralları eklenebilir
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmNewPasswordController,
                obscureText: _isConfirmNewPasswordObscured,
                decoration: InputDecoration(
                  labelText: 'Yeni Şifre Tekrar',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isConfirmNewPasswordObscured
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed:
                        () => setState(
                          () =>
                              _isConfirmNewPasswordObscured =
                                  !_isConfirmNewPasswordObscured,
                        ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Yeni şifreyi tekrar girin.';
                  if (value != _newPasswordController.text)
                    return 'Şifreler eşleşmiyor.';
                  return null;
                },
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
                      onPressed: _isLoading ? null : _submitUpdatePassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF8128), // turuncu
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
