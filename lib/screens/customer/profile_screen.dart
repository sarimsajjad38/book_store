import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/gradient_button.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            final user = auth.user;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  // Avatar
                  Container(
                    width: 90, height: 90,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 6))],
                    ),
                    child: Center(child: Text(user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : '?', style: GoogleFonts.poppins(fontSize: 36, fontWeight: FontWeight.w700, color: Theme.of(context).cardColor))),
                  ),
                  const SizedBox(height: 16),
                  Text(user?.name ?? 'User', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(user?.email ?? '', style: GoogleFonts.poppins(fontSize: 14, color: Theme.of(context).textTheme.bodySmall?.color)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                    child: Text(user?.role.name.toUpperCase() ?? 'CUSTOMER', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary)),
                  ),
                  const SizedBox(height: 32),

                  // Menu items
                  _buildMenuItem(context, Icons.person_outline_rounded, 'Edit Profile', () {}),
                  _buildMenuItem(context, Icons.location_on_outlined, 'Manage Addresses', () {}),
                  _buildMenuItem(context, Icons.favorite_border_rounded, 'Wishlist', () {}),
                  _buildMenuItem(context, Icons.headset_mic_outlined, 'Help & Support', () {}),
                  _buildMenuItem(context, Icons.info_outline_rounded, 'About App', () {
                    showAboutDialog(context: context, applicationName: 'BookNest', applicationVersion: '1.0.0', applicationLegalese: '© 2026 BookNest. Your Literary Paradise.');
                  }),
                  const SizedBox(height: 24),

                  // Logout
                  GradientButton(
                    text: 'Logout',
                    icon: Icons.logout_rounded,
                    gradient: const LinearGradient(colors: [Color(0xFFEF4444), Color(0xFFF87171)]),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Logout'),
                          content: const Text('Are you sure you want to logout?'),
                          actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')), TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Logout', style: TextStyle(color: AppColors.error)))],
                        ),
                      );
                      if (confirm == true) {
                        await auth.logout();
                        if (context.mounted) {
                          Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(14), border: Border.all(color: Theme.of(context).dividerColor)),
        child: Row(children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: AppColors.primary, size: 20)),
          const SizedBox(width: 14),
          Expanded(child: Text(title, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w500))),
          Icon(Icons.chevron_right_rounded, color: Theme.of(context).textTheme.bodySmall?.color),
        ]),
      ),
    );
  }
}
