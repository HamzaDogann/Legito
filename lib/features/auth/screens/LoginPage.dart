// lib/features/auth/screens/LoginPage.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../state_management/auth_provider.dart';
import '../../mentor_features/home/models/mentor_home_args.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  // bool _isLoading = false; // isLoading will now be managed by AuthProvider

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    FocusScope.of(context).unfocus();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.clearDisplayedError(); // Clear previous errors

    if (_formKey.currentState?.validate() ?? false) {
      // setState(() => _isLoading = true); // AuthProvider handles isLoading

      bool success = await authProvider.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;
      // setState(() => _isLoading = false); // AuthProvider handles isLoading

      if (success) {
        if (authProvider.isUser()) {
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
        } else {
          if (mounted &&
              (authProvider.operationError == null &&
                  (authProvider.operationErrorsList?.isEmpty ?? true))) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(
                  "Giriş başarılı ancak rolünüz için yönlendirme bulunamadı.",
                ),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
          // Errors will be displayed by the Consumer
        }
      } else {
        // Errors will be displayed by the Consumer
      }
    }
  }

  Widget _buildErrorMessages(AuthProvider auth) {
    if (auth.isLoading) return const SizedBox.shrink();

    List<Widget> errorWidgets = [];
    if (auth.operationErrorsList?.isNotEmpty ?? false) {
      errorWidgets.addAll(
        auth.operationErrorsList!.map(
          (error) => Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              error,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    } else if (auth.operationError != null) {
      errorWidgets.add(
        Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            auth.operationError!,
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (errorWidgets.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, top: 8.0),
      child: Column(children: errorWidgets),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(
      context,
    ); // Listen to isLoading and errors

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
                    'assets/images/Legito.png',
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
                const SizedBox(height: 32), // Reduced space
                // Consumer to display API errors
                Consumer<AuthProvider>(
                  builder: (context, auth, _) => _buildErrorMessages(auth),
                ),

                // const SizedBox(height: 8), // Space after errors if any
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'E-Posta',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty)
                      return 'Lütfen e-posta adresinizi girin.';
                    if (!value.contains('@') || !value.contains('.'))
                      return 'Geçerli bir e-posta adresi girin.';
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
                    if (value == null || value.isEmpty)
                      return 'Lütfen şifrenizi girin.';
                    return null;
                  },
                ),
                const SizedBox(
                  height: 24,
                ), // Increased space for error messages
                SizedBox(
                  width: double.infinity,
                  child:
                      authProvider.isLoading
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
                      authProvider.isLoading
                          ? null
                          : () =>
                              Navigator.pushNamed(context, AppRoutes.register),
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
                      authProvider.isLoading
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
