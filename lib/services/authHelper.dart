import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:plant_aplication/services/appNavigator.dart';
import '../../services/authStorage.dart';

Future<bool> checkTokenAndLogout() async {
  final String? token = await AuthStorage.getAccessToken();

  if (token == null || token.isEmpty) {
    return true;
  }

  final decoded = JwtDecoder.decode(token);

  final int exp = decoded['exp'];

  final expiryDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);

  final now = DateTime.now();

  if (now.isAfter(expiryDate)) {
    await AuthStorage.clear();

    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      '/login',
      (route) => false,
    );

    return true;
  }

  return false;
}
