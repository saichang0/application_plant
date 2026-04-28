import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Language Notifier
class LanguageNotifier extends StateNotifier<String> {
  LanguageNotifier() : super('lo') {
    // Default to Lao
    _loadLanguage();
  }

  // Load saved language from SharedPreferences
  Future<void> _loadLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLanguage = prefs.getString('language') ?? 'lo';
      state = savedLanguage;
    } catch (e) {
      // If error, default to Lao
      state = 'lo';
    }
  }

  // Set and save language
  Future<void> setLanguage(String languageCode) async {
    state = languageCode;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('language', languageCode);
    } catch (e) {
      print('Error saving language: $e');
    }
  }

  // Get current language
  String get currentLanguage => state;

  // Check if current language is English
  bool get isEnglish => state == 'en';

  // Check if current language is Lao
  bool get isLao => state == 'lo';
}

// Language Provider
final languageProvider = StateNotifierProvider<LanguageNotifier, String>((ref) {
  return LanguageNotifier();
});
