import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:plant_aplication/constant/colorConst.dart';
import 'package:plant_aplication/controller/themeProvider.dart';
import 'package:plant_aplication/controller/languageController.dart';
import 'package:plant_aplication/until/appTranslate.dart';
import 'package:plant_aplication/controller/user/userController.dart';
import 'package:plant_aplication/page/loginPage/otpverification.dart';
import 'package:plant_aplication/services/authStorage.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({Key? key}) : super(key: key);
  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

final emailProvider = StateProvider<String>((ref) => '');
final passwordProvider = StateProvider<String>((ref) => '');
final rememberMeProvider = StateProvider<bool>((ref) => false);
final obscurePasswordProvider = StateProvider<bool>((ref) => true);
final emailErrorProvider = StateProvider<String?>((ref) => null);
final passwordErrorProvider = StateProvider<String?>((ref) => null);

void _userLogin(BuildContext context, WidgetRef ref) {
  final email = ref.read(emailProvider).trim();
  final password = ref.read(passwordProvider).trim();
  final language = ref.read(languageProvider);

  ref.read(emailErrorProvider.notifier).state = null;
  ref.read(passwordErrorProvider.notifier).state = null;

  bool isValid = true;

  if (email.isEmpty) {
    ref.read(emailErrorProvider.notifier).state = 'this_field_is_required'.tr(
      language,
    );
    isValid = false;
  }

  if (password.isEmpty) {
    ref.read(passwordErrorProvider.notifier).state = 'this_field_is_required'
        .tr(language);
    isValid = false;
  }

  if (isValid) {
    // "Remember me": save the email to pre-fill next time, or forget it.
    if (ref.read(rememberMeProvider)) {
      AuthStorage.saveRememberedEmail(email);
    } else {
      AuthStorage.clearRememberedEmail();
    }

    debugPrint('userData: email=$email, password=$password');
    UserController.loginUser(
      email: email,
      password: password,
      context: context,
      ref: ref,
    );
  }
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _restoreRememberedEmail();
  }

  /// Pre-fills the email field if the user previously checked "Remember me".
  Future<void> _restoreRememberedEmail() async {
    final savedEmail = await AuthStorage.getRememberedEmail();
    if (savedEmail != null && savedEmail.isNotEmpty && mounted) {
      _emailController.text = savedEmail;
      ref.read(emailProvider.notifier).state = savedEmail;
      ref.read(rememberMeProvider.notifier).state = true;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rememberMe = ref.watch(rememberMeProvider);
    final obscurePassword = ref.watch(obscurePasswordProvider);
    final emailError = ref.watch(emailErrorProvider);
    final passwordError = ref.watch(passwordErrorProvider);
    final isDark = ref.watch(themeProvider);
    final language = ref.watch(languageProvider);

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Image.asset(
                  'assets/images/logogreentr.png',
                  width: 150,
                  height: 100,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 10),
                Center(
                  child: Text(
                    'login_to_your_account'.tr(language),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _emailController,
                      onChanged: (value) {
                        ref.read(emailProvider.notifier).state = value;
                        if (emailError != null) {
                          ref.read(emailErrorProvider.notifier).state = null;
                        }
                      },
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'email'.tr(language),
                        hintStyle: TextStyle(
                          color: isDark ? Colors.white : Colors.grey[400],
                        ),
                        prefixIcon: Icon(
                          Icons.email_outlined,
                          color: isDark ? Colors.white : Colors.grey[400],
                        ),
                        filled: true,
                        fillColor: isDark ? Colors.grey[900] : Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: emailError != null
                                ? Colors.red
                                : Colors.transparent,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: emailError != null
                                ? Colors.red
                                : Colors.transparent,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: emailError != null
                                ? Colors.red
                                : ColorConstants.primaryColor,
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 10,
                        ),
                      ),
                    ),
                    if (emailError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0, left: 12.0),
                        child: Text(
                          emailError,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      onChanged: (value) {
                        ref.read(passwordProvider.notifier).state = value;
                        if (passwordError != null) {
                          ref.read(passwordErrorProvider.notifier).state = null;
                        }
                      },
                      obscureText: obscurePassword,
                      decoration: InputDecoration(
                        hintText: 'password'.tr(language),
                        hintStyle: TextStyle(
                          color: isDark ? Colors.white : Colors.grey[400],
                        ),
                        prefixIcon: Icon(
                          Icons.lock_outline,
                          color: isDark ? Colors.white : Colors.grey[400],
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey[400],
                          ),
                          onPressed: () {
                            ref.read(obscurePasswordProvider.notifier).state =
                                !obscurePassword;
                          },
                        ),
                        filled: true,
                        fillColor: isDark ? Colors.grey[900] : Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: passwordError != null
                                ? Colors.red
                                : Colors.transparent,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: passwordError != null
                                ? Colors.red
                                : Colors.transparent,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: passwordError != null
                                ? Colors.red
                                : ColorConstants.primaryColor,
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 10,
                        ),
                      ),
                    ),
                    if (passwordError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0, left: 12.0),
                        child: Text(
                          passwordError,
                          style: TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: rememberMe,
                        onChanged: (value) {
                          ref.read(rememberMeProvider.notifier).state =
                              value ?? false;
                        },
                        activeColor: ColorConstants.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'remember_me'.tr(language),
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => _userLogin(context, ref),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorConstants.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'sign_in'.tr(language),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: Container(
                    width: double.infinity,
                    height: 46,
                    child: TextButton(
                      onPressed: () {
                        ref.read(emailErrorProvider.notifier).state = null;
                        ref.read(passwordErrorProvider.notifier).state = null;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const OtpVerificationPage(),
                          ),
                        );
                      },
                      child: Text(
                        'forget_the_password'.tr(language),
                        style: TextStyle(
                          color: ColorConstants.primaryColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey[300])),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'or'.tr(language),
                        style: TextStyle(
                          color: isDark ? Colors.grey[300] : Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey[300])),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  height: 46,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 5,
                          ),
                          child: SizedBox(
                            height: 20,
                            child: Image.asset(
                              'assets/images/images-removebg-preview.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'sign_in_with_google'.tr(language),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${'dont_have_account'.tr(language)} ',
                        style: TextStyle(
                          color: isDark ? Colors.grey[300] : Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          ref.read(emailErrorProvider.notifier).state = null;
                          ref.read(passwordErrorProvider.notifier).state = null;
                          Navigator.pushNamed(context, '/register');
                        },
                        child: Text(
                          'sign_up'.tr(language),
                          style: TextStyle(
                            color: ColorConstants.primaryColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
