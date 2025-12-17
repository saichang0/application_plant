import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:plant_aplication/constant/colorConst.dart';
import 'package:plant_aplication/controller/themeProvider.dart';
import 'package:plant_aplication/controller/user/userController.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

final firstNameProvider = StateProvider<String>((ref) => '');
final lastNameProvider = StateProvider<String>((ref) => '');
final emailRegisterProvider = StateProvider<String>((ref) => '');
final phoneProvider = StateProvider<String>((ref) => '');
final passwordRegisterProvider = StateProvider<String>((ref) => '');
final obscurePasswordRegisterProvider = StateProvider<bool>((ref) => true);
final isLoadingProvider = StateProvider<bool>((ref) => false);

final firstNameErrorProvider = StateProvider<String?>((ref) => null);
final lastNameErrorProvider = StateProvider<String?>((ref) => null);
final emailRegisterErrorProvider = StateProvider<String?>((ref) => null);
final phoneErrorProvider = StateProvider<String?>((ref) => null);
final passwordRegisterErrorProvider = StateProvider<String?>((ref) => null);

class _RegisterPageState extends ConsumerState<RegisterPage> {
  Future<void> _userRegister(BuildContext context, WidgetRef ref) async {
    final firstName = ref.read(firstNameProvider).trim();
    final lastName = ref.read(lastNameProvider).trim();
    final email = ref.read(emailRegisterProvider).trim();
    final phone = ref.read(phoneProvider).trim();
    final password = ref.read(passwordRegisterProvider);

    // Reset all errors
    ref.read(firstNameErrorProvider.notifier).state = null;
    ref.read(lastNameErrorProvider.notifier).state = null;
    ref.read(emailRegisterErrorProvider.notifier).state = null;
    ref.read(phoneErrorProvider.notifier).state = null;
    ref.read(passwordRegisterErrorProvider.notifier).state = null;

    bool isValid = true;

    if (firstName.isEmpty) {
      ref.read(firstNameErrorProvider.notifier).state =
          'This field is required';
      isValid = false;
    }

    if (lastName.isEmpty) {
      ref.read(lastNameErrorProvider.notifier).state = 'This field is required';
      isValid = false;
    }

    if (email.isEmpty) {
      ref.read(emailRegisterErrorProvider.notifier).state =
          'This field is required';
      isValid = false;
    }

    if (phone.isEmpty) {
      ref.read(phoneErrorProvider.notifier).state = 'This field is required';
      isValid = false;
    }

    if (password.isEmpty) {
      ref.read(passwordRegisterErrorProvider.notifier).state =
          'This field is required';
      isValid = false;
    }

    if (isValid) {
      ref.read(isLoadingProvider.notifier).state = true;

      try {
        await UserController.registerUser(
          context: context,
          firstName: firstName,
          lastName: lastName,
          phoneNumber: phone,
          password: password,
          email: email,
        );
      } catch (e) {
        debugPrint('Registration error: $e');
      } finally {
        if (context.mounted) {
          ref.read(isLoadingProvider.notifier).state = false;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final obscurePassword = ref.watch(obscurePasswordRegisterProvider);
    final isLoading = ref.watch(isLoadingProvider);
    final firstNameError = ref.watch(firstNameErrorProvider);
    final lastNameError = ref.watch(lastNameErrorProvider);
    final emailError = ref.watch(emailRegisterErrorProvider);
    final phoneError = ref.watch(phoneErrorProvider);
    final passwordError = ref.watch(passwordRegisterErrorProvider);
    final isDark = ref.watch(themeProvider);

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.asset(
                  'assets/images/logogreentr.png',
                  width: 150,
                  height: 100,
                  fit: BoxFit.contain,
                ),
              ),
              Center(
                child: Text(
                  'Create Your Account',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.grey[300] : Colors.grey[400],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              _buildTextField(
                ref: ref,
                provider: firstNameProvider,
                errorProvider: firstNameErrorProvider,
                error: firstNameError,
                hint: 'First Name',
                icon: Icons.person_outline,
                isDark: isDark,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                ref: ref,
                provider: lastNameProvider,
                errorProvider: lastNameErrorProvider,
                error: lastNameError,
                hint: 'Last Name',
                icon: Icons.person_4,
                isDark: isDark,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                ref: ref,
                provider: emailRegisterProvider,
                errorProvider: emailRegisterErrorProvider,
                error: emailError,
                hint: 'Email',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                isDark: isDark,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                ref: ref,
                provider: phoneProvider,
                errorProvider: phoneErrorProvider,
                error: phoneError,
                hint: '20 777 777',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                isDark: isDark,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                ref: ref,
                provider: passwordRegisterProvider,
                errorProvider: passwordRegisterErrorProvider,
                error: passwordError,
                hint: 'Password',
                icon: Icons.lock_outline,
                obscure: true,
                obscurePassword: obscurePassword,
                onToggleObscure: () {
                  ref.read(obscurePasswordRegisterProvider.notifier).state =
                      !obscurePassword;
                },
                isDark: isDark,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () => _userRegister(context, ref),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isLoading
                        ? Colors.grey[300]
                        : ColorConstants.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          'Sign up',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey[300])),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'or',
                      style: TextStyle(
                        color: isDark ? Colors.grey[300] : Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.grey[300])),
                ],
              ),
              const SizedBox(height: 20),
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
                        'Sign in with Google',
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
              const SizedBox(height: 28),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Already have an account? ",
                      style: TextStyle(
                        color: isDark ? Colors.grey[300] : Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        ref.read(firstNameErrorProvider.notifier).state = null;
                        ref.read(lastNameErrorProvider.notifier).state = null;
                        ref.read(emailRegisterErrorProvider.notifier).state =
                            null;
                        ref.read(phoneErrorProvider.notifier).state = null;
                        ref.read(passwordRegisterErrorProvider.notifier).state =
                            null;
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      child: Text(
                        'Login',
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
    );
  }

  Widget _buildTextField({
    required WidgetRef ref,
    required StateProvider<String> provider,
    required StateProvider<String?> errorProvider,
    required String? error,
    required String hint,
    required IconData icon,
    required bool isDark,
    bool obscure = false,
    bool? obscurePassword,
    VoidCallback? onToggleObscure,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          onChanged: (value) {
            ref.read(provider.notifier).state = value;
            if (error != null) {
              ref.read(errorProvider.notifier).state = null;
            }
          },
          obscureText: obscure && (obscurePassword ?? true),
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: isDark ? Colors.grey[300] : Colors.grey[400],
            ),
            prefixIcon: Icon(
              icon,
              color: isDark ? Colors.grey[300] : Colors.grey[400],
            ),
            suffixIcon: obscure
                ? IconButton(
                    icon: Icon(
                      (obscurePassword ?? true)
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: isDark ? Colors.grey[300] : Colors.grey[400],
                    ),
                    onPressed: onToggleObscure,
                  )
                : null,
            filled: true,
            fillColor: isDark ? Colors.grey[900] : Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: error != null ? Colors.red : Colors.transparent,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: error != null ? Colors.red : Colors.transparent,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: error != null ? Colors.red : ColorConstants.primaryColor,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
          ),
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 12),
            child: Text(
              error,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }
}
