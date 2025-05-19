import 'package:flutter/material.dart';

class MembershipAgreementPage extends StatelessWidget {
  const MembershipAgreementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Üyelik Sözleşmesi'),
        backgroundColor: const Color(0xFFF4F4F4),
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.black,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Üyelik Sözleşmesi',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFF8128),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Bu uygulamaya kayıt olarak, aşağıda belirtilen tüm koşulları kabul etmiş sayılırsınız.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              '1. Hesap Sorumluluğu',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'Kullanıcı, oluşturduğu hesabın gizliliğinden ve güvenliğinden sorumludur. '
              'Hesabınızla gerçekleştirilen tüm işlemlerden siz sorumlu olursunuz.',
            ),
            SizedBox(height: 12),
            Text(
              '2. Hizmet Koşulları',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'Uygulamanın sunduğu içerik yalnızca kişisel kullanım amaçlıdır. '
              'Hiçbir içerik izinsiz kopyalanamaz, çoğaltılamaz veya dağıtılamaz.',
            ),
            SizedBox(height: 12),
            Text(
              '3. Veri Kullanımı ve Gizlilik',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'Uygulama tarafından toplanan veriler yalnızca hizmet kalitesini artırmak için kullanılır '
              've hiçbir şekilde üçüncü taraflarla paylaşılmaz.',
            ),
            SizedBox(height: 12),
            Text(
              '4. Değişiklik Hakkı',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'Uygulama yönetimi, üyelik sözleşmesini önceden bildirimde bulunmaksızın güncelleme hakkını saklı tutar.',
            ),
            SizedBox(height: 12),
            Text(
              '5. Kabul ve Onay',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'Hesap oluşturduğunuzda bu sözleşmeyi okuduğunuzu ve tüm maddelerini kabul ettiğinizi beyan etmiş olursunuz.',
            ),
            SizedBox(height: 24),
            Text(
              'LEGİTO ailesi olarak teşekkür ederiz.',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFFFF8128),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
