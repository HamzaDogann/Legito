import 'package:flutter/material.dart';

class UpdatePasswordPage extends StatefulWidget {
  const UpdatePasswordPage({super.key});

  @override
  State<UpdatePasswordPage> createState() => _UpdatePasswordPageState();
}

class _UpdatePasswordPageState extends State<UpdatePasswordPage> {
  // Sadece yeni şifre alanları için görünürlük durumunu tutacak değişkenler
  bool _isNewPasswordObscured = true;
  bool _isConfirmNewPasswordObscured = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Şifre Değiştir"),
        backgroundColor: const Color(0xFFF4F4F4),
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
          color: Colors.black,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TextField(
              // Mevcut şifre alanında göz ikonu yok, her zaman gizli
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Mevcut Şifre',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              // Yeni şifre alanı için göz ikonu
              obscureText: _isNewPasswordObscured,
              decoration: InputDecoration(
                labelText: 'Yeni Şifre',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isNewPasswordObscured
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _isNewPasswordObscured = !_isNewPasswordObscured;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              // Yeni şifre tekrar alanı için göz ikonu
              obscureText: _isConfirmNewPasswordObscured,
              decoration: InputDecoration(
                labelText: 'Yeni Şifre Tekrar',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isConfirmNewPasswordObscured
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _isConfirmNewPasswordObscured =
                          !_isConfirmNewPasswordObscured;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.grey),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
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
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        // Şifre kaydetme işlemi
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF8128),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        'Kaydet',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
