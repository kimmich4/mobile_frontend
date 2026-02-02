import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'main_screen.dart';
import 'edit_profile_screen.dart';
import 'progress_tracking_screen.dart';
import 'ai_assistant_screen.dart';
import 'animate_in.dart';
import 'theme_manager.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  late bool _darkModeEnabled;
  bool _dataSharingEnabled = false;

  @override
  void initState() {
    super.initState();
    _darkModeEnabled = ThemeManager.themeMode.value == ThemeMode.dark;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          AnimateIn(child: _buildHeader(context)),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                AnimateIn(delay: const Duration(milliseconds: 100), child: _buildAccountSection()),
                const SizedBox(height: 16),
                AnimateIn(delay: const Duration(milliseconds: 200), child: _buildPreferencesSection()),
                const SizedBox(height: 16),
                AnimateIn(delay: const Duration(milliseconds: 300), child: _buildPrivacySection()),
                const SizedBox(height: 16),
                AnimateIn(delay: const Duration(milliseconds: 400), child: _buildSupportSection()),
                const SizedBox(height: 16),
                AnimateIn(delay: const Duration(milliseconds: 500), child: _buildBrandingSection()),
                const SizedBox(height: 16),
                AnimateIn(delay: const Duration(milliseconds: 600), child: _buildLegalSection(context)),
                const SizedBox(height: 24),
                AnimateIn(delay: const Duration(milliseconds: 700), child: _buildLogoutButton(context)),
                const SizedBox(height: 24),
                AnimateIn(delay: const Duration(milliseconds: 800), child: _buildFooter()),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 64, left: 24, right: 24, bottom: 32),
      decoration: const BoxDecoration(
        color: Color(0xFF003135),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                'Settings',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildProfileCard(),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    return InkWell(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 30,
              backgroundColor: Color(0xFF0FA4AF),
              child: Text('J', style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text('Mohamed Abdallah', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                   Text('Premium Member', style: TextStyle(color: Color(0xFFAFDDE5), fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSection() {
    return _buildCardWrapper(
      title: 'Account',
      children: [
        _buildItem(Icons.person, 'Edit Profile', () { _navigateTo(context, const EditProfileScreen()); }),
        _buildItem(Icons.monitor_heart, 'Health Data', () { _navigateTo(context, const ProgressTrackingScreen()); }),
      ],
    );
  }

  Widget _buildPreferencesSection() {
    return _buildCardWrapper(
      title: 'Preferences',
      children: [
        _buildItem(Icons.notifications, 'Notifications', null, trailing: Switch(
          value: _notificationsEnabled,
          onChanged: (v) => setState(() => _notificationsEnabled = v),
          activeColor: const Color(0xFF0FA4AF),
        )),
        _buildItem(Icons.dark_mode, 'Dark Mode', null, trailing: Switch(
          value: _darkModeEnabled,
          onChanged: (v) {
            setState(() => _darkModeEnabled = v);
            ThemeManager.toggleTheme(v);
          },
          activeColor: const Color(0xFF0FA4AF),
        )),
      ],
    );
  }

  Widget _buildPrivacySection() {
    return _buildCardWrapper(
      title: 'Privacy & Security',
      children: [
        _buildItem(Icons.lock, 'Privacy Settings', () { _showModal(context, 'Privacy', 'Settings here.'); }),
        _buildItem(Icons.share, 'Data Sharing', null, trailing: Switch(
          value: _dataSharingEnabled,
          onChanged: (v) => setState(() => _dataSharingEnabled = v),
          activeColor: const Color(0xFF0FA4AF),
        )),
      ],
    );
  }

  Widget _buildSupportSection() {
    return _buildCardWrapper(
      title: 'Support',
      children: [
        _buildItem(Icons.download, 'Export Data', () { _showExportDialog(context); }),
     ],
    );
  }

  Widget _buildCardWrapper({required String title, required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF024950))),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildItem(IconData icon, String label, VoidCallback? onTap, {Widget? trailing}) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF0FA4AF)),
      title: Text(label),
      trailing: trailing ?? const Icon(Icons.chevron_right, color: Color(0xFFAFDDE5)),
      onTap: onTap,
    );
  }

  Widget _buildBrandingSection() {
    return const Center(child: Text('FitBife AI v1.0.0', style: TextStyle(color: Color(0xFF024950))));
  }

  Widget _buildLegalSection(BuildContext context) {
    return _buildCardWrapper(
      title: 'Legal',
      children: [
        _buildItem(Icons.description, 'Terms of Service', () {}),
        _buildItem(Icons.privacy_tip, 'Privacy Policy', () {}),
      ],
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () { _showLogoutDialog(context); },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF964734),
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 50),
      ),
      child: const Text('Logout'),
    );
  }

  Widget _buildFooter() {
    return const Center(child: Text('Made with ❤️', style: TextStyle(fontSize: 12)));
  }

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  void _showModal(BuildContext context, String title, String desc) {
    showModalBottomSheet(context: context, builder: (_) => Padding(padding: const EdgeInsets.all(24), child: Text(title)));
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(context: context, builder: (_) => AlertDialog(
      title: const Text('Logout'),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        TextButton(onPressed: () => Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const AuthScreen()), (_) => false), child: const Text('Logout')),
      ],
    ));
  }

  void _showExportDialog(BuildContext context) {
    showDialog(context: context, builder: (_) => const AlertDialog(title: Text('Exporting...')));
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      Navigator.of(context).pop();
    });
  }
}