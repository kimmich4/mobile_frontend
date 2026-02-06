import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'edit_profile_screen.dart';
import 'progress_tracking_screen.dart';
import 'login_screen.dart';
import '../components/animate_in.dart';
import '../../viewmodels/settings_view_model.dart';


class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize dark mode state from ThemeManager via ViewModel
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SettingsViewModel>().initializeDarkMode();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: ListView(
            padding: EdgeInsets.zero,
            children: [
              AnimateIn(child: _buildHeader(context, viewModel)),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    AnimateIn(delay: const Duration(milliseconds: 100), child: _buildAccountSection(context, viewModel)),
                    const SizedBox(height: 16),
                    AnimateIn(delay: const Duration(milliseconds: 200), child: _buildPreferencesSection(context, viewModel)),
                    const SizedBox(height: 16),
                    AnimateIn(delay: const Duration(milliseconds: 300), child: _buildPrivacySection(context, viewModel)),
                    const SizedBox(height: 16),
                    AnimateIn(delay: const Duration(milliseconds: 400), child: _buildSupportSection(context, viewModel)),
                    const SizedBox(height: 16),
                    AnimateIn(delay: const Duration(milliseconds: 500), child: _buildBrandingSection()),
                    const SizedBox(height: 16),
                    AnimateIn(delay: const Duration(milliseconds: 600), child: _buildLegalSection(context, viewModel)),
                    const SizedBox(height: 24),
                    AnimateIn(delay: const Duration(milliseconds: 700), child: _buildLogoutButton(context, viewModel)),
                    const SizedBox(height: 24),
                    AnimateIn(delay: const Duration(milliseconds: 800), child: _buildFooter()),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, SettingsViewModel viewModel) {
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
          _buildProfileCard(viewModel),
        ],
      ),
    );
  }

  Widget _buildProfileCard(SettingsViewModel viewModel) {
    return InkWell(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: const Color(0xFF0FA4AF),
              child: Text(viewModel.userInitial, style: const TextStyle(color: Colors.white, fontSize: 24)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(viewModel.userName, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                   Text(viewModel.membershipStatus, style: const TextStyle(color: Color(0xFFAFDDE5), fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSection(BuildContext context, SettingsViewModel viewModel) {
    return _buildCardWrapper(
      context,
      title: 'Account',
      children: [
        _buildItem(Icons.person, 'Edit Profile', () { viewModel.navigateTo(context, const EditProfileScreen()); }),
        _buildItem(Icons.monitor_heart, 'Health Data', () { viewModel.navigateTo(context, const ProgressTrackingScreen()); }),
      ],
    );
  }

  Widget _buildPreferencesSection(BuildContext context, SettingsViewModel viewModel) {
    return _buildCardWrapper(
      context,
      title: 'Preferences',
      children: [
        _buildItem(Icons.notifications, 'Notifications', null, trailing: Switch(
          value: viewModel.notificationsEnabled,
          onChanged: (v) => viewModel.setNotificationsEnabled(v),
          activeColor: const Color(0xFF0FA4AF),
        )),
        _buildItem(Icons.dark_mode, 'Dark Mode', null, trailing: Switch(
          value: viewModel.darkModeEnabled,
          onChanged: (v) => viewModel.setDarkModeEnabled(v),
          activeColor: const Color(0xFF0FA4AF),
        )),
      ],
    );
  }

  Widget _buildPrivacySection(BuildContext context, SettingsViewModel viewModel) {
    return _buildCardWrapper(
      context,
      title: 'Privacy & Security',
      children: [
        _buildItem(Icons.lock, 'Privacy Settings', () { viewModel.showModal(context, 'Privacy', 'Settings here.'); }),
        _buildItem(Icons.share, 'Data Sharing', null, trailing: Switch(
          value: viewModel.dataSharingEnabled,
          onChanged: (v) => viewModel.setDataSharingEnabled(v),
          activeColor: const Color(0xFF0FA4AF),
        )),
      ],
    );
  }

  Widget _buildSupportSection(BuildContext context, SettingsViewModel viewModel) {
    return _buildCardWrapper(
      context,
      title: 'Support',
      children: [
        _buildItem(Icons.download, 'Export Data', () { viewModel.showExportDialog(context); }),
     ],
    );
  }

  Widget _buildCardWrapper(BuildContext context, {required String title, required List<Widget> children}) {
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

  Widget _buildLegalSection(BuildContext context, SettingsViewModel viewModel) {
    return _buildCardWrapper(
      context,
      title: 'Legal',
      children: [
        _buildItem(Icons.description, 'Terms of Service', () {}),
        _buildItem(Icons.privacy_tip, 'Privacy Policy', () {}),
      ],
    );
  }

  Widget _buildLogoutButton(BuildContext context, SettingsViewModel viewModel) {
    return ElevatedButton(
      onPressed: () { 
        viewModel.showLogoutDialog(context, () {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const AuthScreen()), 
            (_) => false
          );
        }); 
      },
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
}

