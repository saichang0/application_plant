import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../../services/authStorage.dart';

final accessTokenProvider = FutureProvider<String?>((ref) async {
  final token = await AuthStorage.getAccessToken();

  if (token == null || token.isEmpty) {
    return null;
  }

  final isExpired = JwtDecoder.isExpired(token);

  if (isExpired) {
    await AuthStorage.clear();
    return null;
  }

  return token;
});
