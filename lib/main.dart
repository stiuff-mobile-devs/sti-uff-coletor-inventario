import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:stiuffcoletorinventario/features/about/views/about_page.dart';
import 'package:stiuffcoletorinventario/features/login/view/login_screen.dart';
import 'features/home/views/home_page.dart';
import 'features/settings/views/settings_page.dart';
import 'shared/utils/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Coletor Inventário',
      theme: ThemeData(
        primarySwatch: AppColors.primaryColor,
        appBarTheme: const AppBarTheme(
          elevation: 2.0,
          shadowColor: AppColors.shadowColor,
          color: AppColors.appBarColor,
        ),
        scaffoldBackgroundColor: AppColors.scaffoldBackgroundColor,
        splashColor: AppColors.lightOrangeSplashColor,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomePage(),
        '/settings': (context) => const SettingsPage(),
        '/about': (context) => const AboutPage(),
      },
    );
  }
}
