import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:plant_aplication/constant/colorConst.dart';
import 'package:plant_aplication/controller/languageController.dart';
import 'package:plant_aplication/controller/themeProvider.dart';
import 'package:plant_aplication/controller/user/userProfileController.dart';
import 'package:plant_aplication/page/home.dart';
import 'package:plant_aplication/page/profilePage/editProfile.dart';
import 'package:plant_aplication/page/profilePage/language.dart';
import 'package:plant_aplication/services/authStorage.dart';
import 'package:plant_aplication/until/appTranslate.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({Key? key}) : super(key: key);

  Future<void> _pickProfileImage(BuildContext context, WidgetRef ref) async {
    final isDark = ref.read(themeProvider);
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                Icons.photo_camera,
                color: isDark ? Colors.white : Colors.black87,
              ),
              title: Text(
                'Camera',
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              ),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: Icon(
                Icons.photo_library,
                color: isDark ? Colors.white : Colors.black87,
              ),
              title: Text(
                'Gallery',
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              ),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;

    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: source, imageQuality: 85);
      if (picked == null) return;

      final currentUser = ref.read(userProvider).value ?? {};
      await ref.read(userProvider.notifier).saveUser({
        ...currentUser,
        'profileImage': picked.path,
      });
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);
    final isDark = ref.watch(themeProvider);
    final language = ref.watch(languageProvider);

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : Colors.white,
        surfaceTintColor: isDark ? Colors.black : const Color(0xFFFAFAFA),
        elevation: 0,
        title: Text(
          'profile'.tr(language),
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
              _buildProfileHeader(
                context,
                ref,
                user,
                isDark,
                language,
              ), // Now isDark is accessible
              const SizedBox(height: 32),
              _buildMenuSection(
                context,
                ref,
                isDark,
                language,
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
                color: isDark ? Colors.grey[400] : Colors.grey,
              ),
              const SizedBox(height: 16),
              Text(
                'failed_to_load_profile'.tr(language),
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic>? user,
    bool isDark,
    String language,
  ) {
    final name = user != null
        ? "${user['firstName'] ?? ''} ${user['lastName'] ?? ''}".trim()
        : 'guest'.tr(language);
    final phone = user?['phoneNumber'] ?? '';
    final profileImage = user?['profileImage'] as String?;
    final hasImage = profileImage != null && profileImage.isNotEmpty;
    final isRemote = hasImage && profileImage.startsWith('http');

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
                image: hasImage
                    ? DecorationImage(
                        image: isRemote
                            ? NetworkImage(profileImage) as ImageProvider
                            : FileImage(File(profileImage)),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: () => _pickProfileImage(context, ref),
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

  Widget _buildMenuSection(
    BuildContext context,
    WidgetRef ref,
    bool isDark,
    String language,
  ) {
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
            title: 'edit_profile'.tr(language),
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
            title: 'address'.tr(language),
            isDark: isDark,
            onTap: () {},
          ),
          _buildDivider(isDark),
          _buildMenuItem(
            icon: Icons.notifications_outlined,
            title: 'notification'.tr(language),
            isDark: isDark,
            onTap: () {},
          ),
          // _buildDivider(isDark),
          // _buildMenuItem(
          //   icon: Icons.payment_outlined,
          //   title: 'Payment',
          //   isDark: isDark,
          //   onTap: () {},
          // ),
          _buildDivider(isDark),
          _buildMenuItem(
            icon: Icons.language_outlined,
            title: 'language'.tr(language),
            trailing: language == 'en'
                ? 'lang_en'.tr(language)
                : 'lang_lo'.tr(language),
            isDark: isDark,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LanguagePage()),
              );
            },
          ),
          _buildDivider(isDark),
          _buildMenuItem(
            icon: Icons.dark_mode_outlined,
            title: isDark
                ? 'light_mode'.tr(language)
                : 'dark_mode'.tr(language),
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
            icon: Icons.logout,
            title: 'logout'.tr(language),
            titleColor: Colors.red,
            iconColor: Colors.red,
            showArrow: false,
            isDark: isDark,
            onTap: () {
              _showLogoutDialog(context, ref, isDark, language);
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

  void _showLogoutDialog(
    BuildContext context,
    WidgetRef ref,
    bool isDark,
    String language,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'logout'.tr(language),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        content: Text(
          'are_you_want_to_logout'.tr(language),
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
              'cancel'.tr(language),
              style: TextStyle(
                fontSize: 15,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              await AuthStorage.clear();
              await ref.read(userProvider.notifier).clearUser();
              ref.read(bottomNavProvider.notifier).reset();
              if (!context.mounted) return;
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
            child: Text(
              'confirm'.tr(language),
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
