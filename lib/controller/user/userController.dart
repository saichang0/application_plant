import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:plant_aplication/constant/apiConst.dart';
import 'package:plant_aplication/controller/user/userProfileController.dart';
import 'package:plant_aplication/graphql/user/mutation.dart';
import 'package:plant_aplication/page/home.dart';
import 'package:plant_aplication/until/toast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserController {
  static Future<Map<String, dynamic>> registerUser({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String password,
    required String email,
    required BuildContext context,
  }) async {
    try {
      final body = json.encode({
        'query': userRegisterMutation,
        'variables': {
          'data': {
            'firstName': firstName,
            'lastName': lastName,
            'phoneNumber': phoneNumber,
            'password': password,
            'email': email,
          },
        },
      });

      final response = await http.post(
        Uri.parse(ApiConstants.graphQlUrl),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        if (responseData['errors'] != null) {
          throw Exception(responseData['errors'][0]['message']);
        }
        final registerResponse = responseData['data']?['createCustomer'];
        if (registerResponse == null) {
          throw Exception('Empty response from server');
        }
        if (registerResponse['status'] == true) {
          // Backwards-compat: expose customer under `user` key as well.
          final customer = registerResponse['customer'];
          final result = Map<String, dynamic>.from(registerResponse);
          result['user'] = customer;
          if (context.mounted) {
            ToastHelper.showSuccess(
              context,
              "Success",
              "User registered successfully",
            );
          }
          if (context.mounted) {
            Navigator.pushNamed(context, '/login');
          }
          return result;
        } else {
          if (context.mounted) {
            ToastHelper.showError(
              context,
              "Failed",
              registerResponse['message'] ?? 'Register failed',
            );
          }
          throw Exception(registerResponse['message']);
        }
      } else {
        if (context.mounted) {
          ToastHelper.showError(context, "Failed", response.body);
        }
        throw Exception(
          'HTTP Error: ${response.statusCode} ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      if (context.mounted) {
        ToastHelper.showError(context, "Failed", e.toString());
      }
      throw Exception('Failed to register user: $e');
    }
  }

  static Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
    required BuildContext context,
    required WidgetRef ref,
  }) async {
    try {
      final body = json.encode({
        'query': userLoginMutation,
        'variables': {
          'data': {'identifier': email, 'password': password},
        },
      });
      final response = await http.post(
        Uri.parse(ApiConstants.graphQlUrl),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      final Map<String, dynamic> responseData = json.decode(response.body);

      if (responseData['errors'] != null) {
        throw Exception(responseData['errors'][0]['message']);
      }
      final loginResponse = responseData['data']?['loginCustomer'];
      if (loginResponse == null) {
        throw Exception('Empty response from server');
      }
      if (loginResponse['status'] == true) {
        final prefs = await SharedPreferences.getInstance();
        if (loginResponse['accessToken'] != null) {
          await prefs.setString('accessToken', loginResponse['accessToken']);
        }
        if (loginResponse['refreshToken'] != null) {
          await prefs.setString('refreshToken', loginResponse['refreshToken']);
        }
        final customer = loginResponse['customer'];
        if (customer != null) {
          await ref
              .read(userProvider.notifier)
              .saveUser(Map<String, dynamic>.from(customer));
        }
        if (context.mounted) {
          ToastHelper.showSuccess(
            context,
            "Congratulations!",
            "Your account is ready to use. You will be redirected to the home page in a few seconds.",
          );
        }
        Future.delayed(const Duration(seconds: 3), () {
          if (context.mounted) {
            ToastHelper.close();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          }
        });
        // Backwards-compat: expose customer under `user` key.
        final result = Map<String, dynamic>.from(loginResponse);
        result['user'] = customer;
        return result;
      } else {
        final errorMessage = loginResponse['message'] ?? 'Login failed';
        if (context.mounted) {
          ToastHelper.showError(context, "Failed", errorMessage);
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (context.mounted) {
        ToastHelper.showError(context, "Failed", e.toString());
      }
      throw Exception('Failed to login user: $e');
    }
  }

  static Future<Map<String, dynamic>> requiresOtp({
    required String email,
    required BuildContext context,
  }) async {
    try {
      final body = json.encode({
        'query': requestOTPMutation,
        'variables': {
          'data': {'email': email},
        },
      });
      final response = await http.post(
        Uri.parse(ApiConstants.graphQlUrl),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      final Map<String, dynamic> responseData = json.decode(response.body);
      if (responseData['errors'] != null) {
        throw Exception(responseData['errors'][0]['message']);
      }
      final otpResponse = responseData['data']?['requestOTP'];
      if (otpResponse == null) {
        throw Exception('Empty response from server');
      }
      if (otpResponse['status'] == true) {
        if (context.mounted) {
          ToastHelper.showSuccess(
            context,
            "Success",
            "User request OTP successfully",
          );
        }
        return Map<String, dynamic>.from(otpResponse);
      } else {
        final errorMessage = otpResponse['message'] ?? 'Request OTP failed';
        if (context.mounted) {
          ToastHelper.showError(context, "Failed", errorMessage);
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (context.mounted) {
        ToastHelper.showError(context, "Failed", e.toString());
      }
      throw Exception('Failed to request OTP: $e');
    }
  }

  static Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otp,
    required BuildContext context,
  }) async {
    try {
      final body = json.encode({
        'query': verifyOTPMutation,
        'variables': {
          'data': {'email': email, 'otp': otp},
        },
      });
      final response = await http.post(
        Uri.parse(ApiConstants.graphQlUrl),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      final Map<String, dynamic> responseData = json.decode(response.body);
      if (responseData['errors'] != null) {
        throw Exception(responseData['errors'][0]['message']);
      }
      final verifyResponse = responseData['data']?['verifyOTP'];
      if (verifyResponse == null) {
        throw Exception('Empty response from server');
      }
      if (verifyResponse['status'] == true) {
        if (context.mounted) {
          ToastHelper.showSuccess(
            context,
            "Success",
            "User verify OTP successfully",
          );
        }
        return Map<String, dynamic>.from(verifyResponse);
      } else {
        final errorMessage = verifyResponse['message'] ?? 'Verify OTP failed';
        if (context.mounted) {
          ToastHelper.showError(context, "Failed", errorMessage);
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (context.mounted) {
        ToastHelper.showError(context, "Failed", e.toString());
      }
      throw Exception('Failed to verify OTP: $e');
    }
  }

  static Future<Map<String, dynamic>> resetPassword({
    required String newPassword,
    required String email,
    required BuildContext context,
    String otp = '',
    String? confirmPassword,
  }) async {
    try {
      final body = json.encode({
        'query': resetPasswordMutation,
        'variables': {
          'data': {
            'email': email,
            'otp': otp,
            'password': newPassword,
            'confirmPassword': confirmPassword ?? newPassword,
          },
        },
      });
      final response = await http.post(
        Uri.parse(ApiConstants.graphQlUrl),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      final Map<String, dynamic> responseData = json.decode(response.body);
      if (responseData['errors'] != null) {
        throw Exception(responseData['errors'][0]['message']);
      }
      final resetResponse = responseData['data']?['resetPassword'];
      if (resetResponse == null) {
        throw Exception('Empty response from server');
      }
      if (resetResponse['status'] == true) {
        if (context.mounted) {
          ToastHelper.showSuccess(
            context,
            "Success",
            "User reset password successfully",
          );
        }
        return Map<String, dynamic>.from(resetResponse);
      } else {
        final errorMessage =
            resetResponse['message'] ?? 'Reset password failed';
        if (context.mounted) {
          ToastHelper.showError(context, "Failed", errorMessage);
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (context.mounted) {
        ToastHelper.showError(context, "Failed", e.toString());
      }
      throw Exception('Failed to reset password: $e');
    }
  }
}
