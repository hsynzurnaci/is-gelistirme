import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = false;
  bool _notifications = true;
  bool _locationServices = true;
  String _selectedLanguage = 'Türkçe';
  String _selectedCurrency = '₺';
  double _fontSize = 16.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withOpacity(0.8),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.person,
                          size: 40,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Kullanıcı Adı',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'kullanici@email.com',
                        style: TextStyle(
                          color: Colors.white.withAlpha(204),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Genel Ayarlar'),
                  _buildSettingsCard([
                    _buildSettingTile(
                      'Karanlık Mod',
                      'Uygulamayı karanlık temada kullan',
                      Icons.dark_mode,
                      Switch(
                        value: _darkMode,
                        activeColor: Theme.of(context).primaryColor,
                        onChanged: (value) {
                          setState(() {
                            _darkMode = value;
                          });
                        },
                      ),
                    ),
                    _buildDivider(),
                    _buildSettingTile(
                      'Bildirimler',
                      'Bildirimleri aç/kapat',
                      Icons.notifications,
                      Switch(
                        value: _notifications,
                        activeColor: Theme.of(context).primaryColor,
                        onChanged: (value) {
                          setState(() {
                            _notifications = value;
                          });
                        },
                      ),
                    ),
                    _buildDivider(),
                    _buildSettingTile(
                      'Konum Servisleri',
                      'Konum bazlı özellikleri kullan',
                      Icons.location_on,
                      Switch(
                        value: _locationServices,
                        activeColor: Theme.of(context).primaryColor,
                        onChanged: (value) {
                          setState(() {
                            _locationServices = value;
                          });
                        },
                      ),
                    ),
                  ]),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Görünüm'),
                  _buildSettingsCard([
                    _buildSettingTile(
                      'Dil',
                      'Uygulama dilini değiştir',
                      Icons.language,
                      DropdownButton<String>(
                        value: _selectedLanguage,
                        underline: const SizedBox(),
                        items: ['Türkçe', 'English', 'Deutsch']
                            .map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedLanguage = newValue;
                            });
                          }
                        },
                      ),
                    ),
                    _buildDivider(),
                    _buildSettingTile(
                      'Para Birimi',
                      'Para birimini değiştir',
                      Icons.currency_exchange,
                      DropdownButton<String>(
                        value: _selectedCurrency,
                        underline: const SizedBox(),
                        items: ['₺', '\$', '€'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedCurrency = newValue;
                            });
                          }
                        },
                      ),
                    ),
                    _buildDivider(),
                    _buildSettingTile(
                      'Yazı Boyutu',
                      'Yazı boyutunu ayarla',
                      Icons.format_size,
                      SizedBox(
                        width: 200,
                        child: Slider(
                          value: _fontSize,
                          min: 12,
                          max: 24,
                          divisions: 6,
                          activeColor: Theme.of(context).primaryColor,
                          label: _fontSize.round().toString(),
                          onChanged: (double value) {
                            setState(() {
                              _fontSize = value;
                            });
                          },
                        ),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Hesap'),
                  _buildSettingsCard([
                    _buildSettingTile(
                      'Profil Bilgileri',
                      'Profil bilgilerini düzenle',
                      Icons.person,
                      const Icon(Icons.chevron_right),
                      onTap: () {
                        // Profil düzenleme sayfasına git
                      },
                    ),
                    _buildDivider(),
                    _buildSettingTile(
                      'Şifre Değiştir',
                      'Hesap şifresini güncelle',
                      Icons.lock,
                      const Icon(Icons.chevron_right),
                      onTap: () {
                        // Şifre değiştirme sayfasına git
                      },
                    ),
                    _buildDivider(),
                    _buildSettingTile(
                      'Hesabı Sil',
                      'Hesabınızı kalıcı olarak silin',
                      Icons.delete_forever,
                      const Icon(Icons.chevron_right),
                      onTap: () {
                        _showDeleteAccountDialog();
                      },
                    ),
                  ]),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Uygulama'),
                  _buildSettingsCard([
                    _buildSettingTile(
                      'Hakkında',
                      'Uygulama bilgileri',
                      Icons.info,
                      const Icon(Icons.chevron_right),
                      onTap: () {
                        _showAboutDialog();
                      },
                    ),
                    _buildDivider(),
                    _buildSettingTile(
                      'Gizlilik Politikası',
                      'Gizlilik politikasını görüntüle',
                      Icons.privacy_tip,
                      const Icon(Icons.chevron_right),
                      onTap: () {
                        // Gizlilik politikası sayfasına git
                      },
                    ),
                    _buildDivider(),
                    _buildSettingTile(
                      'Yardım ve Destek',
                      'Yardım alın',
                      Icons.help,
                      const Icon(Icons.chevron_right),
                      onTap: () {
                        // Yardım sayfasına git
                      },
                    ),
                  ]),
                  const SizedBox(height: 32),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Çıkış yap
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text('Çıkış Yap'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSettingTile(
    String title,
    String subtitle,
    IconData icon,
    Widget trailing, {
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: trailing,
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1);
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hesabı Sil'),
        content: const Text(
          'Hesabınızı silmek istediğinize emin misiniz? Bu işlem geri alınamaz.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              // Hesap silme işlemi
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hesabı Sil'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hakkında'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40,
              child: Icon(Icons.business, size: 40),
            ),
            SizedBox(height: 16),
            Text(
              'İş Geliştirme Uygulaması',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text('Versiyon 1.0.0'),
            SizedBox(height: 16),
            Text(
              'İşletmenizi büyütmek için geliştirilmiş kapsamlı bir yönetim uygulaması.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }
}
