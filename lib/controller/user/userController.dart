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
      print("registerUser");
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
        final userResponse = responseData['data']['createUser'];
        if (userResponse['status'] == true) {
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
          return userResponse;
        } else {
          if (context.mounted) {
            ToastHelper.showError(context, "Failed", userResponse['message']);
          }
          throw Exception(userResponse['message']);
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
      if (responseData['data']['userLogin']['status'] == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          'accessToken',
          responseData['data']['userLogin']['accessToken'],
        );
        await prefs.setString(
          'refreshToken',
          responseData['data']['userLogin']['refreshToken'],
        );
        await ref
            .read(userProvider.notifier)
            .saveUser(responseData['data']['userLogin']['user']);
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
        return responseData['data']['userLogin'];
      } else {
        final errorMessage =
            responseData['data']['userLogin']['message'] ?? 'Login failed';
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
      if (responseData['data']['requestOTP']['status'] == true) {
        if (context.mounted) {
          ToastHelper.showSuccess(
            context,
            "Success",
            "User request OTP successfully",
          );
        }
        return responseData['data']['requestOTP'];
      } else {
        final errorMessage =
            responseData['data']['requestOTP']['message'] ??
            'Request OTP failed';
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
      if (responseData['data']['verifyOTP']['status'] == true) {
        if (context.mounted) {
          ToastHelper.showSuccess(
            context,
            "Success",
            "User verify OTP successfully",
          );
        }
        return responseData['data']['verifyOTP'];
      } else {
        final errorMessage =
            responseData['data']['verifyOTP']['message'] ?? 'Verify OTP failed';
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
  }) async {
    try {
      final body = json.encode({
        'query': resetPasswordMutation,
        'variables': {
          'data': {'email': email, 'password': newPassword},
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
      if (responseData['data']['resetPassword']['status'] == true) {
        if (context.mounted) {
          ToastHelper.showSuccess(
            context,
            "Success",
            "User reset password successfully",
          );
        }
        return responseData['data']['resetPassword'];
      } else {
        final errorMessage =
            responseData['data']['resetPassword']['message'] ??
            'Reset password failed';
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
