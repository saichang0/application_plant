import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plant_aplication/constant/colorConst.dart';
import 'package:plant_aplication/controller/languageController.dart';
import 'package:plant_aplication/controller/user/userProfileController.dart';
import 'package:plant_aplication/until/appTranslate.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;

  bool _isLoading = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userAsync = ref.read(userProvider);
    userAsync.whenData((userData) {
      if (userData != null) {
        _firstNameController.text = userData['firstName'] ?? '';
        _lastNameController.text = userData['lastName'] ?? '';
        _phoneController.text = userData['phoneNumber'] ?? '';
        _emailController.text = userData['email'] ?? '';
      }
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userAsync = ref.read(userProvider);
      final currentUserData = userAsync.value ?? {};

      final updatedUserData = {
        ...currentUserData,
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'phoneNumber': _phoneController.text,
        'email': _emailController.text,
      };

      await ref.read(userProvider.notifier).saveUser(updatedUserData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ອັບເດດຂໍ້ມູນສຳເລັດ'),
            backgroundColor: ColorConstants.accentDarkGreenColor,
          ),
        );
        setState(() {
          _isEditing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ອັບເດດຂໍ້ມູນບໍ່ສຳເລັດ: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final language = ref.watch(languageProvider);

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: ColorConstants.accentDarkGreenColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'profile_details'.tr(language),
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isEditing ? Icons.close : Icons.edit,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                color: isDark ? Colors.grey[900] : Colors.white,
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    _buildProfileField(
                      label: 'first_name'.tr(language),
                      controller: _firstNameController,
                      enabled: _isEditing,
                      isDark: isDark,
                    ),
                    _buildDivider(),
                    const SizedBox(height: 20),
                    _buildProfileField(
                      label: 'last_name'.tr(language),
                      controller: _lastNameController,
                      enabled: _isEditing,
                      isDark: isDark,
                    ),
                    _buildDivider(),
                    const SizedBox(height: 20),
                    _buildProfileField(
                      label: 'email'.tr(language),
                      controller: _emailController,
                      enabled: _isEditing,
                      keyboardType: TextInputType.emailAddress,
                      isDark: isDark,
                    ),
                    _buildDivider(),
                    const SizedBox(height: 20),
                    _buildProfileField(
                      label: 'phone'.tr(language),
                      controller: _phoneController,
                      enabled: _isEditing,
                      keyboardType: TextInputType.phone,
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_isEditing)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorConstants.accentDarkGreenColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'ບັນທຶກການປ່ຽນແປງ',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProfileField({
    required String label,
    required TextEditingController controller,
    required bool enabled,
    required bool isDark,
    bool obscureText = false,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white : Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              enabled: enabled,
              obscureText: obscureText,
              keyboardType: keyboardType,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w400,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: enabled ? 'ກະລຸນາໃສ່ຂໍ້ມູນ' : '',
                hintStyle: TextStyle(fontSize: 14, color: Colors.grey[400]),
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 1,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.grey[300]!,
              width: 1,
              style: BorderStyle.solid,
            ),
          ),
        ),
      ),
    );
  }
}
