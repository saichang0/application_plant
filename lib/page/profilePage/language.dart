import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plant_aplication/constant/colorConst.dart';
import 'package:plant_aplication/controller/languageController.dart';

// Language Page
class LanguagePage extends ConsumerWidget {
  const LanguagePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLanguage = ref.watch(languageProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: ColorConstants.accentDarkGreenColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          currentLanguage == 'en' ? 'Language' : 'ພາສາ',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            _buildLanguageOption(
              context: context,
              ref: ref,
              languageCode: 'lo',
              languageName: 'ລາວ',
              subtitle: 'Lao',
              isSelected: currentLanguage == 'lo',
            ),
            _buildDivider(),
            _buildLanguageOption(
              context: context,
              ref: ref,
              languageCode: 'en',
              languageName: 'English',
              subtitle: 'English',
              isSelected: currentLanguage == 'en',
            ),
            _buildDivider(),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption({
    required BuildContext context,
    required WidgetRef ref,
    required String languageCode,
    required String languageName,
    required String subtitle,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () {
        ref.read(languageProvider.notifier).setLanguage(languageCode);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF3F5A8E).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  languageCode == 'lo' ? '🇱🇦' : '🇬🇧',
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    languageName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: Color(0xFF00D4AA), size: 24)
            else
              Icon(Icons.circle_outlined, color: Colors.grey[400], size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(height: 1, color: Colors.grey[300]),
    );
  }
}
