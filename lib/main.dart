import 'package:flutter/material.dart';
import 'package:stiuffcoletorinventario/about_page.dart';
import 'home_page.dart';
import 'settings_page.dart';
import 'app_colors.dart'; // Importando a classe de cores

void main() {
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
      initialRoute: '/home',
      routes: {
        '/home': (context) => const HomePage(),
        '/settings': (context) => const SettingsPage(),
        '/about': (context) => const AboutPage(),
      },
    );
  }
}
