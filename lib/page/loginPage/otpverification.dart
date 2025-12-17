import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:plant_aplication/constant/colorConst.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:plant_aplication/controller/themeProvider.dart';
import 'package:plant_aplication/controller/user/userController.dart';

class OtpVerificationPage extends ConsumerStatefulWidget {
  const OtpVerificationPage({Key? key}) : super(key: key);

  @override
  ConsumerState<OtpVerificationPage> createState() =>
      _OtpVerificationPageState();
}

final inputProvider = StateProvider<String>((ref) => '');
final errorMessageProvider = StateProvider<String?>((ref) => null);

final _emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
final _phoneRegex = RegExp(r'^\+?[0-9]{8,15}$');
final otpCodeProvider = StateProvider<String>((ref) => '');
final showOtpFieldProvider = StateProvider<bool>((ref) => false);
final isLoadingProvider = StateProvider<bool>((ref) => false);
final countdownProvider = StateProvider<int>((ref) => 0);
final otpFieldKeyProvider = StateProvider<int>((ref) => 0);
final otpErrorProvider = StateProvider<bool>((ref) => false);
final passwordProvider = StateProvider<String>((ref) => '');
final confirmPasswordProvider = StateProvider<String>((ref) => '');
final isOtpVerifiedProvider = StateProvider<bool>((ref) => false);
final passwordErrorProvider = StateProvider<String?>((ref) => null);
final showPasswordProvider = StateProvider<bool>((ref) => false);
final showConfirmPasswordProvider = StateProvider<bool>((ref) => false);

final isValidInputProvider = Provider<bool>((ref) {
  final input = ref.watch(inputProvider);
  if (input.isEmpty) return false;
  return _emailRegex.hasMatch(input) || _phoneRegex.hasMatch(input);
});

final inputTypeProvider = Provider<String>((ref) {
  final input = ref.watch(inputProvider);
  if (_emailRegex.hasMatch(input)) return 'email';
  if (_phoneRegex.hasMatch(input)) return 'phone';
  return '';
});

class _OtpVerificationPageState extends ConsumerState<OtpVerificationPage> {
  Timer? _countdownTimer;

  void _handleRequiredOtp(BuildContext context, WidgetRef ref) async {
    final input = ref.read(inputProvider).trim();
    final isValid = ref.read(isValidInputProvider);

    ref.read(errorMessageProvider.notifier).state = null;
    ref.read(isLoadingProvider.notifier).state = true;

    if (input.isEmpty) {
      ref.read(errorMessageProvider.notifier).state = 'This field is required';
      ref.read(isLoadingProvider.notifier).state = false;
      return;
    }
    if (!isValid) {
      ref.read(errorMessageProvider.notifier).state =
          'Please enter a valid email or phone number';
      ref.read(isLoadingProvider.notifier).state = false;
      return;
    }
    try {
      ref.read(isLoadingProvider.notifier).state = true;
      final response = await UserController.requiresOtp(
        email: input,
        context: context,
      );
      print('response $response');
      if (response['status'] == true) {
        ref.read(showOtpFieldProvider.notifier).state = true;
        ref.read(isLoadingProvider.notifier).state = false;
        _startCountdown(ref);
      }
    } catch (e) {
      if (context.mounted) {
        ref.read(errorMessageProvider.notifier).state = e.toString();
      }
      ref.read(isLoadingProvider.notifier).state = false;
    }
  }

  void _startCountdown(WidgetRef ref) {
    const countdownDuration = 60;
    ref.read(otpCodeProvider.notifier).state = '';
    ref.read(otpFieldKeyProvider.notifier).state++;
    ref.read(countdownProvider.notifier).state = countdownDuration;
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final countdown = ref.read(countdownProvider);
      if (countdown > 0) {
        ref.read(countdownProvider.notifier).state = countdown - 1;
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _handleVerifyOtp(BuildContext context, WidgetRef ref) async {
    final otpCode = ref.read(otpCodeProvider);
    final input = ref.read(inputProvider).trim();
    if (otpCode.isEmpty || otpCode.length != 6) {
      ref.read(otpErrorProvider.notifier).state = true;
      return;
    }
    ref.read(isLoadingProvider.notifier).state = true;
    ref.read(otpErrorProvider.notifier).state = false;

    try {
      final response = await UserController.verifyOtp(
        email: input,
        otp: otpCode,
        context: context,
      );

      if (response['status'] == true) {
        _countdownTimer?.cancel();
        ref.read(passwordErrorProvider.notifier).state = null;
        ref.read(passwordProvider.notifier).state = '';
        ref.read(confirmPasswordProvider.notifier).state = '';
        ref.read(isOtpVerifiedProvider.notifier).state = true;
      }
    } catch (e) {
      if (context.mounted) {
        ref.read(isLoadingProvider.notifier).state = false;
      }
    }
  }

  Future<void> _handleResetPassword(BuildContext context, WidgetRef ref) async {
    final password = ref.read(passwordProvider);
    final confirmPassword = ref.read(confirmPasswordProvider);
    final input = ref.read(inputProvider).trim();
    if (password.isEmpty || confirmPassword.isEmpty) {
      ref.read(passwordErrorProvider.notifier).state =
          'Please fill in all fields';
      return;
    }
    if (password != confirmPassword) {
      ref.read(passwordErrorProvider.notifier).state = 'Passwords do not match';
      return;
    }
    if (password.length < 6 || confirmPassword.length < 6) {
      ref.read(passwordErrorProvider.notifier).state =
          'Password must be at least 6 characters';
      return;
    }
    ref.read(isLoadingProvider.notifier).state = true;
    ref.read(passwordErrorProvider.notifier).state = null;
    try {
      final response = await UserController.resetPassword(
        newPassword: password,
        email: input,
        context: context,
      );
      if (response['status'] == true) {
        ref.read(isOtpVerifiedProvider.notifier).state = false;
        ref.read(showOtpFieldProvider.notifier).state = false;
        ref.read(countdownProvider.notifier).state = 0;
        ref.read(otpCodeProvider.notifier).state = '';
        ref.read(inputProvider.notifier).state = '';
        ref.read(passwordProvider.notifier).state = '';
        ref.read(confirmPasswordProvider.notifier).state = '';
        if (context.mounted) {
          Navigator.of(context).pushReplacementNamed('/login');
        }
      }
    } catch (e) {
      if (context.mounted) {
        ref.read(isLoadingProvider.notifier).state = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final errorMessage = ref.watch(errorMessageProvider);
    final showOtpField = ref.watch(showOtpFieldProvider);
    final countdown = ref.watch(countdownProvider);
    final isOtpExpired = showOtpField && countdown == 0;
    final isDark = ref.watch(themeProvider);

    Color buttonColor;
    if (showOtpField) {
      buttonColor = isOtpExpired
          ? const Color.fromARGB(255, 124, 230, 110)
          : const Color(0xFF00A86B);
    } else {
      buttonColor = const Color(0xFF00A86B);
    }

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black87,
          ),
          onPressed: () => {
            ref.read(showOtpFieldProvider.notifier).state = false,
            ref.read(isLoadingProvider.notifier).state = false,
            ref.read(isOtpVerifiedProvider.notifier).state = false,
            ref.read(errorMessageProvider.notifier).state = null,
            Navigator.pop(context),
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 50, 24, 0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        child: SizedBox(
                          height: 150,
                          child: Image.asset(
                            'assets/images/password.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Enter your email or phone number to receive an OTP',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark ? Colors.white : Colors.black87,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Column(
                        children: [
                          if (!ref.watch(isOtpVerifiedProvider)) ...[
                            TextField(
                              onChanged: (value) {
                                ref.read(inputProvider.notifier).state = value;
                                if (ref.read(errorMessageProvider) != null) {
                                  ref
                                          .read(errorMessageProvider.notifier)
                                          .state =
                                      null;
                                }
                              },
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                hintText: 'Email or phone number',
                                hintStyle: TextStyle(
                                  color: isDark
                                      ? Colors.grey[300]
                                      : Colors.grey[400],
                                ),
                                prefixIcon: Icon(
                                  Icons.person_outline,
                                  color: isDark
                                      ? Colors.grey[300]
                                      : Colors.grey[400],
                                ),
                                filled: true,
                                fillColor: isDark
                                    ? Colors.grey[900]
                                    : Colors.grey[100],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: errorMessage != null
                                        ? Colors.red
                                        : Colors.transparent,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: errorMessage != null
                                        ? Colors.red
                                        : Colors.transparent,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: errorMessage != null
                                        ? Colors.red
                                        : const Color(0xFF00A86B),
                                    width: 2,
                                  ),
                                ),
                              ),
                              style: const TextStyle(height: 1),
                            ),
                          ],
                          if (ref.watch(isOtpVerifiedProvider)) ...[
                            TextField(
                              key: const ValueKey('password-field'),
                              obscureText: !ref.watch(showPasswordProvider),
                              onChanged: (value) =>
                                  ref.read(passwordProvider.notifier).state =
                                      value,
                              decoration: InputDecoration(
                                hintText: 'New Password',
                                prefixIcon: Icon(
                                  Icons.lock_outline,
                                  color: isDark
                                      ? Colors.grey[300]
                                      : Colors.grey[400],
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    ref.watch(showPasswordProvider)
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: isDark
                                        ? Colors.grey[300]
                                        : Colors.grey[400],
                                  ),
                                  onPressed: () {
                                    ref
                                        .read(showPasswordProvider.notifier)
                                        .state = !ref.read(
                                      showPasswordProvider,
                                    );
                                  },
                                ),
                                filled: true,
                                fillColor: isDark
                                    ? Colors.grey[900]
                                    : Colors.grey[100],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color:
                                        ref.watch(passwordErrorProvider) != null
                                        ? Colors.red
                                        : Colors.transparent,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color:
                                        ref.watch(passwordErrorProvider) != null
                                        ? Colors.red
                                        : const Color(0xFF00A86B),
                                    width: 2,
                                  ),
                                ),
                              ),
                              style: const TextStyle(height: 1),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              key: const ValueKey('confirm-password-field'),
                              obscureText: !ref.watch(
                                showConfirmPasswordProvider,
                              ),
                              onChanged: (value) =>
                                  ref
                                          .read(
                                            confirmPasswordProvider.notifier,
                                          )
                                          .state =
                                      value,
                              decoration: InputDecoration(
                                hintText: 'Confirm Password',
                                prefixIcon: Icon(
                                  Icons.lock_outline,
                                  color: isDark
                                      ? Colors.grey[300]
                                      : Colors.grey[400],
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    ref.watch(showConfirmPasswordProvider)
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: isDark
                                        ? Colors.grey[300]
                                        : Colors.grey[400],
                                  ),
                                  onPressed: () {
                                    ref
                                        .read(
                                          showConfirmPasswordProvider.notifier,
                                        )
                                        .state = !ref.read(
                                      showConfirmPasswordProvider,
                                    );
                                  },
                                ),
                                filled: true,
                                fillColor: isDark
                                    ? Colors.grey[900]
                                    : Colors.grey[100],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: errorMessage != null
                                        ? Colors.red
                                        : Colors.transparent,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: errorMessage != null
                                        ? Colors.red
                                        : const Color(0xFF00A86B),
                                    width: 2,
                                  ),
                                ),
                              ),
                              style: const TextStyle(height: 1),
                            ),
                            if (ref.watch(passwordErrorProvider) != null)
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 8.0,
                                  left: 12.0,
                                ),
                                child: Text(
                                  ref.watch(passwordErrorProvider)!,
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 20),
                      if (!ref.watch(isOtpVerifiedProvider))
                        Consumer(
                          key: ValueKey(ref.watch(otpFieldKeyProvider)),
                          builder: (context, ref, _) {
                            final showOtpField = ref.watch(
                              showOtpFieldProvider,
                            );
                            if (!showOtpField) return const SizedBox.shrink();
                            return Column(
                              children: [
                                OtpTextField(
                                  autoFocus: true,
                                  enabled: ref.watch(countdownProvider) > 0,
                                  numberOfFields: 6,
                                  borderColor: ref.watch(otpErrorProvider)
                                      ? Colors.red
                                      : ColorConstants.accentPurpleColor,
                                  focusedBorderColor:
                                      ref.watch(otpErrorProvider)
                                      ? Colors.red
                                      : ColorConstants.accentPurpleColor,
                                  styles: List.generate(6, (index) {
                                    final colors = [
                                      ColorConstants.accentPurpleColor,
                                      ColorConstants.accentYellowColor,
                                      ColorConstants.accentDarkGreenColor,
                                      ColorConstants.accentOrangeColor,
                                      ColorConstants.accentPinkColor,
                                      ColorConstants.accentPurpleColor,
                                    ];
                                    return TextStyle(
                                      color: ref.watch(otpErrorProvider)
                                          ? Colors.red
                                          : colors[index % colors.length],
                                    );
                                  }),
                                  showFieldAsBox: false,
                                  borderWidth: 2.0,
                                  onCodeChanged: (String code) {
                                    ref.read(otpCodeProvider.notifier).state =
                                        code;
                                    if (code.isNotEmpty) {
                                      ref
                                              .read(otpErrorProvider.notifier)
                                              .state =
                                          false;
                                    }
                                  },
                                  onSubmit: (String verificationCode) {
                                    ref.read(otpCodeProvider.notifier).state =
                                        verificationCode;
                                    debugPrint(
                                      'OTP entered: $verificationCode',
                                    );
                                  },
                                ),

                                const SizedBox(height: 20),
                                Consumer(
                                  builder: (context, ref, _) {
                                    final countdown = ref.watch(
                                      countdownProvider,
                                    );
                                    return countdown > 0
                                        ? Text(
                                            'Resend code in $countdown seconds',
                                            style: const TextStyle(
                                              color:
                                                  ColorConstants.primaryColor,
                                            ),
                                          )
                                        : TextButton(
                                            onPressed: () {
                                              _handleRequiredOtp(context, ref);
                                            },
                                            child: const Text(
                                              "Didn't receive code? Resend",
                                              style: TextStyle(
                                                color:
                                                    ColorConstants.primaryColor,
                                              ),
                                            ),
                                          );
                                  },
                                ),
                              ],
                            );
                          },
                        ),
                      if (errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0, left: 12.0),
                          child: Text(
                            errorMessage,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: ElevatedButton(
                          onPressed: isOtpExpired
                              ? null
                              : ref.watch(isOtpVerifiedProvider)
                              ? () => _handleResetPassword(context, ref)
                              : ref.watch(showOtpFieldProvider)
                              ? () => _handleVerifyOtp(context, ref)
                              : () => _handleRequiredOtp(context, ref),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: buttonColor,
                            disabledBackgroundColor: const Color.fromARGB(
                              255,
                              158,
                              158,
                              158,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                          child: ref.watch(isLoadingProvider)
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  isOtpExpired
                                      ? 'OTP Expired'
                                      : ref.watch(isOtpVerifiedProvider)
                                      ? 'Reset Password'
                                      : ref.watch(showOtpFieldProvider)
                                      ? 'Verify OTP'
                                      : 'Get OTP',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
