// lib/features/auth/screens/LoginPage.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../state_management/auth_provider.dart';
import '../../mentor_features/home/models/mentor_home_args.dart'; // Mentor yönlendirmesi için

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    FocusScope.of(context).unfocus(); // Klavye açıksa kapat

    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      bool success = await authProvider.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return; // Widget ağaçtan kaldırıldıysa işlem yapma

      setState(() => _isLoading = false);

      if (success) {
        // Yönlendirme AuthProvider'daki role göre yapılacak.
        // Backend'den gelen rol "Member" ise ve UserRole enum'ınızda UserRole.user buna karşılık geliyorsa:
        if (authProvider.isUser()) {
          // AuthProvider.isUser() "Member" rolünü de kontrol etmeli
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.publicHome,
            (route) => false,
          );
        } else if (authProvider.isMentor()) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.mentorHome,
            (route) => false,
            arguments: MentorHomeArgs(
              mentorId: authProvider.userId ?? 'unknown_mentor_id',
              mentorName: authProvider.displayName ?? 'Mentor',
            ),
          );
        }
        // Diğer roller için (örn: admin) else if blokları eklenebilir.
        else {
          // Rol tanımlı değilse veya beklenmedik bir durumsa
          // AuthProvider.operationError zaten set edilmiş olmalı.
          // Bu hata LoginPage'in build metodunda gösterilecek.
          if (mounted && authProvider.operationError == null) {
            // Eğer özel bir hata yoksa genel mesaj
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(
                  "Giriş başarılı ancak rolünüz için yönlendirme bulunamadı.",
                ),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        }
      } else {
        // Hata mesajı AuthProvider.operationError'dan alınacak,
        // bu yüzden burada ek bir setState'e gerek yok, widget build'da gösterilecek.
        // İsterseniz anlık bir SnackBar gösterebilirsiniz ama zaten Text olarak gösteriliyor.
        // if (authProvider.operationError != null && mounted) {
        //    ScaffoldMessenger.of(context).showSnackBar(
        //     SnackBar(
        //       content: Text(authProvider.operationError!),
        //       backgroundColor: Theme.of(context).colorScheme.error,
        //     ),
        //   );
        // }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Hata mesajını AuthProvider'dan dinlemek için Consumer veya Provider.of kullanabiliriz.
    // Provider.of kullanırsak, her build'de yeniden alınır.
    // Consumer sadece ilgili widget'ı yeniden build eder.

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 32),
                Center(
                  child: Image.asset(
                    'assets/images/Legito.png', // Path'in doğru olduğundan emin olun
                    width: 160,
                    height: 80,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Giriş Yap',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 48),

                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'E-Posta',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Lütfen e-posta adresinizi girin.';
                    }
                    if (!value.contains('@') || !value.contains('.')) {
                      return 'Geçerli bir e-posta adresi girin.';
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
                      return 'Lütfen şifrenizi girin.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                // Hata mesajını AuthProvider'dan göster
                Consumer<AuthProvider>(
                  builder: (context, auth, child) {
                    if (auth.operationError != null && !_isLoading) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Text(
                          auth.operationError!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }
                    return const SizedBox.shrink(); // Hata yoksa boş widget
                  },
                ),
                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  child:
                      _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: _login,
                            child: const Text(
                              'Giriş Yap',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                ),
                const SizedBox(height: 24),

                GestureDetector(
                  onTap:
                      _isLoading
                          ? null
                          : () {
                            Navigator.pushNamed(context, AppRoutes.register);
                          },
                  child: const Text.rich(
                    TextSpan(
                      text: 'Bir hesabın yok mu? ',
                      style: TextStyle(color: Colors.black, fontSize: 15),
                      children: [
                        TextSpan(
                          text: 'Hesap Oluştur',
                          style: TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed:
                      _isLoading
                          ? null
                          : () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Şifremi unuttum özelliği henüz aktif değil.',
                                ),
                              ),
                            );
                          },
                  child: const Text(
                    'Şifremi Unuttum?',
                    style: TextStyle(color: Colors.black54, fontSize: 15),
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
