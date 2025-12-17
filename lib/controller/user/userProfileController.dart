import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plant_aplication/services/authStorage.dart';
import 'package:shared_preferences/shared_preferences.dart';

final userProvider = AsyncNotifierProvider<UserNotifier, Map<String, dynamic>?>(
  UserNotifier.new,
);

final accessTokenProvider = FutureProvider<String?>((ref) async {
  final token = await AuthStorage.getAccessToken();
  if (token != null && token.trim().isEmpty) return null;
  return token;
});

class UserNotifier extends AsyncNotifier<Map<String, dynamic>?> {
  static const _userKey = 'user';

  @override
  Future<Map<String, dynamic>?> build() async {
    return await getUser();
  }

  Future<void> saveUser(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, json.encode(userData));
    state = AsyncValue.data(userData);
  }

  Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString(_userKey);
    if (userString != null) {
      return json.decode(userString) as Map<String, dynamic>;
    }
    return null;
  }

  Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    state = const AsyncValue.data(null);
  }

  Future<String> getUserName() async {
    final user = await getUser();
    return user?['name'] ?? 'Guest';
  }
}
