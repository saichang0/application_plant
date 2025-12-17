import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plant_aplication/constant/appTheme.dart';
import 'package:plant_aplication/controller/themeProvider.dart';
import 'package:plant_aplication/controller/user/userProfileController.dart';
import 'package:plant_aplication/page/home.dart';
import 'package:plant_aplication/page/loginPage/login.dart';
import 'package:plant_aplication/page/registerPage/register.dart';
import 'package:plant_aplication/services/appNavigator.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'Green_Market',
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const LoadingPage(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/MainScreen': (context) => const HomePage(),
      },
    );
  }
}

class LoadingPage extends ConsumerWidget {
  const LoadingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncToken = ref.watch(accessTokenProvider);
    return asyncToken.when(
      loading: () => const Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading...', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
      error: (error, stack) {
        return const LoginPage();
      },
      data: (token) {
        print('token: $token');
        if (token != null && token.isNotEmpty) {
          return const HomePage();
          // return const LoginPage();
        } else {
          return const LoginPage();
          // return const HomePage();
        }
      },
    );
  }
}
