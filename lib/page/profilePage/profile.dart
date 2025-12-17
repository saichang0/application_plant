import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plant_aplication/constant/colorConst.dart';
import 'package:plant_aplication/controller/themeProvider.dart';
import 'package:plant_aplication/controller/user/userProfileController.dart';
import 'package:plant_aplication/page/profilePage/editProfile.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);
    final isDark = ref.watch(themeProvider);

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : Colors.white,
        surfaceTintColor: isDark ? Colors.black : const Color(0xFFFAFAFA),
        elevation: 0,
        title: Text(
          'Profile',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.settings_outlined,
              color: isDark ? Colors.white : Colors.black,
            ),
            onPressed: () {
              // Settings action
            },
          ),
        ],
      ),
      body: userAsync.when(
        data: (user) => SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 24),
              _buildProfileHeader(user, isDark), // Now isDark is accessible
              const SizedBox(height: 32),
              _buildMenuSection(
                context,
                ref,
                isDark,
              ), // Now isDark is accessible
              const SizedBox(height: 24),
            ],
          ),
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFF00D4AA)),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: isDark
                    ? Colors.grey[400]
                    : Colors.grey, // Now isDark is accessible
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load profile',
                style: TextStyle(
                  fontSize: 16,
                  color: isDark
                      ? Colors.grey[400]
                      : Colors.grey[600], // Now isDark is accessible
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(Map<String, dynamic>? user, bool isDark) {
    final name = user != null
        ? "${user['firstName'] ?? ''} ${user['lastName'] ?? ''}".trim()
        : 'Guest';
    final phone = user?['phone'] ?? '';
    final profileImage = user?['profileImage'];

    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? Colors.grey[800] : Colors.grey[200],
                image: profileImage != null
                    ? DecorationImage(
                        image: NetworkImage(profileImage),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: ColorConstants.secondaryColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? Colors.black : Colors.white,
                    width: 2,
                  ),
                ),
                child: const Icon(Icons.edit, color: Colors.white, size: 16),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          name,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          phone,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildMenuSection(BuildContext context, WidgetRef ref, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.person_outline,
            title: 'Edit Profile',
            isDark: isDark,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfilePage()),
              );
            },
          ),
          _buildDivider(isDark),
          _buildMenuItem(
            icon: Icons.location_on_outlined,
            title: 'Address',
            isDark: isDark,
            onTap: () {},
          ),
          _buildDivider(isDark),
          _buildMenuItem(
            icon: Icons.notifications_outlined,
            title: 'Notification',
            isDark: isDark,
            onTap: () {},
          ),
          _buildDivider(isDark),
          _buildMenuItem(
            icon: Icons.payment_outlined,
            title: 'Payment',
            isDark: isDark,
            onTap: () {},
          ),
          _buildDivider(isDark),
          _buildMenuItem(
            icon: Icons.security_outlined,
            title: 'Security',
            isDark: isDark,
            onTap: () {},
          ),
          _buildDivider(isDark),
          _buildMenuItem(
            icon: Icons.language_outlined,
            title: 'Language',
            trailing: 'English (US)',
            isDark: isDark,
            onTap: () {},
          ),
          _buildDivider(isDark),
          _buildMenuItem(
            icon: Icons.dark_mode_outlined,
            title: 'Dark Mode',
            hasSwitch: true,
            isSwitchValue: ref.watch(themeProvider),
            isDark: isDark,
            onSwitchChanged: (value) {
              ref.read(themeProvider.notifier).setTheme(value);
            },
            onTap: () {},
          ),
          _buildDivider(isDark),
          _buildMenuItem(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            isDark: isDark,
            onTap: () {},
          ),
          _buildDivider(isDark),
          _buildMenuItem(
            icon: Icons.help_outline,
            title: 'Help Center',
            isDark: isDark,
            onTap: () {},
          ),
          _buildDivider(isDark),
          _buildMenuItem(
            icon: Icons.person_add_outlined,
            title: 'Invite Friends',
            isDark: isDark,
            onTap: () {},
          ),
          _buildDivider(isDark),
          _buildMenuItem(
            icon: Icons.logout,
            title: 'Logout',
            titleColor: Colors.red,
            iconColor: Colors.red,
            showArrow: false,
            isDark: isDark,
            onTap: () {
              _showLogoutDialog(context, ref, isDark);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? trailing,
    Color? titleColor,
    Color? iconColor,
    bool hasSwitch = false,
    Function(bool)? onSwitchChanged,
    bool isSwitchValue = false,
    bool showArrow = true,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(
              icon,
              color:
                  iconColor ?? (isDark ? Colors.grey[400] : Colors.grey[700]),
              size: 22,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: titleColor ?? (isDark ? Colors.white : Colors.black87),
                ),
              ),
            ),
            if (trailing != null)
              Text(
                trailing,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            if (hasSwitch)
              Switch(
                value: isSwitchValue,
                onChanged: (value) {
                  onSwitchChanged?.call(value);
                },
                activeColor: const Color(0xFF00D4AA),
              ),
            if (showArrow && !hasSwitch) const SizedBox(width: 8),
            if (showArrow && !hasSwitch)
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: isDark ? Colors.grey[600] : Colors.grey[400],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Divider(
        height: 1,
        color: isDark ? Colors.grey[800] : Colors.grey[200],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Logout',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: TextStyle(
            fontSize: 15,
            color: isDark ? Colors.grey[300] : Colors.black87,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              'Cancel',
              style: TextStyle(
                fontSize: 15,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              await ref.read(userProvider.notifier).clearUser();
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text(
              'Logout',
              style: TextStyle(
                fontSize: 15,
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
